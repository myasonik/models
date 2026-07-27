// switch_plate_001.scad
// Screwless two-gang wall plate, two-part design (US device dimensions).
// Left gang: opening for a standard toggle switch. Right gang: blank.
//
// Part 1 "base": screws to the switch yoke (left, 6-32 at 60.3 mm spacing)
// and to the box's device holes (right, 83.3 mm spacing) with countersunk
// flat-head screws. A perimeter rim carries four chamfered snap ridges.
// Part 2 "cover": snap shell, no visible fasteners. Its side walls have
// windows that click over the base's ridges; a pry notch on the bottom
// edge releases it. Cover prints face-down, base prints back-down.
//
// part = "both" lays the two out side by side (~257 mm wide — render one
// part at a time for smaller beds).

part = "both"; // "base" | "cover" | "both"

$fa = 2;
$fs = 0.4;

// ---- device standards (US) ----
gang_dx   = 23.02;   // half of 1.812 in gang-to-gang spacing
yoke_dy   = 30.16;   // half of 2-3/8 in yoke screw spacing (6-32)
box_dy    = 41.67;   // half of 3-9/32 in box device-screw spacing
tog_w     = 11.5;    // toggle opening in cover (10.4 x 24 nominal + play)
tog_h     = 25;
base_tog_w = 14;     // larger pass-through in base for the toggle bushing
base_tog_h = 28;

// ---- cover shell ----
cov_w     = 125;
cov_h     = 125;
cov_r     = 8;       // corner radius
cov_d     = 8;       // total depth incl. face
face_t    = 2.4;
wall_t    = 1.6;     // 4 x 0.4 mm perimeters

// ---- base plate ----
clr       = 0.4;     // lateral base-to-cover clearance [6]
base_w    = cov_w - 2*wall_t - 2*clr;   // 121.0
base_h    = cov_h - 2*wall_t - 2*clr;
base_r    = cov_r - wall_t;
base_t    = 2.4;
rim_t     = 1.6;
rim_h     = 4;       // rim rises base_t..base_t+rim_h
relief_d  = 1.2;     // back pocket so a proud switch yoke sits flush
screw_d   = 3.6;     // 6-32 free fit
cs_d      = 7.2;     // flat-head countersink diameter
cs_depth  = 1.8;     // gives a 45 deg countersink cone [9]

// ---- snap fit ----
bump_y    = 28;      // ridge centers, +/- on left and right edges
bump_len  = 10;
bump_d    = 1.4;     // ridge proudness; 1.0 mm engages past the 0.4 clearance
bump_hh   = 1.1;     // ridge half-height (45 deg chamfer both ways)
win_len   = 12;      // snap window in cover wall
win_h     = 2.6;
// assembled: rim center z = base_t + rim_h/2; cover back edge sits at
// base_t + rim_h + 0.3 + face_t - cov_d above the wall
cov_back_z = base_t + rim_h + 0.3 + face_t - cov_d;   // 1.3
win_z      = base_t + rim_h/2 - cov_back_z;           // 3.2 from cover back edge

module rrect(w, h, r) {
    offset(r = r) square([w - 2*r, h - 2*r], center = true);
}

// horizontal snap ridge, triangular profile, pointing +x, length along y
module ridge() {
    rotate([90, 0, 0])
        linear_extrude(bump_len, center = true)
            polygon([[0, -bump_hh], [bump_d, 0], [0, bump_hh]]);
}

module base() {
    difference() {
        union() {
            linear_extrude(base_t) rrect(base_w, base_h, base_r);
            translate([0, 0, base_t]) linear_extrude(rim_h)
                difference() {
                    rrect(base_w, base_h, base_r);
                    rrect(base_w - 2*rim_t, base_h - 2*rim_t, base_r - rim_t);
                }
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*base_w/2, sy*bump_y, base_t + rim_h/2])
                    rotate([0, 0, sx > 0 ? 0 : 180]) ridge();
        }
        // toggle pass-through (left gang)
        translate([-gang_dx, 0, -1])
            linear_extrude(base_t + 2) square([base_tog_w, base_tog_h], center = true);
        // yoke screw holes, countersunk (left gang)
        for (sy = [-1, 1]) translate([-gang_dx, sy*yoke_dy, 0]) {
            translate([0, 0, -1]) cylinder(d = screw_d, h = base_t + 2);
            translate([0, 0, base_t - cs_depth])
                cylinder(d1 = screw_d, d2 = cs_d, h = cs_depth + 0.01);
        }
        // box screw holes, countersunk (right gang, blank)
        for (sy = [-1, 1]) translate([gang_dx, sy*box_dy, 0]) {
            translate([0, 0, -1]) cylinder(d = screw_d, h = base_t + 2);
            translate([0, 0, base_t - cs_depth])
                cylinder(d1 = screw_d, d2 = cs_d, h = cs_depth + 0.01);
        }
        // back relief pocket so the switch yoke doesn't rock the plate
        translate([-gang_dx, 0, -0.01])
            linear_extrude(relief_d) square([26, 76], center = true);
    }
}

// modeled assembled-orientation: back edge z=0, face outer z=cov_d
module cover() {
    union() {
        difference() {
            linear_extrude(cov_d) rrect(cov_w, cov_h, cov_r);
            // hollow interior up to the face inner surface
            translate([0, 0, -1])
                linear_extrude(cov_d - face_t + 1)
                    rrect(cov_w - 2*wall_t, cov_h - 2*wall_t, cov_r - wall_t);
            // toggle opening (left gang)
            translate([-gang_dx, 0, cov_d - face_t - 1])
                linear_extrude(face_t + 2) square([tog_w, tog_h], center = true);
            // snap windows through both side walls
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*cov_w/2, sy*bump_y, win_z])
                    cube([2*wall_t + 2, win_len, win_h], center = true);
            // pry notch, bottom edge
            translate([0, -cov_h/2, 0])
                cube([12, 2*wall_t + 2, 3], center = true);
        }
        // stiffening rib between the gangs
        translate([0, 0, win_z - 0.8])
            linear_extrude(cov_d - face_t - win_z + 0.8)
                square([1.6, 110], center = true);
    }
}

if (part == "base" || part == "both")
    translate([part == "both" ? -67 : 0, 0, 0]) base();
if (part == "cover" || part == "both")
    translate([part == "both" ? 67 : 0, 0, cov_d])
        rotate([0, 180, 0]) cover();   // face-down for printing
