// Draw/Discard deck marker card — 43 x 65 mm, printed flat on the bed.
//
// v002: flush inlays kept, text moved near the top edge (ink top sits
//   text_gap = 6mm below it), and the whole thing ships as ONE
//   multi-shell STL. Each word's letters merge into a thin backing
//   plate buried 0.6mm below the face, so every word is one connected
//   body: in the slicer, Split -> To parts yields exactly 3 parts
//   (card, DISCARD, DRAW) for per-part filament assignment.
//   NOTE: OpenSCAD unions everything it exports, which would weld the
//   flush letters into the card and erase the text. The bodies MUST be
//   exported with part="card" and part="letters" separately and then
//   concatenated (ASCII STL allows multiple solids per file).
//   DRAW is mirrored to read correctly after a side-over-side flip
//   (about the long axis), which preserves its near-the-top position.
// v001: flush two-body inlay version, text centered, two STL files.

part = "all";   // "card" | "letters" | "all" (preview only — see NOTE)

$fn = 64;

card_w   = 43;    // X — the words read across this axis
card_l   = 65;    // Y
card_t   = 4;     // 5 works too; 4 saves ~8 layers at a 0.2 nozzle
corner_r = 3;
margin   = 3;     // side margin for the text
inlay    = 0.6;   // visible letter depth, flush with each face
plate_t  = 0.6;   // buried backing plate thickness (connects a word)
plate_pad = 1.5;  // backing plate outline beyond the letter ink

font      = "Liberation Sans:style=Bold";
font_size = 6.11; // calibrated: DISCARD measures 36.97mm wide (target 37)
cap_h     = 6.01; // measured ink height at that size

// Text position: ink top sits text_gap below the card's top edge.
text_gap = 6;
text_y   = card_l/2 - text_gap - cap_h/2;

word_top = "DISCARD";
word_bot = "DRAW";

eps = 0.01;

// Card interior must remain solid between the two buried plates.
assert(card_t - 2*(inlay + plate_t) >= 1.5,
       "card too thin: the two word pockets leave <1.5mm of core");

module card_blank() {
    linear_extrude(height = card_t)
        offset(r = corner_r)
            square([card_w - 2*corner_r, card_l - 2*corner_r], center = true);
}

module word_2d(w) {
    translate([0, text_y])
        text(w, size = font_size, font = font,
             halign = "center", valign = "center");
}

// One word as a single connected solid, face at local Z=0 going down:
// letters 0..-inlay, backing plate -inlay..-inlay-plate_t.
module word_body(w) {
    translate([0, 0, -inlay])
        linear_extrude(height = inlay + eps) word_2d(w);
    translate([0, 0, -inlay - plate_t])
        linear_extrude(height = plate_t + eps)
            offset(r = plate_pad) word_2d(w);
}

// Both words, placed: DISCARD flush with the top face, DRAW flush with
// the bottom. rotate([0,180,0]) IS the side-over-side flip: it mirrors
// X (reading direction), sends the body up into the card from the
// bottom face, and preserves Y so the word stays near the top edge.
module letters() {
    translate([0, 0, card_t]) word_body(word_top);
    rotate([0, 180, 0]) word_body(word_bot);
}

module card() {
    difference() {
        card_blank();
        letters();   // identical solids as pockets: zero clearance
    }
}

// color() renders in preview mode only; export ignores it.
if (part == "card" || part == "all") color("DimGray") card();
if (part == "letters" || part == "all") color("Gold") letters();
