# Switch Plate — Design Specification

All dimensions in mm unless noted. Both parts print without slicer
supports. The cover — which cannot print face-down because of the
raised emblem — carries its own modeled sacrificial props inside the
cavity; they snap out before assembly, and supports must never touch
the visible face or emblem.

## 1. What it is

A screwless two-gang US wall plate in two printed parts:

- **Base** — screws to the wall hardware and is never seen. Left gang
  screws to a toggle switch's yoke (6-32); right gang (blank) screws to
  the box's device holes. A perimeter rim carries four french-cleat
  hook lugs.
- **Cover** — a slide-on shell with no visible fasteners. To install:
  hold it 5 above final position, press flat to the wall (the lugs pass
  through bayonet slots in the side walls), slide down 5. Each lug's
  45° outward-sloping top wall wedges the cover toward the wall as it
  slides — french-cleat action — until the face seats on the rim.
  Gravity keeps it wedged; a thumb notch on the bottom edge helps slide
  it back up to remove. The blank right gang carries a raised 3D emblem.
  **The current emblem is a placeholder** (roundel + star + dome) that
  exists to validate the supported print process; the final artwork — a
  3D relief of the coat of arms (ash tree between a bear rampant and a
  fox rampant, whose 2D art is kept in the source) — will replace it
  without changing the process.

`part = "base" | "cover" | "both"` selects the layout; `"both"` is
~257 mm wide — render one part at a time for smaller beds.

## 2. US device standards honored

| Feature | Standard | Value in model |
|---|---|---|
| Gang-to-gang spacing | 1.812 in | 46.04 (`2*gang_dx`) |
| Toggle-yoke plate screws | 2-3/8 in, 6-32 | 60.32 (`2*yoke_dy`) |
| Box device screws | 3-9/32 in, 6-32 | 83.34 (`2*box_dy`) |
| Toggle bat opening (nominal) | ~10.4 × 24 | cover 11.5 × 25 (with play) |

The 125 × 125 footprint is oversize ("jumbo") relative to a standard
114 × 116 two-gang plate — deliberate, so the cover walls and snap
travel fit outside the device envelope.

## 3. Cover

- Outer shell 125 × 125 × 8 deep (`cov_w/cov_h/cov_d`), corner radius 8.
- Face 2.4 thick (`face_t`); walls 1.6 (`wall_t`, 4 perimeters at 0.4).
- Toggle opening 11.5 × 25 through the face, left gang center
  (−23.02, 0).
- Raised emblem on the face, right gang center, 5.9 proud (`emb_h`),
  placeholder geometry: roundel plateau d 40 × 1.2, five-point star
  r 16 extruded 2.2 with a 55% taper, center dome r 5 squashed to
  2.5 tall.
- Four bayonet slots through the side walls at y = ±28 (`hook_y`):
  a locked pocket fitting the lug with 0.3 clearance (`slot_clr`) on
  its sides and bottom but cut on the **exact** lug bevel line on top,
  so the cleat bottoms out just as the face meets the rim; a slide
  corridor 5 (`trav`) below the pocket; and an entry mouth open past
  the back edge for press-on.
- Thumb notch 12 wide × 3 tall on the bottom edge (slide-up grip).
- Stiffening rib 1.6 × 110 between the gangs, from the face's inner
  surface down to z = `win_z` − 0.8 (local frame).
- Sacrificial print props (print layout only, not part of the design):
  seven 0.8-thick walls across the cavity on a ≤17 pitch (`sac_ys`),
  split 2.3 clear of the stiffening rib and stopping 1.5 short of the
  side walls, plus a 0.6-thick spine under the rib. Each necks to a
  0.3 knife-edge fused 0.1 into the surface it props, so it snaps out
  through the open back after printing.

## 4. Base

- Plate 121.0 wide × 116.0 tall × 2.4 (`base_w/base_h/base_t`), corner
  radius 6.4 — the cover's inner outline minus 0.4 lateral clearance
  (`clr`) per side, and 5 (`trav`) shorter at the **bottom** (outline
  centered at y = +2.5) so the raised cover fits over it at entry.
- Perimeter rim 1.6 wide (`rim_t`) × 4 tall (`rim_h`) on the front face.
- Four cleat hook lugs on the rim's outer faces at y = ±28 (`hook_y`):
  each 10 wide (`hook_w`), protruding 1.9 (`hook_p`, ending 0.1 shy of
  the cover wall's outer surface), underside at z = 3.0 (`hook_z`),
  2.4 thick (`hook_t`) with the top wall sloping outward at 45° (rising
  `hook_t` over its depth) — the cleat bevel. Mirrored, not rotated, on
  the −x side so both bevels rise in +y (one slide direction).
- Toggle pass-through 14 × 28 (`base_tog_w/h`), left gang — oversize so
  the bushing and bat clear.
- Four screw holes d 3.9 (`screw_d` — 6-32 free fit with allowance for
  printed-hole shrinkage), countersunk to d 7.5 × 1.8 deep (45° cone,
  prints support-free): yoke pair at (−23.02, ±30.16), box pair at
  (+23.02, ±41.67).
- Back relief pocket 26 × 92 × 1.2 deep (`relief_d`) behind the left
  gang, long enough (y ±46) that the switch yoke, its plaster ears, and
  its box-mounting screw heads at y ±41.7 all sit inside it instead of
  rocking the plate.

## 5. Assembly stack (z from the wall)

- Base back on the wall at z = 0; plate front at 2.4; rim top at 6.4.
- Lugs span z = 3.0–5.4 (plus the 45° bevel rising across that depth).
- Cover back edge at z = 0.8 (`cov_back_z`) — a slim perimeter reveal;
  face inner **seats on the rim top at 6.4** (no axial gap — the cleat
  wedge closes it); face outer at 8.8; emblem tip at 14.7.
- Verified by boolean check: base ∩ assembled cover = zero volume
  (tangent contact only, at the rim seat and along the lug bevels);
  same at the +5 entry position.

## 6. Printability requirements

- **Cover prints face-up, slicer supports OFF**: walls and props on the
  bed, face and emblem on top. The face bridges the ≤17 spans between
  the sacrificial props (hidden interior surface — sag is cosmetic
  only); snap the props out through the open back before assembly. Use
  a brim — bed contact is the 1.6 wall ring plus the prop feet. The
  visible face prints as clean top layers; the emblem must stay
  self-supporting in this direction (≤45° overhangs on an upward-facing
  relief — the placeholder's vertical roundel edge, inward-tapering
  star, and dome all qualify).
- **Base prints back-down, support-free**; its downward faces are the
  45° countersinks, the hidden 1.2-deep relief pocket bridge, and the
  lug undersides — 1.9-deep flat cantilevers that print with minor
  droop, acceptable because the lugs' working faces are their top
  bevels and vertical sides.
- One manifold solid per part; no console warnings.
- All wall-forming thicknesses are multiples of the 0.4 line width
  (1.6, 2.4).
- Countersinks and cleat bevels are 45° — self-supporting; in the
  face-up cover print the slot pockets' beveled tops are 45° rooflines.
- $fa = 2, $fs = 0.4.
