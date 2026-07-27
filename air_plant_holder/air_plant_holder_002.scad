// Air Plant Holder v002 — Symmetric Double-Diamond Wireframe Cage
// Variant of v001 where the top is an exact mirror of the bottom about the
// waist: the upper diamond gets its own front scoop and cradle ribs, and the
// top carries a crown ring mirroring the wireframe base pyramid.

$fn = 32;

// ---- Parameters ----
bs_front = 30;   // ring front vertex (+y)
bs_back  = 38;   // ring back vertex (-y)
bs_side  = 36;   // ring side vertices (±x)
ring_z   = 1.4;  // ground ring center height; shaved flat underneath
base_h  = 14;    // height where the base risers meet the cage's bottom vertex

yF   = 16;       // front frame plane (y)
pop  = 22;       // how far the back apexes pop out behind center
fpop = 16;       // how far the front scoops pop out past the front frame
tilt = 8;        // degrees the cage rocks backward
strut_r = 2.2;   // strut radius

// Front-view silhouette (x = half-width at height z); both halves identical
zB = base_h;         // bottom vertex
zT = 152;            // top vertex
zw = (zB + zT) / 2;  // waist (mirror plane)
w1 = 30; z1 = (zB + zw) / 2;   // diamond widest point
ww = 7;              // waist half-width
yW = -6;             // waist bar pulled back clear of the plant

// ---- Helpers ----
module strut(p1, p2) {
    hull() {
        translate(p1) sphere(strut_r);
        translate(p2) sphere(strut_r);
    }
}

function lerp(a, b, t) = a + (b - a) * t;

// mirror about the waist plane (z -> zB + zT - z; x, y unchanged)
module mz() {
    translate([0, 0, zB + zT]) mirror([0, 0, 1]) children();
}

// ---- Lower-half vertices ----
B  = [  0, yF, zB];
L1 = [-w1, yF, z1];  R1 = [ w1, yF, z1];
WL = [-ww, yW, zw];  WR = [ ww, yW, zw];
A1 = [0, -pop, z1];          // back apex
F1 = [0, yF + fpop, 44];     // front scoop apex

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

// Crown: the base pyramid mirrored to the top — ring opening upward from the
// top vertex. Lives inside the tilt so it follows the cage.
module crown() {
    cz = zB + zT - ring_z;
    CF = [ 0,        bs_front, cz];
    CB = [ 0,       -bs_back,  cz];
    CL = [-bs_side, -4,        cz];
    CR = [ bs_side, -4,        cz];
    P  = [ 0, yF, zT];

    strut(CF, CR); strut(CR, CB); strut(CB, CL); strut(CL, CF);
    strut(CF, P);  strut(CR, P);  strut(CB, P);  strut(CL, P);
}

// One half of the cage: diamond V, back pyramid, front scoop, cradle ribs
module half() {
    strut(B,  L1);  strut(B,  R1);   // diamond V
    strut(L1, WL);  strut(R1, WR);   // up to waist

    strut(B,  A1);                   // back pyramid
    strut(L1, A1);  strut(R1, A1);
    strut(WL, A1);  strut(WR, A1);

    strut(B,  F1);                   // front scoop
    strut(L1, F1);  strut(R1, F1);

    for (s = [-1, 1])                // cradle ribs back to the apex
        strut([lerp(0, s*w1, 0.45), yF, lerp(zB, z1, 0.45)], A1);
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
    n = 14; len = 85;
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
        half();          // bottom half
        mz() half();     // top half, exact mirror about the waist
        strut(WL, WR);   // shared waist bar
        crown();
        %translate([0, 8, 24]) plant();
    }
}
