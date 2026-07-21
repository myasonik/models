// Air Plant Holder — Double-Diamond Wireframe Cage
// For the tall Tillandsia (caput-medusae type): plant ~135mm tall, bulb ~40mm wide
//
// Two stacked diamonds accentuate the plant's height. The cage only exists at
// the back and around the lower bulb area — the front above the bulb is fully
// open. Flat base plate for table placement.

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

// interpolate between two 2D silhouette points
function lerp(a, b, t) = a + (b - a) * t;

// ---- Parts ----
module base() {
    difference() {
        translate([-base_w/2, -base_d/2, 0])
            cube([base_w, base_d, base_h]);
        translate([0, 0, -1]) cylinder(h = base_h + 2, d = 8);  // drainage
    }
}

// Lower diamond cage: full wireframe front + back, holds the bulb
module lower_cage() {
    for (y = [yF, yB]) {
        B  = [  0, y, zB];
        L1 = [-w1, y, z1];  R1 = [ w1, y, z1];
        WL = [-ww, y, zw];  WR = [ ww, y, zw];

        strut(B,  L1);  strut(B,  R1);   // V bottom
        strut(L1, WL);  strut(R1, WR);   // up to waist
        strut(WL, WR);                   // waist bar
    }
    // front-to-back connectors at the diamond's corners
    for (p = [[-w1, z1], [w1, z1], [-ww, zw], [ww, zw]])
        strut([p[0], yF, p[1]], [p[0], yB, p[1]]);

    // cradle ribs: two longitudinal struts low in the V to support the bulb
    for (s = [-1, 1]) {
        x = lerp(0, s*w1, 0.4);
        z = lerp(zB, z1, 0.4);
        strut([x, yF, z], [x, yB, z]);
    }
}

// Upper diamond: back plane only, so the front stays fully open
module upper_cage() {
    WLb = [-ww, yB, zw];  WRb = [ ww, yB, zw];
    L2  = [-w2, yB, z2];  R2  = [ w2, yB, z2];
    T   = [  0, yB, zT];

    strut(WLb, L2);  strut(WRb, R2);   // waist up to widest point
    strut(L2,  T);   strut(R2,  T);    // up to apex
    strut([0, yB, zw], T);             // center vertical spine

    // diagonal braces from the FRONT waist corners back up to the wide points
    strut([-ww, yF, zw], L2);
    strut([ ww, yF, zw], R2);
}

// ---- Assembly ----
union() {
    base();
    lower_cage();
    upper_cage();
}
