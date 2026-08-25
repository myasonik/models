---
name: coat-of-arms
description: Reference art for the family coat of arms — a bear rampant, an ash tree, and a fox rampant — as a downloaded relief plaque STL and a cleaned height-map PNG of the three figures. Use when a model carries the coat of arms, crest, seal, or the bear/tree/fox emblem, or when the emblem's size, depth, or placement on a part is in question.
allowed-tools:
  - Read
  - Glob
---

# Coat of arms reference

The family coat of arms as relief art. The source is a downloaded plaque
mesh. Nothing in this repo can regenerate it, so it lives here and not in
a model folder. The height map derives from it with the script below.

## Files

### `assets/coat_of_arms_plaque.stl`

The downloaded plaque. Binary STL, 1,000,000 triangles, 50 MB, unitless,
2.0 wide. Its content: a rectangular frame, a recessed field with carved
swirl texture, a rock mound, and on the mound a bear rampant (left), an
ash tree (center), and a fox rampant (right). The plaque sits tilted 12°
about x in the file. Do not import it into a model: it is too heavy to
render and it carries the frame and mound.

### `assets/coat_of_arms_relief.png`

The three figures only, as an 8-bit grayscale height map for OpenSCAD
`surface()`. The frame, field, swirls, and mound are removed.

| Property | Value |
| --- | --- |
| Size | 720 × 413 px, aspect 1.743 |
| Content | bear, tree, fox; a 1.5-px blank pad on each side |
| Gray 0 | the plate face (background) |
| Gray 255 | the relief peak, the bear's shoulder |
| Native depth | peak = 0.162 of the plaque width; 7.4 mm at 72 mm wide |
| Lowest figure parts | about 8 % of peak (the bear's far hind leg) |
| Base of the figures | the animals' feet and the flat-cut trunk lie on the bottom edge |

`surface()` maps gray 0–255 to height 0–100 and puts the image's top row
at high y, so the art is upright when viewed from +z. A W × H image
spans (W − 1) × (H − 1) units before scaling, and the solid's underside
sits at z = −1. Scale all three axes:

```scad
// model folder at the repo root (one level deep)
emb_png = "../.claude/skills/coat-of-arms/assets/coat_of_arms_relief.png";
emb_px  = [720, 413];
emb_w   = 72;                 // printed width of the image
emb_h   = 4;                  // printed height of the peak
s = emb_w / (emb_px[0] - 1);
scale([s, s, emb_h / 100])
    surface(file = emb_png, center = true, convexity = 10);
```

The surface's rectangle is solid from z = −1 up to the background plane at
z = 0. Sink it below the face so that plane is inside the part.

Check the render log for `WARNING: Can't open` — a wrong path renders
nothing and still exits 0.

### `assets/user-marks.json`

Hand-painted keep/remove brush strokes in the 2400 × 1352 height-map
pixel grid, saved from the Relief Marker artifact
(https://claude.ai/code/artifact/53c1cfa1-c87f-429f-b7df-5a8a23267887).
A stroke is a brush path or a flood fill (a click plus a tolerance;
the fill spreads over the connected region of similar height, computed
identically in the page and in the build script). The build script
applies them after every automatic cut, in stroke order: keep restores
the sculpt's height with a 0.025 floor, remove cuts to the face. To revise the art, paint in that page and press
Save marks; then rewrite this file from the artifact's embedded JSON
and re-run the build.

## Rebuilding the PNG

The generic pipeline (alignment, segmentation, marks, export, and the
Relief Marker page) lives in the `relief-pipeline` skill;
`scripts/build-relief.py` here is just this plaque's config plus a call
into it.

```bash
python3 -m venv /tmp/coa-venv && /tmp/coa-venv/bin/pip install numpy scipy trimesh pillow
/tmp/coa-venv/bin/python .claude/skills/coat-of-arms/scripts/build-relief.py
```

The build is seeded and deterministic; it runs for about two minutes.
All polylines, zones and restore polygons are pixel coordinates for
this STL only.
