# Hair Comb — History

## v005
- `tooth_w_max` 3.7 to 4.225, on the user's call, so the teeth bulge
  further and the narrowest clear gap between two neighbouring teeth
  falls to 0.8. The silhouette table is unchanged, so the root and tip
  scale with it: root 3.26 to 3.72, tip 1.18 to 1.35.
- The width is solved from the solids, not from `pitch - width`. Each
  tooth is a straight prism on a 5.3705° angular pitch, so neighbours sit
  tilted and their facing edges converge toward the inner radius. The
  true clear gap runs about 0.05 under the subtraction.
- The user first asked for 0.4 and then changed it to 0.8. At 0.4 a 0.4
  nozzle has one extrusion width to work with, and the slicer fuses
  neighbouring teeth or closes the gap on the first layer. 0.8 gives two.
- Break force rises to 7.38 N from 6.26 N. Peak stress stays near the
  tip, 4.8 from the end.
- Volume 4173 to 4640 mm³, or 5.8 g in PLA.

## v004
- **Corrects a misreading.** "Ovular" meant the tooth's silhouette, not
  its cross-section. v003 turned the section into a stadium on that
  mistake. The user's red outline around one tooth settles it: the
  silhouette is a long pointed oval.
- The tooth is no longer widest at the root. It leaves the spine at 88%
  of full width, swells to full width 42% down, then tapers to a point.
  The profile is a lookup table read off the red mask row by row, lofted
  over 48 sections per tooth. SPEC section 5 carries the table.
- Cross-section reverts to a rounded rectangle at `corner_r` 0.6. The
  stadium was v003's invention and cost 28% of the break force.
- `shell_t` and `tooth_t_root` revert to 3.0, and `tooth_t_tip` goes to
  1.1. The user picked 2.6 in v003 to manage the stadium's flat-face
  fraction, and that reason no longer exists. The 3.0 root was their
  earlier choice on solid ground.
- Break force 6.26 N, against 7.32 N for v002's straight taper and 4.30 N
  for v003. Peak stress now sits 4.6 from the tip rather than mid-span,
  so a failure costs a tip fragment instead of half a tooth.
- The slot pinches where the tooth swells: 1.81 at the root, 1.37 at the
  widest point, 3.89 at the tip.

## v003
- Tooth cross-section changed from a rounded rectangle to a stadium.
  **Superseded by v004** — this was a misreading of "ovular".
- `tooth_t_root` 3.0 to 2.6, `tooth_t_tip` 1.8 to 1.6, and `shell_t` 3.0
  to 2.6 with them. Reverted in v004.
- Teeth started 0.5 below `spine_h` instead of at Z=0, which removed the
  bullnose taper v002 carried. Kept in v004.
- Correction recorded here: v002 broke at 7.32 N, not 8.14 N. The 8.14
  figure used the sharp-rectangle formula `w*t^2/6`; the real
  rounded-rectangle section modulus at a 0.6 corner is 5.163 mm³.

## v002
- Reorients the print so the teeth lie flat. In v001 the tooth axis stood
  vertical, so bending stress ran straight across a layer boundary and a
  tooth snapped at 2.45 N at the tip. Flat teeth put that stress in the
  layer plane.
- Requires support. v001 needed none. The comb is a cylinder section
  whose axis runs along the teeth, so laying the teeth flat lays that
  axis flat, and a cylinder on a plate has a horizontal tangent at its
  contact line. The underside starts at 90° overhang and never reaches
  45° across a 75° arc. No orientation with flat teeth avoids this, and
  the user chose to accept the support rather than heat-form a flat
  print.
- `tooth_t_root` 2.2 to 3.0, on the user's call.
- `tooth_t_tip` 1.4 to 1.8. A tooth breaks mid-span, not at the root,
  because the section grows faster than the moment.
- `shell_t` 2.4 to 3.0, so the spine sits flush with the thickened tooth
  root instead of the root standing proud.
- The spine's outer edge became a full bullnose instead of a 0.5 chamfer.
  That edge no longer lands on the build plate, so it can match the
  original's rounding.
- All bed chamfers removed. Nothing sits flat on the plate.

## v001
- Initial version. Reproduces a curved plastic side comb from two
  photographs and the user's two stated figures: a 12 mm peak and 14
  teeth.
- The 69 mm chord and the 12 mm rise fix a 55.594 mm outer radius and a
  75° span. The arc spans 75°, so "semi-circle" describes the look, not
  the angle.
- First pass at the photographs read 27 teeth. The tooth-edge shadows
  double the count in an intensity profile. The user's count of 14
  corrected it, and a recount at the tooth tips in photo 002 confirmed a
  5.1 mm pitch.
- `half_angle` solves for the end cap's equator, not the sector's outer
  corner. The plain `asin(chord/2 / R_out)` puts the part at 68.34 wide
  instead of 69.0, because the end cap pulls the widest point inward.
- The spine started as a stacked set of `offset()` slices to cut its
  bottom chamfer. That left 22 mm² of flat-down facets, one per step, and
  the print audit flagged them. Replacing the stack with a hull chain of
  chamfered pucks cut a true 45° chamfer and dropped the flat-down area
  to zero.
- Printed spine down with no supports.
