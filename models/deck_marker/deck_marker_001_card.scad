// Draw/Discard deck marker card — 43 x 65 mm, printed flat on the bed.
// "DISCARD" inlaid on top, "DRAW" (mirrored) inlaid on the bottom, both
// at the same font size and center. Letters are a separate body for
// multi-color printing; pockets in the card are the exact same solids
// (zero clearance — multi-material bodies must touch).
//
// The bottom word is mirrored across X so it reads correctly after
// flipping the card side-over-side (about its long axis).
//
// font_size is calibrated so DISCARD spans card width minus margins;
// verified against the exported mesh (see comment at font_size).

part = "card";   // "card" | "letters" | "all"

$fn = 64;

card_w   = 43;    // X — the words read across this axis
card_l   = 65;    // Y
card_t   = 4;     // 5 works too; 4 saves ~8 layers at a 0.2 nozzle
corner_r = 3;
margin   = 3;     // side margin for the text on each side
inlay    = 0.6;   // letter depth, flush with each face

font      = "Liberation Sans:style=Bold";
font_size = 6.11; // calibrated: DISCARD measures 36.97mm wide (target 37)

word_top = "DISCARD";
word_bot = "DRAW";

eps = 0.01;

module card_blank() {
    linear_extrude(height = card_t)
        offset(r = corner_r)
            square([card_w - 2*corner_r, card_l - 2*corner_r], center = true);
}

module word_2d(w) {
    text(w, size = font_size, font = font,
         halign = "center", valign = "center");
}

// Letters, positioned in their inlay pockets.
module letters() {
    // Top face: DISCARD, flush at Z = card_t.
    translate([0, 0, card_t - inlay])
        linear_extrude(height = inlay) word_2d(word_top);
    // Bottom face: DRAW, mirrored, flush at Z = 0.
    mirror([1, 0, 0])
        linear_extrude(height = inlay) word_2d(word_bot);
}

// Pockets: identical letter shapes, extended past the faces for a clean cut.
module pockets() {
    translate([0, 0, card_t - inlay])
        linear_extrude(height = inlay + 1) word_2d(word_top);
    mirror([1, 0, 0])
        translate([0, 0, -1])
            linear_extrude(height = inlay + 1) word_2d(word_bot);
}

module card() {
    difference() {
        card_blank();
        pockets();
    }
}

if (part == "card" || part == "all") card();
if (part == "letters" || part == "all") letters();
