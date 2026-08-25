# Switch Plate — Design Specification

All dimensions in mm unless noted. Both parts print without slicer
supports. The cover prints face-up, and carries its own modeled
sacrificial props inside the cavity; they come out before assembly, and
supports must never touch the visible face.

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
  Gravity keeps it wedged. To remove it, grip the cover's sides and
  push it up 5, then lift it off the lugs. The bottom edge carries no
  notch: the cover stands 6 proud of the wall with a beveled edge,
  which is grip enough, and a notch would break that edge line.
  **The right gang carries the coat of arms** as a raised relief: an ash
  tree between a bear rampant (left, toward the toggle) and a fox
  rampant (right), the three figures alone — no shield, no frame, and
  no ground except a small patch of the rock mound kept under the
  bear's front hind foot, where the sculpt hides the foot in the rock.
  The art comes from the `coat-of-arms` skill's height map;
  `emblem = false` drops it for a cheaper fit-test print.

`part = "base" | "cover" | "both"` selects the layout; `"both"` is
~257 mm wide — render one part at a time for smaller beds.

## 2. US device standards honored

| Feature | Standard | Value in model |
|---|---|---|
| Gang-to-gang spacing | 1.812 in | 46.04 (`2*gang_dx`) |
| Toggle-yoke plate screws | 2-3/8 in, 6-32 | 60.32 (`2*yoke_dy`) |
| Box device screws | 3-9/32 in, 6-32 | 83.34 (`2*box_dy`) |
| Toggle bat opening (nominal) | ~10.4 × 24 | cover 11.5 × 25 (with play) |

The 129 × 129 footprint is oversize ("jumbo") relative to a standard
114 × 116 two-gang plate — deliberate, so the cover walls and snap
travel fit outside the device envelope.

## 3. Cover

- Outer shell 5.8 deep (`cov_d`), corner radius 8 (`cov_r`). The depth
  is derived, not chosen: rim-top height + face thickness − back reveal
  (4.0 + 2.0 − 0.2). The walls stand 3.8 tall from the back edge to the
  face's inner surface, and cover all but 0.2 of the base's height.
- The reveal is the only free variable in that stack, and it is worth
  stating why. The face's height above the wall is the base's height
  plus the face thickness; the reveal does not enter it. The walls'
  height is the base's height minus the reveal. So shrinking the reveal
  is the only way to cover more base without standing prouder. Raising
  the rim adds both together, one for one.
- The outer surface slopes inward as it rises, in three segments. It is
  vertical from the back edge to z 2.0 (`bev_z`), at the full 129 × 129
  outline (`cov_w/cov_h`). It then bevels 0.8 in (`bev_wall`) over
  1.8 — 24.0° from vertical — reaching 127.4 square at the face plane.
  It then chamfers 2.0 in (`bev_face`) over 2.0 — 45° — reaching
  123.4 square at the face's outer surface. The eye reads the stack as a ramp, not a
  cliff.
- Three things fix that profile, and none of them are free choices:
  - The bevel starts at z 2.0, the layer above the cleat's retention
    lip top at 1.9. The lip keeps its full 1.6 thickness.
  - The wall bevel stops at 0.8 in, because the base's rim rises to the
    face plane at half-width 60.5. The cavity therefore stays vertical
    at half-width 60.9 for the full depth, and 0.8 (2 lines) is the
    least wall to leave where the bevel meets the face.
  - Above the face plane the material is solid face, so the chamfer
    there takes any angle. 45° matches the countersinks and the cleat
    bevels.
- Face 2.0 thick (`face_t`, 10 layers at 0.2); walls 1.6 at the lip
  (`wall_t`,
  4 perimeters at 0.4). The face is the only thing between the wall and
  the room, so it is as thin as a 125-square PLA panel with a 1.6 wall
  ring and a stiffening rib can be without feeling flexy.
- Toggle opening 11.5 × 25 through the face, left gang center
  (−23.02, 0).
- Coat-of-arms relief on the right gang, from
  `../.claude/skills/coat-of-arms/assets/coat_of_arms_relief.png`
  (`emb_png`, 720 × 413 px, `emb_px`) through `surface()`:
  - **Width 72 (`emb_w`)**, the image edge to edge, centered on the gang
    at (23.02, 0). That is as wide as the gang allows: the image's left
    edge lands at x −13.0, 4.3 clear of the toggle opening's edge at
    −17.3, and its right edge at 59.0, 2.7 short of the face chamfer at
    61.7. The image is 1.743:1, so it stands 41.3 tall (y ±20.6), well
    inside the face. The figures fill the image but for a 0.15 blank
    pad on each side. One pixel is 0.1 mm; the slicer drops
    detail narrower than one line (0.4), which costs the finest leaf
    serrations and nothing else.
  - **Peak 4.0 proud of the face (`emb_h`, 20 layers)**, gray 255 in the
    map. The source plaque carves the peak at 0.162 of its width, which
    is 7.4 at this size; 4.0 keeps the modeling legible at 54 % of that
    depth without standing a finger's width off the wall. Every other
    height scales with it: the bear's flank ~3.2, the tree's crown
    ~1.5–2.0, the bear's far hind leg ~0.3.
  - The height map's background plane sinks 0.05 (`emb_sink`) into the
    face, and its solid underside a further 0.04, so the image's
    rectangle adds nothing outside the figures and the union is clean.
    The z scale is `(emb_h + emb_sink)/100` so the peak lands exactly
    `emb_h` above the face.
  - A height map has no undercuts by construction: every surface faces
    up or is vertical, so it prints face-up unsupported, whatever the
    sculpt's slopes.
- Four bayonet slots through the side walls at y = ±28 (`hook_y`):
  a locked pocket fitting the lug with 0.3 clearance (`slot_clr`) on
  its sides and underside, and its upper end cut parallel to the lug's
  bevel but 0.15 clear of it (`bevel_clr`), so the **rim is the only
  hard stop**. Cutting it on the exact bevel line stops the cover twice
  at once — on the bevel and on the rim — and any printing tolerance
  then decides which wins, leaving the face proud of the rim when the
  bevel wins. With the clearance the cover slides about 0.15 further,
  lands on the rim, and the wedge stays loaded. The slot is also **open at the top straight up to the face's inner surface** — the
  lug top and the rim top are one plane and the face seats on both, so
  no wall is needed over the lug and none is modeled (the face bridges
  the slot). The wall left under the pocket — the retention lip that
  catches the lug's underside if the cover is pulled — is 1.3 tall
  (lug underside 2.4 − 0.3 clearance − 0.8 reveal). A slide corridor 5
  (`trav`) below the pocket, and an entry mouth open past the back edge
  for press-on. Slide travel to seat is 5 plus the bevel clearance.
- Stiffening rib 1.6 wide × 100 long between the gangs, hanging from
  the face's inner surface down to 0.4 clear of the base plate's front
  (1.2 tall). 100 long so it clears the base rim during the raised
  press-on.
- Sacrificial print props (print layout only, not part of the design):
  seven 0.8-thick walls across the cavity at y = 0, ±13.5, ±30, ±46.5
  (`sac_ys`), split 2.3 clear of the stiffening rib and stopping 0.8
  short of the side walls. Two things fix those positions:
  - **±13.5 brackets the toggle opening**, whose short edges sit at
    ±12.5. The face's first layer bridges along y, so those edges and
    the perimeter loop around the hole print over air. At the old ±17
    they hung 4.5 clear of any support and sagged; at ±13.5 they hang
    1.0 clear. The rest of the pitch follows from there, at 16.5 or
    less.
  - **0.8 from the side walls**, not 1.5. Whatever the props do not
    reach becomes bridge lines running the cavity's full 121.8 length
    with nothing under them, and those sag and wander. 0.8 leaves two
    such lines instead of four, and is still two line widths of air, so
    no prop welds to a wall. Reaching the wall outright would weld 14
    prop ends to it, about 40 mm². Each tapers to a 0.4 top (`sac_neck`) — one line width,
  so the slicer prints it as drawn — and stops **0.2 below the face's
  inner surface** (`sac_gap_z`, one layer of air). The prop catches the
  face's sag and never bonds to it. Two rails 1.2 wide × 1.0 tall at
  x = ±26 (`rail_x/rail_t/rail_h`) tie each half's seven walls into one
  comb, so a half lifts out in a single piece.
- The rib's spine is the one prop that must bond. The rib hangs from the
  face and starts 1.2 below it, so the rib's first layer needs an
  anchor. The spine is 0.6 thick and stops 0.4 short of the rib. It
  reaches the rib through teeth 2.0 long on a 10.0 pitch
  (`spine_tooth/spine_pitch`), each necked to 0.4 and fused 0.1 into
  the rib. The rib's first layer bridges the 8.0 gaps between teeth.
  The weld totals 8 mm² instead of 40, and it peels one tooth at a
  time.

## 4. Base

- Outline 125.0 wide × 120.0 tall (`base_w/base_h`), corner radius
  6.4 — the cover's inner outline minus 0.4 lateral clearance (`clr`)
  per side, and 5 (`trav`) shorter at the **bottom** (outline centered
  at y = +2.5) so the raised cover fits over it at entry.
- The base is an open frame, 2.4 thick (`base_t`) everywhere it bears
  on the wall; nothing fills the gangs. Members:
  - **Perimeter band** 4.8 wide (`band_w`, 12 lines) around the outline — the wall
    bearing surface under the rim, and the frame's stiffness.
  - **Spine** 6 wide (`spine_w`) at x = 0, top band to bottom band. Sits
    under the cover's stiffening rib with 0.4 axial clearance.
  - **Four arms** 6.4 wide (`arm_w`, 16 lines) running in x at each
    screw's y (±30.16 left, ±41.67 right), from the side band through
    the screw seat to the spine — a ladder tying both sides to the
    spine, so the rim can't rack.
  - **Right screw pads** d 10.8 (`pad_d`, 27 lines: countersink 7.6 plus
    4 lines of wall each side) on the right arms at the box-screw
    centers. Full thickness, on the bed.
  - **Left screw seats** are d 8.0 bosses (`boss_d`) on the arms at the
    yoke screws. Each boss lies wholly inside the relief (±4.0 in x,
    relief half-width 11), so it stands 1.2 off the wall and clears the
    plaster ears. Only full-thickness material has to avoid the ears,
    which begin ~4.4 past the plate-screw holes (inner end at |y| ≈
    34.6, measured). The boss leaves 1.25 of solid bridge on each side
    of the punch-out's score ring.
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
  each 10 wide (`hook_w`), 1.6 thick (`hook_t` = `rim_h`), protruding
  1.6 (`hook_p`, 4 lines — the tip
  lands 0.4 shy of the cover wall's outer surface, with 1.2 of
  engagement inside the wall), underside coplanar with the plate
  front at z = 2.4 (`hook_z` = `base_t`), 1.6 thick (`hook_t`) so its
  top is coplanar with the rim top, with the top (+y) wall sloping
  outward at 45° (rising `hook_t` over its depth) — the cleat bevel.
  Mirrored, not rotated, on the −x side so both bevels rise in +y (one
  slide direction).
- Four screw holes d 3.9 (`screw_d` — 6-32 free fit with allowance for
  printed-hole shrinkage), 45° countersunk (prints support-free):
  - box pair at (+23.02, ±41.67): d 7.6 × 1.85 deep (`cs_d/cs_depth`),
    head flush;
  - yoke pair at (−23.02, ±30.16): d 5.6 × 0.85 deep (`cs_d_l`, 14
    lines), leaving 3 whole lines of boss around it. The 7.1 flat head
    sits 0.75 proud of the boss, top at z 3.15, still 0.85 under the
    cover face at 4.0.
- The **bottom** yoke hole is closed at the back by a **0.2 sacrificial membrane**
  (`memb_t`, one layer at z 1.2–1.4), so the relief bridge prints as one
  anchored sheet. A **score ring** 0.8 wide (`score_w`, 2 line widths)
  cut through that one layer separates the membrane into a punch-out
  disc d 3.9, held by three 0.4 tabs (`tab_w`, one line, at 90/210/330°).
  The ring
  makes the disc a separate island: the slicer closes a perimeter around
  it and changes direction, instead of running bridge lines straight
  from the sheet through the disc. The disc then shears at the tabs
  (3 × 0.4 × 0.2 = 0.24 mm², about 12 N in PLA) instead of tearing the
  sheet. Push both discs out from the back before mounting. The disc
  matches the hole diameter, so it passes out through the front. The
  top yoke hole has no membrane and no ring: its arm is solid, so the
  hole runs straight through with nothing to bridge.
- Back relief, **bottom-left arm only**, 1.2 deep (`relief_d`). The
  pocket runs from the left band's inner edge at x = −57.7
  (`relief_x1`) to x = −12.02 (`relief_x2`), and 8.8 across
  (`relief_arm_w`) — wider than the arm and its boss, so that whole
  length of arm thins to 1.2. It clears the measured 17.1 strap and
  everything else proud of the wall out to the band. That arm bears on
  the yoke through its screw, not on the wall.
- The **top-left arm has no relief**. The strap is flush with the wall
  there, so the arm stays solid 2.4 across its full length and bears on
  both. This is the frame's one rigid seat on the switch side.
- Sacrificial props under the four cleat lugs (print layout only): a
  free-standing block per lug, 1.5 wide × 9.6 × 2.2 tall (`lp_clr`,
  `lp_gap`). Each stands on the bed under its lug, 0.4 clear of the
  band's outer face so it never fuses sideways, and stops 0.2 below the
  lug's underside so it never fuses upward. Nothing else can hold that
  underside up: the cover's retention lip slides into exactly that
  space, so a permanent gusset there breaks the cleat. Lift the four
  blocks away after printing.
- Sacrificial props under the bottom-left pocket (print layout only,
  not part of the design): five fins 0.8 thick across the pocket at
  x = −47.5, −39, −30.5, −26.5, −19.5 (`bp_xs`), each necked to 0.4 and
  stopping 0.2 below the pocket's ceiling (`bp_gap`), tied by a rail
  0.8 × 0.6 (`bp_rail_h`) on the bed. They cut the 43.5 span into
  bridges of 8.5 or less, and two of them bracket the score ring. Push
  the comb out of the open pocket after printing.

## 5. Assembly stack (z from the wall)

- Base back on the wall at z = 0; plate front at 2.4; rim top at 4.0.
- Lugs span z = 2.4–4.0, tops coplanar with the rim top.
- Cover back edge at z = 0.2 (`cov_back_z`) — one layer of reveal, so
  the wall surface is never the stop; retention lip 0.2–2.1; face inner
  **seats on the rim top and lug tops at 4.0** (no axial gap — the cleat
  wedge closes it); face outer at 6.0; relief peak at 10.0, the plate's
  highest point.
- The cleat stack sets the face height: reveal 0.2 + lip 1.9 +
  clearance 0.3 + lug 1.6 = 4.0. Shrinking the reveal moves that height
  into the lip, which is why the lip is 1.9 and not 1.3.
- Verified by boolean check: base ∩ assembled cover = zero volume at
  the seated position (tangent contact at the rim seat), at that
  position slid 0.15 further along the bevel clearance, and at the +5
  entry position.

## 6. Printability requirements

- **Cover prints face-up, slicer supports OFF**: walls and props on the
  bed, face on top. The face bridges the ≤17 spans between
  the sacrificial props (hidden interior surface — sag is cosmetic
  only); lift the two prop combs out through the open back, then peel
  the rib spine off tooth by tooth, before assembly. Use
  a brim — bed contact is the 1.6 wall ring plus the prop feet. The
  visible face prints as clean top layers, and the relief on top of it is
  a height field — upward-facing or vertical everywhere — so it needs no
  support in this direction either.
- **Base prints back-down, support-free**; its downward faces are the
  45° countersinks, the bottom-left arm's 1.2-thick relief ceiling —
  43.5 long, broken into bridges of 8.5 or less by the fins, with the
  hole closed by its membrane — and the
  lug undersides — 1.9-deep flat cantilevers (at the plate-front level)
  that print onto their sacrificial blocks. Without a block the lug's
  first layer extrudes into open air across its full 1.9 depth, curls,
  and leaves an uneven underside — which is the surface the cover's lip
  catches on a 0.3 clearance.
- **Use a brim on the base too**, not only on the cover. Its 4001 mm² of
  bed contact is spread over narrow members — a 4.8 band, 6.4 arms — and
  nothing wide holds their ends down.
- One manifold solid per part; no console warnings.
- **Every material thickness is a whole multiple of the 0.4 line width
  (`lw`), and every z feature a whole multiple of the 0.2 layer height
  (`lh`).** Both are named parameters, and the thicknesses are written
  as multiples of them, so a nozzle change re-derives the part. The
  slicer then never has to fill a leftover narrower than one line, which
  is what it does with ragged variable-width beads. Clearances keep
  their own values — `clr` 0.4, `slot_clr` 0.3, `lp_clr` 0.4 — because
  they are air, not extrusions.
- Quantizing widths cannot fix a tangency: where a round screw seat runs
  into a straight arm, the gap between them narrows continuously to
  zero, and no choice of diameter changes that. So the frame's plan gets
  a morphological close — dilate by 1.2 (`fillet`, 3 lines), then erode
  by the same — which fillets every inside corner to 1.2 and fills those
  wedges. It adds 7.2 mm² (0.2%) and leaves every convex outline, seat
  diameter, and hole unchanged.
- Countersinks and cleat bevels are 45° — self-supporting. In the
  face-up cover print the slots are open-topped notches in the wall
  that the face's first layer bridges (≤15.6 span, 1.6 wide).
- The cover's outer surface only moves inward as z rises, so it prints
  face-up with no overhang anywhere on the visible edge.
- Slice the base with **bridge infill direction = 180** (Orca reads 0
  as "auto" and 180 as 0° — i.e. along x, along the arms) and **thick
  external bridges on**; auto direction chose 45° on the old plate and
  doubled the span. Thick *internal* bridges is irrelevant here (no
  bridging over infill).
- $fa = 2, $fs = 0.4.
