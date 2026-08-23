# Switch Plate — Design Specification

All dimensions in mm unless noted. Both parts print without slicer
supports. The cover — which cannot print face-down because of the
raised emblem — carries its own modeled sacrificial props inside the
cavity; they snap out before assembly, and supports must never touch
the visible face or emblem.

## 1. What it is

A screwless two-gang US wall plate in two printed parts:

- **Base** — screws to the wall hardware and is never seen, so it is
  a bare frame, not a plate: only the rim, the screw seats, and the
  members that hold them rigid and flat on the wall. Left gang screws
  to a toggle switch's yoke (6-32); right gang (blank) screws to the
  box's device holes. A perimeter rim carries four french-cleat hook
  lugs.
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

- Outer shell 125 × 125 × 5.2 deep (`cov_w/cov_h/cov_d`), corner
  radius 8. The depth is derived, not chosen: rim-top height + face
  thickness − back reveal (4.0 + 2.0 − 0.8).
- Face 2.0 thick (`face_t`, 10 layers at 0.2); walls 1.6 (`wall_t`,
  4 perimeters at 0.4). The face is the only thing between the wall and
  the room, so it is as thin as a 125-square PLA panel with a 1.6 wall
  ring and a stiffening rib can be without feeling flexy.
- Toggle opening 11.5 × 25 through the face, left gang center
  (−23.02, 0).
- Raised emblem on the face, right gang center, 5.9 proud (`emb_h`),
  placeholder geometry: roundel plateau d 40 × 1.2, five-point star
  r 16 extruded 2.2 with a 55% taper, center dome r 5 squashed to
  2.5 tall.
- Four bayonet slots through the side walls at y = ±28 (`hook_y`):
  a locked pocket fitting the lug with 0.3 clearance (`slot_clr`) on
  its sides and underside, cut on the **exact** lug bevel line at its
  upper end so the cleat bottoms out just as the face meets the rim,
  and **open at the top straight up to the face's inner surface** — the
  lug top and the rim top are one plane and the face seats on both, so
  no wall is needed over the lug and none is modeled (the face bridges
  the slot). The wall left under the pocket — the retention lip that
  catches the lug's underside if the cover is pulled — is 1.3 tall
  (lug underside 2.4 − 0.3 clearance − 0.8 reveal). A slide corridor 5
  (`trav`) below the pocket, and an entry mouth open past the back edge
  for press-on.
- Thumb notch 12 wide × 3 tall on the bottom edge (slide-up grip).
- Stiffening rib 1.6 wide × 100 long between the gangs, hanging from
  the face's inner surface down to 0.4 clear of the base plate's front
  (1.2 tall). 100 long so it clears the base rim during the raised
  press-on.
- Sacrificial print props (print layout only, not part of the design):
  seven 0.8-thick walls across the cavity on a ≤17 pitch (`sac_ys`),
  split 2.3 clear of the stiffening rib and stopping 1.5 short of the
  side walls, plus a 0.6-thick spine under the rib. Each necks to a
  0.3 knife-edge fused 0.1 into the surface it props, so it snaps out
  through the open back after printing.

## 4. Base

- Outline 121.0 wide × 116.0 tall (`base_w/base_h`), corner radius
  6.4 — the cover's inner outline minus 0.4 lateral clearance (`clr`)
  per side, and 5 (`trav`) shorter at the **bottom** (outline centered
  at y = +2.5) so the raised cover fits over it at entry.
- The base is an open frame, 2.4 thick (`base_t`) everywhere it bears
  on the wall; nothing fills the gangs. Members:
  - **Perimeter band** 5 wide (`band_w`) around the outline — the wall
    bearing surface under the rim, and the frame's stiffness.
  - **Spine** 6 wide (`spine_w`) at x = 0, top band to bottom band. Sits
    under the cover's stiffening rib with 0.4 axial clearance.
  - **Four arms** 6.4 wide (`arm_w`, 16 lines) running in x at each
    screw's y (±30.16 left, ±41.67 right), from the side band through
    the screw seat to the spine — a ladder tying both sides to the
    spine, so the rim can't rack.
  - **Right screw pads** d 10.5 (`pad_d`, countersink 7.5 + 1.5 wall) on
    the right arms at the box-screw centers. Full thickness, on the bed.
  - **Left screw seats are the arms themselves** — no pad. The yoke's
    plaster ears begin ~4.4 above/below the plate-screw holes (ear inner
    end at |y| ≈ 34.6, measured), at the same proud height as the strap
    but possibly wider than the relief; a wider seat would land its
    full-thickness part on an ear corner and rock the frame. A 6.4 arm
    reaches |y| = 33.36, 1.25 clear of the ears.
  Everything a real plate would have done — hiding the box, supporting
  the face — the cover does; the frame only has to hold four screws and
  a rim in plane. The toggle needs no pass-through: the left gang is
  open.
- Perimeter rim 1.6 wide (`rim_t`) × 1.6 tall (`rim_h`) on the band's
  outer edge. The rim is exactly as tall as the lugs — it exists to
  locate the cover laterally, seat the face, and carry the lugs, and
  nothing in the cavity needs more height (countersunk heads sit
  ~flush).
- Four cleat hook lugs on the rim's outer faces at y = ±28 (`hook_y`):
  each 10 wide (`hook_w`), protruding 1.9 (`hook_p`, ending 0.1 shy of
  the cover wall's outer surface), underside coplanar with the plate
  front at z = 2.4 (`hook_z` = `base_t`), 1.6 thick (`hook_t`) so its
  top is coplanar with the rim top, with the top (+y) wall sloping
  outward at 45° (rising `hook_t` over its depth) — the cleat bevel.
  Mirrored, not rotated, on the −x side so both bevels rise in +y (one
  slide direction).
- Four screw holes d 3.9 (`screw_d` — 6-32 free fit with allowance for
  printed-hole shrinkage), 45° countersunk (prints support-free):
  - box pair at (+23.02, ±41.67): d 7.5 × 1.8 deep (`cs_d/cs_depth`),
    head flush;
  - yoke pair at (−23.02, ±30.16): d 5.8 × 0.95 deep (`cs_d_l`) — as
    much cone as a 6.4 arm can hold with a 0.3 wall at the top edge.
    The 7.1 flat head sits ~0.6 proud of the arm, top at ≈ z 3.0, 1.0
    under the cover face; it bears on the cone from d 3.9 to 5.8, all
    within the arm. Each yoke hole is closed at the back by a **0.2
    sacrificial membrane** (`memb_t`, one layer at z 1.2–1.4) so the
    relief bridge prints as one continuous anchored sheet — poke both
    out from the back before mounting.
- Back relief 22 wide × 92 × 1.2 deep (`relief_w/relief_d`) behind the
  left gang: the only members inside it — the middle 22 of each left
  arm — are set 1.2 off the wall. Width is the measured 17.1 strap
  plus 2.45 margin per side (the arms screw to the strap, so the relief
  is self-centred on it); depth suits a strap sitting on the wall
  surface. The left arms bear on the yoke through the screws, not on
  the wall. Nothing else crosses the yoke, its ears, or the box-screw
  heads at y ±41.7.

## 5. Assembly stack (z from the wall)

- Base back on the wall at z = 0; plate front at 2.4; rim top at 4.0.
- Lugs span z = 2.4–4.0, tops coplanar with the rim top.
- Cover back edge at z = 0.8 (`cov_back_z`) — a slim perimeter reveal;
  retention lip 0.8–2.1; face inner **seats on the rim top and lug tops
  at 4.0** (no axial gap — the cleat wedge closes it); face outer at
  6.0; emblem tip at 11.9.
- The only thing setting the face height is the cleat stack: reveal
  0.8 + lip 1.3 + clearance 0.3 + lug 1.6 = 4.0. Thinning the face or
  base below that buys nothing; going lower means a thinner lug and lip.
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
  45° countersinks, the left arms' 1.2-thick relief bridges — two
  straight 6.4 × 22 bridges, every line anchored on the relief wall at
  both ends, the hole closed by the membrane — and the
  lug undersides — 1.9-deep flat cantilevers (at the plate-front level)
  that print with minor droop, acceptable because the lugs' working
  faces are their end bevels, tops, and vertical sides.
- One manifold solid per part; no console warnings.
- All wall-forming thicknesses are multiples of the 0.4 line width
  (1.6, 2.0, 2.4).
- Countersinks and cleat bevels are 45° — self-supporting. In the
  face-up cover print the slots are open-topped notches in the wall
  that the face's first layer bridges (≤15.6 span, 1.6 wide).
- Slice the base with **bridge infill direction = 180** (Orca reads 0
  as "auto" and 180 as 0° — i.e. along x, along the arms) and **thick
  external bridges on**; auto direction chose 45° on the old plate and
  doubled the span. Thick *internal* bridges is irrelevant here (no
  bridging over infill).
- $fa = 2, $fs = 0.4.
