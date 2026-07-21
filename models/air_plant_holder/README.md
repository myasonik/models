# Air Plant Holder — Double-Diamond Wireframe Cage

A geometric display stand for the tall Tillandsia (the leftmost plant, caput-medusae type). Two stacked diamonds accentuate the plant's height. The front face is a flat double-diamond wireframe; the back pops out — each diamond tapers to an apex vertex behind its widest point, so the side profile is a crystal-like zigzag rather than a flat plane. The whole cage rocks back 8° so the plant reclines, and a scoop cage pops out the front of the bottom section to catch the base of the plant. No solid faces anywhere.

![front](preview_front.png)

## Plant measurements (from caliper photo)

- Full plant height: ~135mm
- Bulb width: ~40mm
- Bulb depth: ~30mm

## Model dimensions

- Overall height: ~152mm; the two diamond sections are identical — 60mm wide × 74mm tall each
- Cage incline: 8° backward, pivoting at the base contact so the plant sits reclined
- Base: wireframe cage like everything else — a diamond-plan ground ring (72 × 68mm) whose four corners send risers up to the cage's bottom vertex, forming a hollow pyramid; the ring struts are shaved flat underneath so it sits level
- Struts: 4.4mm diameter round
- Cradle ribs run from the lower V back to its apex and support the bulb
- Front scoop: the bottom section's corners converge on an apex 16mm in front of the front frame, catching the reclined bulb
- Waist bar recessed 22mm behind the front frame so it doesn't push the plant out
- Each diamond's four corners converge on a back apex vertex 22mm behind center — the popped-out crystal profile
- A reference plant model (bulb + leaves, `%` modifier) shows in previews to check fit but is excluded from the STL

## Design intent

- **Geometric**: stacked diamond silhouette per the sketch
- **Height-accentuating**: the tall upper diamond frames the plant's leaves and tops out just above them
- **Open front**: no solid faces anywhere; the flat front frame leaves the plant fully visible while the cage volume pops backward behind it
- **Flat base**: sits flat on a table; the bulb wedges into the lower V and rests on two cradle ribs

## Printing

- Print upright as modeled, PLA or PETG
- 0.2mm layers; the two horizontal corner-to-apex struts on each diamond bridge ~45mm — most printers handle this, but enable supports if your bridging is poor
- No infill to speak of — the part is struts and a thin plate
- ~30g of filament

## Customization

Key parameters at the top of `air_plant_holder_001.scad`:

```openscad
zT = 152;        // overall height
w2 = 34;         // upper diamond half-width
pop = 22;        // how far the back apexes pop out
fpop = 16;       // how far the front scoop pops out
tilt = 8;        // backward incline in degrees
strut_r = 2.2;   // strut radius
```

## Version 002 — symmetric variant

`air_plant_holder_002.scad` mirrors the bottom half exactly onto the top: the
upper diamond gets its own front scoop and cradle ribs, and a crown ring —
the base pyramid mirrored — opens upward from the top vertex. Print note: the
crown ring is a large horizontal loop in mid-air and will need supports.

## Version 003 — triple diamond

`air_plant_holder_003.scad` extends v001 to THREE stacked identical diamonds
(60 × 46mm each, ~164mm overall). Same wireframe base pyramid, back apex per
diamond, bottom front scoop, and two recessed waist bars. The plant occupies
the lower two diamonds; the top diamond crowns the height. The base pyramid
matches the diamonds' proportions exactly: 60 × 60mm ground ring, 25mm tall —
the same shape as a diamond half. Vertical beams run along the front edges
through the diamonds' collinear side tips (x = ±30), tying the three diamonds
together and stiffening the front frame.

## Version 004 — hanging wall pendant

`air_plant_holder_004.scad` is a wall-hung take on a geometric hanging pendant:
a teardrop wireframe (~52mm wide, ~148mm tall plus hanging tab) whose back
plane is shaved flat to lie flush against the wall. The front pops 36mm off
the wall to a vertex at the widest ring, forming a basket that cradles the
bulb (interior ~48mm wide × ~31mm deep); cradle ribs bridge the lower cone.
The hanging eyelet is nested inside the upper cone just below the tip — a
small teardrop washer flush with the wall, with a 5mm nail hole; the front
strut is ~7mm off the wall there, leaving nail-head clearance. Print it lying
on its flat back; light support under the front vertex may help.

## Files

- `air_plant_holder_001.scad` / `.stl` — two-diamond version (validated)
- `air_plant_holder_002.scad` / `.stl` — symmetric variant of v001 (validated)
- `air_plant_holder_003.scad` / `.stl` — triple-diamond version (validated)
- `air_plant_holder_004.scad` / `.stl` — hanging wall pendant (validated)
- `preview_*.png` — v001; `preview2_*.png` — v002; `preview3_*.png` — v003;
  `preview4_*.png` — v004
