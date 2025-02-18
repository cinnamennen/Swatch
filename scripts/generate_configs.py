#!/usr/bin/env python3

import csv
import os
import sys
from pathlib import Path

# Base config templates for different profile types
PROFILE_TEMPLATES = {
    'QUALITY': {
        'layer_height': lambda h: h,  # Use CSV value
        'perimeters': '3',
        'top_solid_layers': '5',
        'bottom_solid_layers': '4',
        'fill_density': '20%',
        'fill_pattern': 'grid',
        'external_perimeter_speed': '40',
        'infill_speed': '80',
        'max_print_speed': '100',
        'small_perimeter_speed': '25',
    },
    'SPEED': {
        'layer_height': lambda h: h,  # Use CSV value
        'perimeters': '2',
        'top_solid_layers': '4',
        'bottom_solid_layers': '3',
        'fill_density': '15%',
        'fill_pattern': 'grid',
        'external_perimeter_speed': '60',
        'infill_speed': '120',
        'max_print_speed': '200',
        'small_perimeter_speed': '35',
    },
    'DRAFT': {
        'layer_height': lambda h: h,  # Use CSV value
        'perimeters': '2',
        'top_solid_layers': '3',
        'bottom_solid_layers': '3',
        'fill_density': '10%',
        'fill_pattern': 'grid',
        'external_perimeter_speed': '80',
        'infill_speed': '150',
        'max_print_speed': '200',
        'small_perimeter_speed': '45',
    }
}

# Material-specific settings
MATERIAL_TEMPLATES = {
    'PLA': {
        'first_layer_temperature': lambda t: str(int(t) + 5),
        'temperature': lambda t: t,
        'first_layer_bed_temperature': lambda t: t,
        'bed_temperature': lambda t: str(int(t) - 5),
        'fan_always_on': '1',
        'fan_below_layer_time': '60',
        'min_fan_speed': '100',
        'max_fan_speed': '100',
        'bridge_fan_speed': '100',
        'disable_fan_first_layers': '1',
    },
    'PETG': {
        'first_layer_temperature': lambda t: str(int(t) + 5),
        'temperature': lambda t: t,
        'first_layer_bed_temperature': lambda t: t,
        'bed_temperature': lambda t: str(int(t) - 5),
        'fan_always_on': '1',
        'fan_below_layer_time': '20',
        'min_fan_speed': '30',
        'max_fan_speed': '50',
        'bridge_fan_speed': '100',
        'disable_fan_first_layers': '3',
    }
}

def generate_config(material_data):
    """Generate a PrusaSlicer config from material data."""
    profile_type = material_data['Profile'].upper()
    material_type = material_data['Material'].upper()
    
    if profile_type not in PROFILE_TEMPLATES:
        raise ValueError(f"Unknown profile type: {profile_type}")
    if material_type not in MATERIAL_TEMPLATES:
        raise ValueError(f"Unknown material type: {material_type}")
    
    config = []
    
    # Add profile settings
    for key, value in PROFILE_TEMPLATES[profile_type].items():
        if callable(value):
            config.append(f"{key} = {value(material_data['LayerHeight'])}")
        else:
            config.append(f"{key} = {value}")
    
    # Add material settings
    for key, value in MATERIAL_TEMPLATES[material_type].items():
        if callable(value):
            if 'temperature' in key.lower():
                temp_value = material_data.get('Temperature', None) or material_data.get('BedTemp', None)
                if temp_value:
                    config.append(f"{key} = {value(temp_value)}")
            else:
                config.append(f"{key} = {value(material_data['LayerHeight'])}")
        else:
            config.append(f"{key} = {value}")
    
    return '\n'.join(config)

def process_csv(csv_path):
    """Process a CSV file and generate configs for each material."""
    output_dir = Path('configs')
    output_dir.mkdir(exist_ok=True)
    
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                config_content = generate_config(row)
                safe_name = f"{row['Brand']}_{row['Material']}_{row['Color']}".replace(' ', '_')
                config_path = output_dir / f"{safe_name}.ini"
                
                with open(config_path, 'w') as cf:
                    cf.write(config_content)
                print(f"Generated config for {safe_name}")
            except ValueError as e:
                print(f"Error processing {row}: {e}", file=sys.stderr)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: generate_configs.py <csv_file>", file=sys.stderr)
        sys.exit(1)
    
    process_csv(sys.argv[1]) 