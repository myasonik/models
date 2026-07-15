// view helper: true 2D section at y=0 through holder + lid + next holder.
use <u1_holder_lid_004.scad>

lid_z  = 45.8 - 4.18;
next_z = lid_z + 5.45;

projection(cut = true) rotate([-90, 0, 0]) {
    import("holder_reference.stl");
    translate([0, 0, lid_z]) lid();
    translate([0, 0, next_z]) import("holder_reference.stl");
}
