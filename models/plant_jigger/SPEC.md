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
- Outer radius 20, inner radius 18 (2 mm wall), upper hemisphere only.
- Straight cylindrical skirt below the dome equator: height 3, same radii.
- Arched doorway on the −Y side (see §3).

### Neck
- Column, radius 10, spanning z 15..30; each end shaped by (seated against)
  the mating sphere, sunk 0.3 mm into each shell so the union is robust
  (tangent surfaces make non-manifold meshes).

### Large cup
- Outer radius 20, inner radius 18 (2 mm wall).
- Spherical bottom dome centered at z 45; cylindrical barrel from there to
  the open top at z 93. Cavity matches (r 18), open at the top.

## 3. Pour spout (functional requirement)

Grounded in drip-free / "teapot effect" pour research:

- **Open trough.** The spout is an open-topped U-channel its entire length.
- **Radial**: points straight out along −Y, perpendicular to the body axis —
  the geometric discontinuity forces the stream to detach cleanly.
- **Reach**: lip extends 5–6 mm beyond the outer wall 
- **Lip**: channel width 7 at the lip (tip radius 3.5, research says < 4);
  walls and floor taper from 2 mm at the root to **0.8 mm at the lip** — a
  thin, sharp lip forces flow separation; thick or rounded lips dribble.
- **Rising floor**: the channel floor climbs monotonically from sill height
  to ~1.6 mm above it at the lip, so residue drains back into the small cup when
  the jigger is set down. No dips that trap water.
- **45° undercut** below the lip for a sharp lower pour edge (also keeps the
  overhang printable). Underside otherwise flat on the bed.
- **Wall crest**: side walls emerge from the dome low (~1.7 mm above bell
  center height) — below the arch shoulder — and fall gently to ~1.5 mm at
  the lip. Use a rounded-rectangle outer profile at the tip so the side
  walls hold 0.8 mm thickness down to the floor (a semicircular crest
  pinches to ~0.1 mm).

## 4. Printability requirements

- One manifold solid (CGAL "Simple: yes"); overlap all unions ≥0.3 mm —
  never tangent.
- Prints upright with no supports: flat footprint, no feature tapering to a
  zero-width tip
- $fa = 2, $fs = 0.4 or finer.