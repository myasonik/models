"""Shared library for turning a relief sculpt into a surface()-ready PNG.

Every function takes a project config dict (see the SKILL.md for the
key list; .claude/skills/coat-of-arms/scripts/build-relief.py is the
reference project). All pixel coordinates live in the height map's
grid: cfg['raster_w'] wide, height set by the source's aspect.

Determinism contract: rasterize() is seeded, and every rule that a
saved mark depends on (height8/height16 quantization, fill region
growth, territory clipping, stroke order) is computed here exactly as
the Relief Marker page computes it in the browser. Change one side and
saved marks stop meaning what the user saw.
"""
import json
import os
import sys

import numpy as np
import trimesh
from PIL import Image, ImageDraw
from scipy import ndimage

DEFAULTS = dict(
    raster_w=2400,     # px across the source's full width
    field_lift=0.012,  # keep pixels this far above the field level
    min_blob=400,      # px; smaller raised blobs are noise
    out_w=720,         # output PNG width
    pad=4,             # blank px around the cropped art
    keep_floor=0.025,  # height floor under keep-marks and restores
    rect=None,         # (x0, x1, y0, y1) crop of valid art, else full
    mound=None,        # cut polyline left-to-right; below it is removed
    zones=(),          # ((x0,x1,y0,y1), rel_thr|None) local overrides
    restore=(),        # (polygon, floor) patches applied after cuts
    field_window=None, # (y0, y1, x0, x1) histogram window for the field
    field_range=(-0.06, 0.02),
)


def cfg_get(cfg, key):
    return cfg[key] if key in cfg else DEFAULTS[key]


def align(m):
    """Rotate the mesh so its dominant flat face (the back) looks down
    and the relief faces +z."""
    n, a = m.face_normals, m.area_faces
    keys, inv = np.unique(np.round(n * 20).astype(int), axis=0, return_inverse=True)
    dom = keys[np.argmax(np.bincount(inv, weights=a))] / 20
    sel = np.linalg.norm(n - dom, axis=1) < 0.08
    N = (n[sel] * a[sel, None]).sum(0); N /= np.linalg.norm(N)
    zp = N; xp = np.array([1., 0, 0]); xp -= xp.dot(zp) * zp; xp /= np.linalg.norm(xp)
    R = np.eye(4); R[:3, :3] = np.vstack([xp, np.cross(zp, xp), zp])
    m.apply_transform(R)
    m.apply_transform(trimesh.transformations.rotation_matrix(np.pi, [1, 0, 0]))
    return m


def rasterize(m, cfg):
    """Max-z height map by dense seeded surface sampling, holes filled."""
    b = m.bounds
    x0, x1, y0, y1 = b[0, 0], b[1, 0], b[0, 1], b[1, 1]
    W = cfg_get(cfg, 'raster_w'); H = int(round(W * (y1 - y0) / (x1 - x0)))
    img = np.full((H, W), -1e9)
    front = m.submesh([np.where(m.face_normals[:, 2] > -0.99)[0]], append=True)
    rng = np.random.default_rng(0)
    for _ in range(12):
        pts, _ = trimesh.sample.sample_surface(front, 6_000_000, seed=rng)
        ix = np.clip(((pts[:, 0] - x0) / (x1 - x0) * W).astype(int), 0, W - 1)
        iy = np.clip(((y1 - pts[:, 1]) / (y1 - y0) * H).astype(int), 0, H - 1)
        np.maximum.at(img, (iy, ix), pts[:, 2])
    v = front.vertices
    ix = np.clip(((v[:, 0] - x0) / (x1 - x0) * W).astype(int), 0, W - 1)
    iy = np.clip(((y1 - v[:, 1]) / (y1 - y0) * H).astype(int), 0, H - 1)
    np.maximum.at(img, (iy, ix), v[:, 2])
    for _ in range(5):
        hole = img < -1e8
        if not hole.any(): break
        nb = ndimage.maximum_filter(np.where(hole, -1e9, img), size=3)
        img[hole] = nb[hole]
    hole = img < -1e8
    if hole.any():
        idx = ndimage.distance_transform_edt(hole, return_distances=False, return_indices=True)
        img = img[tuple(idx)]
    return img


def load_heightmap(cfg):
    cache = cfg.get('hm_cache')
    if cache and os.path.exists(cache):
        return np.load(cache)
    f = rasterize(align(trimesh.load(cfg['src'])), cfg)
    if cache:
        np.save(cache, f)
    return f


def field_level(f, cfg):
    """Mode of the background plane's height."""
    w = cfg_get(cfg, 'field_window')
    inner = f[w[0]:w[1], w[2]:w[3]] if w else f
    lo, hi = cfg_get(cfg, 'field_range')
    hist, edges = np.histogram(inner, bins=400, range=(lo, hi))
    return edges[np.argmax(hist)] + (edges[1] - edges[0]) / 2


def valid_rect(f, cfg):
    r = cfg_get(cfg, 'rect')
    rect = np.zeros(f.shape, bool)
    if r:
        rect[r[2]:r[3], r[0]:r[1]] = True
    else:
        rect[:] = True
    return rect


def segment(f, cfg, with_marks=True):
    """Field threshold + cut polyline + zones + blob filter + restores,
    then (optionally) the user's saved marks."""
    H, W = f.shape
    f0 = field_level(f, cfg)
    field_lift = cfg_get(cfg, 'field_lift')
    below = np.zeros((H, W), bool)
    mound = cfg_get(cfg, 'mound')
    if mound:
        im = Image.new('L', (W, H), 0)
        ImageDraw.Draw(im).polygon(list(mound) + [(W - 1, H - 1), (0, H - 1)], fill=255)
        below = np.array(im) > 0
    for (x0, x1, y0, y1), thr in cfg_get(cfg, 'zones'):
        t = f0 + (field_lift if thr is None else thr)
        below[y0:y1, x0:x1] = f[y0:y1, x0:x1] <= t
    keep = (f - f0) > field_lift
    keep &= ~below
    rect = valid_rect(f, cfg)
    keep &= rect
    lab, n = ndimage.label(keep)
    sizes = ndimage.sum(keep, lab, range(1, n + 1))
    min_blob = cfg_get(cfg, 'min_blob')
    keep = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s > min_blob])
    print(f'field level {f0:.4f}; kept {int(keep.sum())} px in '
          f'{(sizes > min_blob).sum()} blobs', file=sys.stderr)
    rel = np.where(keep, f - f0, 0).clip(0)
    for pts, floor in cfg_get(cfg, 'restore'):
        pm = Image.new('L', (W, H), 0)
        ImageDraw.Draw(pm).polygon(list(pts), fill=255)
        pmask = (np.array(pm) > 0) & rect
        rel = np.maximum(rel, np.where(pmask, np.maximum(f - f0, floor), 0))
    if with_marks:
        rel = apply_marks(rel, f, f0, rect, cfg)
    return rel


# ---- quantizations shared bit-for-bit with the Relief Marker page ----

def height8(f, cfg):
    return np.clip((f - cfg['h_min']) / cfg['h_range'] * 255, 0, 255).round().astype(np.uint8)


def height16(f, cfg):
    return np.clip((f - cfg['h_min']) / cfg['h_range'] * 65535, 0, 65535).round().astype(np.int64)


def load_territory(cfg):
    p = cfg.get('territory')
    return np.array(Image.open(p)) if p and os.path.exists(p) else None


def build_territory(rel, n_figures, out_path):
    """Nearest-figure partition of the whole map from the extraction's
    n largest blobs, left to right, as gray 0, 120, 240, ... Frozen to a
    file so the page and the build clip fills identically."""
    lab, n = ndimage.label(rel > 0)
    sizes = ndimage.sum(rel > 0, lab, range(1, n + 1))
    big = np.argsort(sizes)[::-1][:n_figures] + 1
    cx = [ndimage.center_of_mass(lab == i)[1] for i in big]
    order = [big[i] for i in np.argsort(cx)]
    dists = [ndimage.distance_transform_edt(lab != i) for i in order]
    step = 240 // max(1, n_figures - 1)
    terr = (np.argmin(np.stack(dists), axis=0) * step).astype(np.uint8)
    Image.fromarray(terr, 'L').save(out_path, optimize=True)
    return terr


def apply_marks(rel, f, f0, rect, cfg):
    """Strokes saved from the Relief Marker page, in map pixel coords.

    {imgW, imgH, strokes: [...]}. A stroke is a brush path {c, w, pts},
    a band fill {c, f: [x, y, tol]} (legacy: connected region of height8
    within tol of the seed), or an edge fill {c, f: [x, y], s: step}
    (connected region reachable without a single-pixel height16 jump
    above step). Fills never cross territories. Strokes apply in order;
    'e' reverts to the automatic result; 'k' keeps the sculpt's height
    with the keep_floor; 'r' cuts to the face."""
    marks_path = cfg.get('marks')
    if not marks_path or not os.path.exists(marks_path):
        return rel
    m = json.load(open(marks_path))
    H, W = rel.shape
    assert (m['imgW'], m['imgH']) == (W, H), 'marks were painted on another map'
    h8 = height8(f, cfg)
    terr = load_territory(cfg)
    four = ndimage.generate_binary_structure(2, 1)
    mk = np.zeros((H, W), np.uint8)
    val = {'k': 1, 'r': 2, 'e': 0}
    for st in m['strokes']:
        v = val[st['c']]
        if 'f' in st:
            x, y = int(round(st['f'][0])), int(round(st['f'][1]))
            if not (0 <= x < W and 0 <= y < H):
                continue
            if 's' in st:
                h16 = height16(f, cfg)
                step = int(st['s'])
                from scipy.sparse import coo_matrix
                from scipy.sparse.csgraph import connected_components
                idx = np.arange(H * W).reshape(H, W)
                eh = (np.abs(np.diff(h16, axis=1)) <= step)
                ev = (np.abs(np.diff(h16, axis=0)) <= step)
                if terr is not None:
                    eh &= terr[:, 1:] == terr[:, :-1]
                    ev &= terr[1:, :] == terr[:-1, :]
                rows = np.concatenate([idx[:, :-1][eh], idx[:-1, :][ev]])
                cols = np.concatenate([idx[:, 1:][eh], idx[1:, :][ev]])
                g = coo_matrix((np.ones(len(rows), np.int8), (rows, cols)),
                               shape=(H * W, H * W))
                _, comp = connected_components(g, directed=False)
                mk[(comp == comp[y * W + x]).reshape(H, W)] = v
                continue
            tol = int(round(st['f'][2]))
            sel = np.abs(h8.astype(int) - int(h8[y, x])) <= tol
            if terr is not None:
                sel &= terr == terr[y, x]
            lab, _ = ndimage.label(sel, structure=four)
            mk[lab == lab[y, x]] = v
            continue
        w = st['w']
        im = Image.new('L', (W, H), 0)
        d = ImageDraw.Draw(im)
        pts = [(p[0], p[1]) for p in st['pts']]
        for (a, b) in zip(pts, pts[1:]):
            d.line([a, b], fill=1, width=int(round(w)))
        for p in pts if len(pts) == 1 else [pts[0], pts[-1]]:
            d.ellipse([p[0]-w/2, p[1]-w/2, p[0]+w/2, p[1]+w/2], fill=1)
        mk[np.array(im) > 0] = v
    floor = cfg_get(cfg, 'keep_floor')
    kmask = (mk == 1) & rect
    rel = np.maximum(rel, np.where(kmask, np.maximum(f - f0, floor), 0))
    rel[(mk == 2) & rect] = 0
    print(f"marks: {len(m['strokes'])} strokes applied", file=sys.stderr)
    return rel


def export(relief, cfg):
    """Crop, resample, and write the 8-bit PNG for surface(), with the
    cut mask re-applied after resampling so edges stay crisp."""
    pad = cfg_get(cfg, 'pad'); out_w = cfg_get(cfg, 'out_w')
    ys, xs = np.where(relief > 0)
    c = relief[ys.min() - pad:ys.max() + 1 + pad, xs.min() - pad:xs.max() + 1 + pad]
    H, W = c.shape
    out_h = int(round(H * out_w / W))
    im = Image.fromarray((c / c.max() * 65535).astype(np.uint16))
    im = im.resize((out_w, out_h), Image.LANCZOS)
    a = np.clip(np.round(np.asarray(im).astype(float) / 65535 * 255), 0, 255)
    mask = Image.fromarray(((c > 0) * 255).astype(np.uint8)).resize((out_w, out_h), Image.BILINEAR)
    a = (a * (np.asarray(mask) > 127)).astype(np.uint8)
    Image.fromarray(a, 'L').save(cfg['out'])
    print(f'crop {W}x{H} px -> {out_w}x{out_h}; peak {c.max():.4f} units; '
          f'wrote {os.path.relpath(cfg["out"])}', file=sys.stderr)


def run_build(cfg):
    export(segment(load_heightmap(cfg), cfg), cfg)


# ---- Relief Marker page generation ----

def shade(z255, mask=None):
    gy, gx = np.gradient(z255)
    n2 = np.dstack([-gx, -gy, np.ones_like(z255) * 8])
    n2 /= np.linalg.norm(n2, axis=2, keepdims=True)
    l = np.array([-0.5, 0.6, 0.62]); l /= np.linalg.norm(l)
    sh = np.clip(n2 @ l, 0, 1) * 0.82 + 0.18
    if mask is not None:
        sh[~mask] = 0.05
    return (sh * 255).astype(np.uint8)


def _durl(img, fmt='JPEG', q=82):
    import base64, io
    b = io.BytesIO()
    if fmt == 'JPEG':
        img.save(b, fmt, quality=q)
    else:
        img.save(b, fmt, optimize=True)
    mime = 'jpeg' if fmt == 'JPEG' else 'png'
    return 'data:image/%s;base64,' % mime + base64.b64encode(b.getvalue()).decode()


def make_marker(cfg, template_path, out_html):
    """Build the Relief Marker page: base shades, pre-marks mask, result
    view, both fill quantizations, territory, and the saved strokes."""
    f = load_heightmap(cfg)
    H, W = f.shape
    rel_pre = segment(f, cfg, with_marks=False)
    rel_post = segment(f, cfg, with_marks=True)
    span = f.max() - f.min()
    imN = Image.fromarray(np.stack([shade((f - f.min()) / (span * 1.3) * 255)] * 3, -1))
    imCur = Image.fromarray(shade(rel_post / rel_post.max() * 255,
                                  mask=rel_post > 0)).convert('RGB')
    mrgba = np.zeros((H, W, 4), np.uint8)
    mrgba[..., 0:3] = 255
    mrgba[..., 3] = np.where(rel_pre > 0, 255, 0)
    imM = Image.fromarray(mrgba, 'RGBA')
    imH = Image.fromarray(height8(f, cfg), 'L')
    v16 = height16(f, cfg)
    rgb = np.zeros((H, W, 3), np.uint8)
    rgb[..., 0] = (v16 >> 8).astype(np.uint8)
    rgb[..., 1] = (v16 & 255).astype(np.uint8)
    imH2 = Image.fromarray(rgb, 'RGB')
    terr = load_territory(cfg)
    if terr is None:
        raise SystemExit('territory file missing: run build_territory first')
    imT = Image.fromarray(terr, 'L')
    marks_path = cfg.get('marks')
    marks = (json.load(open(marks_path)) if marks_path and os.path.exists(marks_path)
             else {"v": 1, "imgW": W, "imgH": H, "strokes": []})
    html = open(template_path).read()
    for ph, val in [('__MARKS__', json.dumps(marks)), ('__N__', _durl(imN)),
                    ('__M__', _durl(imM, 'PNG')), ('__CUR__', _durl(imCur)),
                    ('__H__', _durl(imH, 'PNG')), ('__H2__', _durl(imH2, 'PNG')),
                    ('__T__', _durl(imT, 'PNG')),
                    ('__IW__', str(W)), ('__IH__', str(H))]:
        assert html.count(ph) == 1, ph
        html = html.replace(ph, val)
    open(out_html, 'w').write(html)
    print(f'wrote {out_html} ({len(html)//1024} KB)', file=sys.stderr)
