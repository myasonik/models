// switch_plate_002.scad
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
// v002: coat of arms engraved 0.6 mm into the blank right gang [24] --
// ash tree between a bear rampant (left) and a fox rampant (right),
// both facing the tree with forepaws raised, on a ground line, inside
// a heater-shield border groove.
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
cov_back_z = base_t + rim_h + 0.3 + face_t - cov_d;
win_z      = base_t + rim_h/2 - cov_back_z;

// ---- coat of arms ----
engrave_d = 0.6;     // 3 layers deep; leaves 1.8 mm of face

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

// ======================= coat of arms (2D art) =========================
// Local coords: shield centered on origin, ~38 wide x 39 tall.

function bez(p0, p1, p2, t) =
    (1-t)*(1-t)*p0 + 2*(1-t)*t*p1 + t*t*p2;

// round-bottomed (Iberian) shield: straight sides, elliptical base --
// wider at the bottom than a heater, so the supporters' feet fit
module shield2d() {
    polygon(concat(
        [[-19, 18], [19, 18]],
        [for (th = [0:5:180]) [19*cos(th), -8 - 13*sin(th)]]
    ));
}

// capsule between two points (limbs, torsos)
module limb(a, b, ra, rb) {
    hull() { translate(a) circle(ra); translate(b) circle(rb); }
}

module tree2d() {   // ash: flared trunk, tall narrow crown clear of the paws
    polygon([[-2.6, -14.8], [-1.1, -8], [-1.1, 9],
             [1.1, 9], [1.1, -8], [2.6, -14.8]]);
    for (p = [[0, 12, 3.4], [-2.7, 10.2, 2.8], [2.7, 10.2, 2.8],
              [0, 9.2, 3.4], [-1.6, 7.6, 2.2], [1.6, 7.6, 2.2]])
        translate([p.x, p.y]) circle(p.z);
}

module bear2d() {   // rampant, facing the tree (+x); bulky, round ears
    limb([-11.6, -8.6], [-9.4, -0.6], 3.2, 2.8);      // torso
    limb([-8.2, 3.4], [-9.4, -0.8], 1.5, 1.8);        // neck
    translate([-8.2, 3.6]) circle(2.2);               // head
    translate([-9.9, 5.4]) circle(0.95);              // ear
    translate([-7.1, 5.9]) circle(0.95);              // ear
    limb([-8.2, 3.4], [-6.4, 3.1], 1.4, 0.85);        // muzzle toward tree
    limb([-7.0, -1.8], [-3.6, 3.4], 1.15, 1.05);      // upper forepaw, raised
    limb([-7.6, -2.6], [-3.4, 0.6], 1.15, 1.0);       // lower forepaw, raised
    limb([-11.2, -9.2], [-10.2, -14.2], 2.6, 1.4);    // near hind leg
    limb([-10.2, -14.3], [-8.7, -14.4], 1.4, 1.2);    // near foot
    limb([-13.0, -9.6], [-13.5, -14.2], 2.2, 1.2);    // far hind leg
    limb([-13.5, -14.3], [-12.3, -14.4], 1.2, 1.05);  // far foot
    translate([-14.6, -7.4]) circle(1.0);             // stub tail
}

module fox2d() {    // rampant, facing the tree (-x); slim, pointed, brush tail
    limb([11.4, -8.6], [9.6, -0.6], 2.5, 2.1);        // torso
    limb([8.4, 3.6], [9.7, -0.8], 1.1, 1.4);          // neck
    translate([8.3, 4.1]) circle(1.8);                // head
    limb([8.3, 3.8], [5.7, 3.9], 1.2, 0.45);          // pointed snout toward tree
    polygon([[7.3, 5.4], [6.7, 7.6], [8.5, 5.9]]);    // ear
    polygon([[8.7, 5.6], [9.5, 7.5], [9.9, 5.3]]);    // ear
    limb([7.9, -1.6], [3.7, 3.4], 0.9, 0.8);          // upper forepaw, raised
    limb([8.3, -2.2], [3.5, 0.6], 0.9, 0.8);          // lower forepaw, raised
    limb([11.0, -9.2], [10.3, -14.3], 2.1, 1.1);      // near hind leg
    limb([10.3, -14.4], [9.1, -14.5], 1.1, 0.95);     // near foot
    limb([12.6, -9.6], [13.4, -14.3], 1.9, 1.05);     // far hind leg
    limb([13.4, -14.4], [12.3, -14.5], 1.05, 0.9);    // far foot
    limb([12.9, -10.2], [13.9, -6.6], 1.35, 1.45);    // brush tail, curving up
    limb([13.9, -6.6], [13.3, -3.2], 1.45, 1.05);
}

module ground2d() { limb([-15, -15.6], [15, -15.6], 1.0, 1.0); }

module coat_of_arms2d() {
    difference() { shield2d(); offset(r = -1.4) shield2d(); }  // border groove
    intersection() {  // keep all art clear of the border groove
        union() { tree2d(); bear2d(); fox2d(); ground2d(); }
        offset(r = -2.4) shield2d();
    }
}
// =======================================================================

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
            // engraved coat of arms (right gang) [24]
            translate([gang_dx, 0, cov_d - engrave_d])
                linear_extrude(engrave_d + 1) coat_of_arms2d();
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
