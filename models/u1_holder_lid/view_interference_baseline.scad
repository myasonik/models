// baseline: overlap between two ORIGINAL holders stacked at the pitch
// implied by their own geometry (45.8 - 4.15 = 41.65). Whatever shows here
// is inherent to the original design's zero-clearance cone seating.
intersection() {
    import("holder_reference.stl");
    translate([0, 0, 41.65]) import("holder_reference.stl");
}
