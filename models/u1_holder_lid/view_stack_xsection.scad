// view helper: holder + lid + second holder stacked, cut at y=0
// holder_reference.stl sits with bottom at z=0, rim at 45.8
// v002 fit clearance: lid seats 4.18 below rim; next holder 5.45 above lid
use <u1_holder_lid_004.scad>

lid_z  = 45.8 - 4.18;   // 41.62
next_z = lid_z + 5.45;  // 47.07

difference() {
    union() {
        import("holder_reference.stl");
        translate([0, 0, lid_z]) lid();
        color("lightblue") translate([0, 0, next_z]) import("holder_reference.stl");
    }
    translate([-100, 0, -1]) cube([200, 100, 200]);
}
