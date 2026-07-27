// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (two-body Fusion export, 2026-07-10) plus the user's section screenshots.
// Dimensions taken from per-body vertex extraction; see comments.
//
// TWO PARTS: set `part` to "pot", "tray", or "all" (assembly preview).
//
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
//   - In the source file the band interpenetrates the tray plate by 2mm
//     (CAD interference); here the band stops 0.2mm above the tray floor
//     so the parts actually fit.
// v005: center tray + windowed ring (architecture right, details wrong).
// v004: 5x 8mm round drainage holes per horticultural guidance, kept.
// v002/v003: rim setback fix / open-tray rework (superseded).

part = "pot";   // "pot" | "tray" | "all"

$fn = 48;

// --- Shell: linear taper, ground to rim (per-body verts) ---
top_x   = 185.5;
top_y   = 117.5;
bot_x   = 163.2;   // skirt outer at Z=0 (+-81.59)
bot_y   = 95.2;    // (+-47.59)
height  = 105;
r_top   = 10.4;
r_bot   = 5;
wall    = 3;

// --- Rim: flat rim setback ---
rim_flat  = 1;
setback_h = 4;

// --- Pot floor (STEP: bottom face Z=19, top ~22) ---
floor_bot = 19;
floor_top = 22;

// Drainage: 5 round 8mm holes (v004 horticultural spec; the STEP floor
// face also carries 5 round holes).
hole_d   = 8;
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// --- Hex ring band (verts: outline +-61.59 x +-27.59, wall 1.0 in file,
//     1.2 here for printability; band bottom at tray_t + clearance) ---
band_x    = 123.2;
band_y    = 55.2;
band_wall = 1.2;
band_ch   = 3;       // corner chamfer
band_top  = 15;      // straight band top; 45deg shoulder to floor above
hex_w     = 5.0;     // hexagon width (flat-to-flat across mid corners)
hex_h     = 8.0;     // hexagon point-to-point height
hex_pitch = 6.5;
hex_cz    = 8.4;     // hexagon center height (points at 4.4 / 12.4)
n_hex_x   = 16;      // per long side
n_hex_y   = 6;       // per short side
notch_w   = 1.5;     // castellation under each hex
notch_h   = 1.5;
clearance = 0.2;     // band bottom to tray floor top

// --- Drip tray (separate part; verts exact) ---
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

band_bot = tray_t + clearance;

// Tapered rounded-rectangle shell: hull of four bottom and four top discs.
module shell(bx, by, tx, ty, h, rb, rt) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(bx/2 - rb), sy*(by/2 - rb), 0])
                cylinder(h = eps, r = rb);
            translate([sx*(tx/2 - rt), sy*(ty/2 - rt), h - eps])
                cylinder(h = eps, r = rt);
        }
    }
}

module rounded_box(x, y, h, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(x/2 - r), sy*(y/2 - r), 0])
            cylinder(h = h, r = r);
}

// Rectangle with 45deg chamfered corners, extruded.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h)
        polygon([[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
                 [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
                 [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]]);
}

// Point-up hexagon prism, for punching band holes. Long axis along `axis`.
module hex_hole(cx, cz, axis) {
    pts = [[0, cz - hex_h/2], [hex_w/2, cz - hex_h/2 + 2.5],
           [hex_w/2, cz + hex_h/2 - 2.5], [0, cz + hex_h/2],
           [-hex_w/2, cz + hex_h/2 - 2.5], [-hex_w/2, cz - hex_h/2 + 2.5]];
    if (axis == "x")
        translate([cx, 0, 0]) rotate([90, 0, 0])
            translate([0, 0, -band_y/2 - 2])
                linear_extrude(height = band_y + 4) polygon(pts);
    else
        translate([0, cx, 0]) rotate([90, 0, 90])
            translate([0, 0, -band_x/2 - 2])
                linear_extrude(height = band_x + 4) polygon(pts);
}

function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

module rim_cutter() {
    ix_top = top_x - 2*rim_flat;
    iy_top = top_y - 2*rim_flat;
    ov = 1;
    translate([0, 0, height - setback_h])
        shell(ix_top - 2*setback_h, iy_top - 2*setback_h,
              ix_top + 2*ov, iy_top + 2*ov,
              setback_h + ov, r_top, r_top);
}

module cavity() {
    translate([0, 0, -eps])
        shell(bot_x - 2*wall, bot_y - 2*wall,
              top_x - 2*wall, top_y - 2*wall,
              height + 2*eps, r_bot, max(r_top - wall, 1));
}

// Drainage must drip inside the hex band footprint (so it lands on the
// tray, which is wider than the band). Checked against the band's inner
// faces including its corner chamfer.
band_in_x  = band_x/2 - band_wall;
band_in_y  = band_y/2 - band_wall;
function holes_in_band() =
    [for (p = hole_pos)
        assert(abs(p[0]) + hole_d/2 < band_in_x,
               str("hole at ", p, " outside hex band in X"))
        assert(abs(p[1]) + hole_d/2 < band_in_y,
               str("hole at ", p, " outside hex band in Y"))
        assert(abs(p[0]) + abs(p[1]) + hole_d/2 * 1.415
                 < band_in_x + band_in_y - band_ch,
               str("hole at ", p, " outside hex band corner chamfer"))
        p];

module pot() {
    difference() {
        union() {
            // Shell: solid skirt, ground to rim, linear taper.
            difference() {
                shell(bot_x, bot_y, top_x, top_y, height, r_bot, r_top);
                cavity();
            }
            // Floor.
            intersection() {
                cavity();
                translate([0, 0, floor_bot])
                    rounded_box(ox(floor_top), oy(floor_top),
                                floor_top - floor_bot, r_bot);
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
                // Castellated bottom edge: notch under each hex.
                for (i = [0 : n_hex_x - 1])
                    translate([(i - (n_hex_x - 1)/2) * hex_pitch, 0,
                               band_bot + notch_h/2])
                        cube([notch_w, band_y + 4, notch_h + 2*eps],
                             center = true);
                for (j = [0 : n_hex_y - 1])
                    translate([0, (j - (n_hex_y - 1)/2) * hex_pitch,
                               band_bot + notch_h/2])
                        cube([band_x + 4, notch_w, notch_h + 2*eps],
                             center = true);
            }
        }

        // Drainage holes through the floor.
        for (p = holes_in_band())
            translate([p[0], p[1], (floor_bot + floor_top)/2])
                cylinder(h = floor_top - floor_bot + 2,
                         d = hole_d, center = true);

        rim_cutter();
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

module main() {
    if (part == "pot" || part == "all") pot();
    if (part == "tray" || part == "all") tray();
}

if (is_list(holes_in_band())) main();
