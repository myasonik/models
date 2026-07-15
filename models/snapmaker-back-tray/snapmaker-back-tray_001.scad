// Snapmaker back gridfinity tray — recreation of snapmaker_back_gridfinity-v7
// (measured from the v7 STEP/3MF), plus one extra screw hole carried over
// from rear-tray.3mf (models centered on top of each other: hole lands at
// x=0, y=-9.75 — on the center divider).
//
// Geometry is hand-built to match the measured v7 reference exactly (the
// library baseplate module can't produce this hybrid: solid end pads over
// the end cells, through-openings, custom outer size, zero-clearance
// sockets). Socket profile measured: 0.7 @45 / 1.8 straight / 2.15 @45,
// bottom opening 36.3 sq r1.15, top opening 42.0 sq r4.0 per cell.
//
// Coordinates: x/y match the original files (x centered on 0,
// cell row center at y = -7.25); z rebased so the underside is z = 0.

$fa = 4;
$fs = 0.25;

// ---------------- user-tweakable parameters ----------------
cells        = 6;        // grid cells along x (42mm pitch)
pitch        = 42;
outer_len    = 263.6;    // overall x
outer_wid    = 44;       // overall y
total_h      = 8.95;     // overall z
corner_r     = 2;        // outer corner radius

cell_cy      = -7.25;    // y of cell-row centerline (original frame)
y_min        = cell_cy - outer_wid/2;         // outer outline is symmetric
                                              // about the cell centerline

// socket (baseplate) profile, bottom to top
prof_h       = 4.65;                 // socket profile height
prof_seg     = [0.7, 1.8, 2.15];     // 45deg / straight / 45deg
sock_top_hw  = pitch/2;              // 21.0 — zero-clearance 42.0 opening
sock_top_r   = 4.0;                  // corner radius at socket top
sock_bot_hw  = sock_top_hw - prof_seg[0] - prof_seg[2];  // 18.15
sock_bot_r   = sock_top_r  - prof_seg[0] - prof_seg[2];  // 1.15
sock_z       = total_h - prof_h;     // 4.3 — profile start height
recess      = 0.1;                   // socket floor recess below profile start

// solid end pads (cover the outer part of the end cells)
pad_inner_x  = 108;      // pads run from |x|=108 to the outer edge

// underside grooves, one per end, running in from the end faces
groove_w     = 3.3;      // y width
groove_h     = 3.2;      // z height from the underside
groove_cy    = -16.5;    // y center
groove_depth = 23.8;     // how far in from each end face (reaches x=+-108)

// screw holes: countersink dia8 -> shaft dia3.7 -> 45deg reducer -> pilot dia2.3
cs_r         = 4.0;      // countersink top radius (at the top face)
shaft_r      = 1.85;
pilot_r      = 1.15;
shaft_top_z  = total_h - (cs_r - shaft_r);          // 6.8
shaft_bot_z  = sock_z + prof_seg[0];                // 5.0
pilot_top_z  = shaft_bot_z - (shaft_r - pilot_r);   // 4.3

// 4 corner holes (concentric with the socket top corner arcs) + 1 hole
// mapped from rear-tray.3mf (centers of both models aligned)
corner_hole_x = cells/2*pitch - sock_top_r;         // 122
hole_pos = [
    [-corner_hole_x, cell_cy - sock_top_hw + sock_top_r],  // (-122, -24.25)
    [-corner_hole_x, cell_cy + sock_top_hw - sock_top_r],  // (-122,   9.75)
    [ corner_hole_x, cell_cy - sock_top_hw + sock_top_r],  // ( 122, -24.25)
    [ corner_hole_x, cell_cy + sock_top_hw - sock_top_r],  // ( 122,   9.75)
    [ 0, -9.75],                                           // from rear-tray
];

eps = 0.01;

// ---------------- helpers ----------------

// rounded-rect slab: footprint size x*y (centered), corner radius r
module rslab(x, y, r, h) {
    linear_extrude(h)
        offset(r = r) square([x - 2*r, y - 2*r], center = true);
}

// one cell's socket cutter: measured baseplate profile swept around the
// cell footprint, built as hulls of thin rounded-rect slices
module socket_cutter() {
    z0 = sock_z;
    z1 = z0 + prof_seg[0];
    z2 = z1 + prof_seg[1];
    z3 = z2 + prof_seg[2];
    hw0 = sock_bot_hw;             // 18.15 @ z0
    hw1 = sock_bot_hw + prof_seg[0];  // 18.85 @ z1..z2
    r0 = sock_bot_r; r1 = r0 + prof_seg[0];
    // 45deg lower flare
    hull() {
        translate([0, 0, z0]) rslab(2*hw0, 2*hw0, r0, eps);
        translate([0, 0, z1 - eps]) rslab(2*hw1, 2*hw1, r1, eps);
    }
    // straight section
    translate([0, 0, z1 - eps]) rslab(2*hw1, 2*hw1, r1, z2 - z1 + 2*eps);
    // 45deg upper flare, extended past the top face
    hull() {
        translate([0, 0, z2]) rslab(2*hw1, 2*hw1, r1, eps);
        translate([0, 0, z3]) rslab(2*sock_top_hw, 2*sock_top_hw, sock_top_r, eps);
    }
    translate([0, 0, z3 - eps])
        rslab(2*sock_top_hw, 2*sock_top_hw, sock_top_r, 1);
    // 0.1 floor recess below the profile (shapes the end-pad floors)
    translate([0, 0, z0 - recess]) rslab(2*hw0, 2*hw0, r0, recess + eps);
}

// countersunk screw hole, top face at z = total_h
module screw_hole() {
    translate([0, 0, total_h])                  // countersink dia8 -> dia3.7
        cylinder(h = cs_r - shaft_r + eps, r1 = cs_r, r2 = shaft_r + eps,
                 center = false) ;
    translate([0, 0, shaft_top_z + eps]) mirror([0, 0, 1])
        cylinder(h = cs_r - shaft_r + 2*eps, r1 = shaft_r + eps, r2 = cs_r);
    translate([0, 0, shaft_bot_z])              // dia3.7 shaft
        cylinder(h = shaft_top_z - shaft_bot_z + eps, r = shaft_r);
    translate([0, 0, pilot_top_z])              // 45deg reducer
        cylinder(h = shaft_r - pilot_r, r1 = pilot_r, r2 = shaft_r);
    translate([0, 0, -eps])                     // dia2.3 pilot, through
        cylinder(h = pilot_top_z + 2*eps, r = pilot_r);
}

// ---------------- model ----------------
difference() {
    // outer body
    translate([0, y_min + outer_wid/2, 0])
        rslab(outer_len, outer_wid, corner_r, total_h);

    for (i = [0 : cells - 1]) {
        cx = (i - (cells - 1)/2) * pitch;
        // socket
        translate([cx, cell_cy, 0]) socket_cutter();
        // through-opening below the socket, clipped by the end pads
        intersection() {
            translate([cx - sock_bot_hw, cell_cy - sock_bot_hw, -eps])
                cube([2*sock_bot_hw, 2*sock_bot_hw, sock_z + 2*eps]);
            translate([-pad_inner_x, y_min - 1, -2*eps])
                cube([2*pad_inner_x, outer_wid + 2, sock_z + 4*eps]);
        }
    }

    // underside grooves in from both end faces
    for (sx = [-1, 1]) scale([sx, 1, 1])
        translate([outer_len/2 - groove_depth, groove_cy - groove_w/2, -eps])
            cube([groove_depth + 1, groove_w, groove_h + eps]);

    // screw holes
    for (p = hole_pos) translate([p.x, p.y, 0]) screw_hole();
}

echo(str("Tray: ", outer_len, " x ", outer_wid, " x ", total_h,
         " mm, ", cells, " cells @ ", pitch, "mm"));
echo(str("Extra hole from rear-tray at ", hole_pos[4]));
