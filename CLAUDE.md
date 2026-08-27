# Models

OpenSCAD source for 3D-printed parts. One folder per model, at the repo root.
Unstarted ideas live in `IDEAS.md`.
Retired models live in `ARCHIVE/` — leave it alone unless asked. Archived
models keep only their sources; renders and STLs are deleted because they
rebuild from the `.scad`. Archive with the `archive-model` skill, never by
hand.

## Printer

Snapmaker U1, sliced in the Snapmaker fork of Orca.

- Build volume 270 × 270 × 270 mm — a model that doesn't fit is a bug, flag it early.
- Four SnapSwap toolheads, 0.4 mm stainless nozzles, up to 300 °C.
- Bed to 100 °C, textured PEI. Bottom surfaces come out with a matte texture.

## Ask before designing

Two things change the geometry and are never safe to assume:

- **Material.** Iteration prints are PLA, but the final part may be anything.
  Ask which filament this model is for, then design to it — clearances,
  shrinkage, and minimum wall thickness all depend on the answer.
- **Single- or multi-color.** Both are in play, and the choice decides whether
  the model is one solid or separate bodies per toolhead. The user will
  specify; ask if they haven't.

## Clear filament

When the user says a part prints in clear, transparent, or translucent
filament (clear PETG is the usual case), run the `print-audit` skill's
clarity review (section D) on the model before any other work on it.
Light scatters at every boundary between extruded lines, so the wall
must be a constant thickness equal to a whole number of line widths, with
nothing else inside it. A wall that tapers, or that leaves room for a
band of infill or gap fill, prints with a visible frosted band. The audit
script measures wall thickness by height; read its table, do not guess
from the parameters.

## Design for no supports

Default to a model that prints unsupported in a single orientation:

- Keep overhangs at or under 45°.
- Horizontal holes as teardrops; chamfer bottom edges rather than rounding.
- Pick the print orientation deliberately and record it in `SPEC.md`.

Say so explicitly if a design genuinely needs supports — don't add them silently.

## Workflow

Use the skills in `.claude/skills/` rather than calling OpenSCAD directly:
`openscad` for versioning, `preview-scad` to render, `print-audit` before
export, `export-stl` to produce the STL, `gridfinity` for anything on the
42 mm grid, `archive-model` to retire one, `u1-reference` for printer geometry
and reference meshes, `orca-presets` for slicer and filament profiles,
`openscad-setup` when the toolchain itself misbehaves.

Reference geometry a model is designed *around* — vendor meshes, scans,
downloaded parts — lives in a skill, never in a model folder. Nothing in this
repo can rebuild those files, so they must not sit where cleanup might delete
them.

Every model folder keeps a `SPEC.md` (current spec, no history) and a
`HISTORY.md` (one entry per version, newest first). Every new version updates
both. See the `openscad` skill for the full convention.
