# Hair Comb — Design Specification

All dimensions in mm unless noted. One solid, one color, one part. **It
needs slicer supports.** See section 7.

## 1. What it is

A reproduction of a curved plastic side comb. The comb is a section of a
cylinder. Fourteen teeth hang from a solid spine bar, and the whole strip
curves so that it hugs the head.

The source is three photographs of the original comb next to a tape
measure. The third photograph carries a red freehand outline the user
drew around one tooth, which fixes the tooth silhouette.

People flex the teeth for fun, so the teeth must survive it. That drives
the print orientation and the tooth section.

## 2. Driving dimensions

These five numbers set the geometry. Everything else derives from them.

| Name | Value | Source |
|---|---|---|
| `chord` | 69.0 | Straight-line width across the two ends, read on the tape at 16.4 px/mm |
| `rise` | 12.0 | Peak height of the convex face above the chord, stated by the user |
| `height` | 40.0 | Spine outer edge to tooth tip |
| `teeth` | 14 | Counted by the user on the original |
| `shell_t` | 3.0 | Radial thickness at the spine |

`shell_t` runs 0.6 over the original's 2.4. The tooth root is 3.0 for
strength, and the spine has to match it or the root stands proud of the
spine face. Both sit flush at 3.0.

## 3. Derived arc

A chord of 69.0 with a rise of 12.0 fixes one circle. The radius follows
from `R = (chord^2/4 + rise^2) / (2*rise)`.

| Name | Formula | Value |
|---|---|---|
| `R_out` | `(chord^2/4 + rise^2)/(2*rise)` | 55.594 |
| `R_in` | `R_out - shell_t` | 52.594 |
| `R_mid` | `R_out - shell_t/2` | 54.094 |
| `center_y` | `rise - R_out` | -43.594 |
| `end_r` | `shell_t/2` | 1.500 |
| `half_angle` | `90 - acos((chord/2 - end_r)/R_mid)` | 37.593° |
| `span` | `2 * half_angle` | 75.187° |
| `arc_mid` | `R_mid * span` in radians | 70.985 |

The arc spans 75°, not 180°. Each end tilts 37.6° away from the peak.
"Semi-circle" names the look, not the angle.

`half_angle` does not come from `asin(chord/2 / R_out)`. The spine ends
in a semicircular cap of `end_r` centered on `R_mid`, so the widest point
of the part is that cap's equator rather than the sector's outer corner.
Solving for the equator at `chord/2` gives 37.593°, and the part measures
69.000 wide.

## 4. Tooth layout

The span divides into 14 equal angular cells. One tooth centers in each
cell.

| Name | Formula | Value |
|---|---|---|
| `cell` | `span / teeth` | 5.3705° |
| `pitch` | `R_mid * cell` in radians | 5.070 |
| tooth center `i` | `-half_angle + cell*(i + 0.5)` | i = 0..13 |

## 5. Tooth shape

### Silhouette

**The tooth is not widest at the root.** It leaves the spine at 88% of
full width, swells to full width 42% of the way down, and then tapers to
a point. Seen face-on it reads as a long pointed oval.

The profile comes from the red outline the user drew around one tooth.
Extracting the red mask and measuring the outer edge of the two strokes
row by row gives, with `s` = 0 at the spine and 1 at the tip:

| `s` | 0.00 | 0.10 | 0.20 | 0.30 | 0.42 | 0.55 | 0.65 | 0.75 | 0.85 | 0.93 | 1.00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| width / max | 0.88 | 0.92 | 0.95 | 0.98 | 1.00 | 0.97 | 0.92 | 0.81 | 0.63 | 0.46 | 0.32 |

The model interpolates this table linearly and lofts 48 sections along
each tooth. The table is the specification; do not replace it with a
formula without checking it back against the photograph.

Unverified: the stroke is a freehand marker about 25 px wide, or 1.5 mm.
Tracking the two bounding slots in the unannotated photograph agrees on
the direction and puts the root near 76% of the maximum rather than 88%.
The two methods bracket the answer; a caliper on the original settles it.

### Dimensions

| Name | Value | Note |
|---|---|---|
| `tooth_len` | 35.0 | `height - spine_h` |
| `tooth_w_max` | 4.225 | Widest point, at `s` = 0.42. Solved for a 0.8 clear gap |
| width at the root | 3.72 | `0.88 * tooth_w_max` |
| width at the tip | 1.35 | `0.32 * tooth_w_max` |
| `tooth_t_root` | 3.0 | Radial thickness at the spine, equal to `shell_t` |
| `tooth_t_tip` | 1.1 | Radial thickness at the free end |
| `corner_r` | 0.6 | Corner radius on the tooth cross-section |

The cross-section is a rounded rectangle. The corner radius shrinks
wherever the section is too small to carry the full 0.6.

The tip ends on a flat face of 1.35 by 1.10. A true point produces a
non-manifold mesh.

The thickness taper never lets the section stand taller than it is wide,
so the tooth reads flat at every station.

### The gap between teeth

Two different numbers describe the spacing, and they are not the same.

**Centre to centre is 5.070**, fixed by 14 teeth on the 70.985 arc.

**The clear gap is the solid-to-solid distance**, and it varies along the
tooth because the tooth swells. `tooth_w_max` is solved so its narrowest
value is 0.8:

| `s` | 0.00 | 0.20 | **0.42** | 0.65 | 0.85 | 1.00 |
|---|---|---|---|---|---|---|
| clear gap | 1.27 | 0.99 | **0.80** | 1.16 | 2.40 | 3.71 |

The clear gap runs about 0.05 under `pitch - width`. Each tooth is a
straight prism sitting on a 5.3705° angular pitch, so two neighbours are
tilted relative to each other and their facing edges converge toward the
inner radius. Compute the gap from the solids, not by subtraction.

At 0.8 a 0.4 nozzle lays two extrusion widths across the narrowest point.
No bridging and no support inside the gap. Going to 0.4 would leave one
extrusion width, where the slicer fuses neighbouring teeth or closes the
gap on the first layer.

### Where the tooth breaks

The tooth does not break at the root. Scanning `sigma(x) = F*x / S(x)`
from the tip puts the peak 4.8 from the tip, where the section has run
down but the lever arm is already 4.8 long.

| Location | Break force at the tip |
|---|---|
| **4.8 from the tip (governs)** | **7.38 N** |
| the root | 8.16 N |

The failure mode is better than it looks. A tooth that fails 4.8 from its
tip loses a 4.8 fragment. The straight-tapered tooth of v002 failed near
mid-span and lost half the tooth.

Unverified: the 55 MPa in-layer figure for printed PLA is a literature
value, not a measurement from this printer.

## 6. Spine

| Name | Value |
|---|---|
| `spine_h` | 5.0 |
| Radial thickness | `shell_t` = 3.0 |
| Angular span | full `span`, 75.187° |
| End cap radius in the arc plane | `end_r` = 1.500 |
| Outer edge | full bullnose, radius `end_r` |

The spine occupies the tooth axis from 0 to 5. The teeth occupy 5 to 40.

The spine builds as a chain of hulls between pucks placed along `R_mid`.
Each puck is a cylinder of `shell_t` capped by a hemisphere at the outer
edge. The chain gives a strip of constant `shell_t`, semicircular end
caps, and one continuous bullnose around the outer edge.

The original rounds that outer edge, and this model rounds it too. No
edge of this part touches the build plate, so nothing here needs a
chamfer.

The teeth start 0.5 below `spine_h`, buried in the spine, so the union is
robust. Below `spine_h` the spine is solid across the whole arc, so
nothing of the tooth needs to exist there.

## 7. Print orientation

**Teeth horizontal, arc in the XZ plane, convex face up.** The comb
arches over the build plate like a bridge. It rests on the bottom of its
two end caps, 69.0 apart. The envelope measures 69.0 by 40.0 by 14.232.

### Why this orientation

The tooth axis lies flat. Bending a tooth in any direction then produces
axial stress along Y, which runs in the layer plane. The layer bond never
carries it, so the tooth fails at bulk strength instead of layer
strength. The same tooth printed upright breaks near 4.0 N.

### Why it needs support

The comb is a cylinder section whose axis runs along the teeth. Lay the
teeth flat and that axis goes horizontal. A cylinder resting on a plate
touches along one line, and its tangent there is horizontal, so the
underside starts at a 90° overhang and never reaches 45° anywhere in a
75° arc. Every orientation that lays the teeth flat needs support under
every tooth. There is no support-free version of this shape.

### Support settings

- **Tree or organic support.** Point contacts, far less scarring than
  grid support across 14 teeth.
- **Support on build plate only: ON.** The whole arch sits above open
  plate, so every support column grows from Z=0.
- **Contact Z distance 0.2**, one interface layer.
- Support touches the concave inner face, which faces the head. The
  convex outer face prints as a top surface and stays clean.
- Do not enable support inside the slots. The slots open upward and carry
  no downward face above them.

### What the audit measures

The audit reports 1551 mm² of faces steeper than 60° and 403 mm² between
45° and 60°. That is the whole underside, and it confirms the paragraph
above.

Bed contact measures 13 mm², the two end caps alone. Everything else
rides on support, so the support carries the print. Confirm the slicer
builds support under both end caps and across the full arch before
starting.

The comb holds 4640 mm³, or 5.8 g in PLA. The arch cavity spans about
22000 mm³, and tree support at 10% fill puts roughly 2200 mm³ under it.

Estimate: the 10% support fill is a rule of thumb, not a slicer figure.
Slice it once to get the real number.

### Cleanup

Support pulls out from below, through the open arch. The slots carry no
support, but check the tooth undersides at the two ends, where the
surface runs closest to vertical and the interface bites hardest.

## 8. Material

PLA for the first prints. The part carries no mating fit, so shrinkage
changes nothing that matters at this size: 69.0 in PLA moves 0.2.

Toughness matters more than strength for a tooth people flex. Tip
deflection before the material yields, for this 35.0 cantilever:

| Build | Yields at |
|---|---|
| PLA, 3.0 root | 4.3 mm |
| PETG, 3.0 root | 6.8 mm |
| PETG, 2.2 root | 9.3 mm |

PLA snaps near 2% strain whatever the orientation. PETG and nylon bend
and come back. If teeth still break after this version, change filament
before changing geometry again.

Unverified: the modulus and yield figures above are literature values,
and the deflection formula assumes a constant thickness while this tooth
tapers.

### Wall width

`shell_t` = 3.0 is not a multiple of the 0.4 line width. Accepted. The
spine and the teeth are solid at this thickness, not walls around infill,
so the slicer has no gap to leave. Arachne variable-width extrusion
covers 3.0 with seven walls of adjusted width. Nothing in this part mates
with anything, so the wall count carries no fit consequence.

## 9. Build volume

The Snapmaker U1 offers 270 by 270 by 270. This part needs 69.0 by 40.0
by 14.232, plus support. It fits.

## 10. Open measurements

Four readings carry doubt. A caliper on the original settles them all.

- **`height` = 40.0.** The tape reads 38.1 at the tooth tips, but the
  comb tilts away from the camera there and the projection shortens.
  Scaling by the comb's own depth gives 44.8 instead. The spec takes
  40.0 between those two figures.
- **The tooth's root width.** The red trace puts it at 88% of the
  maximum; slot tracking in the unannotated photograph puts it at 76%.
  The model uses 88%. At 76% the root drops to 3.21, the clear gap at the
  root opens to 1.78, and the root-limited break force falls to about
  6.3 N.
- **What the 12 mm measures.** This spec reads `rise` as the height of
  the convex outer face above the chord line. The printed part stands
  14.232 tall, because the shell has thickness and each end caps as a
  semicircle on `R_mid`, so the bottom of each end cap drops 2.232 below
  the chord. Stand the model on a table, convex face up, and a ruler
  reads 14.2 at the peak.

  If the 12 mm came from that table reading instead, `rise` drops to
  about 10, the radius grows past 63, and the comb hugs a larger head.
- **`shell_t`.** The original's end cap reads 2.2 to 2.6 in the
  photograph. This model uses 3.0 by choice, not by measurement, to match
  the thickened tooth root.
