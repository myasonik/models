# Plant Jigger — History

## v015
- Supportless cup roof, volume-neutral. The bell cavity's spherical cap was
  a ~25 mm near-flat interior ceiling printed rim-down — the audit measured
  265 mm² of flat-down faces at its apex, and the slicer demanded internal
  supports. The interior is now spherical only up to latitude ≈28.40°, then
  a 45° cone whose apex tunnels into the solid neck. The blend latitude is
  the root of 2s³+6s²+3s−3 = 0, chosen so the cone's volume equals the cap
  it replaces: capacity stays 15.268 ml (STL solid volumes differ 0.018%).
  Exterior unchanged; flat-down faces now 10 mm² (hairline slivers at the
  lip tip's first layers, addressed by slicer settings instead — see the
  new SPEC §5: the draft preset's 0.32 mm layers step 0.55 mm per layer on
  the 60° lip, which is why v014's spout printed dirty).

## v014
- Stronger kick-out at the pour edge for cleaner stream detachment: ease
  changed from 1−sin to (1−sin)^1.3, steepening the lip from ~53° to ~60°
  from vertical at the rim while keeping the tangent merge. A sin^q kick
  was tried first and rejected by the print audit — its infinite rim slope
  produced unsupported flat-down faces in the first layers. Print audit
  also confirmed rim-down remains the right orientation: flipping would
  put the 0.8 mm lip at a 60° unsupported lean at the top of the print.

## v013
- Spout restyled as a pitcher lip, per the user's sketch. The trough
  attached low on the wall is gone; the bell rim itself now flares outward
  into a soft teardrop point, like a pulled creamer lip. Built as a
  stacked-hull loft (0.2 mm steps): at each height the outer section is
  hull(bowl silhouette, spout circle), the spout circle retreating on a
  sine ease — full pour angle at the rim, tangent merge into the dome.
  Channel void is the same loft on the inner silhouette, open across the
  rim plane. Pour edge in the rim plane, 0.8 mm walls at the lip, prints
  flat on the bed. Old crest/trough/minkowski/chamfer machinery deleted.

## v012
- Crest plateau removed so the spout reads as a single continuous curve.
  In v011 the crest ran flat from the wall (y −15…−18) before the cosine
  ease began, so the silhouette read as ledge + curve with a visible
  shoulder. The ease now spans the entire flare — from the tangent point
  where the spout leaves the bowl wall to the tip — giving one S-curve
  with zero slope at both ends. No other geometry changed.

## v011
- Spout made one fluid piece with the bowl: outer form is the hull of the
  bowl circle and the tip circle, leaving the wall on exact tangents (a
  pitcher-lip flare with no seam). Channel void likewise a hull of two
  circles for a smoothly converging mouth.

## v010
- Spout rebuilt as one smooth loft: tangent plan into a round tip,
  cosine-eased crest, edges rounded via minkowski with a hemisphere (flat
  bottom preserved for the bed).

## v009
- Reframed print orientation: bed plane = rim plane in use, so the channel
  opens toward the bed; spec's "rising floor" and "45° undercut" restated
  as use-frame requirements.

## v008
- Rebuilt from spec only, printing bell-down (bell rim and spout underside
  on Z=0, no supports).

## v007
- De-horned the trough walls: v006's crest cut sat at doorway-top height,
  leaving shoulder stock that tapered into thin curved spikes against the
  dome.

## v006
- Working spout passage restored: v005's niche back wall had sealed the
  doorway, so the basin had no path to the spout. Arch is a through-doorway
  again, open trough, no stray holes.

## v005
- Sealed the doorway visually: the open-bottomed dome made the
  through-doorway read as a hole from every angle, so the arch became a
  recessed niche.

## v004
- Stubbier spout + doorway sill: beak reach cut from 12 mm to 5.5 mm beyond
  the wall (still above the 4–5 mm minimum from drip-free spout studies).

## v003
- Closed the gap in the spout floor: v002's doorway re-cut ran 2 mm past
  the bell wall, leaving the trough floorless at the root.

## v002
- Pour spout added at the bell's arched cutout, following drip-free
  ("teapot effect") research.

## v001
- Initial version: recreation of "plant jigger.step" as a parametric
  OpenSCAD model — bell, neck, and large cup unioned into one printable
  solid.
