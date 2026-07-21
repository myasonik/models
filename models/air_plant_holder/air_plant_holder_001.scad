// Air Plant Holder — Double-Diamond Crystal Cage
// For the tall Tillandsia (caput-medusae type): plant ~135mm tall, bulb ~40mm wide
//
// Two stacked diamonds accentuate the plant's height. The front face is a flat
// double-diamond wireframe (fully open); the back POPS OUT — each diamond
// tapers to an apex vertex behind its widest point, so the side profile is a
// crystal-like zigzag instead of a flat plane. The whole cage rocks back a few
// degrees so the plant sits on an incline, and a small cage scoop pops out the
// front of the bottom section to catch the base of the plant. Flat base plate.

$fn = 32;

// ---- Parameters ----
base_w  = 64;    // base plate width (x)
base_d  = 58;    // base plate depth (y)
base_ctr = -4;   // base plate y center (footprint spans front scoop to back apexes)
base_h  = 4;     // base plate thickness

yF   = 16;       // front frame plane (y)
pop  = 22;       // how far the back apexes pop out behind center
fpop = 16;       // how far the front scoop pops out past the front frame
tilt = 8;        // degrees the cage rocks backward
strut_r = 2.2;   // strut radius

// Front-view silhouette (x = half-width at height z)
zB = base_h;         // bottom vertex of lower diamond
w1 = 27; z1 = 32;    // lower diamond widest point
ww = 7;  zw = 58;    // waist between the diamonds
w2 = 34; z2 = 108;   // upper diamond widest point
zT = 152;            // top vertex

// ---- Helpers ----
module strut(p1, p2) {
    hull() {
        translate(p1) sphere(strut_r);
        translate(p2) sphere(strut_r);
    }
}

function lerp(a, b, t) = a + (b - a) * t;

// ---- Front frame vertices ----
B  = [  0, yF, zB];
L1 = [-w1, yF, z1];  R1 = [ w1, yF, z1];
WL = [-ww, yF, zw];  WR = [ ww, yF, zw];
L2 = [-w2, yF, z2];  R2 = [ w2, yF, z2];
T  = [  0, yF, zT];

// Back apexes: one behind each diamond's widest height
A1 = [0, -pop, z1];   // lower diamond
A2 = [0, -pop, z2];   // upper diamond

// Front scoop apex: pops out ahead of the lower diamond to catch the bulb
F1 = [0, yF + fpop, 30];

// ---- Parts ----
module base() {
    difference() {
        translate([-base_w/2, base_ctr - base_d/2, 0])
            cube([base_w, base_d, base_h]);
        translate([0, base_ctr, -1]) cylinder(h = base_h + 2, d = 8);  // drainage
    }
}

// Flat double-diamond outline on the front plane
module front_frame() {
    strut(B,  L1);  strut(B,  R1);   // lower diamond V
    strut(L1, WL);  strut(R1, WR);   // up to waist
    strut(WL, WR);                   // waist bar
    strut(WL, L2);  strut(WR, R2);   // upper diamond
    strut(L2, T);   strut(R2, T);    // up to apex
}

// Each diamond's corners converge on its back apex — the "pop"
module back_pop() {
    // lower diamond pyramid
    strut(B,  A1);
    strut(L1, A1);  strut(R1, A1);
    strut(WL, A1);  strut(WR, A1);

    // upper diamond pyramid
    strut(WL, A2);  strut(WR, A2);
    strut(L2, A2);  strut(R2, A2);
    strut(T,  A2);
}

// Front scoop: the bottom section's corners converge on a forward apex,
// forming a protruding cage that catches the base of the plant
module front_scoop() {
    strut(B,  F1);
    strut(L1, F1);  strut(R1, F1);
}

// Two ribs from the front V edges back to the lower apex; the bulb rests here
module cradle_ribs() {
    for (s = [-1, 1])
        strut([lerp(0, s*w1, 0.45), yF, lerp(zB, z1, 0.45)], A1);
}

// Conical gusset where the cage meets the base — the bottom vertex is the
// only base contact, so reinforce that joint
module gusset() {
    translate([B[0], B[1], 0]) cylinder(h = 14, d1 = 22, d2 = 5);
}

// ---- Assembly ----
union() {
    base();
    // rock the whole cage backward about its base contact point
    translate([0, yF, base_h]) rotate([tilt, 0, 0]) translate([0, -yF, -base_h]) {
        gusset();
        front_frame();
        back_pop();
        front_scoop();
        cradle_ribs();
    }
}
