// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (Fusion export, 2026-07-10). Dimensions measured from the STEP's
// topological vertices; see comments on each parameter.
//
// Simplifications vs the Fusion original: edge fillets and the stepped rim
// micro-profile are approximated (stepped setback -> single 45-degree
// chamfer), and the foot rail is one continuous ring instead of segments.

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

// --- Rim: "flat rim setback" — inner chamfer over the top 4mm leaves a
//     1mm flat at Z=105 (rim verts step 92.76 -> 91.78 at Z 105 -> 101.3)
rim_flat  = 1;
setback_h = 4;

// --- Raised slotted floor (Z plateaus 2..3 bottom, ~10 top) ---
floor_bot = 3;
floor_top = 10;

// Drainage grid: 2.6mm square holes, 6.5mm pitch, field +-63 x +-19.5
slot    = 2.6;
pitch   = 6.5;
slots_x = 19;
slots_y = 7;

// --- Foot rail under the floor (verts at Z 0..3 along X +-60, Y +-25) ---
foot_x = 120;      // rail centerline rectangle
foot_y = 50;
foot_w = 5;

eps = 0.01;        // boolean overlap so every cut stays manifold

// Tapered rounded-rectangle shell: hull of four bottom and four top corner
// discs. Straight ruled walls, rounded vertical corners.
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

// Outer size interpolated at height z (for sizing interior features).
function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

// Rim-setback cutter: rectangular ring wedge. Inner boundary is vertical at
// (top_x - 2*rim_flat - 2*setback_h) at the bottom growing to
// (top_x - 2*rim_flat) at the top would give 45 degrees; the outer boundary
// reaches past the shell so the cut opens outward.
module rim_cutter() {
    ix_top = top_x - 2*rim_flat;
    iy_top = top_y - 2*rim_flat;
    translate([0, 0, height - setback_h])
        difference() {
            rounded_box(top_x + 2, top_y + 2, setback_h + eps, r_top);
            // 45-degree chamfer surface: small at bottom, full at top.
            translate([0, 0, -eps])
                shell(ix_top - 2*setback_h, iy_top - 2*setback_h,
                      ix_top, iy_top,
                      setback_h + 3*eps, r_top, r_top);
        }
}

module pot() {
    union() {
        difference() {
            shell(bot_x, bot_y, top_x, top_y, height, r_bot, r_top);

            // Main cavity: starts at floor_top, leaving the floor slab.
            translate([0, 0, floor_top])
                shell(ox(floor_top) - 2*wall, oy(floor_top) - 2*wall,
                      top_x - 2*wall, top_y - 2*wall,
                      height - floor_top + 1, r_bot, max(r_top - wall, 1));

            // Underside pocket below the floor (feet added back after).
            translate([0, 0, -eps])
                rounded_box(ox(floor_bot) - 2*wall, oy(floor_bot) - 2*wall,
                            floor_bot + 2*eps, r_bot);

            // Drainage holes through the floor slab, centered grid.
            for (i = [0 : slots_x - 1], j = [0 : slots_y - 1])
                translate([(i - (slots_x - 1)/2) * pitch,
                           (j - (slots_y - 1)/2) * pitch,
                           (floor_bot + floor_top)/2])
                    cube([slot, slot, floor_top - floor_bot + 4], center = true);

            rim_cutter();
        }

        // Foot rail ring, Z 0..floor_bot.
        difference() {
            rounded_box(foot_x + foot_w, foot_y + foot_w, floor_bot, r_bot);
            translate([0, 0, -eps])
                rounded_box(foot_x - foot_w, foot_y - foot_w,
                            floor_bot + 2*eps, r_bot);
        }
    }
}

pot();
