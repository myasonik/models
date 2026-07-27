// switch_plate_006.scad
// Screwless two-gang wall plate, two-part design (US device dimensions).
// Left gang: opening for a standard toggle switch. Right gang: blank.
//
// Part 1 "base": screws to the switch yoke (left, 6-32 at 60.3 mm spacing)
// and to the box's device holes (right, 83.3 mm spacing) with countersunk
// flat-head screws. A perimeter rim carries four french-cleat hook lugs.
// Part 2 "cover": slide-on shell, no visible fasteners. Bayonet slots in
// its side walls drop over the lugs: hold the cover trav high, press it
// to the wall, slide it down. The 45 deg bevel atop each lug wedges the
// cover toward the wall as it slides (cleat action) until the face seats
// on the rim. A thumb notch on the bottom edge helps slide it back up.
//
// v002: coat of arms engraved 0.6 mm into the blank right gang [24] --
// ash tree between a bear rampant (left) and a fox rampant (right),
// both facing the tree with forepaws raised, on a ground line, inside
// a heater-shield border groove.
//
// v003: audit fixes -- 6-32 clearance holes opened to 3.9 (printed holes
// shrink; 3.6 was line-to-line on a 3.51 mm screw), countersinks to 7.5
// to keep the 45 deg cone, and the back relief pocket lengthened to 92
// so the switch's box-mounting screw heads and plaster ears at y +/-41.7
// sit inside it instead of rocking the plate.
//
// v004: PLACEHOLDER 3D emblem (roundel + pyramidal star + dome) raised
// off the right gang instead of the engraving; cover flipped to a
// face-up print with slicer supports filling the interior.
//
// v005: the cover no longer needs slicer supports. Modeled sacrificial
// props [13,15,23] stand on the bed inside the cavity -- thin walls on
// a <=17 mm pitch the face bridges between, plus a spine under the
// stiffening rib -- each necked to a 0.3 mm knife-edge at the top so
// it snaps out through the open back before assembly. Slice the cover
// with supports OFF and a brim; face and emblem print clean on top.
// The 2D coat-of-arms art is kept below for the final emblem.
// Base still prints support-free, back-down.
//
// v006: snap fit replaced by a french-cleat slide-on. Each clip spot
// becomes a hook lug on the base rim whose top wall slopes outward at
// 45 deg instead of standing at 90; the cover's windows become bayonet
// slots with matching sloped tops. Sliding the cover down trav = 5
// wedges it toward the wall until the face seats on the rim (the old
// 0.3 axial gap is gone -- the cleat closes it). The base outline is
// trav shorter at the bottom so the cover fits over it during entry.
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
trav      = 5;       // cleat slide-down travel
base_w    = cov_w - 2*wall_t - 2*clr;   // 121.0
base_h    = cov_h - 2*wall_t - 2*clr - trav;  // 116: bottom edge sits trav
base_y0   = trav/2;  // higher so the raised cover drops over it at entry
base_r    = cov_r - wall_t;
base_t    = 2.4;
rim_t     = 1.6;
rim_h     = 4;       // rim rises base_t..base_t+rim_h
relief_d  = 1.2;     // back pocket so a proud switch yoke sits flush
screw_d   = 3.9;     // 6-32 free fit incl. printed-hole shrinkage
cs_d      = 7.5;     // flat-head countersink diameter
cs_depth  = 1.8;     // gives a 45 deg countersink cone [9]

// ---- cleat hooks ----
hook_y    = 28;      // lug centers, +/- on left and right edges
hook_w    = 10;      // lug width along y at its bottom edge
hook_t    = 2.4;     // lug z-thickness; also the 45 deg bevel's y-gain
hook_z    = 3.0;     // lug underside height off the wall
hook_p    = 1.9;     // protrusion past the rim face; ends 0.1 shy of the
                     // cover wall's outer surface
slot_clr  = 0.3;     // slot clearance around the lug -- except the bevel,
                     // which is cut on the exact lug bevel line so the
                     // cleat bottoms out just as the face meets the rim
// assembled: face inner seats ON the rim top (no axial gap; the cleat
// pulls it closed), so the cover back edge sits at
cov_back_z = base_t + rim_h + face_t - cov_d;   // 0.8 above the wall
rib_z      = base_t + rim_h/2 - cov_back_z;     // rib/spine anchor height
hook_zl    = hook_z - cov_back_z;               // lug underside, cover frame

// ---- 3D emblem mock (placeholder for the final design) ----
emb_base_d = 40;     // roundel plateau
emb_base_h = 1.2;
emb_star_r = 16;     // 5-point star, pyramidal (extrude tapers to 55%)
emb_star_ri = 6.5;
emb_star_h = 2.2;
emb_dome_r = 5;      // center dome, squashed to half height
emb_dome_h = emb_dome_r * 0.5;
emb_h = emb_base_h + emb_star_h + emb_dome_h;  // 5.9 total proudness

// ---- sacrificial print props (cover only; snap out before assembly) ----
sac_t    = 0.8;                    // prop wall thickness (2 perimeters)
sac_neck = 0.3;                    // knife-edge contact at the face
sac_ys   = [-51, -34, -17, 0, 17, 34, 51];  // <=17 mm roof bridge spans
sac_top  = cov_d - face_t + 0.1;   // fused 0.1 into the face inner surface
sac_end  = cov_w/2 - wall_t - 1.5; // stop clear of the side walls
sac_gap  = 2.3;                    // stay clear of the stiffening rib at x=0

module rrect(w, h, r) {
    offset(r = r) square([w - 2*r, h - 2*r], center = true);
}

// cleat hook lug pointing +x, y centered: a tab whose top wall slopes
// outward at 45 deg (rising hook_t over its hook_t depth) -- the bevel
// that wedges the sliding cover toward the wall. Polygon coords land as
// (y, z) after the rotate.
module hook() {
    rotate([90, 0, 90]) linear_extrude(hook_p)
        polygon([[-hook_w/2, hook_z], [hook_w/2 - hook_t, hook_z],
                 [hook_w/2, hook_z + hook_t], [-hook_w/2, hook_z + hook_t]]);
}

// bayonet slot profile in the cover wall, (y, z) in the cover frame:
// locked pocket around the lug (bevel line exact, slot_clr elsewhere),
// the slide corridor trav BELOW it (the raised cover sees the lugs trav
// low), and an entry mouth open past the back edge for press-on
module slot2d() {
    p = [[-hook_w/2 - slot_clr, hook_zl - slot_clr],
         [hook_w/2 - hook_t - slot_clr, hook_zl - slot_clr],
         [hook_w/2 + slot_clr, hook_zl + hook_t + slot_clr],
         [-hook_w/2 - slot_clr, hook_zl + hook_t + slot_clr]];
    hull() { polygon(p); translate([-trav, 0]) polygon(p); }
    hull() { translate([-trav, 0]) polygon(p); translate([-trav, -4]) polygon(p); }
}

module base() {
    difference() {
        union() {
            translate([0, base_y0]) {
                linear_extrude(base_t) rrect(base_w, base_h, base_r);
                translate([0, 0, base_t]) linear_extrude(rim_h)
                    difference() {
                        rrect(base_w, base_h, base_r);
                        rrect(base_w - 2*rim_t, base_h - 2*rim_t, base_r - rim_t);
                    }
            }
            // cleat lugs; mirror (not rotate) on -x so the bevel still
            // rises in +y on both sides -- one slide direction
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*base_w/2, sy*hook_y, 0])
                    mirror([sx > 0 ? 0 : 1, 0, 0]) hook();
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
        // back relief pocket so the switch yoke, plaster ears, and the
        // box-mounting screw heads (y +/-41.7) don't rock the plate
        translate([-gang_dx, 0, -0.01])
            linear_extrude(relief_d) square([26, 92], center = true);
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
            // bayonet slots through both side walls (same orientation on
            // both sides -- the profile has no x-dependence)
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*cov_w/2, sy*hook_y, 0])
                    rotate([90, 0, 90])
                        linear_extrude(2*wall_t + 2, center = true) slot2d();
            // thumb notch, bottom edge, for sliding the cover back up
            translate([0, -cov_h/2, 0])
                cube([12, 2*wall_t + 2, 3], center = true);
        }
        // stiffening rib between the gangs (100 long: short enough to
        // clear the base rim during the raised press-on)
        translate([0, 0, rib_z - 0.8])
            linear_extrude(cov_d - face_t - rib_z + 0.8)
                square([1.6, 100], center = true);
        // placeholder 3D emblem raised off the face (right gang)
        translate([gang_dx, 0, cov_d - 0.01]) emblem3d();
    }
}

function star_pts(n, ro, ri) =
    [for (i = [0 : 2*n - 1]) let (a = 90 + i * 180 / n)
        [(i % 2 == 0 ? ro : ri) * cos(a), (i % 2 == 0 ? ro : ri) * sin(a)]];

// stand-in relief: plateau + tapered star + dome, ~emb_h proud of the face
module emblem3d() {
    cylinder(d = emb_base_d, h = emb_base_h + 0.01);
    translate([0, 0, emb_base_h])
        linear_extrude(emb_star_h + 0.01, scale = 0.55)
            polygon(star_pts(5, emb_star_r, emb_star_ri));
    translate([0, 0, emb_base_h + emb_star_h]) scale([1, 1, 0.5])
        difference() {
            sphere(emb_dome_r);
            translate([0, 0, -emb_dome_r]) cube(2 * emb_dome_r, center = true);
        }
}

if (part == "base" || part == "both")
    translate([part == "both" ? -67 : 0, 0, 0]) base();
// necked prop wall running along +x: sac_t wide, tapering to a
// sac_neck knife-edge over the last 0.5 so it snaps out cleanly
module sac_wall(len) {
    rotate([90, 0, 90]) linear_extrude(len)
        polygon([[-sac_t/2, 0], [sac_t/2, 0], [sac_t/2, sac_top - 0.5],
                 [sac_neck/2, sac_top], [-sac_neck/2, sac_top],
                 [-sac_t/2, sac_top - 0.5]]);
}

// snap-out roof props for the face-up cover print: bed-standing walls
// the face bridges between, split around the stiffening rib, plus a
// spine that props the rib itself (rib bottom = rib_z - 0.8)
module print_props() {
    for (y = sac_ys, sx = [-1, 1])
        translate([sx < 0 ? -sac_end : sac_gap, y, 0])
            sac_wall(sac_end - sac_gap);
    rotate([90, 0, 0]) linear_extrude(100, center = true)
        polygon([[-0.3, 0], [0.3, 0], [0.3, rib_z - 1.3],
                 [0.15, rib_z - 0.7], [-0.15, rib_z - 0.7],
                 [-0.3, rib_z - 1.3]]);
}

if (part == "cover" || part == "both")
    translate([part == "both" ? 67 : 0, 0, 0]) {
        cover();        // face-UP: walls on the bed, face and emblem on top
        print_props();  // sacrificial; snap out before assembly
    }
