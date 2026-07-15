// view helper: full stack — holder, lid, second holder, lid — at seat pitches
use <u1_holder_lid_004.scad>

color("khaki")      import("holder_reference.stl");
color("steelblue")  translate([0, 0, 41.62]) lid();
color("khaki")      translate([0, 0, 41.62 + 5.45]) import("holder_reference.stl");
color("steelblue")  translate([0, 0, 41.62 + 5.45 + 41.62]) lid();
