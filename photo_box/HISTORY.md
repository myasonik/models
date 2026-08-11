# Photo Box — History

## v003
- New dimensions, and the model now covers **two boxes** rather than one:
  195 × 65 and 245 × 65, both 158.75 tall. Depth dropped 101.6 → 65 and
  length 254 → 195/245.
- Built as one model with a `variant = "a" | "b"` switch rather than two
  folders. The boxes differ only in length, so duplicating the source
  would mean every future fix had to be made twice — the exact drift the
  spec's "a change to one is a change to both" is there to prevent. Four
  print layouts (`_{a,b}_{box,lid}`) come off the one file.
- `nail_w` became derived — `min(60, box_w − 4 × corner_r)` — instead of a
  fixed 60. At the sizes first quoted for this revision (19.5 and 24.5)
  a fixed 60 notch would have been wider than the box and cut the wall
  away entirely. The clamp is inactive at 195 and 245, but the failure it
  prevents is silent, so it stays.
- 8 × 10 in photos still do not fit, and now cannot stand on end either
  (254 exceeds the 148.15 floor-to-ledge height). 4 × 6 and 5 × 7 fit both
  variants.
- All five §9 acceptance checks re-run across all four parts. Filament
  628 g for the pair, against 452 g for the single v002 box.

## v002
- **Envelope violation fixed.** v001's lid grab tabs projected 6 beyond
  the front and back walls, making the lid 113.10 deep against a
  specified 101.6 — 11.5 over. The stated outside dimensions are a hard
  constraint, not a nominal size to trade against ergonomics, so the
  tabs are gone. `SPEC.md` §2 now says so explicitly and §9 adds a
  bounding-box check against the envelope as an acceptance test, because
  v001 shipped an STL that broke a requirement no check would have
  caught.
- Grip replaced with a **nail catch**: a 60 × 3.0 notch in the box rim,
  front and back, that the lid edge overhangs. Subtractive, so it costs
  no envelope.
- The notch was first cut as a 45° chamfer into the lid plate's
  underside. That failed the print audit — the plate overhangs the skirt
  by only 1.65, so a 3.0 chamfer removed the plate from under the skirt
  and left it bridging 60 in mid-air (161 mm² of flat-down overhang, four
  40 mm² facets at the top of the lid print). Moved into the rim, which
  has 5.0 of depth to spend. The lid plate is now uncut and back to zero
  overhang.
- Both parts re-verified against all five §9 acceptance checks.

## v001
- Initial version. Lidded box for shipping photos, 254 × 101.6 × 158.75
  outside, PLA, single colour.
- Lid interface is a gridfinity-style rabbet: the wall thickens inward
  on a 34° ramp, is cut back to leave a 2.0 ledge and a 1.6 × 5.0
  standing rim, and the lid's 4.6 skirt drops into it on a 45° lead-in
  with 0.3 clearance per side. The rim carries the load, not the ledge —
  the skirt is held 0.4 clear so the two seats cannot fight.
- Walls set at 2.0 rather than the 3.2 first sketched. A closed box is a
  rigid shell and wall thickness here is solid extrusion, so 3.2 was
  buying stiffness the part does not need at ~200 g of filament. Ribs
  were considered as the stiffness lever instead and left out; the box
  does not need them yet.
- Lid gained 60 × 6 grab tabs on the front and back edges. Earlier
  attempts to put the grip in the box wall all cut into the 1.6 rim or
  perforated the shell, which a box meant to keep dust off photos should
  not have. Tabs are the only thing that breaks the rectangular
  envelope, so they are parametric and removable.
- Ramp started at 1.6 rise / 1.6 inward — exactly 45°, sitting on the
  self-support limit. The print audit binned 2134 mm² there, so the rise
  went to 2.4 (34°), dropping it to 585 mm², which is only the foot
  chamfer at the first layer.
- Output guard is an explicit `part == "both"` rather than a bare
  `else`, so an unrecognised `part` emits nothing and the file can be
  `include`d and section-cut for verification without drawing itself.
- Known limitation: the 246.8 throat is 7 too narrow for 8×10 in photos.
  Left as-is — the requested outside width was 10 in, and the dimensions
  are expected to change once the photos are measured.
