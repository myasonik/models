# Marsh Repot — History

## v035
Finger-pull recess enlarged (user, from a print: opening too narrow to
get a finger in; some depth still available; wants a more positive
catch). Three params, each checked against the assert it shares before
moving:

- **POCKET_W** 40 -> 48mm: wider mouth. The pot's sill notch is required
  to stay `>= pocket_w + 2` (assert), so `notch_w` follows: 44 -> 52mm
  (still 10mm under its own `slot_w - 8` ceiling). Pocket half-width now
  23.2mm inside a 34.5mm-half-width face plate — 11.3mm of material left
  on each side, unchanged margin logic from before.
- **POCKET_D** 7.2 -> 8.4mm: deeper. This one had almost no headroom — the
  web-thickness assert (`face_t - face_setback + sill_h*tan(draft) -
  pocket_d >= 1.6`) was passing with only 0.16mm to spare at the old
  values. `face_t` grows to match (9.0 -> 10.4mm) purely to restore margin
  (0.36mm) for the deeper cut; it doesn't change the plate's visible outer
  face (that's fixed by the `face_x0` draft-plane trim, independent of
  `face_t` — `face_t` only sets how much raw stock exists behind the
  recess before the trim).
- **HOOK_D** 2.0 -> 3.0mm: taller lip. `pocket_z1` (the hook shelf itself)
  is already at its own ceiling (`face_h - 3`, an equality already at
  v024), so it can't grow without growing `face_h`, which is set by the
  pot's `slot_open` — a bigger cross-part change than asked for. `hook_d`
  — the undercut's own depth, i.e. how far the lip actually overhangs for
  a fingertip to hook under — had plenty of headroom once `pocket_d`
  grew (limit is `hook_d < pocket_d - 1.6` = 6.8mm), so that's the lever
  pulled instead. Verified: 3.0 + 1.6 < 8.4.

## v034
Skirt corner softened (user: brim peel chips a corner on the bed-contact
wall). Measured the existing G2 blend rather than guessing: at
`ch_bot=5`/`blend_l=8` the blend already consumed ~95% of the chamfer edge
(only ~0.35mm flat remained total) — the base corner was already close to
a true curve, just a small one. Softening it further means growing the
radius, not adding more curve to the same size: `ch_bot` 5 -> 8,
`blend_l` 8 -> 10 together (`blend_l` has to move with `ch_bot` or the
blend falls behind and leaves *more* flat facet, not less — verified:
`ch_bot`=8 with `blend_l` left at 8 leaves ~3mm flat). Result: corner
reach 7.07 -> 11.31mm, flat facet remaining ~0.97mm total, spreading the
curvature (and so the brim-peel stress) over a longer, gentler arc.
`ch_bot`=8 leaves 1.4mm of margin on the `slot_w`/`ch_bot` assert (the
hard ceiling is ~9.4mm — the slot and the base corner share the back
wall's flat span). `blend_l` is shared with the rim chamfer (`ch_top`),
so the rim corner also gets a little smoother as a side effect — harmless,
not the target of this change.

## v033
End-wall reinforcement (user: back wall on the printer flexes more than
the others, and the opposite wall too — both print with their 3.2mm
cross-section stacked flat, layer on layer, so their strength is pure
interlayer bond with no in-plane fiber to help).

- **END_WALL**: back/front wall thickness split out from the shared `wall`
  (still 3.2mm, unchanged on the two side walls) into its own `end_wall`
  param, 3.2 -> 4.8mm (12x a 0.4mm line, same convention as `wall`). More
  material through the same weak stacking direction still raises the
  absolute force needed to delaminate it. `cavity()` now insets
  asymmetrically (the outline is pre-shrunk in X by `2*(end_wall-wall)`
  before the usual `wall`-width offset runs) instead of uniformly;
  `slot_cut`'s run and `tray_len` both follow the thicker front/back wall
  (`tray_len` 160 -> 157.8, keeping the same ~0.3mm stop clearance the
  v011 comment established; the old `tray_len` assert checked against
  `wall` there, which was wrong once the front wall got its own thickness
  — fixed to `end_wall`, same bug class `slot_cut`'s run had before the
  fix).
- **END_WALL_RIBS**: vertical fins on the inside face of both end walls,
  floor to just under the rim. A fin's two large faces are Y-normal —
  unlike the wall itself, Y-normal stays vertical no matter how far the
  part is tipped for printing (the rotation is about Y only), so each fin
  prints in the normal ring-stacked orientation and acts as a bonded
  stringer the wall can't provide for itself. Tapered with the wall's own
  draft (same hull-of-two-drafted-ends technique as `face_x()`) so each
  fin stays flush against the wall through its full height instead of
  drifting off it. Kept clear of the drain-hole cutters and the rim
  roundover in Z, and well inside the side-wall chamfer in Y (both checked
  by assert).
- Considered and rejected: printing the pot at a shallower tip (e.g. ~45deg
  on an edge instead of ~85deg flat on the back wall) as a way to improve
  end-wall strength without a redesign. Rotation math shows this trades the
  wrong way — at 45deg the end walls only improve from ~0-10deg off flat to
  ~40-50deg off flat (still not a genuinely strong orientation), while the
  floor and slot roof (Z-normal features) drop from ~85deg off horizontal
  (comfortably self-supporting) to exactly 45deg (the bare overhang limit,
  no margin, and now on a much larger ~155x85mm span). It also moves the
  part from resting on a full face to balancing on a single edge, on a
  print that ends up *taller* (213mm vs. 185mm) — worse adhesion and
  stability, not better. No single rotation helps both problems: the
  floor/slot want the rotation to approach 90deg, the end walls want it to
  approach 0deg, and the floor's failure mode (an unremovable internal
  support column) is worse than the end walls' (reduced strength, fixable
  independently). Kept the print orientation as-is.

## v032
Detent ENLARGED (print feedback: the tray still slides out too easily).
`det_h` 0.6 -> 0.8 (the v027 original; v029 dropped it alongside the
spring tongues and v030 kept the lighter bump). The v029 "hard push"
complaint was really the ~18mm jacked ride, which v031 fixed — with the
ride now a ~4mm blip the taller bump costs little on insertion. `det_in`
stays 0.8, so the retaining face is now a true 45deg (0.6/0.8 was ~37deg);
`det_out` 2.2 -> 3.0 keeps the insertion ramp at ~15deg. Pocket depth and
length follow from the parameters.

## v031
v030's pocket-tail extension was WRONG and is reverted (user questioned
4.4 -> 8.9; the question exposed the error). Kinematics: during insertion
the bump traverses (in tray coordinates) from the front edge toward the
pocket, riding under the SOLID strip between them; the drop is gated by
the pocket's FRONT wall, which is the retention face and cannot move
without adding seated free play. So the tail extension never changed when
the drop happens — the jacked ride equals the bump's distance behind the
tray's front edge. Fixed properly: `det_x` -60 -> -74.5 (bump ~4mm behind
the front edge, where the lip is backed by the basin's front wall), so the
ride is a ~4mm blip instead of ~18mm; pocket back to its original
`det_len` (+0.5 margin). Retention face, gap, and `det_h` unchanged.

## v030
v029's spring tongues REVERTED (user: overengineered). The pot is back to
a plain bump per shelf; instead the tray's catch pockets are ~4.5mm LONGER
on the insertion side, so during insertion the bump drops into the pocket
early and the final seating travel happens with the bump already inside —
no more pushing the tray through its jacked-up ride to engage. Retention
is unchanged: it is set by the pocket's front wall camming the bump's
45deg face (`det_gap` play), not by pocket length. `det_h` stays at the
lighter 0.6. Grip grooves kept.

## v029
Detent made COMPLIANT + grip grooves return (print feedback: engaging the
stops needed a hard push — the rigid tray had to jack itself `det_h` up
over the bumps).

- SPRING TONGUES: each detent bump now rides a cantilever tongue cut into
  the channel shelf (two slits + an under-relief leaving a thin, long
  finger, anchored toward the front). The tongue deflects ~`det_h` down as
  the tray slides over and snaps into the pocket: a light click in, a firm
  45deg cam-out, and tolerance-robust because the spring absorbs
  elephant-foot squish. Flex lives on the POT side because any flexure
  slit in the tray floor would leak the basin. `det_h` 0.8 -> 0.6: the
  spring makes retention reliable without brute interference.
- GRIP GROOVES return (v017-style), now along the tray's FULL length but
  confined to the center span so they never ratchet across the detent
  bumps or the shelf/sill sliding strips.

## v028
Finger access reworked — the detent's firmer pull exposed how awkward the
grip path was: a finger had to wrap the sill's bottom lip, climb 3mm, and
could only edge-grip the 5mm recess.

- SILL FINGER NOTCH: the central span of the sill is cut away below the
  recess (the slot effectively reaches the pot's bottom plane there), so a
  finger goes STRAIGHT up into the hook. The tray still rides the sill's
  two side segments and the detent still pivots on them; the notch lives
  in the bed face, visible only from the back like the rest of the drawer.
- RECESS DEEPENED for purchase: `face_t` 6.8 -> 9.0, `pocket_d` 5 -> 7.2
  (web still >=1.6mm): a fingertip pad seats fully behind the hook shelf,
  making the detent's breakout force easy to deliver.

## v027
Tray RETENTION DETENT (user: tray slides out too easily). Chosen over a
reverse-inclined channel, which would have cost ~2.7mm of the shallow
basin's usable water depth per degree and tilted the whole slot geometry.
Bump-and-pocket click: each channel shelf carries a small ramp bump (45deg
face toward the front = the retaining side; ~20deg ramp toward the slot =
the insertion side), and the tray's underside has a matching shallow
pocket. Inserting, the tray's chamfered front lip cams over the ramp,
rides high for the last stretch, and drops the pocket onto the bump — an
audible seat. Pulling out, the pocket's front wall must cam up the 45deg
face: bumps and vibration won't, a finger on the pull will.

## v026
Cross-section feedback round.

1. FLOOR DISHED: a perimeter cove (quarter-round) rises from the flat
   floor up the cavity walls, tangent to both — rounds the floor-to-wall
   corner AND slopes the floor perimeter toward the flat middle where all
   5 drain holes sit, so water cannot pool at the walls.
2. CHANNEL TRENCH CLOSED: the gap between each rail upstand and the skirt
   wall carried nothing and read as an open trench through the bay. The
   upstand is now filled solid to the wall — a clean step, stiffer weld,
   same sliding surfaces.
3. GRIP GROOVES REMOVED from the tray underside: redundant since the v024
   bottom-open finger recess.

## v025
Finger pull "double lip" smoothed out. The v024 recess had two ridges
around its mouth, both leftovers from the closed, tiny-mouth pocket.
Replaced by a single continuous profile: a lead-in ceiling that rises
gently from one entry edge, then a single undercut step up to the hook
shelf — a door-pull underside.

## v024
Print-feedback round (first physical print).

1. CORNERS. The chamfer<->fillet transition was tangent-smooth but
   curvature-discontinuous (a "step" a fingertip could find, and a layer-
   stair density jump in the face print). Arc fillets replaced by G2
   blends: tangent angle swept with a raised-cosine curvature profile,
   zero curvature at both ends. Wall thickness was also not uniform (top
   corners ~2.3mm, bottom corners ~4.5mm vs. 3.2mm flats) — the cavity is
   now a true parallel inset of the outer outline, 3.2mm everywhere,
   corners included.
2. FINGER PULL. The pocket mouth only admitted a fingernail. The pocket
   now opens through the BOTTOM of the face plate: a finger comes up from
   below (the pot bottom is open air there), slides flat into the recess,
   and curls behind the hook shelf to pull.
3. HEIGHT COMPACTION. Dead air around the tray removed: basin 11 -> 8mm
   tall, slot opening 13.5 -> 9.5mm, pot floor dropped — a deliberate
   departure from the source STEP file's floor heights, for soil volume
   and root depth.

## v023
Finger pocket filleted on every edge: cutter rebuilt from rounded
sphere-hull volumes + entry flare; nib grown so the catch survives the
rounding.

## v022
Four base-corner nubs fixed — the rail shelves punched teeth through the
skirt corner chamfers at bed level (since v015); rails now clipped to an
inset copy of the base outline.

## v021
Rim-corner sweep bug fixed — roundover slices were shrunk before rounding,
over-insetting corners (the rim nub, v013-v020); slices are now true
parallel curves (inset applied after rounding).

## v020
`corner_rf` 3 -> 6 attempting the rim nubs (superseded by v021).

## v019
v011's transition fillets returned on the body chamfers (superseded by
v024's G2 blends).

## v018
Pocket deepened to 5.0 (first-knuckle hook); pure 45deg chamfers returned.

## v017
Protruding pull lip replaced by an inset pull; the face plate is a wedge
parallel to the back wall's draft plane; grip grooves on the tray
underside.

## v016
Outer surfaces smoothed (round fillets; superseded), rim roundover swept
at 6deg steps (kept).

## v015
Hanging support: L-section channel rails carry the tray; slot bottom on a
solid sill, skirt ring continuous.

## v014
Hex band, struts, and captive drip tray REMOVED; drawer bay + pull-out
drip tray through a back-wall slot. Visible only from the back.

## v013
Flat-rim setback REMOVED; uniform wall to the top, 3mm rim roundover.

## v012 / v011 / v010 / v009
Rim radius; chamfer+fillet combo; 5deg draft everywhere; side-print audit
fixes (hex drainage holes, 3.2mm walls).

## v002 – v008
Strut band; one-body merge; exact two-body geometry (shell taper LINEAR,
outer 163.2x95.2 -> 185.5x117.5); early reworks. 5x drainage holes per
horticultural guidance (v004), as 10x7 hexes since v009.

## v001
Initial version, rebuilt from the source STEP file's per-body vertex
extraction.
