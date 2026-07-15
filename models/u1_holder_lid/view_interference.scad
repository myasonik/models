// verification: renders ONLY the overlap between parts in the stack, with
// each part lifted 0.05 above its measured seat pitch (lid seats at 41.62,
// holder-on-lid at +5.45). A correct fit renders nothing at all.
use <u1_holder_lid_004.scad>

lid_z  = 41.62 + 0.05;
next_z = lid_z + 5.45 + 0.05;

// lid vs lower holder
intersection() {
    import("holder_reference.stl");
    translate([0, 0, lid_z]) lid();
}
// upper holder vs lid
intersection() {
    translate([0, 0, next_z]) import("holder_reference.stl");
    translate([0, 0, lid_z]) lid();
}
