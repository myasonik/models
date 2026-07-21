// Air Plant Holder v004 — Hanging Wall Pendant
// Wall-mount take on a hanging geometric pendant: a teardrop wireframe whose
// back plane is shaved flat to lie flush against the wall, with the front
// popping out to basket the bulb. Hangs from a nail through the top tab.
// Sized to the caput-medusae: bulb ~40mm wide x ~30mm deep, leaves to ~135mm.

$fn = 32;

// ---- Parameters ----
strut_r = 2.2;   // strut radius
shave   = -1;    // back plane; everything behind this is cut flat for the wall

W    = 26;       // half-width at the widest ring
zW   = 45;       // height of the widest ring (bulb sits just below)
zT   = 148;      // top tip of the teardrop
fpop = 36;       // how far the front vertex pops off the wall

hole_z = 122;    // nail hole center — inside the upper cone, below the tip
hole_d = 5;      // nail hole diameter

// ---- Helpers ----
module strut(p1, p2) {
    hull() {
        translate(p1) sphere(strut_r);
        translate(p2) sphere(strut_r);
    }
}

function lerp(a, b, t) = a + (b - a) * t;

// ---- Frame vertices (back plane at y=0, wall behind) ----
B  = [  0, 0, 0];      // bottom tip
WL = [ -W, 0, zW];     // widest ring, on the wall
WR = [  W, 0, zW];
T  = [  0, 0, zT];     // top tip
F  = [  0, fpop, zW];  // front vertex of the ring, off the wall

// ---- Parts ----
// Flat teardrop outline lying against the wall
module back_frame() {
    strut(B,  WL);  strut(B,  WR);   // lower cone edges
    strut(WL, T);   strut(WR, T);    // upper cone edges
    strut(WL, WR);                   // ring bar along the wall
}

// Depth struts to the front vertex — the pendant's forward pop
module front_pop() {
    strut(B,  F);    // lower front edge (the bulb rests on this)
    strut(WL, F);  strut(WR, F);     // ring closing the basket
    strut(T,  F);    // long upper front edge, like the reference pendant
}

// Two short ribs bridging the lower cone, forming the bulb basket
module cradle_ribs() {
    for (s = [-1, 1])
        strut([lerp(0, s*W, 0.4), 0, lerp(0, zW, 0.4)],
              [0, lerp(0, fpop, 0.4), lerp(0, zW, 0.4)]);
}

// Hanging eyelet nested INSIDE the upper cone, just below the tip — a small
// teardrop washer flush with the wall, bridging the converging edges. The
// front strut (T-F) is ~7mm off the wall here, leaving nail-head clearance.
module hang_eye() {
    difference() {
        hull() {
            translate([0, shave, hole_z])      rotate([-90, 0, 0]) cylinder(h = 4, r = 7);
            translate([0, shave, hole_z + 12]) rotate([-90, 0, 0]) cylinder(h = 4, r = 2.5);
        }
        translate([0, -10, hole_z]) rotate([-90, 0, 0]) cylinder(h = 20, d = hole_d);
    }
}

// ---- Reference plant (preview only — % excludes it from render/STL) ----
function arcp(R, bend, t) = [R*(1 - cos(bend*t)), 0, R*sin(bend*t)];
function wavep(len, t) = [10*sin(540*t), 0, len*t];

module p_leaf(az, len, bend, r0) {
    n = 10;
    R = len / (bend * PI / 180);
    rotate([0, 0, az]) translate([0, 0, 38])
        for (i = [0:n-1]) {
            t0 = i/n; t1 = (i+1)/n;
            hull() {
                translate(arcp(R, bend, t0)) sphere(r0*(1 - 0.85*t0));
                translate(arcp(R, bend, t1)) sphere(r0*(1 - 0.85*t1));
            }
        }
}

module p_tall_leaf() {
    n = 14; len = 90;
    translate([0, 0, 38])
        for (i = [0:n-1]) {
            t0 = i/n; t1 = (i+1)/n;
            hull() {
                translate(wavep(len, t0)) sphere(4*(1 - 0.8*t0));
                translate(wavep(len, t1)) sphere(4*(1 - 0.8*t1));
            }
        }
}

module plant() {
    hull() { translate([0,0,6])  sphere(8);  translate([0,0,22]) sphere(19); }
    hull() { translate([0,0,22]) sphere(19); translate([0,0,40]) sphere(8);  }
    // leaves kept forward/sideways of the wall plane
    p_leaf( 90, 85, 70, 4.5);
    p_leaf( 30, 78, 75, 4);
    p_leaf(150, 72, 80, 4);
    p_leaf(-30, 68, 60, 4);
    p_leaf(180, 55, 45, 4);
    p_tall_leaf();
}

// ---- Assembly ----
difference() {
    union() {
        back_frame();
        front_pop();
        cradle_ribs();
        hang_eye();
        // bulb nests in the basket, back against the wall, leaves spilling out
        %translate([0, 18, 16]) plant();
    }
    // shave the back flat so it lies flush on the wall
    translate([-200, shave - 400, -200]) cube([400, 400, 600]);
}
