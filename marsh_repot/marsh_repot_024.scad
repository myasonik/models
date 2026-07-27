// Marsh repot liner — rebuilt from "Marsh repot - FIX flat rim setback.step"
// (two-body Fusion export, 2026-07-10) plus the user's section screenshots.
// Dimensions taken from per-body vertex extraction; see comments.
//
// TWO PARTS: set `part` to "pot", "tray", or "all" (assembly preview;
// `pullout` slides the tray out along +X for illustration).
//
// PRINT ORIENTATION (pot): on its BACK face — the +X end wall — rotated
// (90 - draft) about Y so that wall lies flat: 85deg at the current 5deg
// draft. Hanging tension then runs along layer planes [25]. The drawer
// slot lives in that same wall, so in use it faces the wall it hangs on
// and the pot reads as an unbroken solid from the front and sides.
// The tray prints as modelled: flat on the bed, basin up.
//
// v024: print-feedback round (first physical print).
//   1) CORNERS. (a) The chamfer<->fillet transition was tangent-smooth
//      (G1) but curvature-DISCONTINUOUS: kappa jumps 0 -> 1/rf at each
//      tangent line, which reads as a "step" under a fingertip, and the
//      near-horizontal corner rails in the face print change their
//      layer-stair density abruptly at the same lines. The arc fillets
//      are replaced by G2 blends: tangent angle swept with a
//      raised-cosine curvature profile (zero curvature at both ends),
//      sampled into the outline polygon. blend_l sets the blend length
//      along the outline (auto-clamped where the base chamfer is too
//      short to host it). (b) Wall thickness was NOT uniform: the
//      cavity reused the outer chamfer sizes, leaving bottom corners
//      ~4.5mm and TOP CORNERS ONLY ~2.3mm vs the 3.2mm flats. The
//      cavity is now a true parallel inset (inset = wall) of the outer
//      outline: 3.2mm everywhere, corners included.
//   2) FINGER PULL. The pocket mouth (~7mm) only admitted a fingernail.
//      The pocket now opens through the BOTTOM of the face plate: in
//      use the pot bottom is open air, so a finger comes up from below,
//      slides flat into the recess, and curls behind the hook shelf /
//      nib to pull. All edges keep their pocket_fr fillets; the entry
//      flare now eases the two side rims and the shelf rim.
//   3) HEIGHT COMPACTION (+volume). Dead air around the tray removed:
//      basin 11 -> 8 tall (capacity ~60mL, ample for drainage catch),
//      slot opening 13.5 -> 9.5 (top at 12.5), pot floor dropped
//      19..22 -> 14.5..17.5 (a deliberate departure from the STEP
//      source floor heights). Soil volume gain ~63mL and +4.5mm root
//      depth; every clearance in the stack is now 1.5-2mm.
// v023: finger pocket filleted on every edge: cutter rebuilt from
//   rounded sphere-hull volumes + entry flare; nib grown to 1.6x1.6 so
//   the catch survives the rounding.
// v022: four base-corner nubs fixed — the rail shelves punched ~1.6mm
//   teeth through the skirt corner chamfers at bed level (since v015);
//   rails now clipped to an inset copy of the base outline.
// v021: rim-corner sweep bug fixed — roundover slices were shrunk
//   before rounding, over-insetting corners by ~0.41*inset (the rim
//   nub, v013-v020); slices are now true parallel curves (inset applied
//   after rounding — soft_prism keeps this order in v024's G2 form).
// v020: corner_rf 3 -> 6 attempting the rim nubs (superseded by v021).
// v019: v011's transition fillets returned on the body chamfers
//   (superseded by v024's G2 blends).
// v018: pocket deepened to 5.0 (first-knuckle hook); pure 45deg
//   chamfers returned (ch_top 10.4 / ch_bot 5).
// v017: protruding pull lip replaced by an inset pull; the face plate
//   is a wedge parallel to the back wall's draft plane, 0.3mm inside
//   it; grip grooves on the tray underside.
// v016: outer surfaces smoothed (round fillets; superseded), rim
//   roundover swept at 6deg steps (kept).
// v015: hanging support: L-section channel rails carry the tray; slot
//   bottom on a solid sill (sill_h), skirt ring continuous.
// v014: hex band, struts, and captive drip tray REMOVED; drawer bay +
//   pull-out drip tray through a back-wall slot. Visible only from the
//   back.
// v013: flat-rim setback REMOVED; uniform wall to the top, 3mm rim
//   roundover.
// v012/v011/v010/v009: rim r1; chamfer+fillet combo; 5deg draft
//   everywhere (height = 11.15/tan(5) = 127.44); side-print audit
//   fixes (hex drainage holes, 3.2 walls).
// v008..v002: strut band; one-body merge; exact two-body geometry
//   (shell taper LINEAR, outer 163.2x95.2 -> 185.5x117.5); early
//   reworks. 5x drainage holes per horticultural guidance (v004), as
//   10x7 hexes since v009.

part    = "all";   // "pot" | "tray" | "all"
pullout = 40;      // assembly preview only: tray drawn out along +X (mm)

$fn = 96;

// --- Shell: linear taper, ground to rim (per-body verts) ---
top_x   = 185.5;
top_y   = 117.5;
bot_x   = 163.2;   // skirt outer at Z=0 (+-81.59)
bot_y   = 95.2;    // (+-47.59)
draft   = 5;       // wall draft, degrees — all four walls
height  = (top_x - bot_x)/2 / tan(draft);   // 127.44 at 5deg
// One height can only set every wall to `draft` because both directions
// share the same half-difference; keep it that way.
assert(abs((top_x - bot_x) - (top_y - bot_y)) < 1e-6,
       "X and Y tapers differ; a single height cannot give one draft");
ch_top  = 10.4;    // 45deg corner chamfer at the rim
ch_bot  = 5;       // 45deg corner chamfer at the base
blend_l = 8;       // G2 blend length on each chamfer transition [v024];
                   // auto-clamped where the chamfer edge is too short
wall    = 3.2;     // 8x a 0.4mm extrusion line [1]; uniform everywhere
                   // incl. corners since v024 (cavity = parallel inset)

// --- Rim: uniform wall thickness to the top, rounded outer lip ---
rim_r = 3;   // top-edge roundover; on a 3.2 wall this sweeps to within
             // 0.2mm of the inner face (a near-full-width rounded lip)
assert(rim_r <= wall,
       "rim_r > wall: the roundover would undercut the inner face");

// --- Pot floor (was 19..22 per STEP; dropped in v024 to reclaim the
//     drawer bay's dead height as soil volume) ---
floor_bot = 14.5;
floor_top = 17.5;

// Drainage: 5 holes (v004 horticultural spec), hexagonal for the face
// print — pointed along pot-X so the points face print-vertical [3,4].
// 10x7 hex ~= 45mm2 open, matching the previous 8mm round hole.
drain_x  = 10;     // point-to-point, along pot-X
drain_y  = 7;      // across, along pot-Y
hole_pos = [[0, 0], [38, 19], [-38, 19], [38, -19], [-38, -19]];

// --- Drawer slot (back wall = +X end wall, the print-bed face) ---
sill_h    = 3;     // solid sill below the slot; its top is the channel
                   // floor at the back, and it keeps the skirt ring whole
slot_open = 9.5;   // opening height above the sill (13.5 before v024)
slot_w    = 70;    // opening width, centered in Y
slot_top  = sill_h + slot_open;   // 12.5
slot_ch   = 1;     // 45deg chamfer on the slot's top corners (2 before
                   // v024; the compacted stack needs the corner room)
tray_clr  = 0.5;   // per-side clearance, slot to tray
assert(slot_top <= floor_bot - 2,
       "slot too tall: keep a solid lintel band below the pot floor");
assert(slot_w/2 <= bot_y/2 - wall - ch_bot,
       "slot_w too wide: slot must stay in the flat of the back wall");

// --- Channel rails: L-section, one per side, full bay length ---
rail_under = 3.5;  // shelf reach beneath each tray edge
rail_lip_t = 3;    // upstand thickness
rail_lip_h = 8;    // upstand height (guides the basin's lower half)
rail_gap   = 0.5;  // lateral clearance, tray edge to upstand

// --- Pull-out drip tray (modelled with its bottom at Z0 = as printed;
//     seated in the pot it rides the channel at Z = sill_h) ---
tray_len   = 160;    // front edge stops 0.26 shy of the far wall when
                     // the face plate is flush with the back at Z0
tray_w     = slot_w - 2*tray_clr;   // 69
tray_wall  = 2;      // basin wall
tray_floor = 2;      // basin floor plate
tray_rim   = 8;      // basin height (~60mL; 11 before v024)
tray_ch    = 2;      // basin corner chamfer, in plan
face_t     = 6.8;    // face plate thickness at its base — thick enough
                     // to hide the finger recess behind a >=1.6mm web
face_h     = slot_open - tray_clr;  // 9
face_setback = 0.3;  // face plane parked this far inside the wall plane

// Inset pull: finger recess in the face plate, OPEN AT THE BOTTOM
// [v024] — a finger comes up from under the pot, slides into the
// recess, and curls behind the hook shelf / nib. Every edge filleted
// [v023].
pocket_w  = 40;      // opening width, centered
pocket_d  = 5.0;     // depth, measured from the (drafted) face plane
pocket_z1 = 6;       // hook shelf: the bar your fingertip curls behind
nib_d     = 1.6;     // nib at the shelf's outer edge...
nib_h     = 1.6;     //   ...hangs this far below the shelf
pocket_fr = 0.8;     // fillet on every pocket edge + the entry rims

// Grip grooves across the tray's underside near the back — the same
// under-pot reach that serves the pull.
grip_n     = 3;
grip_w     = 4;      // groove width (45deg-chamfered sides, prints flat)
grip_d     = 0.6;    // depth into the tray_floor plate
grip_x0    = 58;     // outermost groove center (pot X)
grip_pitch = 8;

assert(tray_rim < slot_open - tray_clr, "basin rim cannot pass the slot");
assert(sill_h + tray_rim + tray_clr <= slot_top - slot_ch,
       "basin's top corners reach into the slot's corner chamfers");
assert(sill_h + face_h + tray_clr <= slot_top,
       "face plate taller than the opening above the sill");
assert(pocket_z1 <= face_h - 3,
       "hook shelf too high: keep a stiff rail above the recess");
assert(pocket_z1 - nib_h >= 3,
       "no room under the nib for a fingertip to enter the hook");
assert(nib_d + 2*pocket_fr < pocket_d,
       "nib too deep: no room behind it for the filleted hook shelf");
assert(face_t - face_setback + sill_h*tan(draft) - pocket_d >= 1.6,
       "recess too deep: <1.6mm web behind it at the plate bottom");
assert(grip_d <= tray_floor - 1.2,
       "grip grooves too deep for the tray floor plate");

back_x = bot_x/2;    // back wall outer plane at Z0 (the flush reference)
// Insertion stop: front edge meets the far wall inner face at sill_h.
assert(back_x - tray_len >= -(bot_x/2 - wall) - sill_h*tan(draft),
       "tray_len too long: front edge starts inside the far wall");

// Rail cross-section, derived from the tray so the fit is definitional:
rail_y_in   = tray_w/2 - rail_under;          // shelf inner edge (31)
rail_lip_in = tray_w/2 + rail_gap;            // upstand inner face (35)
rail_y_weld = bot_y/2 - wall + 2;             // buried into the skirt
rail_x_end  = bot_x/2 - 1.6;                  // buried into both end walls
assert(rail_lip_in >= slot_w/2 - 0.01,
       "upstand faces must not sit inside the slot side walls");

eps = 0.01;

// Chamfered-rectangle corner points — the design language throughout:
// body shell, floor plinth, slot, and tray all share it.
function cham_pts(x, y, ch) =
    [[-x/2 + ch, -y/2], [x/2 - ch, -y/2], [x/2, -y/2 + ch],
     [x/2,  y/2 - ch], [x/2 - ch,  y/2], [-x/2 + ch,  y/2],
     [-x/2,  y/2 - ch], [-x/2, -y/2 + ch]];

// Rectangle with sharp 45deg chamfered corners, extruded — the interior
// prisms (floor plinth, tray, basin) stay crisp.
module hex_prism(x, y, h, ch) {
    linear_extrude(height = h) polygon(cham_pts(x, y, ch));
}

// --- G2 corner blends [v024] -----------------------------------------
// Tangent angle swept with a raised-cosine curvature profile: kappa is
// zero at both ends of the blend, so flats meet blends with NO
// curvature jump (the v019-v023 arc fillets were G1 only — the "step"
// you could feel). _bc integrates the unit-length blend curve for a
// 45deg left turn; a_unit is its tangent length behind the vertex.
bc_n = 16;                       // samples per blend
function _theta(u) = 45 * (u - sin(360*u) / (2*PI));   // degrees
function _bc(L, i = 0, p = [0, 0], acc = [[0, 0]]) =
    i >= bc_n ? acc :
    let(th = _theta((i + 0.5) / bc_n),
        q  = p + (L/bc_n) * [cos(th), sin(th)])
    _bc(L, i + 1, q, concat(acc, [q]));
bc_unit = _bc(1);
bc_end  = bc_unit[len(bc_unit) - 1];
a_unit  = bc_end.x - bc_end.y;   // tangent length per unit L (cot 45 = 1)

// Chamfered rectangle whose 8 vertices are replaced by G2 blends of
// length L (clamped so two blends fit on the chamfer edge).
function smooth_pts(x, y, ch, L) =
    let(Lc = min(L, 0.95 * (ch * sqrt(2) / 2) / a_unit),
        P  = cham_pts(x, y, ch), N = len(P))
    [for (j = [0 : N - 1])
        let(V   = P[j],
            din = (V - P[(j + N - 1) % N]) / norm(V - P[(j + N - 1) % N]),
            ang = atan2(din.y, din.x),
            S   = V - a_unit * Lc * din)
        for (q = _bc(Lc))
            S + [q.x * cos(ang) - q.y * sin(ang),
                 q.x * sin(ang) + q.y * cos(ang)]];

// Chamfer+G2-blend outline, extruded. `inset` parallel-insets the
// FINISHED outline (applied after blending — the v021 rule), so rim
// roundover slices and the cavity are true parallel curves.
module soft_prism(x, y, h, ch, L, inset = 0) {
    linear_extrude(height = h)
        offset(delta = -inset)
            polygon(smooth_pts(x, y, ch, L));
}
// ----------------------------------------------------------------------

// Outer shell with a rounded top edge: the hull's top is a stack of
// inset slices tracing a quarter-round of radius rim_r, at 6deg steps.
module outer_shell() {
    hull() {
        soft_prism(bot_x, bot_y, eps, ch_bot, blend_l);
        for (t = [0 : 6 : 90])
            translate([0, 0, height - rim_r + rim_r*sin(t) - eps])
                soft_prism(top_x, top_y, eps, ch_top, blend_l,
                           inset = rim_r*(1 - cos(t)));
    }
}

// Cavity: a true parallel inset (inset = wall) of the outer outlines,
// so the wall is 3.2mm THROUGH the corners too [v024] — before this the
// top corners ran ~2.3mm and the bottom corners ~4.5mm.
module cavity() {
    hull() {
        translate([0, 0, -eps])
            soft_prism(bot_x, bot_y, eps, ch_bot, blend_l, inset = wall);
        translate([0, 0, height + eps])
            soft_prism(top_x, top_y, eps, ch_top, blend_l, inset = wall);
    }
}

// Drainage hexagon: pointed along pot-X (print-vertical when the floor
// prints as a vertical wall), 45deg point slopes, punched along pot-Z.
module drain_hole() {
    hu = drain_x/2; hv = drain_y/2; rise = hv;   // rise = hv -> 45deg
    linear_extrude(height = floor_top - floor_bot + 4, center = true)
        polygon([[-hu, 0], [-hu + rise, hv], [hu - rise, hv],
                 [hu, 0], [hu - rise, -hv], [-hu + rise, -hv]]);
}

function ox(z) = bot_x + (top_x - bot_x) * z / height;
function oy(z) = bot_y + (top_y - bot_y) * z / height;

// Slot / face-plate profile in the Y-Z plane: flat bottom at `bot`,
// 45deg chamfers on the top two corners only (the bottom rides the
// sill / channel floor).
function slot_pts(w, h, ch, bot) =
    [[-w/2, bot], [w/2, bot], [w/2, h - ch], [w/2 - ch, h],
     [-w/2 + ch, h], [-w/2, h - ch]];

// Punch the drawer slot along +X through the back wall, from the sill
// top up. The wall leans outward with height (5deg draft), so the
// cutter runs from inside the empty bay to well past the outer face.
module slot_cut() {
    run = 10 + wall + slot_top*tan(draft) + 5;
    translate([back_x - 10, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = run)
                polygon(slot_pts(slot_w, slot_top, slot_ch, sill_h));
}

// Channel rails: an L per side — shelf under the tray edge, upstand
// beside it. Both run the full bay length and bury into the skirt side
// walls and both end walls. In the face print these are vertical fins:
// no overhangs. The whole set is clipped to an inset copy of the base
// outline so the buried weld corners stop >=1mm behind the outer skin
// instead of punching teeth through the corner chamfers [v022].
module rails() {
    intersection() {
        union() {
            for (m = [0, 1]) mirror([0, m, 0]) {
                // Shelf: channel floor, continuous with the sill top.
                translate([-rail_x_end, rail_y_in, 0])
                    cube([2*rail_x_end, rail_y_weld - rail_y_in, sill_h]);
                // Upstand: lateral guide, coplanar with the slot side
                // wall.
                translate([-rail_x_end, rail_lip_in, 0])
                    cube([2*rail_x_end, rail_lip_t, rail_lip_h]);
            }
        }
        hex_prism(bot_x - 2.4, bot_y - 2.4, rail_lip_h + 2, ch_bot);
    }
}

// Drainage must drip inside the tray basin (checked against the basin's
// inner faces with the tray fully seated).
basin_in_y  = tray_w/2 - tray_wall;
basin_in_x0 = back_x - tray_len + tray_wall;   // front inner face
basin_in_x1 = back_x - face_t;                 // face-plate inner face
function holes_over_tray() =
    [for (p = hole_pos)
        assert(p[0] + drain_x/2 < basin_in_x1,
               str("hole at ", p, " past the tray face plate"))
        assert(p[0] - drain_x/2 > basin_in_x0,
               str("hole at ", p, " past the tray front wall"))
        assert(abs(p[1]) + drain_y/2 < basin_in_y,
               str("hole at ", p, " outside the tray basin in Y"))
        p];

module pot() {
    difference() {
        union() {
            // Shell: solid skirt, ground to rim, linear taper.
            difference() {
                outer_shell();
                cavity();
            }
            // Floor.
            intersection() {
                cavity();
                translate([0, 0, floor_bot])
                    hex_prism(ox(floor_top), oy(floor_top),
                              floor_top - floor_bot, ch_bot);
            }
            // Channel rails for the tray.
            rails();
        }

        // Drainage holes through the floor.
        for (p = holes_over_tray())
            translate([p[0], p[1], (floor_bot + floor_top)/2])
                drain_hole();

        // Drawer slot through the back wall, above the sill.
        slot_cut();
    }
}

// Face plane of the seated tray, in tray-local coords (bottom at Z0):
// parallel to the back wall's draft plane, face_setback inside it.
face_x0 = back_x - face_setback + sill_h*tan(draft);   // at tray Z0
function face_x(z) = face_x0 + z*tan(draft);

// Finger recess cutter, every edge filleted [v023], open through the
// plate bottom [v024]: three rounded volumes (hulls of r=pocket_fr
// spheres tracking the drafted face plane).
//   A1 — mouth cavity: from below the plate up to the nib's underside,
//        running out past the face;
//   A2 — the tall cavity behind the nib, up to the hook shelf;
//   B  — entry flare: rounded edges reach pocket_fr past the face
//        plane, easing the side and shelf rims.
// The nib's inner-bottom hook corner (A1-top meets A2-wall) stays crisp
// for grip. In the flat tray print: vertical walls and short rounded
// bridges only.
module pocket_cut() {
    fr = pocket_fr;
    yh = pocket_w/2 - fr;
    zm = pocket_z1 - nib_h;   // nib underside
    // A1: bottom-open mouth, up to the nib underside.
    hull()
        for (zc = [-3, zm - fr], yc = [-yh, yh],
             dc = [pocket_d - fr, -2])
            translate([face_x(zc) - dc, yc, zc]) sphere(r = fr);
    // A2: bottom-open cavity behind the nib, up to the hook shelf.
    hull()
        for (zc = [-3, pocket_z1 - fr], yc = [-yh, yh],
             dc = [pocket_d - fr, nib_d + fr])
            translate([face_x(zc) - dc, yc, zc]) sphere(r = fr);
    // B: entry flare, also open-bottom, rounded rim at the face plane.
    hull()
        for (zc = [-3, zm], yc = [-pocket_w/2, pocket_w/2],
             dc = [0, -3])
            translate([face_x(zc) - dc, yc, zc]) sphere(r = fr);
}

// Grip grooves: shallow 45deg-sided channels across the tray underside.
module grip_grooves() {
    for (i = [0 : grip_n - 1])
        translate([grip_x0 - i*grip_pitch, 0, 0])
            rotate([90, 0, 0])
                linear_extrude(height = tray_w - 2*tray_ch - 2,
                               center = true)
                    polygon([[-grip_w/2, -eps], [grip_w/2, -eps],
                             [grip_w/2 - grip_d, grip_d],
                             [-grip_w/2 + grip_d, grip_d]]);
}

// Pull-out drip tray: basin + inset-pull face plate. Modelled with its
// bottom at Z0 (prints as-is, basin up); main() seats it at sill_h.
module tray() {
    xc = back_x - tray_len/2;   // basin center
    difference() {
        union() {
            // Basin: uniform tray_wall walls on a tray_floor plate.
            difference() {
                translate([xc, 0, 0])
                    hex_prism(tray_len, tray_w, tray_rim, tray_ch);
                translate([xc, 0, tray_floor])
                    hex_prism(tray_len - 2*tray_wall,
                              tray_w - 2*tray_wall, tray_rim, tray_ch);
            }
            // Face plate: extruded past the draft plane, then trimmed
            // back to it — a wedge whose outer face parallels the wall.
            difference() {
                translate([back_x - face_t, 0, 0])
                    rotate([90, 0, 90])
                        linear_extrude(height = face_t + 4)
                            polygon(slot_pts(tray_w, face_h, slot_ch, 0));
                translate([face_x0, 0, 0])
                    rotate([0, draft, 0])
                        translate([0, -tray_w, -5])
                            cube([30, 2*tray_w, face_h + 10]);
            }
        }
        // Inset pull.
        pocket_cut();
        // Underside grip.
        grip_grooves();
    }
}

module main() {
    if (part == "pot" || part == "all") pot();
    if (part == "tray") tray();
    if (part == "all")
        translate([pullout, 0, sill_h]) tray();   // seated on the channel
}

if (is_list(holes_over_tray())) main();
