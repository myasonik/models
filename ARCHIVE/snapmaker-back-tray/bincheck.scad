// Intersect the finished tray with the socket void of the two middle cells
// (everything above the recessed floor plane, inside the socket profile).
// Any volume left = material that would collide with a seated bin.
$fa = 4; $fs = 0.25;
eps = 0.01;
module rslab(x, y, r, h) {
    linear_extrude(h) offset(r = r) square([x - 2*r, y - 2*r], center = true);
}
module socket_void() {
    // profile: hw 18.15 r1.15 @z4.3 -> 18.85 r1.85 @5.0..6.8 -> 21.0 r4 @8.95
    hull() {
        translate([0,0,4.3]) rslab(36.3,36.3,1.15,eps);
        translate([0,0,5.0-eps]) rslab(37.7,37.7,1.85,eps);
    }
    translate([0,0,5.0-eps]) rslab(37.7,37.7,1.85,1.8+2*eps);
    hull() {
        translate([0,0,6.8]) rslab(37.7,37.7,1.85,eps);
        translate([0,0,8.95-eps]) rslab(42,42,4,eps);
    }
    translate([0,0,4.2]) rslab(36.3,36.3,1.15,0.1+eps);  // recess plane
}
intersection() {
    import("v002.stl");
    union() {
        translate([-21,-7.25,0]) socket_void();
        translate([ 21,-7.25,0]) socket_void();
    }
}
