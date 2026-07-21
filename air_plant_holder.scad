// Air Plant Holder - Geometric Cage Design
// Designed for leftmost air plant (~50-60mm tall, ~30-40mm wide)

// Dimensions
base_length = 52;    // mm
base_width = 48;     // mm
base_height = 5;     // mm

// Cage structure
cage_height = 95;    // mm - emphasizes plant height
cage_depth = 32;     // mm - approximate plant depth

// Back panel
back_thickness = 2.5; // mm
back_height = 85;    // mm

// Structural elements (strut/tube diameter)
strut_radius = 2;    // mm

// Main base - flat rectangular platform
module base() {
    linear_extrude(height = base_height) {
        square([base_length, base_width], center = true);
    }
}

// Back panel - solid rectangular support
module back_panel() {
    translate([0, -base_width/2, base_height])
        cube([base_length, back_thickness, back_height], center = true);
}

// Vertical edge struts (the 4 corners of the cage)
module vertical_struts() {
    fl_x = -base_length/2 + 4;
    fr_x = base_length/2 - 4;
    f_y = base_width/2 - 2;
    b_y = -base_width/2 + 2;

    // Front left strut
    translate([fl_x, f_y, base_height])
        cylinder(h = cage_height, r = strut_radius, center = false);

    // Front right strut
    translate([fr_x, f_y, base_height])
        cylinder(h = cage_height, r = strut_radius, center = false);

    // Back left strut
    translate([fl_x, b_y, base_height])
        cylinder(h = cage_height, r = strut_radius, center = false);

    // Back right strut
    translate([fr_x, b_y, base_height])
        cylinder(h = cage_height, r = strut_radius, center = false);
}

// Helper function to draw cylinders between two points
module strut_between(p1, p2, radius) {
    translate(p1)
        rotate([0, atan2(sqrt(pow(p2[0]-p1[0], 2) + pow(p2[1]-p1[1], 2)), p2[2]-p1[2]), atan2(p2[1]-p1[1], p2[0]-p1[0])])
            cylinder(h = sqrt(pow(p2[0]-p1[0], 2) + pow(p2[1]-p1[1], 2) + pow(p2[2]-p1[2], 2)), r = radius, center = false);
}

// Geometric frame - diamond/geometric shapes to create visual interest
module geometric_frame() {
    fl_x = -base_length/2 + 4;
    fr_x = base_length/2 - 4;
    f_y = base_width/2 - 2;
    b_y = -base_width/2 + 2;

    // Base points (at base level + strut offset)
    fl_base = [fl_x, f_y, base_height];
    fr_base = [fr_x, f_y, base_height];
    bl_base = [fl_x, b_y, base_height];
    br_base = [fr_x, b_y, base_height];

    // Lower diamond points (40% up)
    h1 = base_height + cage_height * 0.35;
    fl_d1 = [fl_x, f_y, h1];
    fr_d1 = [fr_x, f_y, h1];
    f_center_d1 = [0, f_y, h1];

    // Lower back
    bl_d1 = [fl_x, b_y, h1];
    br_d1 = [fr_x, b_y, h1];

    // Upper diamond points (70% up)
    h2 = base_height + cage_height * 0.65;
    fl_d2 = [fl_x * 0.6, f_y * 0.7, h2];
    fr_d2 = [fr_x * 0.6, f_y * 0.7, h2];
    f_center_d2 = [0, f_y * 0.5, h2];

    bl_d2 = [fl_x * 0.6, b_y * 0.7, h2];
    br_d2 = [fr_x * 0.6, b_y * 0.7, h2];

    // Front face - lower diamond
    strut_between(fl_base, fl_d1, strut_radius);
    strut_between(fr_base, fr_d1, strut_radius);
    strut_between(fl_d1, f_center_d1, strut_radius);
    strut_between(fr_d1, f_center_d1, strut_radius);

    // Front face - upper diamond
    strut_between(fl_d1, fl_d2, strut_radius);
    strut_between(fr_d1, fr_d2, strut_radius);
    strut_between(fl_d2, f_center_d2, strut_radius);
    strut_between(fr_d2, f_center_d2, strut_radius);

    // Back stabilizing struts
    strut_between(bl_base, bl_d1, strut_radius);
    strut_between(br_base, br_d1, strut_radius);
    strut_between(bl_d1, br_d1, strut_radius);

    strut_between(bl_d1, bl_d2, strut_radius);
    strut_between(br_d1, br_d2, strut_radius);
    strut_between(bl_d2, br_d2, strut_radius);
}

// Top peak - geometric accent
module top_peak() {
    peak_base_h = base_height + cage_height;
    // Connect diagonals to a peak point
    peak_point = [0, 0, peak_base_h + 8];

    fl_x = -base_length/2 + 4;
    fr_x = base_length/2 - 4;

    h2 = base_height + cage_height * 0.65;
    fl_d2 = [fl_x * 0.6, (base_width/2 - 2) * 0.5, h2];
    fr_d2 = [fr_x * 0.6, (base_width/2 - 2) * 0.5, h2];

    strut_between(fl_d2, peak_point, strut_radius * 0.7);
    strut_between(fr_d2, peak_point, strut_radius * 0.7);
}

// Assembly
base();
back_panel();
vertical_struts();
geometric_frame();
top_peak();

// Optional: Uncomment below to add visualization sphere showing plant placement
// translate([0, 0, base_height + 30])
//     %sphere(r = 20, $fn = 30);
