# Switch Plate — History

## v024
- The real coat of arms replaces the placeholder. The downloaded plaque
  mesh (frame, swirl-textured field, rock mound, bear, ash tree, fox) now
  lives in the `coat-of-arms` skill with a script that flattens it to a
  height map and cuts away everything but the three figures: the frame by
  rectangle, the field texture by height, the mound by a traced polyline,
  with local thresholds where a foot stands in front of the rock. The
  result is an 8-bit PNG that `surface()` reads. A second
  cleanup pass fixed the bear: the low background web between and around
  the forepaws is cut (the far foreleg stays), the mound skirt attached
  left of the rear leg is cut, and the front hind foot's threshold
  dropped from the rock level behind the toes to just above it, so the
  toe curl survives instead of ending in a straight chop. A third
  pass replaced the box zones at the bear's feet with one traced cut
  line that hugs the rear leg, heel and toes, because the mound in
  front of them sits at foot height and no threshold separates them; it
  also cut the last low web strip below the forepaws. A fourth pass,
  from a marked-up print: the blob-size floor drops 1500 → 400 px so
  the upper paw's claw tuft survives on its own, a low fur band under
  that paw's toes is restored, a generous patch of the mound comes back
  under the front hind foot (the sculpt hides the foot in the rock, so
  the patch errs large, to be trimmed by eye), and the export now
  re-applies the cut mask after resampling, so cut edges print as clean
  walls instead of soft gray aprons. A fifth pass, from a second marked
  print: the restored fur band conjoined the bear to the tree and was
  not bear, so it is cut again (the claw tuft island stays), and the
  mound patch deepens to the art's bottom line, filling directly below
  and in front of the front hind foot; a pinched notch keeps the other
  foot's toe-tip crease clear of it. A sixth pass, after comparing all
  states side by side: the paw fix had oscillated between all and
  nothing — the restore zone now stops at x 860, keeping the fur fringe
  on the toes without the bridge to the leaf — and the ground patch had
  printed as a lump floating below the leg, because the sculpt's
  leg-to-mound crease dips to field level and fell out of every
  threshold. A restore polygon with a 0.030 height floor now fills that
  crease, tying leg, ground and toes into one surface. A seventh pass:
  the fur fringe's box edge left a boxy nub, so the box shrinks to
  x 840 / y 572, and a second restore strip lays ground under the back
  paws down to row 1214, joining the front shelf. Then hand mark-up
  replaced guesswork: a Relief Marker page (an artifact the user paints
  keep/remove strokes on, which saves them back) supplied 35 strokes
  that the build now applies last — the remaining mound band is gone,
  each figure stands free on small grass tufts, the fox's rear foot
  came back, and the stray bits inside the tree crown are cut. The
  result is a 720 × 413 PNG.
- Placement: 72 wide, centered on the right gang, which is the most the
  gang holds — 4.3 clear of the toggle opening, 2.7 short of the face
  chamfer. 41.0 tall at the image's own 1.756:1.
- Depth: the peak stands 4.0 proud (20 layers). The plaque's own
  proportion gives 7.4 at this width; that is too much for a wall plate
  already 6.0 off the wall, and 4.0 keeps the modeling readable. The
  plate's highest point is 10.0 off the wall.
- The placeholder roundel/star/dome and the hand-drawn 2D art are deleted
  from the source; `emblem = false` now means a flat face.
- Unchanged otherwise: the base, the props, the slots, and every z value
  below the face.

## v023
- Square again at the larger size: `cov_w` 125 → 129, matching `cov_h`.
  The outline is 129 × 129 and the base 125 × 120. Nothing in the z
  stack moves — the face still stands 6.0 proud. Everything driven off
  `base_w` followed on its own: the lugs sit at ±62.5, the cover props
  reach to ±62.1, and the bottom-left relief starts 2 further out at
  x = −57.7. That last one lengthens the span from the band anchor to
  the first fin, 8.2 → 10.2, still well inside the 16.5 the fins use
  elsewhere. Interference check re-run: zero at seated, at seated slid
  0.15, and at entry.

## v022
- The plate is 4 taller in the plane of the wall: `cov_h` 125 → 129.
  Nothing in the z stack moves — the face still stands 6.0 proud and the
  cover is still 5.8 deep. The base's outline derives from the cover's,
  so it grows to 121 × 120. The props stay where they are: the span from
  the outermost prop at ±46.5 to the cavity wall grows 14.4 → 16.4,
  still inside the 16.5 pitch the rest of the props use. Checked the new
  clearances too — the band's inner edge sits at y 57.7, clear of the
  yoke's ends at 53.2 and of the box pads' reach at 47.07. Interference
  check re-run: zero at seated, at seated slid 0.15, and at entry.

## v021
- Switched the placeholder emblem off (`emblem = false`). It existed to
  validate the face-up print, which is settled, and it cost height and
  filament on every fit test. The cover's outer face is flat now: height
  11.69 → 5.80, volume 36.0 → 33.9 cm³. The placeholder geometry and the
  2D coat-of-arms art stay in the source behind the flag. Setting
  `emblem = true` restores it, or `emblem3d()` gets replaced by the real
  relief. Interference check re-run: zero at seated, at seated slid
  0.15, and at entry.

## v020
- Fixed two print defects on the cover's inner face. Both came from
  props that were not where the bridging needed them.
- The props move from y = 0, ±17, ±34, ±51 to 0, ±13.5, ±30, ±46.5. The
  toggle opening's short edges sit at ±12.5, so they hung 4.5 clear of
  the nearest prop: the perimeter loop around the hole printed over air
  and sagged, and every bridge line running into the hole stopped
  mid-span and left a blob. They now hang 1.0 clear. Same seven props,
  and the largest span drops 17 → 16.5.
- The props now stop 0.8 short of the side walls instead of 1.5.
  Whatever they do not reach becomes bridge lines running the cavity's
  full 121.8 length with nothing under them, which is the wavy line
  1.5 in from the wall. Four such lines become two. 0.8 is still two
  line widths of air, so no prop welds to a wall; reaching the wall
  outright would weld 14 prop ends, about 40 mm².
- Verified: prop-to-cover overlap still 0.9 mm³, all of it the rib
  teeth. Interference zero at seated, seated slid 0.15, and entry.

## v019
- The cover covers more of the base, with no change in how proud it
  sits. Only the back reveal moves, 0.8 → 0.2. The face's height above
  the wall is the base's height plus the face thickness — the reveal is
  not in it — while the walls' height is the base's height minus the
  reveal. So the reveal is the only lever that buys coverage for free,
  and it is worth 0.6, not 2.0. Walls 3.2 → 3.8, exposed base 0.8 →
  0.2, retention lip 1.3 → 1.9, face still 6.0 proud and the emblem tip
  still 11.9. The wall bevel now runs over 1.8 instead of 2.0, so it
  steepens from 21.8° to 24°, with the same outline numbers.
- Reverts v018's rim change. Raising the rim added 2.0 of wall height
  and 1.4 of proudness together, which was not what the change was for.

## v018
- The cover's walls are 2.0 taller and cover the base better. Both come
  from the base, not the cover: the rim grows 1.6 → 3.0, which raises
  the face seat, and the back reveal shrinks 0.8 → 0.2, which drops the
  cover's edge closer to the wall. Wall height 3.2 → 5.2, cover depth
  5.2 → 7.2, exposed base 0.8 → 0.2. The reveal stops at one layer
  rather than zero, so the wall surface never becomes a second hard stop
  against the rim seat. Because `hook_t` is `rim_h`, the lug thickens
  1.6 → 3.0 and the retention lip grows 1.3 → 1.9, so the wedge and the
  hold both improve. Face outer moves 6.0 → 7.4 proud, and the emblem
  tip 11.9 → 13.3. The wall bevel runs over 3.2 instead of 2.0, so it
  shallows from 21.8° to 14°; the outline numbers are unchanged. Cover
  props are 5.0 tall now, so their comb rails grow 1.0 → 1.6.
  Interference check re-run: zero at seated, at seated slid 0.15, and at
  entry.

## v017
- Removed the thumb notch from the cover's bottom edge. The beveled edge
  stands 6 proud of the wall, which grips well enough to push the cover
  up for removal, and the notch broke that edge line. Nothing else
  changed. Interference check re-run: zero volume at seated, at seated
  slid 0.15 further, and at entry.

## v016
- Audit fixes. The slot's bevel was cut on the lug's exact bevel line,
  so the cover met two hard stops at the same instant — the bevel and
  the rim — and printing tolerance decided which one won. When the bevel
  won, the face stood proud of the rim and the plate showed a gap all
  round. The slot's +y edge now runs 0.15 clear of the bevel line
  (`bevel_clr`), so the rim is the only hard stop, the cover slides
  about 0.15 further to seat, and the wedge stays loaded. Retention is
  unchanged: the lip still catches the lug's underside. Verified by
  boolean check at three positions — seated, seated slid 0.15 further,
  and entry. v015 interferes by 1.03 mm³ at the slid position; v016 is
  clear at all three.
- SPEC now calls for a brim on the base as well as the cover. The base's
  4001 mm² of bed contact is spread over a 4.8 band and 6.4 arms, with
  nothing wide to hold their ends down.

## v015
- Put every dimension on the process grid, and filleted what the grid
  cannot fix. `lw` (0.4 line width) and `lh` (0.2 layer height) are now
  named parameters, and every material thickness is written as a whole
  multiple of one of them, so a nozzle change re-derives the part.
  Changed to fit: band 5 → 4.8, right pads 10.5 → 10.8 with the box
  countersink 7.5 → 7.6, the yoke countersink 5.8 → 5.6 (3 whole lines
  of boss around it; the head now sits 0.75 proud, 0.85 under the cover
  face), lug protrusion 1.9 → 1.6 (tip 0.4 shy of the wall's outer
  surface, 1.2 of engagement), relief width 9.0 → 8.8, punch-out tabs
  0.6 → 0.4, cover bevel start 1.3 → 1.2. Clearances keep their values,
  because they are air rather than extrusions.
- Quantizing cannot fix a tangency: where the round screw seat runs into
  the straight arm, the gap narrows continuously to zero, and that wedge
  is what the slicer filled with the ragged beads on the printed frame.
  So the frame's plan now gets a morphological close — dilate 1.2, erode
  1.2 — which fillets every inside corner and fills every wedge. It adds
  7.2 mm² (0.2%) and leaves convex outlines, seat diameters, and holes
  unchanged. Interference check re-run: zero volume at seated and entry.

## v014
- The four cleat lugs now print onto sacrificial blocks. Each lug's
  underside is a 1.9-deep flat cantilever off the band, so its first
  layers extruded into open air, curled, and left the uneven surface
  the cover's lip has to catch on a 0.3 clearance. Nothing permanent
  can support it: the lip slides into exactly that space, and a gusset
  or a sloped underside there breaks the cleat's hold. So each lug gets
  a free-standing block on the bed — 1.5 × 9.6 × 2.2, held 0.4 clear of
  the band sideways and 0.2 clear of the lug above. It touches nothing
  and lifts away after printing. Verified: block faces at |x| 60.9 and
  62.4, z 0 to 2.2, and zero overlap volume with the base. Interference
  check re-run: zero volume at seated and entry. Cover unchanged.

## v013
- The back relief now differs per arm, to suit the wall this plate goes
  on. The top-left arm has none: the strap is flush there, so the arm
  stays solid 2.4 across its whole length and bears on wall and strap
  alike. Its screw hole runs straight through, so it drops the membrane
  and the score ring. The bottom-left arm is relieved for its whole
  run — from the left band's inner edge at x = −55.5 out to x = −12.02,
  and 9.0 across, wider than the arm and its boss. That leaves a 43.5
  ceiling to bridge, so five snap-out fins now stand under it on the
  bed at x = −47.5, −39, −30.5, −26.5, −19.5, cutting the span to 8.5
  or less. The fins stop 0.2 below the ceiling and a rail ties them
  into one comb, following v011. Verified by probe: the top arm is
  solid through the relief range, the bottom arm is open from the band
  to x = −12.02, and fin-to-base overlap is zero. Interference check
  re-run: zero volume at seated and entry. Cover unchanged.

## v012
- The cover's side walls now slope instead of standing vertical. Only
  the outer surface slopes: the cavity stays vertical, because the base
  slides down it with 0.4 clearance and a sloped inner face jams that
  slide. The profile has three segments — vertical to z 1.3, then 0.8
  in over 1.9 (22.8°) to the face plane, then 2.0 in over 2.0 (45°) to
  the face. The outline reads 125 at the wall, 123.4 at the face plane,
  119.4 at the face. The cleat fixed all three: the wall stays vertical
  and 1.6 thick through the retention lip below z 1.3, and the base's
  rim reaches the face plane, so 0.8 of wall is all the cavity leaves
  there. Above the face plane the material is solid, so that chamfer
  takes any angle. The outer surface only moves inward as z rises, so
  it prints face-up with no overhang. Interference check re-run: zero
  volume at seated and entry. Base unchanged.

## v011
- Made the cover props come off easily. Each prop was modeled 0.1 into
  the face and necked to 0.3 — narrower than one line width, so the
  slicer widened it — which welded every prop to the face along its
  whole 57 mm length. Props now neck to 0.4 and stop 0.2 (one layer)
  below the face, so they catch its sag without bonding. Two rails
  1.2 × 1.0 at x = ±26 tie each half's seven walls into one comb that
  lifts out whole. The rib's spine is the one prop that must bond,
  because the rib's first layer needs an anchor; it now reaches the rib
  through ten teeth 2.0 long on a 10.0 pitch, so the weld drops from
  about 40 mm² to 8 mm² and peels one tooth at a time. Verified by
  boolean check: prop-to-cover overlap is 0.9 mm³, all of it the teeth.
  Interference check re-run: zero volume at seated and entry. Base
  unchanged.

## v010
- Made the membranes punch out cleanly. Each membrane was the same
  layer as the bridge sheet around it, printed in one continuous pass,
  so it tore instead of shearing. A score ring 0.8 wide, cut through
  that one layer, now leaves a d 3.9 punch-out disc on three 0.6 tabs
  at 90/210/330°. The ring makes the disc a separate island, so the
  slicer closes a perimeter around it and changes direction there. The
  tabs shear at 0.36 mm² total. The left screw seats regain a d 8.0
  boss, which replaces the bridge material the ring removes and leaves
  1.25 of solid sheet on each side of the ring. The boss lies inside
  the relief, so it stands 1.2 off the wall and clears the plaster
  ears; the v009 note that a wider seat lands on an ear applies only to
  full-thickness material. Interference check re-run: zero volume at
  seated and entry. Cover unchanged.

## v009
- Fixed the back-relief print. The old 26 × 92 pocket printed as one
  big diagonal bridge with unanchored lines drooping around the holes
  and the toggle cutout. From the installed switch, measured: strap
  17.1 wide at the plate-screw holes; plaster ears begin ~4.4 past the
  holes. Relief narrowed 26 → 22; the left arms are now plain 6.4-wide
  bars (no round pad — a wider seat could land its full-thickness part
  on an ear corner and rock the frame); their countersinks shrink to
  5.8 × 0.95 (head ~0.6 proud, 1.0 under the cover face); and each
  left hole is closed at the back by a 0.2 sacrificial membrane so the
  bridge prints as one fully anchored 6.4 × 22 sheet — poke both
  membranes out before mounting. Right pads/holes unchanged. Spec now
  calls for bridge direction 0° and thick bridges in the slicer.
  Interference check re-run: zero volume at seated and entry. Cover
  unchanged.

## v008
- Base reduced from a plate to a frame. It is never seen and, since
  v007, nothing rests on its interior (the face seats on the rim), so
  only functional members remain: a 5-wide perimeter band carrying the
  rim and lugs, a 6-wide spine at x = 0 (0.4 under the cover's rib),
  four 6-wide arms at the screw rows tying each side band to the spine,
  and d 10.5 screw pads. The toggle pass-through is gone — the gang is
  open. The back relief is unchanged in footprint and still sets the
  left arms and pads 1.2 off the wall over the yoke. Base volume
  31.4 → 10.8 cm³. Interference check re-run: zero volume at seated and
  entry. Cover unchanged.

## v007
- Slimmed the whole stack. The face sat 8.8 mm off the wall because the
  rim was 4 tall to house 2.4-thick lugs with 0.7 of cover wall closed
  over them; nothing in the cavity needed the height. Now the rim and
  lugs are one 1.6-tall plane (lug underside on the plate front, lug top
  = rim top = face seat), the bayonet slots open straight up to the
  face's inner surface (the face bridges them), and the face thins
  2.4 → 2.0. Face outer 8.8 → 6.0, cover depth 8 → 5.2, emblem tip
  14.7 → 11.9. Retention lip under each lug 1.9 → 1.3; stiffening rib
  now 1.2 tall (0.4 clear of the base front). Base plate, screw seats,
  relief pocket and the cleat action are unchanged. Interference check
  re-run: zero volume at both seated and entry positions. The
  placeholder emblem (5.9 proud) is untouched and is now the largest
  single contributor to the stack.

## v006
- Snap fit replaced with a french-cleat slide-on. Each clip spot became
  a hook lug on the base rim whose top wall slopes outward at 45°
  instead of standing at 90°; the cover's snap windows became bayonet
  slots (entry mouth at the back edge, slide corridor, locked pocket
  cut on the exact bevel line). Install: press on 5 high, slide down —
  the bevels wedge the cover against the rim, closing the old 0.3 mm
  axial gap. The base outline lost 5 mm at the bottom so the raised
  cover fits over it at entry; the stiffening rib shortened 110 → 100
  to clear the rim during press-on; the pry notch became a thumb notch
  for sliding the cover up. Fit verified by boolean interference checks
  at both the seated and entry positions (zero volume).

## v005
- Eliminated slicer supports for the cover. Modeled sacrificial props
  inside the cavity — seven 0.8 walls on a ≤17 mm pitch plus a spine
  under the stiffening rib, each necked to a 0.3 knife-edge at the
  surface it props — let the face bridge instead of being supported.
  Slice the cover with supports off and snap the props out before
  assembly. (A two-part glue-in emblem plaque was considered and
  rejected: the plate must stay one piece.)

## v004
- Replaced the engraved coat of arms with a **placeholder raised 3D
  emblem** (roundel d 40 + tapered five-point star + center dome,
  5.9 proud) on the right gang, to test the supported cover print
  before the final emblem is designed. The cover's print orientation
  flips to face-up — walls on the bed, supports filling the hidden
  interior — so support scars land on the face's inner surface instead
  of the visible face and emblem, which print clean on top. The 2D
  coat-of-arms modules stay in the source for the future relief
  version. Base unchanged.

## v003
- Printability-audit fixes. Opened the 6-32 clearance holes from 3.6 to
  3.9 (printed holes shrink 0.1–0.3; 3.6 was line-to-line on the
  3.51 mm screw) and the countersinks from 7.2 to 7.5 to keep the cone
  at exactly 45°. Lengthened the back relief pocket from 76 to 92 so
  the switch's box-mounting screw heads and plaster ears at y ±41.7 —
  previously outside the pocket — no longer rock the plate.

## v002
- Coat of arms engraved 0.6 into the blank right gang: ash tree between
  a bear rampant and a fox rampant on a ground line, inside a
  round-bottomed shield with a border groove.

## v001
- Initial version: two-part screwless two-gang plate — base screwed to
  yoke and box, snap-on cover with side-wall windows over chamfered rim
  ridges and a pry notch.
