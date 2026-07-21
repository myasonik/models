// Air Plant Holder — Double-Diamond Wireframe Cage
// For the tall Tillandsia (caput-medusae type): plant ~135mm tall, bulb ~40mm wide
//
// Two stacked diamonds accentuate the plant's height. The full silhouette is a
// 3D cage: identical front and back wireframes joined by depth struts. No solid
// faces, so the plant shows through the big front diamond opening. Flat base
// plate for table placement.

$fn = 32;

// ---- Parameters ----
base_w  = 64;    // base plate width (x)
base_d  = 42;    // base plate depth (y)
base_h  = 4;     // base plate thickness

depth   = 32;    // cage depth (y): strut-center to strut-center
strut_r = 2.2;   // strut radius

// Front-view silhouette (x = half-width at height z)
zB = base_h;         // bottom vertex of lower diamond
w1 = 27; z1 = 32;    // lower diamond widest point
ww = 7;  zw = 58;    // waist between the diamonds
w2 = 34; z2 = 108;   // upper diamond widest point
zT = 152;            // top vertex

yF =  depth/2;   // front strut plane
yB = -depth/2;   // back strut plane

// ---- Helpers ----
module strut(p1, p2) {
    hull() {
        translate(p1) sphere(strut_r);
        translate(p2) sphere(strut_r);
    }
}

// interpolate between two values
function lerp(a, b, t) = a + (b - a) * t;

// ---- Parts ----
module base() {
    difference() {
        translate([-base_w/2, -base_d/2, 0])
            cube([base_w, base_d, base_h]);
        translate([0, 0, -1]) cylinder(h = base_h + 2, d = 8);  // drainage
    }
}

// Full double-diamond wireframe outline in a given y plane
module frame(y) {
    B  = [  0, y, zB];
    L1 = [-w1, y, z1];  R1 = [ w1, y, z1];
    WL = [-ww, y, zw];  WR = [ ww, y, zw];
    L2 = [-w2, y, z2];  R2 = [ w2, y, z2];
    T  = [  0, y, zT];

    strut(B,  L1);  strut(B,  R1);   // lower diamond V
    strut(L1, WL);  strut(R1, WR);   // up to waist
    strut(WL, WR);                   // waist bar
    strut(WL, L2);  strut(WR, R2);   // upper diamond
    strut(L2, T);   strut(R2, T);    // up to apex
}

// Front-to-back struts at every silhouette corner
module connectors() {
    for (p = [[-w1, z1], [w1, z1], [-ww, zw], [ww, zw],
              [-w2, z2], [w2, z2], [0, zT]])
        strut([p[0], yF, p[1]], [p[0], yB, p[1]]);
}

// Two longitudinal struts low in the V that the bulb rests on
module cradle_ribs() {
    for (s = [-1, 1]) {
        x = lerp(0, s*w1, 0.4);
        z = lerp(zB, z1, 0.4);
        strut([x, yF, z], [x, yB, z]);
    }
}

// Center vertical spine on the back frame only, so the front stays open
module back_spine() {
    strut([0, yB, zw], [0, yB, zT]);
}

// ---- Assembly ----
union() {
    base();
    frame(yF);
    frame(yB);
    connectors();
    cradle_ribs();
    back_spine();
}
