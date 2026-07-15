// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (Fusion export, 2026-07-10). Dimensions measured from the STEP's
// topological vertices; see comments on each parameter.
//
// v004: drainage per horticultural guidance (Purdue via Ask Extension;
// gardeningmentor.com): 5 round 8mm holes — one center + four at half the
// distance to the floor edge — replacing the 133-slot grid (~250mm2 vs
// ~900mm2 open area). Modest drainage suits a moisture-loving marsh plant;
// 8mm is large enough not to clog with soil. An assert guarantees every
// hole lands strictly on the catch plate below.
// v003: drip tray reworked per user. The bottom is an open skirt tray:
//   - skirt: the outer wall continues to the ground
//   - catch plate at Z 2..3.5 on a foot rail, overflow gap ring at its edge
//   - open drip gap 3.5..6.9
//   - slotted plant floor at Z 6.9..9.9 carried on ribs
//   - small overflow notches in the skirt bottom edge (verts at Z=1)
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

// --- Drip tray stack (Z plateaus 2.0 / 3.0 / 6.9 / 9.9, feet 0..2) ---
foot_h    = 2;      // foot rail height: tray plate clearance off the ground
tray_bot  = 2;      // catch plate bottom face
tray_top  = 3.5;    // catch plate top face
floor_bot = 6.9;    // slotted plant floor, bottom face
floor_top = 9.9;    // slotted plant floor, top face
overflow  = 3;      // gap ring between catch plate edge and skirt

// Drainage: round holes, one center + four in a quincunx at roughly half
// the distance from center to the floor edge.
hole_d   = 8;
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// Foot rail centerline rectangle (feet verts along X +-60, Y +-25)
foot_x = 120;
foot_y = 50;
foot_w = 5;

// Skirt overflow notches (verts at Z=1: 1mm tall, one per long side)
notch_w = 30;
notch_h = 1;

// Ribs carrying the plant floor down to the catch plate
rib_t = 2.5;

eps = 0.01;

// Every drainage hole must land strictly on the catch plate: hole edge
// (center + radius) inside the plate's half-extents. Evaluated inside
// pot() so a violation suppresses the geometry and the render/export
// scripts fail on "no output written" instead of shipping a bad part.
tray_half_x = (ox(tray_top) - 2*wall - 2*overflow) / 2;
tray_half_y = (oy(tray_top) - 2*wall - 2*overflow) / 2;
function holes_on_tray() =
    [for (p = hole_pos)
        assert(abs(p[0]) + hole_d/2 < tray_half_x,
               str("hole at ", p, " overhangs the catch plate in X"))
        assert(abs(p[1]) + hole_d/2 < tray_half_y,
               str("hole at ", p, " overhangs the catch plate in Y"))
        p];

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

// Full-height inner cavity (the skirt tube is outer minus this).
module cavity() {
    translate([0, 0, -eps])
        shell(bot_x - 2*wall, bot_y - 2*wall,
              top_x - 2*wall, top_y - 2*wall,
              height + 2*eps, r_bot, max(r_top - wall, 1));
}

module pot() {
    difference() {
        union() {
            // Walls / skirt: a pure tube, ground to rim.
            difference() {
                shell(bot_x, bot_y, top_x, top_y, height, r_bot, r_top);
                cavity();
            }

            // Plant floor, wall to wall (clipped to the cavity), with round
            // drainage holes that all drip onto the catch plate below.
            intersection() {
                cavity();
                difference() {
                    translate([0, 0, floor_bot])
                        rounded_box(ox(floor_top), oy(floor_top),
                                    floor_top - floor_bot, r_bot);
                    for (p = holes_on_tray())
                        translate([p[0], p[1], (floor_bot + floor_top)/2])
                            cylinder(h = floor_top - floor_bot + 2,
                                     d = hole_d, center = true);
                }
            }

            // Catch plate: solid, inset by the overflow gap.
            translate([0, 0, tray_bot])
                rounded_box(ox(tray_top) - 2*wall - 2*overflow,
                            oy(tray_top) - 2*wall - 2*overflow,
                            tray_top - tray_bot, r_bot);

            // Ribs: catch plate up to the plant floor. Two longitudinal,
            // three transverse, kept inside the catch plate footprint.
            for (y = [-22, 22])
                translate([0, y, tray_top - eps])
                    cube([2*(ox(tray_top)/2 - wall - overflow - r_bot),
                          rib_t, floor_bot - tray_top + 2*eps], center = true);
            for (x = [-45, 0, 45])
                translate([x, 0, tray_top - eps])
                    cube([rib_t,
                          2*(oy(tray_top)/2 - wall - overflow - r_bot),
                          floor_bot - tray_top + 2*eps], center = true);

            // Foot rail ring under the catch plate.
            difference() {
                rounded_box(foot_x + foot_w, foot_y + foot_w, foot_h + eps, r_bot);
                translate([0, 0, -eps])
                    rounded_box(foot_x - foot_w, foot_y - foot_w,
                                foot_h + 3*eps, r_bot);
            }
        }

        rim_cutter();

        // Overflow notches in the skirt bottom edge, one per long side.
        for (sy = [-1, 1])
            translate([0, sy * bot_y/2, notch_h/2 - eps])
                cube([notch_w, 2*wall + 4, notch_h + 2*eps], center = true);
    }
}

// Gate on the hole check: if any hole misses the catch plate the assert
// kills this whole statement, no geometry is produced, and render/export
// fail loudly on the missing output file.
if (is_list(holes_on_tray())) pot();
