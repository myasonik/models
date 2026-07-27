// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (two-body Fusion export, 2026-07-10) plus the user's section screenshots.
// Dimensions taken from per-body vertex extraction; see comments.
//
// ONE BODY: pot, hex band, and drip tray print as a single piece.
//
// PRINT ORIENTATION: short side down, rotated (90 - draft) about Y so
// the end wall lies flat — 85deg at the current 5deg draft. Hanging
// tension then runs along layer planes [25].
//
// v013: flat-rim setback REMOVED (a deliberate departure from the
//   original Fusion design this file was rebuilt from — the source file
//   was named for that feature). The wall now runs uniform 3.2mm
//   thickness to the top, capped by a 3mm outer roundover that sweeps
//   to within 0.2mm of the inner face. Same print cost as the corner
//   fillets: ~1mm under-curl band on the bed-end rim edge only.
// v012: rim outer edge rounded with rim_r = 1: the roundover consumes
//   the 1mm flat and lands tangent to the 45deg setback, which is
//   preserved. Radius is geometry-capped (rim is only wall = 3.2 wide),
//   not print-capped: at r=1 the bed-end rim edge under-curls just
//   0.63mm of first-layer stick-out; other rim edges print clean.
// v011: shell corners softened with the chamfer+fillet combo [10]: the
//   45deg chamfer core stays, its transition edges rounded by
//   corner_rf = 3. In the side print the surface exceeds 45deg only in
//   a ~0.9mm band along the two bed-side corner rails (first-layer
//   stick-out ~1.1mm, sitting in the elephant-foot zone). A pure fillet
//   at the old 10.4 radius would sag ~3mm along those edges; ~3mm
//   radius is the practical ceiling before visible droop.
// v010: pot elongated in height until every wall is at a 5deg draft.
//   Footprints unchanged (rim 185.5x117.5, base 163.2x95.2); because
//   both directions share the same 11.15mm half-difference, one height
//   sets all four walls: height = 11.15/tan(5) = 127.44 (was 105,
//   +22.4). The tray/band/floor stack keeps its fixed Z heights (0..22)
//   — all added height is wall, above the drip-tray works.
// v009: side-print audit fixes (audited via print-audit skill):
//   - Shell corner radii -> 45deg chamfers (ch_top/ch_bot): kills the
//     near-bed corner-sag patches [9] and curve stepping [16], matches
//     the band/tray corner language.
//   - Drainage holes round -> 10x7 hexes pointed along pot-X: pointed
//     along print-vertical since the floor prints as a wall [3,4].
//   - Long-wall band hexes rotated to point along pot-X (print-vertical)
//     [4]. Short-wall hexes unchanged (those walls lie nearly flat in
//     the print; orientation cannot help them).
//   - wall and strut_t 3 -> 3.2 (multiples of a 0.4 line width [1]).
// v008: band-to-tray attachment optimized for airflow and free water
//   movement. v007 welded the band's full perimeter into the tray, so
//   water only crossed it through 44 ports of 1.5x1mm (~66mm2 total) —
//   the bottleneck. Now the band bottom floats 5mm above the tray floor
//   and the load runs through 12 tapered struts (3mm thick vs the 1.2mm
//   band edge; bending stiffness ~15x per attachment, total weld area
//   ~360mm2 vs ~264mm2 before). Bottom opening ~1080mm2, roughly 16x.
//   Struts sit under hex-grid columns: 3 per long side, 1 per short
//   side, 4 corner posts. Hexes shortened 8 -> 6 to clear the gap while
//   keeping solid band rails; castellation ports removed (the open gap
//   replaces them).
// v007: merged into one body; v006's 0.2mm clearance removed.
// v006: exact geometry from the two-body export.
//   - Wall taper is LINEAR rim-to-ground: outer 163.2x95.2 at Z0 to
//     185.5x117.5 at Z105 (skirt ring verts at Z=0: +-81.59 x +-47.59).
//     The v002-v005 bottom size (156x88) was a bad fit. Skirt is SOLID —
//     v005's skirt windows removed.
//   - Hex ring: band outline 123.2x55.2, 1.2mm wall, hanging from the
//     floor to just above the tray. 44 point-up hexagons (16 long side,
//     6 short side), 5.0 wide x 8.0 tall, 6.5 pitch, points at Z 4.4 and
//     12.4. Castellated bottom edge: 1.5mm notch under each hex.
//   - Drip tray: SEPARATE part. Plate 133.2 x 65.2 x 2 (2.83 corner
//     chamfer), rim flares to a 143.2 x 75.2 brim at Z5. Sits captive
//     under the band; 7mm ring gap to the skirt is the evaporation and
//     pour-out path.
//   - In the source file the band interpenetrates the tray plate by 2mm;
//     v006 misread that as CAD interference and added a 0.2mm clearance.
//     It is actually the weld — see v007 note above.
// v005: center tray + windowed ring (architecture right, details wrong).
// v004: 5x 8mm round drainage holes per horticultural guidance, kept.
// v002/v003: rim setback fix / open-tray rework (superseded).

$fn = 48;

// --- Shell: linear taper, ground to rim (per-body verts) ---
top_x   = 185.5;
top_y   = 117.5;
bot_x   = 163.2;   // skirt outer at Z=0 (+-81.59)
bot_y   = 95.2;    // (+-47.59)
draft   = 5;       // wall draft, degrees — all four walls
height  = (top_x - bot_x)/2 / tan(draft);   // 127.44 at 5deg (was 105)
// One height can only set every wall to `draft` because both directions
// share the same half-difference; keep it that way.
assert(abs((top_x - bot_x) - (top_y - bot_y)) < 1e-6,
       "X and Y tapers differ; a single height cannot give one draft");
ch_top  = 10.4;    // 45deg corner chamfer at the rim (was radius 10.4)
ch_bot  = 5;       // corner chamfer at the base
corner_rf = 3;     // fillet on the chamfer transition edges [10]; ~3mm
                   // is the ceiling before the bed-side rails droop
wall    = 3.2;     // 8x a 0.4mm extrusion line [1] (was 3)

// --- Rim: uniform wall thickness to the top, rounded outer lip.
//     The original design's flat-rim setback was removed in v013 at the
//     user's request; the wall runs full thickness to the rim. ---
rim_r = 3;   // top-edge roundover; on a 3.2 wall this sweeps to within
             // 0.2mm of the inner face (a near-full-width rounded lip)
assert(rim_r <= wall,
       "rim_r > wall: the roundover would undercut the inner face");

// --- Pot floor (STEP: bottom face Z=19, top ~22) ---
floor_bot = 19;
floor_top = 22;

// Drainage: 5 holes (v004 horticultural spec), hexagonal for the side
// print — pointed along pot-X so the points face print-vertical [3,4].
// 10x7 hex ~= 45mm2 open, matching the previous 8mm round hole.
drain_x  = 10;     // point-to-point, along pot-X
drain_y  = 7;      // across, along pot-Y
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// --- Hex ring band (verts: outline +-61.59 x +-27.59, wall 1.0 in file,
//     1.2 here for printability; merges into the tray plate below) ---
band_x    = 123.2;
band_y    = 55.2;
band_wall = 1.2;
band_ch   = 3;       // corner chamfer
band_top  = 15;      // straight band top; 45deg shoulder to floor above
hex_w     = 5.0;     // opening across (pot-Z on long walls; pot-X short)
hex_h     = 6.0;     // short-wall hex point-to-point height
hex_len   = 5.0;     // long-wall hex point-to-point along pot-X
hex_rise  = 2.2;     // long-wall point slope: 2.2 over 2.5 (~41deg)
hex_pitch = 6.5;
hex_cz    = 11;      // hexagon center height (long walls: 8.5..13.5)
n_hex_x   = 16;      // per long side
n_hex_y   = 6;       // per short side

// Struts: carry the tray. Tapered (widest at the tray weld), 3mm thick,
// centered under hex-grid columns so they read as band extensions.
strut_t     = 3.2;                // radial thickness (8x line width [1])
strut_w_bot = 10;                 // width at the tray weld
strut_w_top = 6;                  // width at the band bottom
strut_x     = [0, 45.5, -45.5];   // long-side struts (7 x 6.5 = hex column)
strut_y     = [0];                // short-side struts
corner_d    = 6;                  // corner post diameter
gap_h       = 5;                  // clear gap: tray floor (Z2) to band (Z7)

// --- Drip tray (verts exact) ---
tray_x    = 133.2;   // plate
tray_y    = 65.2;
tray_t    = 2;       // plate thickness
tray_ch   = 2.83;    // 45deg corner chamfer
brim_x    = 143.2;   // flared brim at Z5
brim_y    = 75.2;
brim_in_x = 139.2;   // brim top inner opening
brim_in_y = 71.2;
tray_h    = 5;

eps = 0.01;

band_bot = tray_t + gap_h;   // band floats above the tray floor

// Chamfered-rectangle corner points, shared by the prism modules.
function cham_pts(x, y, ch) =
    [[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
     [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
     [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]];

// Rectangle with sharp 45deg chamfered corners, extruded.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h) polygon(cham_pts(x, y, ch));
}

// Chamfer+fillet combo [10]: chamfered rectangle whose transition edges
// are rounded by rf (shrink, then round-offset back out). `inset`
// additionally shrinks the whole outline by a parallel offset — used to
// build the rim roundover slices.
module soft_prism(x, y, h, ch, rf, inset = 0) {
    linear_extrude(height = h)
        offset(r = rf) offset(delta = -rf - inset)
            polygon(cham_pts(x, y, ch));
}

// Outer shell with a rounded top edge: the hull's top is a stack of
// inset slices tracing a quarter-round of radius rim_r.
module outer_shell() {
    hull() {
        soft_prism(bot_x, bot_y, eps, ch_bot, corner_rf);
        for (t = [0, 30, 60, 90])
            translate([0, 0, height - rim_r + rim_r*sin(t) - eps])
                soft_prism(top_x, top_y, eps, ch_top, corner_rf,
                           inset = rim_r*(1 - cos(t)));
    }
}

// Tapered shell: hull of two soft prisms. The 45deg chamfer core prints
// from any orientation [9]; the rf-rounded transitions soften the look
// while confining >45deg surface to a sub-millimetre band in the side
// print (see the v011 note).
module shell(bx, by, tx, ty, h, cb, ct) {
    hull() {
        soft_prism(bx, by, eps, cb, corner_rf);
        translate([0, 0, h - eps]) soft_prism(tx, ty, eps, ct, corner_rf);
    }
}

// Band hexagon holes. The pot prints lying on its short side, so
// "print-vertical" inside the long band walls runs along pot-X: those
// hexes point along X (they read sideways upright, pointed in the
// print). The short band walls lie nearly horizontal in the print —
// orientation can't help them — so they keep the upright point-up look.
module hex_hole(cx, cz, axis) {
    if (axis == "x") {
        // Long walls: pointed along pot-X (print-vertical).
        hu = hex_len/2;             // half point-to-point, along X
        hv = hex_w/2;               // half opening, across pot-Z
        pts = [[-hu, cz], [-hu + hex_rise, cz + hv],
               [hu - hex_rise, cz + hv], [hu, cz],
               [hu - hex_rise, cz - hv], [-hu + hex_rise, cz - hv]];
        translate([cx, 0, 0]) rotate([90, 0, 0])
            translate([0, 0, -band_y/2 - 2])
                linear_extrude(height = band_y + 4) polygon(pts);
    } else {
        // Short walls: upright point-up hexes (cosmetic only here).
        pts = [[0, cz - hex_h/2], [hex_w/2, cz - hex_h/2 + 2.5],
               [hex_w/2, cz + hex_h/2 - 2.5], [0, cz + hex_h/2],
               [-hex_w/2, cz + hex_h/2 - 2.5], [-hex_w/2, cz - hex_h/2 + 2.5]];
        translate([0, cx, 0]) rotate([90, 0, 90])
            translate([0, 0, -band_x/2 - 2])
                linear_extrude(height = band_x + 4) polygon(pts);
    }
}

// Drainage hexagon: pointed along pot-X (print-vertical when the floor
// prints as a vertical wall), 45deg point slopes, punched along pot-Z.
module drain_hole() {
    hu = drain_x/2; hv = drain_y/2; rise = hv;   // rise = hv -> 45deg
    linear_extrude(height = floor_top - floor_bot + 4, center = true)
        polygon([[-hu, 0], [-hu + rise, hv], [hu - rise, hv],
                 [hu, 0], [hu - rise, -hv], [-hu + rise, -hv]]);
}

function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

module cavity() {
    translate([0, 0, -eps])
        shell(bot_x - 2*wall, bot_y - 2*wall,
              top_x - 2*wall, top_y - 2*wall,
              height + 2*eps, ch_bot, max(ch_top - wall, 1));
}

// Drainage must drip inside the hex band footprint (so it lands on the
// tray, which is wider than the band). Checked against the band's inner
// faces including its corner chamfer.
band_in_x  = band_x/2 - band_wall;
band_in_y  = band_y/2 - band_wall;
function holes_in_band() =
    [for (p = hole_pos)
        assert(abs(p[0]) + drain_x/2 < band_in_x,
               str("hole at ", p, " outside hex band in X"))
        assert(abs(p[1]) + drain_y/2 < band_in_y,
               str("hole at ", p, " outside hex band in Y"))
        // Bounding-rect support on the 45deg corner line (conservative).
        assert(abs(p[0]) + abs(p[1]) + (drain_x + drain_y)/2
                 < band_in_x + band_in_y - band_ch,
               str("hole at ", p, " outside hex band corner chamfer"))
        p];

// One tapered strut: hull of a wide foot (welded into the tray plate)
// and a narrower head (welded into the band bottom). Outer face flush
// with the band; body protrudes inward.
module strut_post(w_axis_len_bot, w_axis_len_top) {
    hull() {
        translate([0, 0, 1])   cube([w_axis_len_bot, strut_t, 2], center = true);
        translate([0, 0, band_bot + 0.5])
            cube([w_axis_len_top, strut_t, 1], center = true);
    }
}

module strut() {
    // Long sides: outer face flush with band outer (y = band_y/2).
    for (sy = [-1, 1], x = strut_x)
        translate([x, sy*(band_y/2 - strut_t/2), 0])
            strut_post(strut_w_bot, strut_w_top);
    // Short sides.
    for (sx = [-1, 1], y = strut_y)
        translate([sx*(band_x/2 - strut_t/2), y, 0])
            rotate([0, 0, 90])
                strut_post(strut_w_bot, strut_w_top);
    // Corner posts: round, tucked under the band's chamfered corners.
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(band_x/2 - band_ch - 0.6), sy*(band_y/2 - band_ch - 0.6), 0])
            cylinder(h = band_bot + 1, d = corner_d);
}

module pot() {
    difference() {
        union() {
            // Shell: solid skirt, ground to rim, linear taper.
            difference() {
                outer_shell();
                cavity();
            }
            // Floor.
            intersection() {
                cavity();
                translate([0, 0, floor_bot])
                    hex_prism(ox(floor_top), oy(floor_top),
                                floor_top - floor_bot, ch_bot);
            }
            // Hex band: straight band, then 45deg shoulder up to the floor.
            difference() {
                union() {
                    translate([0, 0, band_bot])
                        hex_prism(band_x, band_y, band_top - band_bot, band_ch);
                    hull() {
                        translate([0, 0, band_top - eps])
                            hex_prism(band_x, band_y, eps, band_ch);
                        translate([0, 0, floor_bot])
                            hex_prism(band_x + 2*(floor_bot - band_top),
                                      band_y + 2*(floor_bot - band_top),
                                      eps, band_ch);
                    }
                }
                // Band interior (leave the shoulder solid ring's inside too).
                translate([0, 0, band_bot - eps])
                    hex_prism(band_x - 2*band_wall, band_y - 2*band_wall,
                              floor_bot - band_bot + 2*eps, band_ch);
                // Hexagon perforations.
                for (i = [0 : n_hex_x - 1])
                    hex_hole((i - (n_hex_x - 1)/2) * hex_pitch, hex_cz, "x");
                for (j = [0 : n_hex_y - 1])
                    hex_hole((j - (n_hex_y - 1)/2) * hex_pitch, hex_cz, "y");
            }

            // Struts: tapered posts from the tray plate (buried to Z=0)
            // up into the band bottom (overlap 1mm past band_bot).
            strut();
        }

        // Drainage holes through the floor.
        for (p = holes_in_band())
            translate([p[0], p[1], (floor_bot + floor_top)/2])
                drain_hole();
    }
}

module tray() {
    difference() {
        // Plate + flare to the brim.
        hull() {
            hex_prism(tray_x, tray_y, tray_t, tray_ch);
            translate([0, 0, tray_h - 0.6])
                hex_prism(brim_x, brim_y, 0.6, tray_ch);
        }
        // Basin: funnel from the brim opening down to the plate top.
        hull() {
            translate([0, 0, tray_t + eps])
                hex_prism(tray_x - 2*tray_ch, tray_y - 2*tray_ch,
                          eps, tray_ch);
            translate([0, 0, tray_h])
                hex_prism(brim_in_x, brim_in_y, eps, 1.41);
        }
        // Open the basin through the brim plane.
        translate([0, 0, tray_h - eps])
            hex_prism(brim_in_x, brim_in_y, 2, 1.41);
    }
}

// One body: the band's buried portion welds the tray to the pot.
module main() {
    union() {
        pot();
        tray();
    }
}

if (is_list(holes_in_band())) main();
