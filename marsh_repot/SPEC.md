# Marsh Repot — Spec

## Purpose
A two-part planter liner (pot + pull-out drip tray) for the marsh plant,
printed on the Snapmaker U1. The pot holds soil and drains through floor
holes into a removable tray that slides out through a slot in the back wall
for emptying, without lifting the pot off its perch/shelf.

## Requirements
- Outer footprint: 163.2 x 95.2mm at the base, tapering to 185.5 x 117.5mm
  at the rim; height 127.44mm; 5deg draft on all four walls.
- Wall thickness: 3.2mm on the two side walls; 4.8mm on the two end walls
  (back/front) — thickened relative to the sides because of the print
  orientation (see Design decisions).
- Drainage: 5 hexagonal holes through the floor (~45mm² each), positioned
  per horticultural guidance, and must stay within the tray's basin
  footprint when the tray is seated.
- Drip tray: pull-out basin (~60mL capacity) that slides out through a slot
  in the back wall. Retained by a detent (bump-and-pocket click) so it
  doesn't slide out under vibration, releases with a finger pull. The
  finger-pull recess in the tray's face plate is reachable from underneath
  the assembled pot.
- Fits the Snapmaker U1's 270 x 270 x 270mm build volume in its print
  orientation (well within — ~185mm tall as printed).
- Print orientation: the pot prints lying on its back (+X, drawer) wall,
  tipped 85deg (90 minus the 5deg draft) about Y, so that wall lies flat on
  the bed. This is load-bearing for the design (see Design decisions), not
  a free choice to revisit per-print.
- The tray prints flat on the bed, basin up, as modelled.
- No supports required for either part.
- Material: PLA (iteration and current production prints).

## Design decisions
- **Print orientation is fixed by the floor, not just the slot.** Printed
  upright, the pot's floor would have to bridge the entire drawer-bay
  cavity beneath it — a cavity open only through the 70 x 9.5mm slot, so
  any support material dropped in there would be unreachable to remove.
  Printed lying on its back wall, both the floor and the slot's roof go
  from Z-normal (would bridge) to near-X-normal (self-supporting) at the
  same time. No partial-tip alternative (e.g. printing on an edge at
  ~45deg) helps: the floor/slot want the rotation to approach 90deg while
  the end walls want it to approach 0deg, so any single rotation trades one
  against the other — and the floor's failure mode (an unreachable,
  unremovable support column) is worse than the end walls' (reduced
  strength, which can be designed around independently).
- **End walls are the structurally weak faces.** Because the print lies
  almost flat on the back wall, both end walls (back and front) print with
  their full wall cross-section stacked flat, layer on layer, so their
  strength is pure interlayer bond with no in-plane fiber to help.
  Mitigated two ways: extra wall thickness on just those two walls
  (`end_wall` = 4.8mm vs. `wall` = 3.2mm on the sides), and vertical
  internal ribs on their inside faces. A rib's two large faces are
  Y-normal, which stays vertical regardless of the print's X-axis tip, so
  each rib prints in the normal strong ring-stacked orientation and acts as
  a bonded stiffener the wall can't provide for itself.
- **Corners use a chamfer + G2 curvature blend**, not a circular fillet —
  tangent- and curvature-continuous transitions (raised-cosine curvature
  profile) so there's no "step" a fingertip or a layer-stair density change
  can find, unlike the plain arc fillets used before v024. The base
  (skirt) corner's chamfer and blend length are sized together
  (`ch_bot`/`blend_l`) so the blend keeps pace with the chamfer and the
  corner stays close to fully rounded rather than regrowing a flat facet
  — the base corner also shares the back wall's flat Y-span with the
  drawer slot, capping `ch_bot` at roughly 9.4mm before the slot-width
  assert fails.
- **Drainage holes are hexagonal, pointed along pot-X** so their points
  face print-vertical in the sideways print orientation, avoiding overhangs
  on the hole walls.
- **Retention detent** (bump-and-pocket) rather than a reverse-inclined
  channel, to avoid costing basin depth or tilting the whole slot geometry.
