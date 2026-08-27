---
name: print-audit
description: Audit an OpenSCAD model for 3D-printability — overhangs, bridges, wall widths, teardrop holes, chamfers, warping, manifold geometry, print orientation, and (for clear or translucent filament) optical clarity. Use after a design looks correct and before exporting for print, and whenever the user says a part prints in clear, transparent, or translucent filament.
allowed-tools:
  - Bash(*/audit-scad.sh*)
  - Bash(*/render-scad.sh*)
  - Bash(*/wall-thickness.py*)
  - Read
  - Grep
  - Glob
---

# Printability Audit Skill

Audit a `.scad` model against the principles in Billie Ruben's
"CAD Design Tips for 3D Printing" poster. Numbers in brackets, e.g. [12],
refer to her 25 tips (left-to-right, top-to-bottom).

The audit has four parts: **A** is mechanical (a script), **B** is a code
review of the `.scad`, **C** is a visual review of renders, **D** is the
clarity review. Run A, B, and C on every model. Run D when the part prints
in clear, transparent, or translucent filament, and say in the report
whether D ran. Emit one combined report.

## A. Mechanical checks (run the script)

```bash
.claude/skills/print-audit/scripts/audit-scad.sh <name>/<name>_<ver>.scad
```

Pass `--line-width <mm>` if the printer's extrusion width is not 0.4mm.

The script covers:

- **[21] Manifold** — OpenSCAD console warnings (non-manifold,
  self-intersecting, degenerate faces). `UNKNOWN` means not validated —
  never treat it as a pass.
- **[2,7,8,9] Overhangs** — STL facet-normal analysis. Downward faces
  steeper than 45° are flagged (bed contact excluded), with area and
  centroid so you can name the feature. 45–60° prints with quality loss;
  >60° or flat-down needs redesign or supports.
- **[12] Bridges** — flat downward faces above the bed. Spans up to
  ~20mm bridge cleanly on most printers; larger ones need ribs [15,23],
  a sacrificial layer [13], or supports.
- **[1] Wall widths** — parameters named like `wall`, `*_t`, `*_w`
  should be multiples of the extrusion line width (0.4 → 0.8, 1.2, 1.6).
- **[1] Wall thickness by height** — `wall-thickness.py` slices the STL
  at 24 heights and measures the distance between neighboring loops. It
  warns when the wall drifts, or when the rounded line count changes with
  height. A parameter lint cannot see this: a wall built from two lines
  with different drafts has no single `wall` parameter to check.
- **[3,16] Horizontal-axis features** — `rotate([90,...])`-style
  candidates listed for the teardrop/curve review in section B.
- **[11] Parametric style** — named parameters vs magic numbers.

## B. Code review (read the .scad)

Work through these against the source:

- **[6] Clearances** — mating/fitted parts need ~0.3mm clearance,
  captive/print-in-place parts more. Check clearance parameters exist
  and are honored where parts meet.
- **[3,4] Horizontal holes** — every candidate the script listed:
  round horizontal holes should be teardrop or pointed-arch shaped so
  the top doesn't sag. Pointed tops (hexagons, arches) are already fine.
- **[8,9,10] Fillets vs chamfers at the base** — a fillet meeting the
  bed or any downward face is a steep overhang; use a 45° chamfer
  (or chamfer+fillet combo) there instead. Fillets are fine elsewhere.
- **[5] Vertical edge fillets** — sharp vertical edges print faster and
  cleaner when filleted (reduces ringing on direction changes).
- **[24] Text** — text should be indented (not embossed) and on a
  vertical surface for best resolution.
- **[17,18] Fasteners and compliance** — where parts clip or bolt:
  trapped-nut slots and flexible push-fit features beat tight rigid fits.
- **[22] Test fits** — for fitted features, suggest isolating the mating
  region into a small test print before committing to the full model.

## C. Visual review (render and read previews)

Render at least a front view, a low three-quarter view, and a bottom
view (`render-scad.sh <file> --camera 0,0,0,<rx>,0,<rz>,0`), then check:

- **[4] Arches** — openings in vertical walls should be pointed, not
  round-topped (unless teardropped).
- **[16] Curves by axis** — curved surfaces with a horizontal axis show
  layer stepping; confirm visible curves have vertical axes where
  aesthetics matter.
- **[19,20] Warping** — large flat bed contact with sharp corners warps:
  suggest rounded corners or mouse ears [19]; very large bases may want
  concentric relief slits [20].
- **[14,15,23] Roofs and ribs** — large internal roofs should have
  staggered triangles, perpendicular sacrificial ribs, or diagonal ribs
  supporting them.
- **[25] Orientation** — layer planes are weak in tension/bending across
  them. Confirm the intended print orientation puts loads along layers,
  and say so explicitly in the report (e.g. thin vertical struts loaded
  sideways are the weak spot).

## D. Clarity review (clear, transparent, or translucent filament)

Run this part when the material is clear PETG, clear PLA, or any filament
the user calls clear, transparent, translucent, natural, or see-through.
Light scatters at every boundary between extruded lines and at every void.
A clear part looks clear only where every line runs the same direction,
fuses to its neighbors, and nothing else sits inside the wall. Any change
in what the slicer puts in the wall shows as a band.

Case that motivated this section: `rosey_pot` v005 had an outer wall at
11.7° draft and an inner wall at 12.0° draft. The wall tapered from
1.93 mm to 1.57 mm. With 0.5 mm lines the slicer fit 3 walls plus a band
of infill below 42 mm, and 3 walls alone above it. The print was frosted
below that height and clear above it, with a ragged line at the change.

Check each item and name the height or feature in the report:

- **D1 Constant wall thickness.** Read the `wall-thickness.py` table from
  part A. The judged wall run must show a spread under 0.25 line widths.
  Inner and outer surfaces must be offsets of each other, not two lines
  with independent slopes. In the `.scad`, look for an inner profile
  built from its own points instead of `offset(r = -wall)` or
  `offset(delta = -wall)` of the outer profile.
- **D2 Whole number of lines.** The wall must equal N × line width for the
  preset in use (`Clear Watertight @ 0.4` uses 0.5 mm lines and asks for
  4 walls; `--line-width 0.5`). A remainder of more than 0.25 lines gets
  infill or gap fill inside the wall. Both scatter light. Pick the wall
  from the line width and the wall count, then write it into `SPEC.md`.
- **D3 Preset matches geometry.** The preset's `wall_loops` × line width
  must equal the wall. Fewer loops than the wall holds leaves infill;
  more loops than fit makes the slicer squeeze or drop lines.
- **D4 No local thickening in the wall.** Rim beads, bosses, ribs, text,
  and fillets that thicken the wall create a local infill or gap-fill
  patch. Each patch prints cloudy. Flag each one, with its height range.
  Accept it only if the user wants an opaque feature there.
- **D5 Solid regions.** Floors and lids are solid layers and print
  cloudy in every case. Say so. For a floor that must stay clear, ask
  for concentric top/bottom infill and note the trade in `SPEC.md`.
- **D6 Seam.** One aligned seam is one line; a random seam is a
  speckled band. Confirm `seam_position` is `aligned` or `rear` in the
  preset, and suggest the least visible side of the part.
- **D7 Slicer check.** Recommend the user slice with the clear preset,
  set the preview color scheme to "Line type", and step through the
  layers. Any "Sparse infill", "Gap infill", or "Internal solid infill"
  inside a wall is a WARN.

## Report format

End with a table: tip number(s), verdict (PASS / WARN / ADVISORY / N/A),
one-line finding. Include rows D1–D7 when part D ran; when it did not
run, add one row "D" marked N/A with the material named. Every WARN needs a concrete suggested fix, phrased as a
parameter change or feature change in the audited file. Do not silently
skip tips — mark inapplicable ones N/A.

## Credit

Principles from Billie Ruben's poster "CAD Design Tips for 3D Printing"
(@BillieRubenMake), which she distributes freely.
