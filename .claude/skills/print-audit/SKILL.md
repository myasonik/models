---
name: print-audit
description: Audit an OpenSCAD model for 3D-printability — overhangs, bridges, wall widths, teardrop holes, chamfers, warping, manifold geometry, print orientation. Use after a design looks correct and before exporting for print.
allowed-tools:
  - Bash(*/audit-scad.sh*)
  - Bash(*/render-scad.sh*)
  - Read
  - Grep
  - Glob
---

# Printability Audit Skill

Audit a `.scad` model against the principles in Billie Ruben's
"CAD Design Tips for 3D Printing" poster. Numbers in brackets, e.g. [12],
refer to her 25 tips (left-to-right, top-to-bottom).

The audit has three parts: **A** is mechanical (a script), **B** is a code
review of the `.scad`, **C** is a visual review of renders. Run all three
and emit one combined report.

## A. Mechanical checks (run the script)

```bash
.claude/skills/print-audit/scripts/audit-scad.sh models/<name>/<name>_<ver>.scad
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

## Report format

End with a table: tip number(s), verdict (PASS / WARN / ADVISORY / N/A),
one-line finding. Every WARN needs a concrete suggested fix, phrased as a
parameter change or feature change in the audited file. Do not silently
skip tips — mark inapplicable ones N/A.

## Credit

Principles from Billie Ruben's poster "CAD Design Tips for 3D Printing"
(@BillieRubenMake), which she distributes freely.
