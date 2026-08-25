---
name: relief-pipeline
description: Turn a relief sculpt mesh (a plaque, seal, or emblem STL) into a clean height-map PNG that OpenSCAD surface() extrudes onto a part, with a browser mark-up tool for hand corrections. Use when extracting figures from a sculpted source, converting an STL relief to a heightfield, cleaning art for embossing, or when the user wants to paint keep/remove corrections on relief art.
allowed-tools:
  - Read
  - Glob
---

# Relief pipeline

Converts a sculpted relief mesh into an 8-bit height map that
`surface()` turns into a raised emblem on a printed part. The
`coat-of-arms` skill is the reference project; `switch_plate` v024
consumes its output.

## Stages

1. **Align + rasterize** — find the mesh's dominant flat face (the
   back), rotate the relief to face +z, and sample a max-z height map
   (default 2400 px wide, seeded, deterministic).
2. **Automatic segmentation** — estimate the background field level by
   histogram mode, keep pixels above `field_lift`, clip to a `rect`,
   cut below a hand-traced `mound` polyline, override boxes with local
   `zones` thresholds, drop blobs under `min_blob`, then add `restore`
   polygons with a height floor. Thresholds cannot separate features
   that sit at the same height, and polylines cannot follow sculpted
   edges — get close, then stop.
3. **Hand mark-up** — generate the Relief Marker page and let the user
   paint the rest. Marks apply after every automatic rule and win.
4. **Export** — crop to the art, resample to `out_w`, re-apply the cut
   mask after resampling (the resampler smears every cut edge into a
   gray skirt that prints as a shadow apron), write the PNG.

## Files

- `scripts/relief_lib.py` — every stage as functions over a project
  `CONFIG` dict. Read its docstrings for the config keys.
- `scripts/make-marker.py <project-build-script.py> <out.html>` —
  renders the mark-up page from `templates/marker.html`.
- A project = a sibling skill holding the source mesh, `CONFIG` in a
  small build script, and the derived assets (`user-marks.json`,
  `territory.png`, the output PNG). See
  `../coat-of-arms/scripts/build-relief.py`.

## The Relief Marker round trip

1. `make-marker.py` builds the page; publish it as an artifact with
   `capabilities: {"artifact": {}}`.
2. The user brushes or flood-fills keep/remove marks; the page is a
   live preview (keep shows the sculpt, remove grays it out; Fill stops
   at height jumps, sized by its slider, and never crosses between
   figure territories).
3. Save republishes the page with the strokes embedded; the session is
   notified. Extract the `<script id="marks">` JSON from the re-read
   artifact into the project's `user-marks.json` and re-run the build.
4. Before republishing the page for any reason, refresh its marks
   block from `user-marks.json` — republishing a stale local copy
   silently rolls back the user's strokes.

## Determinism contract

Saved marks only mean what the user saw if both sides compute
identically. Never change, while marks exist: the seeded rasterize, the
`h_min`/`h_range` quantization, the fill region growth (band fill on
height8, edge fill on height16, 4-connected), the territory file, or
stroke ordering. The territory partition (`build_territory`) is frozen
to a PNG that both the page and the build read.

## OpenSCAD side

`surface()` maps gray 0–255 to z 0–100, puts the image's top row at
+y, spans (W−1)×(H−1) units, and closes the solid at z −1. Scale all
three axes and sink the background plane slightly into the part. The
consuming model records image size and placement (see `switch_plate`'s
SPEC for a worked example).

## Environment

Needs numpy, scipy, trimesh, Pillow:

```bash
python3 -m venv /tmp/relief-venv && /tmp/relief-venv/bin/pip install numpy scipy trimesh pillow
/tmp/relief-venv/bin/python <project>/scripts/build-relief.py
```
