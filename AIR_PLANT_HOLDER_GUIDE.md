# Air Plant Holder - Geometric Cage Model

## Overview
This is a 3D-printable geometric cage holder designed for the leftmost air plant in your collection. The design emphasizes the plant's height with a minimalist, open-front structure perfect for display on a table or shelf.

## Design Specifications

### Dimensions (based on plant measurements with ruler)
- **Plant height**: ~50-60mm
- **Plant base width**: ~30-40mm  
- **Plant depth**: ~32mm

### Model Dimensions
- **Base**: 52mm × 48mm × 5mm (rectangular, flat for stability)
- **Total height**: ~100mm (emphasizes plant height)
- **Cage depth**: 32mm
- **Structure**: Geometric wireframe with struts (~2mm diameter)

### Key Features
1. **Flat rectangular base** - Provides stable placement on tables/shelves
2. **Back panel** - Solid support panel for structural rigidity (85mm tall)
3. **Open front** - Completely open as requested for full visibility of the plant
4. **Geometric frames** - Two nested diamond-shaped geometric structures:
   - Lower diamond at ~35% height
   - Upper diamond at ~65% height
5. **Peak accent** - Tapering geometric point at the top
6. **Vertical struts** - Four corner columns connecting base to frame

## How to Export to STL

### Option 1: Local OpenSCAD Installation (Recommended)
1. Download OpenSCAD from https://openscad.org/ (free, open-source)
2. Open `air_plant_holder.scad` in OpenSCAD
3. **Export as STL**:
   - Press **Ctrl+Shift+E** (or File → Export as STL)
   - Choose binary STL format (smaller file size)
   - Save as `air_plant_holder.stl`
4. Import the STL file into your 3D slicer (Cura, PrusaSlicer, etc.)

### Option 2: Online OpenSCAD Viewer
1. Go to https://www.viewstl.com/ or https://openscad.org/
2. Upload the `air_plant_holder.scad` file
3. Export to STL directly

## 3D Printing Recommendations

### Material
- **PLA** or **PETG** recommended for plant holders
- **Resin** also works well for fine geometric details

### Print Settings
- **Layer height**: 0.2mm
- **Infill**: 15-20% (structure is mostly hollow)
- **Support**: May need minimal support under geometric frames
- **Print time**: ~2-3 hours (depends on printer speed)
- **Estimated weight**: 30-50g

### Post-Processing
1. Remove support material
2. Light sanding for smoother finish (optional)
3. Paint or stain if desired (acrylic paint works well)
4. Consider sanding the base flat if needed for level placement

## Assembly & Usage

1. **Print the model**
2. **Prepare the plant**: Gently inspect your air plant
3. **Place in holder**: 
   - Insert the air plant bulb into the lower cage area
   - The plant should sit naturally within the geometric frames
   - Leaves can extend through the open front and sides
4. **Placement**: 
   - Set on a stable, level surface
   - Position near indirect light as air plants prefer

## Care Notes

- **Watering**: Air plants need misting or soaking 1-2x weekly (remove from holder if soaking)
- **Light**: Bright indirect light preferred
- **Air circulation**: The open cage design allows good airflow
- **Stability**: The flat base keeps it stable even with plant movement

## Customization

Want to adjust the model? Here are key parameters in the OpenSCAD file:

```openscad
base_length = 52;      // mm - adjust base width
base_width = 48;       // mm - adjust base depth
cage_height = 95;      // mm - adjust total height
strut_radius = 2;      // mm - adjust strut thickness
back_height = 85;      // mm - adjust back panel height
```

Edit these values and re-export to STL for custom versions.

## Files Included

- `air_plant_holder.scad` - OpenSCAD source file (editable)
- `AIR_PLANT_HOLDER_GUIDE.md` - This guide

## Questions or Issues?

If the model doesn't fit your plant:
1. Verify plant measurements with ruler
2. Adjust `cage_height` and `base_length`/`base_width` as needed
3. Re-export and test print

Enjoy your new air plant display piece!
