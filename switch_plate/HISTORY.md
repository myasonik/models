# Switch Plate — History

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
