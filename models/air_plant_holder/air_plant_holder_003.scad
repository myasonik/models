// Air Plant Holder v003 — Triple-Diamond Wireframe Cage
// v001 aesthetic with THREE stacked identical diamonds (60 x 62mm each).
// Wireframe base pyramid, back apex behind each diamond's widest point,
// front scoop catching the bulb, recessed waist bars, 8 degree recline.

$fn = 32;

// ---- Parameters ----
bs_front = 26;   // ground ring front vertex (+y)
bs_back  = 34;   // ground ring back vertex (-y), slightly deeper for the lean
bs_side  = 30;   // ground ring side vertices (±x) — matches diamond width
ring_z   = 1.4;  // ring center height; shaved flat underneath
base_h  = 14;    // height where the base risers meet the cage's bottom vertex

yF   = 16;       // front frame plane (y)
pop  = 22;       // how far the back apexes pop out behind center
fpop = 16;       // how far the front scoop pops out past the front frame
tilt = 8;        // degrees the cage rocks backward
strut_r = 2.2;   // strut radius

// Front-view silhouette — three identical diamonds stacked
zB  = base_h;        // bottom vertex (14)
sec = 50;            // height of each diamond section
zw1 = zB + sec;      // first waist (76)
zw2 = zB + 2*sec;    // second waist (138)
zT  = zB + 3*sec;    // top vertex (200)
w   = 30;            // diamond half-width (all three)
z1  = zB  + sec/2;   // widest points (45, 107, 169)
z2  = zw1 + sec/2;
z3  = zw2 + sec/2;
ww  = 7;             // waist half-width
yW  = -6;            // waist bars pulled back clear of the plant

// ---- Helpers ----
module strut(p1, p2) {
    hull() {
        translate(p1) sphere(strut_r);
        translate(p2) sphere(strut_r);
    }
}

function lerp(a, b, t) = a + (b - a) * t;

// ---- Frame vertices ----
B   = [  0, yF, zB];
L1  = [ -w, yF, z1];   R1  = [  w, yF, z1];
V1L = [-ww, yW, zw1];  V1R = [ ww, yW, zw1];
L2  = [ -w, yF, z2];   R2  = [  w, yF, z2];
V2L = [-ww, yW, zw2];  V2R = [ ww, yW, zw2];
L3  = [ -w, yF, z3];   R3  = [  w, yF, z3];
T   = [  0, yF, zT];

A1 = [0, -pop, z1];   // back apexes, one per diamond
A2 = [0, -pop, z2];
A3 = [0, -pop, z3];

F1 = [0, yF + fpop, 40];   // front scoop apex for the bulb

// ---- Parts ----
// Wireframe base cage: diamond-plan ground ring, risers to the bottom vertex
module base() {
    GF = [ 0,        bs_front, ring_z];
    GB = [ 0,       -bs_back,  ring_z];
    GL = [-bs_side, -4,        ring_z];
    GR = [ bs_side, -4,        ring_z];
    P  = [ 0, yF, base_h];

    difference() {
        union() {
            strut(GF, GR); strut(GR, GB); strut(GB, GL); strut(GL, GF);
            strut(GF, P);  strut(GR, P);  strut(GB, P);  strut(GL, P);
        }
        translate([-100, -100, -50]) cube([200, 200, 50]);  // flatten underside
    }
}

// Flat triple-diamond outline on the front plane
module front_frame() {
    strut(B,   L1);   strut(B,   R1);
    strut(L1,  V1L);  strut(R1,  V1R);
    strut(V1L, V1R);                    // waist bar 1
    strut(V1L, L2);   strut(V1R, R2);
    strut(L2,  V2L);  strut(R2,  V2R);
    strut(V2L, V2R);                    // waist bar 2
    strut(V2L, L3);   strut(V2R, R3);
    strut(L3,  T);    strut(R3,  T);
}

// Each diamond's corners converge on its own back apex
module back_pop() {
    strut(B,   A1);
    strut(L1,  A1);  strut(R1,  A1);
    strut(V1L, A1);  strut(V1R, A1);

    strut(V1L, A2);  strut(V1R, A2);
    strut(L2,  A2);  strut(R2,  A2);
    strut(V2L, A2);  strut(V2R, A2);

    strut(V2L, A3);  strut(V2R, A3);
    strut(L3,  A3);  strut(R3,  A3);
    strut(T,   A3);
}

// Vertical beams along the front edges tying the three diamonds together —
// they run through the collinear side vertices (L1-L2-L3 / R1-R2-R3)
module front_beams() {
    strut(L1, L3);
    strut(R1, R3);
}

// Bottom section's corners converge on a forward apex, catching the bulb
module front_scoop() {
    strut(B,  F1);
    strut(L1, F1);  strut(R1, F1);
}

// Two ribs from the front V edges back to the lower apex; the bulb rests here
module cradle_ribs() {
    for (s = [-1, 1])
        strut([lerp(0, s*w, 0.45), yF, lerp(zB, z1, 0.45)], A1);
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
    p_leaf( 90, 85, 70, 4.5);
    p_leaf( 30, 78, 75, 4);
    p_leaf(150, 72, 80, 4);
    p_leaf(-30, 68, 60, 4);
    p_leaf(215, 55, 45, 4);
    p_tall_leaf();
}

// ---- Assembly ----
union() {
    base();
    translate([0, yF, base_h]) rotate([tilt, 0, 0]) translate([0, -yF, -base_h]) {
        front_frame();
        front_beams();
        back_pop();
        front_scoop();
        cradle_ribs();
        %translate([0, 8, 20]) plant();
    }
}
