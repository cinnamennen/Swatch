# Filament Swatch Generator

Automated system to generate and slice 3D printable filament swatches. Uses GitHub Actions to automatically generate 3MF models and pre-sliced GCODE files for various materials and printers.

## Features

- OpenSCAD-based parametric swatch design
- Automated model generation from material CSV files
- Multi-printer GCODE generation
- Uses official PrusaSlicer built-in material profiles
- Automatic ironing of top surfaces via built-in PrusaSlicer settings
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

## Pipeline Architecture

The system is organized into two main phases:

### Phase 1: Model Generation

1. **Base Model Generation**
   - Input: Material parameters (type, brand, color, temperature)
   - Process: Generate 3D model geometry using OpenSCAD
   - Output: 3MF file with material information embedded

2. **Printer-Specific Configuration**
   - Input: Base 3MF file
   - Process: Apply printer-specific settings and enable ironing
   - Output: Configured 3MF file ready for slicing

### Phase 2: Slicing

1. **GCODE Generation**
   - Input: Configured 3MF file
   - Process: Slice the model using PrusaSlicer with ironing enabled
   - Output: Ready-to-print GCODE file

Each stage in the pipeline:
- Has clear input/output interfaces
- Includes validation steps
- Can be independently tested
- Supports configuration via parameters

## Pipeline Validation

Each phase of the pipeline can be validated independently:

### Phase 1: Model Generation Validation

```bash
# Generate base model
python3 scripts/generate_3mf.py \
    --material "PLA" \
    --brand "Test" \
    --color "Natural" \
    --printer "Original Prusa MK4S"

# Verify file exists and has correct size
ls -l output/3mf/Test_PLA_Natural_MK4S.3mf
```

### Phase 2: Slicing Validation

```bash
# Slice the model with PrusaSlicer
prusa-slicer \
  --export-gcode \
  --load "slicer-profiles/PrusaResearch/2.1.11.ini" \
  --printer "Original Prusa MK4S" \
  --print "0.20mm QUALITY MK4S" \
  --filament "Generic PLA" \
  --print-settings "ironing=1" \
  --print-settings "ironing_type=top" \
  --print-settings "ironing_flowrate=15" \
  "output/3mf/Test_PLA_Natural_MK4S.3mf" \
  --output "output/gcode/Test_PLA_Natural_MK4S_quality.gcode"

# Check for ironing in the GCODE
grep -A10 ";TYPE:Ironing" output/gcode/Test_PLA_Natural_MK4S_quality.gcode
```

### Full Pipeline Validation

Test the complete pipeline with a known-good configuration:

```bash
# 1. Generate 3MF
python3 scripts/generate_3mf.py \
    --material "PLA" \
    --brand "Prusament" \
    --color "Galaxy Black" \
    --printer "Original Prusa MK4S"

# 2. Generate GCODE
prusa-slicer \
  --export-gcode \
  --load "slicer-profiles/PrusaResearch/2.1.11.ini" \
  --printer "Original Prusa MK4S" \
  --print "0.20mm QUALITY MK4S" \
  --filament "Prusament PLA" \
  --print-settings "ironing=1" \
  --print-settings "ironing_type=top" \
  --print-settings "ironing_flowrate=15" \
  "output/3mf/Prusament_PLA_Galaxy_Black_MK4S.3mf" \
  --output "output/gcode/Prusament_PLA_Galaxy_Black_MK4S_quality.gcode"

# 3. Check GCODE for ironing
grep -A10 ";TYPE:Ironing" output/gcode/Prusament_PLA_Galaxy_Black_MK4S_quality.gcode
```

## Test File Organization

To keep the repository clean and organized, all test and validation files should be stored in specific directories:

```
.
├── tests/
│   ├── tmp/              # Temporary files during testing (gitignored)
│   ├── fixtures/         # Known-good test files
│   │   ├── 3mf/         # Base 3MF files
│   │   └── gcode/       # Known-good GCODE files
│   └── validation/      # Validation output directory (gitignored)
│       ├── model/       # Model validation
│       └── slice/       # Slice validation
└── output/             # Production output (gitignored)
    ├── 3mf/
    └── gcode/
```

### File Naming Convention

Test files should follow this naming pattern:
- 3MF models: `{brand}_{material}_{color}_{printer}.3mf`
- GCODE: `{brand}_{material}_{color}_{printer}_{quality}.gcode`

## Material CSV Format

Materials are defined in CSV files with the following columns:

```csv
Material,Brand,Color,FilamentProfile,Temperature
PLA,Prusament,Galaxy Black,Prusament PLA,215
PETG,Generic,Blue,Generic PETG,230
```

### Field Descriptions

- `Material`: Type of material (PLA, PETG, etc.)
- `Brand`: Manufacturer name
- `Color`: Color name
- `FilamentProfile`: PrusaSlicer built-in filament profile name (e.g., "Prusament PLA", "Generic PETG")
- `Temperature`: Nozzle temperature for the material

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
   ```

2. Test model generation:
   ```bash
   # Generate model for testing
   python3 scripts/generate_3mf.py \
       --material "PLA" \
       --brand "Test" \
       --color "Natural" \
       --printer "Original Prusa MK4S"
   ```

3. Test full workflow:
   ```bash
   # Generate 3MF
   python3 scripts/generate_3mf.py \
       --material "PLA" \
       --brand "Generic" \
       --color "Natural" \
       --printer "Original Prusa MK4S"
       
   # Generate GCODE with ironing enabled
   prusa-slicer \
     --export-gcode \
     --load "slicer-profiles/PrusaResearch/2.1.11.ini" \
     --printer "Original Prusa MK4S" \
     --print "0.20mm QUALITY MK4S" \
     --filament "Generic PLA" \
     --print-settings "ironing=1" \
     --print-settings "ironing_type=top" \
     --print-settings "ironing_flowrate=15" \
     "output/3mf/Generic_PLA_Natural_MK4S.3mf" \
     --output "output/gcode/Generic_PLA_Natural_MK4S_quality.gcode"
   ```

### Common Issues

1. Material Profile Not Found
   - Check if the material name matches exactly with PrusaSlicer's profile name
   - Verify the printer model is supported
   - Check slicer-profiles submodule is up to date

2. OpenSCAD Errors
   - Verify text lengths are within limits
   - Check for special characters in text fields
   - Ensure temperature is a valid number

3. PrusaSlicer Errors
   - Verify PrusaSlicer version (2.6.0 or later recommended)
   - Check if the print profile exists for your printer
   - Ensure profile names match exactly with the INI file format

## Progress Tracking

### Done ✅
- Basic OpenSCAD swatch model
- GitHub Actions workflow setup
- CSV-based material definition
- Input validation in OpenSCAD
- Text length limitations
- Ironing implementation via PrusaSlicer settings
- PrusaSlicer built-in profile integration
- Multi-printer support

### In Progress 🚧
- Preview image generation
- Material-specific settings
- MVP Testing: Prusament PLA on MK4S with ironing
- CLI argument handling for scripts

### MVP Testing

Currently focusing on testing the following configuration:
- Printer: Original Prusa MK4S
- Material: Prusament PLA
- Feature: Ironing for the top surface

To test the MVP configuration:

```bash
# Generate 3MF and GCODE for Prusament PLA
python3 scripts/generate_3mf.py \
    --material "PLA" \
    --brand "Prusament" \
    --color "Galaxy Black" \
    --printer "Original Prusa MK4S"
```

### Todo 📝
- Add test cases for model generation
- Implement error reporting in GitHub Actions
- Add support for custom material profiles
- Improve error messages and validation

## Contributing

1. Update material definitions in the CSV files
2. Test locally using OpenSCAD and PrusaSlicer
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