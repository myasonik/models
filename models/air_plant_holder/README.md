# Air Plant Holder — Double-Diamond Wireframe Cage

A geometric display stand for the tall Tillandsia (the leftmost plant, caput-medusae type). Two stacked diamonds accentuate the plant's height. The front face is a flat double-diamond wireframe; the back pops out — each diamond tapers to an apex vertex behind its widest point, so the side profile is a crystal-like zigzag rather than a flat plane. The whole cage rocks back 8° so the plant reclines, and a scoop cage pops out the front of the bottom section to catch the base of the plant. No solid faces anywhere.

![front](preview_front.png)

## Plant measurements (from caliper photo)

- Full plant height: ~135mm
- Bulb width: ~40mm
- Bulb depth: ~30mm

## Model dimensions

- Overall height: ~152mm; both sections are equal height (74mm each, waist at the midpoint)
- Cage incline: 8° backward, pivoting at the base contact so the plant sits reclined
- Base plate: 64 × 58 × 4mm, flat for table placement, with an 8mm drainage hole under the bulb
- Struts: 4.4mm diameter round
- Lower diamond: 54mm wide, with cradle ribs running back to its apex that support the bulb
- Front scoop: the bottom section's corners converge on an apex 16mm in front of the front frame, catching the reclined bulb
- Upper diamond: 68mm wide
- Waist bar recessed 22mm behind the front frame so it doesn't push the plant out
- Each diamond's four corners converge on a back apex vertex 22mm behind center — the popped-out crystal profile
- Conical gusset reinforces the single bottom-vertex contact with the base
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

## Files

- `air_plant_holder_001.scad` — OpenSCAD source
- `air_plant_holder_001.stl` — validated, print-ready mesh
- `preview_front.png`, `preview_iso.png`, `preview_side.png` — renders
