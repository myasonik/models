// view helper: close-up of the stacking joint at the right wall, cut at y=0
use <u1_holder_lid_004.scad>

lid_z  = 45.8 - 4.15;
next_z = lid_z + 5.55;

intersection() {
    union() {
        import("holder_reference.stl");
        color("gold") translate([0, 0, lid_z]) lid();
        color("lightblue") translate([0, 0, next_z]) import("holder_reference.stl");
    }
    translate([28, -30, 36]) cube([20, 30, 22]);
}
