# Filament Swatch Generator

Automated system to generate and slice 3D printable filament swatches. Uses GitHub Actions to automatically generate 3MF models and pre-sliced GCODE files for various materials and printers.

## Features

- OpenSCAD-based parametric swatch design
- Automated model generation from material CSV files
- Multi-printer GCODE generation
- Uses official PrusaSlicer built-in material profiles
- Automatic ironing modifier application
- GitHub Actions automation for continuous deployment

## Project Structure

```
.
├── materials/           # CSV files containing material definitions
├── swatch/             # OpenSCAD source files
├── scripts/            # Python scripts for automation
├── slicer-profiles/    # Official PrusaSlicer profiles (submodule)
└── .github/workflows/  # GitHub Actions workflow definitions
```

## Material CSV Format

Materials are defined in CSV files with the following columns:

```csv
Material,Brand,Color,FilamentProfile
PLA,Prusament,Galaxy Black,Prusament PLA
PETG,Generic,Blue,Generic PETG
```

### Field Descriptions

- `Material`: Type of material (PLA, PETG, etc.)
- `Brand`: Manufacturer name
- `Color`: Color name
- `FilamentProfile`: PrusaSlicer built-in filament profile name (e.g., "Prusament PLA", "Generic PETG")

### Supported Printers

The system supports generating GCODE for the following Prusa printers:
- Original Prusa MK3S+ (using MK3.5 profiles)
- Original Prusa MK4IS (using MK4S profiles)
- Original Prusa MK4S
- Original Prusa MINI+
- Prusa CORE ONE
- Original Prusa XL IS

Each printer uses its corresponding official PrusaSlicer profile for optimal slicing settings.

## Printer Support

The system automatically uses PrusaSlicer's built-in printer profiles. Supported printers and their profile mappings:

| Printer Model | Profile Used | Notes |
|--------------|--------------|-------|
| Original Prusa MK3S+ | @MK3.5 | Generic ABS not supported |
| Original Prusa MK4IS | @MK4S | |
| Original Prusa MK4S | @MK4S | |
| Original Prusa MINI+ | @MINIIS, @MINI | |
| Prusa CORE ONE | @COREONE | |
| Original Prusa XL IS | @XLIS, @XL | |

Each printer uses its corresponding quality profiles (e.g., "0.20mm QUALITY MK4S" for MK4S).

## Printer Configurations

Printer configurations are defined in `printers/config.json`:

```json
{
  "printers": [
    {
      "name": "Original Prusa MK4S",
      "profile": "Original Prusa MK4S",
      "print_profiles": [
        "0.20mm QUALITY MK4S",
        "0.28mm DRAFT MK4S"
      ]
    }
  ]
}
```

Each printer configuration specifies:
- `name`: Display name for the printer
- `profile`: PrusaSlicer printer profile name
- `print_profiles`: List of print profiles to generate GCODE for

## Generated Files

For each material and printer combination, the following files are generated:

```
output/
├── 3mf/
│   └── Brand_Material_Color.3mf           # Base 3MF model
│   └── Brand_Material_Color_Printer.3mf   # Printer-specific 3MF
└── gcode/
    └── Brand_Material_Color_Printer_Quality.gcode
    └── Brand_Material_Color_Printer_Draft.gcode
```

## Material Settings

Material settings are automatically extracted from the official PrusaSlicer profiles, including:
- Nozzle temperature (from material profile)
- Layer height (from print profile)

The system follows PrusaSlicer's profile inheritance to get the correct settings:
1. Printer-specific material profile (e.g., "Generic PETG @MK4S")
2. Base material profile (e.g., "Generic PETG")
3. Material type profile (e.g., "*PETG*")
4. Common filament settings

### Material Compatibility

Not all materials are supported on all printers. Notable limitations:
- Generic ABS is not supported on the Original Prusa MK3S+ printer
- For MK3S+, use Prusament ASA or other manufacturer-specific ABS profiles instead

## Text Limitations

To ensure proper model generation, text fields have the following length limits:

- Brand: 30 characters
- Material: 30 characters
- Color: 30 characters

## Testing

### Local Testing

1. Test material config extraction:
   ```bash
   # Test with different materials and printers
   python3 scripts/get_material_config.py "Generic PLA" MK4S
   python3 scripts/get_material_config.py "Generic PETG" MK4S
   python3 scripts/get_material_config.py "Prusament PLA" MK3S
   
   # Test error cases
   python3 scripts/get_material_config.py "NonexistentMaterial" MK4S  # Should fail
   python3 scripts/get_material_config.py "Generic PLA"  # No printer specified
   ```

2. Test model generation:
   ```bash
   # Test with different materials
   for material in "PLA" "PETG" "ASA"; do
     openscad -o "test_${material,,}.3mf" swatch/swatch.scad \
             -D "MATERIAL=\"$material\"" \
             -D "BRAND=\"Test\"" \
             -D "COLOR=\"Natural\"" \
             -D "NOZZLE_TEMP=215"
   done
   ```

3. Test ironing modifier:
   ```bash
   # Test modifier application
   python3 scripts/modify_3mf.py test_pla.3mf
   ```

4. Test full workflow:
   ```bash
   # Example workflow for MK4S with PLA
   # 1. Get material config
   python3 scripts/get_material_config.py "Generic PLA" MK4S > material.json
   
   # 2. Generate model
   openscad -o test_swatch.3mf swatch/swatch.scad \
           -D "MATERIAL=\"PLA\"" \
           -D "BRAND=\"Generic\"" \
           -D "COLOR=\"Natural\"" \
           -D "NOZZLE_TEMP=$(jq -r .temperature material.json)"
   
   # 3. Add ironing modifier
   python3 scripts/modify_3mf.py test_swatch.3mf
   
   # 4. Slice with PrusaSlicer
   prusa-slicer --printer "Original Prusa MK4S" \
                --filament "Generic PLA" \
                --print "0.20mm QUALITY MK4S" \
                --export-gcode \
                --output test_swatch_mk4s.gcode \
                test_swatch.3mf
   ```

### Common Issues

1. Material Profile Not Found
   - Check if the material name matches exactly with PrusaSlicer's profile name
   - Verify the printer model is supported
   - Check slicer-profiles submodule is up to date

2. OpenSCAD Errors
   - Verify text lengths are within limits
   - Check for special characters in text fields
   - Ensure NOZZLE_TEMP is a valid number

3. PrusaSlicer Errors
   - Verify PrusaSlicer version (2.6.0 or later recommended)
   - Check if the print profile exists for your printer
   - Ensure the model has the ironing modifier correctly applied

## Progress Tracking

### Done ✅
- Basic OpenSCAD swatch model
- GitHub Actions workflow setup
- CSV-based material definition
- Input validation in OpenSCAD
- Text length limitations
- Ironing modifier implementation
- PrusaSlicer built-in profile integration
- Multi-printer support

### In Progress 🚧
- Preview image generation
- Material-specific modifier settings
- MVP Testing: Prusament PLA on MK4S with ironing modifiers

### MVP Testing

Currently focusing on testing the following configuration:
- Printer: Original Prusa MK4S
- Material: Prusament PLA
- Feature: Ironing modifier for the top surface

To test the MVP configuration:

```bash
# 1. Generate 3MF for Prusament PLA
python3 scripts/get_material_config.py "Prusament PLA" MK4S > material.json

# 2. Generate base model
openscad -o test_prusament_pla.3mf swatch/swatch.scad \
        -D "MATERIAL=\"PLA\"" \
        -D "BRAND=\"Prusament\"" \
        -D "COLOR=\"Galaxy Black\"" \
        -D "NOZZLE_TEMP=$(jq -r .temperature material.json)"

# 3. Add ironing modifier
python3 scripts/modify_3mf.py test_prusament_pla.3mf

# 4. Slice with PrusaSlicer
prusa-slicer --printer "Original Prusa MK4S" \
             --filament "Prusament PLA" \
             --print "0.20mm QUALITY MK4S" \
             --export-gcode \
             --output test_prusament_pla_mk4s.gcode \
             test_prusament_pla.3mf
```

The ironing modifier is applied to specific surfaces of the swatch to achieve a glossy finish. This is currently being tested and refined for optimal results.

### Todo 📝
- Add test cases for model generation
- Implement error reporting in GitHub Actions
- Add support for custom material profiles
- Improve error messages and validation

## Contributing

1. Update material definitions in the CSV files
2. Test locally using OpenSCAD
3. Submit a pull request

## Local Development

### Prerequisites

- OpenSCAD
- PrusaSlicer 2.6.0 or later
- Python 3.x
- Git (for submodules)

### Setup

1. Clone the repository with submodules:
   ```bash
   git clone --recursive https://github.com/yourusername/swatch-generator.git
   ```

2. Update submodules if needed:
   ```bash
   git submodule update --init --recursive
   ```

### Testing Locally

1. Generate a test swatch:
   ```bash
   # Generate 3MF for MK4S
   python3 scripts/get_material_config.py "Prusament PLA" MK4S > material.json
   openscad -o test_swatch.3mf swatch/swatch.scad -D "MATERIAL=\"PLA\"" \
           -D "BRAND=\"Prusament\"" -D "COLOR=\"Galaxy Black\"" \
           -D "NOZZLE_TEMP=$(jq -r .temperature material.json)"
   
   # Add ironing modifier
   python3 scripts/modify_3mf.py test_swatch.3mf
   
   # Slice with PrusaSlicer
   prusa-slicer --printer "Original Prusa MK4S" \
                --filament "Prusament PLA" \
                --print "0.20mm QUALITY MK4S" \
                --output test_swatch_mk4s_quality.gcode \
                test_swatch.3mf
   ``` 