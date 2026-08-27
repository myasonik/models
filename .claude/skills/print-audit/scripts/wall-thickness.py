#!/usr/bin/env python3
"""Measure shell wall thickness of an STL at sampled Z heights.

Pure Python, no third-party modules. Slices the mesh with horizontal planes,
chains the cut segments into closed loops, and reports the distance from
each loop to the nearest other loop in the same slice. For a hollow part
(pot, cup, tube, box) that distance is the wall thickness.

Usage: wall-thickness.py <model.stl> [--line-width 0.4] [--samples 24]
                         [--zmin Z] [--zmax Z]

Reads ASCII or binary STL. Exit 0 always; verdict lines start with
PASS / WARN / NOTE so audit-scad.sh can pass the report through.
"""
import math
import struct
import sys


def read_stl(path):
    with open(path, "rb") as f:
        data = f.read()
    tris = []
    is_ascii = data[:5] == b"solid" and b"facet" in data[:1000]
    if is_ascii:
        verts = []
        for line in data.decode("ascii", "replace").splitlines():
            parts = line.split()
            if len(parts) == 4 and parts[0] == "vertex":
                verts.append((float(parts[1]), float(parts[2]), float(parts[3])))
                if len(verts) == 3:
                    tris.append(tuple(verts))
                    verts = []
    else:
        n = struct.unpack_from("<I", data, 80)[0]
        off = 84
        for _ in range(n):
            vals = struct.unpack_from("<12f", data, off)
            off += 50
            tris.append(((vals[3], vals[4], vals[5]),
                         (vals[6], vals[7], vals[8]),
                         (vals[9], vals[10], vals[11])))
    return tris


def slice_segments(tris, z):
    """Return the line segments where the plane Z=z cuts the mesh."""
    segs = []
    for tri in tris:
        pts = []
        for i in range(3):
            a = tri[i]
            b = tri[(i + 1) % 3]
            if (a[2] < z) != (b[2] < z):
                t = (z - a[2]) / (b[2] - a[2])
                pts.append((a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1])))
        if len(pts) == 2:
            segs.append((pts[0], pts[1]))
    return segs


def chain_loops(segs, tol=1e-3):
    """Join segments end to end into closed loops."""
    def key(p):
        return (round(p[0] / tol), round(p[1] / tol))

    ends = {}
    for i, (a, b) in enumerate(segs):
        ends.setdefault(key(a), []).append(i)
        ends.setdefault(key(b), []).append(i)
    used = [False] * len(segs)
    loops = []
    for start in range(len(segs)):
        if used[start]:
            continue
        used[start] = True
        a, b = segs[start]
        loop = [a, b]
        cur = b
        while True:
            nxt = None
            for j in ends.get(key(cur), []):
                if not used[j]:
                    nxt = j
                    break
            if nxt is None:
                break
            used[nxt] = True
            p, q = segs[nxt]
            cur = q if key(p) == key(cur) else p
            loop.append(cur)
            if key(cur) == key(loop[0]):
                break
        if len(loop) >= 3:
            loops.append(loop)
    return loops


def loop_length(loop):
    return sum(math.dist(loop[i], loop[i + 1]) for i in range(len(loop) - 1))


def point_seg_dist(p, a, b):
    ax, ay = a
    bx, by = b
    px, py = p
    dx, dy = bx - ax, by - ay
    l2 = dx * dx + dy * dy
    if l2 == 0:
        return math.dist(p, a)
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / l2))
    return math.dist(p, (ax + t * dx, ay + t * dy))


def loop_to_loops_dist(src, others, step=1.0):
    """Nearest distance from sampled points on src to any loop in others.

    Returns (min, median, max) over the sampled points."""
    dists = []
    acc = 0.0
    for i in range(len(src) - 1):
        a, b = src[i], src[i + 1]
        seg_len = math.dist(a, b)
        # sample the segment start point, plus interior points every `step`
        n = max(1, int(seg_len // step))
        for k in range(n):
            t = k / n
            p = (a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1]))
            best = float("inf")
            for o in others:
                for j in range(len(o) - 1):
                    d = point_seg_dist(p, o[j], o[j + 1])
                    if d < best:
                        best = d
            dists.append(best)
        acc += seg_len
    if not dists:
        return None
    dists.sort()
    return dists[0], dists[len(dists) // 2], dists[-1]


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    path = argv[1]
    line_w = 0.4
    samples = 24
    zmin_arg = zmax_arg = None
    i = 2
    while i < len(argv):
        if argv[i] == "--line-width":
            line_w = float(argv[i + 1]); i += 2
        elif argv[i] == "--samples":
            samples = int(argv[i + 1]); i += 2
        elif argv[i] == "--zmin":
            zmin_arg = float(argv[i + 1]); i += 2
        elif argv[i] == "--zmax":
            zmax_arg = float(argv[i + 1]); i += 2
        else:
            print("Unknown option:", argv[i]); return 1

    tris = read_stl(path)
    if not tris:
        print("FAIL: no triangles read from", path)
        return 1
    zs = [v[2] for t in tris for v in t]
    zmin, zmax = min(zs), max(zs)
    lo = zmin_arg if zmin_arg is not None else zmin
    hi = zmax_arg if zmax_arg is not None else zmax
    # keep 2% clear of the extremes so the plane does not sit on a face
    pad = (hi - lo) * 0.02
    lo += pad
    hi -= pad

    print(f"Wall thickness by height  (model Z {zmin:.2f}..{zmax:.2f} mm, "
          f"line width {line_w} mm)")
    print(f"{'Z':>7} {'loops':>5} {'min':>6} {'median':>6} {'max':>6}  "
          f"{'lines':>5}  note")
    rows = []
    for s in range(samples):
        z = lo + (hi - lo) * s / (samples - 1)
        loops = chain_loops(slice_segments(tris, z))
        loops = [l for l in loops if loop_length(l) > 2.0]
        if len(loops) < 2:
            print(f"{z:7.2f} {len(loops):5d}    solid section (no inner loop)")
            rows.append((z, None, len(loops)))
            continue
        # measure from every loop to the others; report the tightest median
        # (that is the wall the slicer has to fill with lines)
        best = None
        for idx, l in enumerate(loops):
            others = loops[:idx] + loops[idx + 1:]
            d = loop_to_loops_dist(l, others)
            if d and (best is None or d[1] < best[1]):
                best = d
        tmin, tmed, tmax = best
        ratio = tmed / line_w
        nlines = int(ratio + 0.5)
        frac = abs(ratio - nlines)
        note = ""
        if frac > 0.25:
            note = f"between {int(ratio)} and {int(ratio)+1} lines -> infill/gap fill"
        print(f"{z:7.2f} {len(loops):5d} {tmin:6.2f} {tmed:6.2f} {tmax:6.2f}  "
              f"{ratio:5.2f}  {note}")
        rows.append((z, tmed, len(loops)))

    # Judge the trend on the longest run of consecutive samples with the
    # same loop count and no thickness jump. Floors, rims, and bosses are
    # not the wall the clarity question is about.
    # A jump of more than one line width between neighbors also ends a
    # run: that is a bead, a boss, or a floor, not the wall itself.
    runs = []
    for z, t, n in rows:
        if t is None:
            continue
        if runs and runs[-1][0] == n and abs(t - runs[-1][1][-1][1]) <= line_w:
            runs[-1][1].append((z, t))
        else:
            runs.append((n, [(z, t)]))
    print()
    if not runs:
        print("NOTE: no hollow sections; no thickness trend to check.")
        return 0
    n_loops, meas = max(runs, key=lambda r: len(r[1]))
    if len(meas) < 2:
        print("NOTE: fewer than two hollow sections; no thickness trend to check.")
        return 0
    print(f"Wall run judged: Z {meas[0][0]:.1f}..{meas[-1][0]:.1f} mm "
          f"({len(meas)} samples, {n_loops} loops each)")
    ts = [t for _, t in meas]
    tmin, tmax = min(ts), max(ts)
    spread = tmax - tmin
    print(f"Wall thickness range: {tmin:.2f}..{tmax:.2f} mm "
          f"(spread {spread:.2f} mm = {spread/line_w:.2f} lines)")
    # where does the rounded line count change?
    counts = [(z, int(t / line_w + 0.5)) for z, t in meas]
    changes = [(counts[k][0], counts[k-1][1], counts[k][1])
               for k in range(1, len(counts)) if counts[k][1] != counts[k-1][1]]
    if changes:
        print("WARN: wall line count changes with height "
              "(the slicer adds or drops a line, or a band of infill/gap fill):")
        for z, a, b in changes:
            print(f"  at Z~{z:.1f} mm: {a} -> {b} lines")
        print("  Fix: make the inner and outer surfaces parallel (offset), "
              "and set the wall to a whole number of line widths.")
    elif spread > 0.25 * line_w:
        print(f"WARN: wall thickness drifts by {spread:.2f} mm over the height; "
              "line widths vary layer to layer (visible on clear filament).")
    else:
        print("PASS: wall thickness is constant over the height.")
    fracs = [abs(t / line_w - int(t / line_w + 0.5)) for t in ts]
    if max(fracs) > 0.25:
        print(f"WARN: wall is not a whole number of {line_w} mm lines at some "
              "heights; the slicer fills the remainder with infill or gap fill.")
    else:
        print(f"PASS: wall is a whole number of {line_w} mm lines at every sample.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
