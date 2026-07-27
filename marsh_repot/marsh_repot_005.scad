// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (Fusion export, 2026-07-10). Dimensions measured from the STEP's
// topological vertices and reconstructed face topology.
//
// v005: drip tray architecture corrected per user + STEP face topology.
//   The pot floor sits HIGH (Z 19..22) with 5 round drainage holes (the
//   STEP's Z=19 floor face has 6 bound loops = outer + 5 holes). Drips
//   fall into a shallow CENTER-ONLY tray at ground level (inner floor
//   face at Z=0, outline +-66.6 x +-32.6, chamfered corners). The tray
//   hangs from the floor by a chamfered-hex ring (outlines +-61.6 x
//   +-27.6 at Z 6.9..15.4) with open windows, and the skirt has windows
//   too — nothing is sealed: water evaporates out or pours out when
//   tilted. Catch plate / foot rail / overflow notches from v003-v004
//   are gone; they were a misreading of this structure.
// v004: 5x 8mm round drainage holes per horticultural guidance
//   (Purdue via Ask Extension; gardeningmentor.com), assert-guarded.
// v003: open skirt tray (superseded).
// v002: rim cutter fix (v001 shaved the outer rim edge).

$fn = 48;

// --- Overall form (STEP true-vertex bbox: X +-92.76, Y +-58.76, Z 0..105) ---
top_x   = 185.5;   // outer length at rim
top_y   = 117.5;   // outer width at rim
height  = 105;
bot_x   = 156;     // outer length at base (fit from corner-blend verts)
bot_y   = 88;      // outer width at base
r_top   = 10.4;    // rim corner radius (10.413 circles in STEP)
r_bot   = 4;       // base corner radius
wall    = 3;

// --- Rim: flat rim setback — 45deg inner chamfer, 1mm flat at the top ---
rim_flat  = 1;
setback_h = 4;

// --- Pot floor (STEP: dished faces at Z~22, hole face at Z=19) ---
floor_bot = 19;
floor_top = 22;

// Drainage: 5 round holes, one center + four in a quincunx (v004 research;
// the STEP's own floor face confirms 5 round holes).
hole_d   = 8;
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// --- Drip tray: center-only, ground level (STEP outline +-66.6 x +-32.6,
//     inner floor at Z=0, rim band to Z~2, flare to +-71.6 at Z~5) ---
tray_x    = 133.2;   // outer length
tray_y    = 65.2;    // outer width
tray_h    = 5.5;     // wall top (STEP collar top face at Z=5)
tray_t    = 1.5;     // floor thickness
tray_wall = 6;       // wide rim band (STEP Z=2 annulus: 60.6..66.6)
tray_ch   = 14;      // 45deg corner chamfer — the "hex" look

// --- Hex ring: hangs the tray from the pot floor (STEP outlines
//     +-61.6 x +-27.6 through Z 6.9..15.4) ---
ring_x    = 123.2;
ring_y    = 55.2;
ring_wall = 2.5;
ring_ch   = 12;      // corner chamfer, matches tray style
ring_win_h_frac = 0.75;  // window height fraction of ring span

// --- Skirt windows: openings all around so the tray bay is open ---
win_z0 = 3;          // window bottom
win_z1 = 16;         // window top
pillar = 22;         // material left at corners/mid-side pillars

eps = 0.01;

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

// Stretched hexagon: rectangle with 45deg chamfered corners, extruded.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h)
        polygon([[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
                 [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
                 [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]]);
}

// Outer size interpolated at height z.
function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

// Rim-setback cutter: tapered plug, walls leaning outward at 45 degrees.
module rim_cutter() {
    ix_top = top_x - 2*rim_flat;
    iy_top = top_y - 2*rim_flat;
    ov = 1;
    translate([0, 0, height - setback_h])
        shell(ix_top - 2*setback_h, iy_top - 2*setback_h,
              ix_top + 2*ov, iy_top + 2*ov,
              setback_h + ov, r_top, r_top);
}

// Full-height inner cavity (the wall tube is outer minus this).
module cavity() {
    translate([0, 0, -eps])
        shell(bot_x - 2*wall, bot_y - 2*wall,
              top_x - 2*wall, top_y - 2*wall,
              height + 2*eps, r_bot, max(r_top - wall, 1));
}

// Every drainage hole must drip strictly into the tray basin: hole edge
// inside the tray's inner walls, including the corner chamfer lines.
tray_in_x  = tray_x/2 - tray_wall;
tray_in_y  = tray_y/2 - tray_wall;
tray_in_ch = tray_ch;   // chamfer line: |x| + |y| <= in_x + in_y - ch
function holes_in_tray() =
    [for (p = hole_pos)
        assert(abs(p[0]) + hole_d/2 < tray_in_x,
               str("hole at ", p, " misses the tray in X"))
        assert(abs(p[1]) + hole_d/2 < tray_in_y,
               str("hole at ", p, " misses the tray in Y"))
        assert(abs(p[0]) + abs(p[1]) + hole_d/2 * 1.415
                 < tray_in_x + tray_in_y - tray_in_ch,
               str("hole at ", p, " misses the tray corner chamfer"))
        p];

module pot() {
    union() {
        difference() {
            union() {
                // Walls / skirt: tube, ground to rim.
                difference() {
                    shell(bot_x, bot_y, top_x, top_y, height, r_bot, r_top);
                    cavity();
                }
                // Pot floor: high, wall to wall.
                intersection() {
                    cavity();
                    translate([0, 0, floor_bot])
                        rounded_box(ox(floor_top), oy(floor_top),
                                    floor_top - floor_bot, r_bot);
                }
            }

            // Drainage holes.
            for (p = holes_in_tray())
                translate([p[0], p[1], (floor_bot + floor_top)/2])
                    cylinder(h = floor_top - floor_bot + 2,
                             d = hole_d, center = true);

            rim_cutter();

            // Skirt windows: the tray bay is open on all four sides.
            // Long sides: two windows each (pillars at x=0 and corners);
            // short sides: one window each.
            for (sy = [-1, 1]) for (sx = [-1, 1]) {
                wlen = (bot_x - 3*pillar) / 2;
                translate([sx*(pillar/2 + wlen/2), sy*bot_y/2,
                           (win_z0 + win_z1)/2])
                    cube([wlen, 2*wall + 6, win_z1 - win_z0], center = true);
            }
            for (sx = [-1, 1])
                translate([sx*bot_x/2, 0, (win_z0 + win_z1)/2])
                    cube([2*wall + 6, bot_y - 2*pillar, win_z1 - win_z0],
                         center = true);
        }

        // Drip tray: center-only basin at ground level.
        difference() {
            union() {
                hex_prism(tray_x, tray_y, tray_h, tray_ch);
                // Outward flare at the rim (STEP collar at Z 4.4..5.5).
                translate([0, 0, tray_h - 1.1])
                    hex_prism(tray_x + 5, tray_y + 5, 1.1, tray_ch + 2.5);
            }
            translate([0, 0, tray_t])
                hex_prism(tray_x - 2*tray_wall, tray_y - 2*tray_wall,
                          tray_h + 1, tray_ch);
        }

        // Hex ring: hangs the tray from the pot floor. Sits ON the tray's
        // wide rim band (ring outline 61.6 inside tray outline 66.6, on
        // the 60.6..66.6 band), rises to the pot floor, windowed.
        translate([0, 0, tray_h - 1])
            difference() {
                span = floor_bot - tray_h + 1;
                hex_prism(ring_x, ring_y, span + eps, ring_ch);
                translate([0, 0, -eps])
                    hex_prism(ring_x - 2*ring_wall, ring_y - 2*ring_wall,
                              span + 3*eps, ring_ch);
                // Windows: one per side, between tray rim and floor.
                wz = 1 + span * (1 - ring_win_h_frac)/2;
                for (sy = [-1, 1])
                    translate([0, sy*ring_y/2, wz + span*ring_win_h_frac/2])
                        cube([ring_x - 2*ring_ch - 2*pillar,
                              2*ring_wall + 4,
                              span*ring_win_h_frac], center = true);
                for (sx = [-1, 1])
                    translate([sx*ring_x/2, 0, wz + span*ring_win_h_frac/2])
                        cube([2*ring_wall + 4, ring_y - 2*ring_ch - 16,
                              span*ring_win_h_frac], center = true);
            }
    }
}

if (is_list(holes_in_tray())) pot();
