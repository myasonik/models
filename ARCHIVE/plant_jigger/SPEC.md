# Plant Jigger — Design Specification

All dimensions in mm. The finished model must sit with the bell rim on Z=0
and print in that orientation without supports.

## 1. What it is

A goblet-shaped jigger, one printable solid, three stacked bodies:

- **Small cup** (top): a hollow dome that forms a shallow **cup** with a side leading to a **pour spout**.
- **Neck** (middle): a solid column joining the two cups.
- **Large cup** (bottom): a tall open-topped reservoir, like the cup of a goblet.

## 2. Body dimensions

Coordinates below use the bell's sphere center as origin; the whole model is
then translated up by `skirt_h` so the rim lands on Z=0.

### Small cup
- Outer radius 20, upper hemisphere only; 2 mm wall below the roof blend.
- Straight cylindrical skirt below the dome equator: height 3, same radii.
- **Interior**: spherical (radius 18) up to latitude asin(0.475687) ≈ 28.40°,
  then a 45° conical roof to an apex that tunnels ~9.4 mm up into the solid
  neck (leaving ≥2.6 mm between the two cups' interiors, ≥2.9 mm around the
  cone inside the neck). The interior must never be flatter than 45°, so the
  cup prints rim-down with no internal supports.
- **Capacity: 15.27 ml** (cavity below the rim plane, skirt band included).
  The blend latitude is the root of 2s³ + 6s² + 3s − 3 = 0, which makes the
  cone hold exactly the volume of the spherical cap it replaces — changing
  the roof shape must not change the capacity.

### Neck
- Column, radius 10, spanning z 15..30; each end shaped by (seated against)
  the mating sphere, sunk 0.3 mm into each shell so the union is robust
  (tangent surfaces make non-manifold meshes).

### Large cup
- Outer radius 20, inner radius 18 (2 mm wall).
- Spherical bottom dome centered at z 45; cylindrical barrel from there to
  the open top at z 93. Cavity matches (r 18), open at the top.

## 3. Pour spout (functional requirement)

A **pitcher lip**: the rim itself flares outward into a soft point, like a
pulled ceramic creamer — not a separate trough attached to the wall. The
lip is one continuous surface with the bowl in every view.

- **Plan silhouette**: the bowl circle bulging smoothly into a rounded
  point on the −Y side (a teardrop) — tangent blends, no corners. Tip
  radius 4.3 outer / 3.5 inner.
- **Reach**: lip tip extends 5–6 mm beyond the outer wall.
- **Elevation**: the flare occupies the top ~8 mm of the small cup (in use
  frame). It leaves the rim at a ~60° pour angle (from vertical) — the
  steepest that still prints cleanly rim-down — and eases back until it
  merges **tangent** into the dome: zero slope at the merge, no crest, no
  shoulder, no flat run. The ease must have a **finite** slope at the rim;
  an infinite-slope kick makes the first print layers unsupported.
- **Pour edge**: lies exactly in the rim plane. Channel width 7 at the
  lip; walls thin to **0.8 mm at the pour edge** (thin, sharp lips force
  flow separation; thick or rounded lips dribble) and thicken toward the
  merge, where the channel fades into the bowl interior.
- **Open channel**: the lip interior is open across the rim plane its full
  length, so residue drains back into the cup when the jigger is set down.
- Thin-lip / sharp-edge choices remain grounded in drip-free ("teapot
  effect") pour research.

## 4. Printability requirements

- One manifold solid (CGAL "Simple: yes"); overlap all unions ≥0.3 mm —
  never tangent.
- Prints upright with no supports: flat footprint, no feature tapering to a
  zero-width tip, no interior surface flatter than 45° (the cup roof cone
  exists for this reason).
- $fa = 2, $fs = 0.4 or finer.

## 5. Slicing (Snapmaker U1, 0.4 nozzle)

The lip leaves the rim at ~60° from vertical — printable, but not at draft
layer heights: at 0.32 mm each layer steps 0.32·tan 60° ≈ 0.55 mm outward,
more than one line width, so the lip's first perimeters print in air.

- **Layer height ≤0.16 mm over the bottom 8 mm** (the whole lip flare).
  Variable layer height is ideal — the rest of the goblet can stay coarse.
  0.16 mm → ~30% perimeter overlap at 60°; 0.12 mm → ~50%.
- Full fan + overhang slowdown on overhangs; keep the outer wall well under
  the 220 mm/s draft speed on the first few millimetres.
- No supports anywhere — if the slicer asks for them, the model is wrong.
- Before a full print, slice only the bottom ~12 mm: it contains the entire
  lip and the start of the dome, and validates the pour edge in minutes.