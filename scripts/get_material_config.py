#!/usr/bin/env python3

import sys
import json
import configparser
from pathlib import Path
import re

SUPPORTED_PRINTERS = {
    'MK3S': '@MK3.5',  # MK3S uses MK3.5 profiles
    'MK4IS': '@MK4S',  # MK4IS uses MK4S profiles
    'MK4S': '@MK4S',
    'MINIIS': '@MINIIS',
    'COREONE': '@COREONE',
    'XLIS': '@XLIS'
}

def get_latest_config_file():
    """Find the latest PrusaSlicer config file version."""
    profiles_dir = Path('slicer-profiles/PrusaResearch')
    version_pattern = re.compile(r'(\d+\.\d+\.\d+)\.ini$')
    
    latest_version = None
    latest_file = None
    
    for file in profiles_dir.glob('*.ini'):
        match = version_pattern.search(file.name)
        if match:
            version = tuple(map(int, match.group(1).split('.')))
            if latest_version is None or version > latest_version:
                latest_version = version
                latest_file = file
    
    if latest_file is None:
        print("Error: No config files found", file=sys.stderr)
        return None
        
    print(f"Using PrusaSlicer config version {'.'.join(map(str, latest_version))}", file=sys.stderr)
    return latest_file

def find_matching_sections(config, profile_name, printer=None):
    """Find all sections that match the profile name and printer."""
    matches = []
    
    # Create base pattern that matches the exact profile name
    base_pattern = f'^filament:{re.escape(profile_name)}($|\\s@|\\s@0\\.)'
    
    # If printer specified, also look for printer-specific profiles
    if printer and printer in SUPPORTED_PRINTERS:
        printer_suffix = SUPPORTED_PRINTERS[printer]
        # Look for both base profile and printer-specific profile
        patterns = [
            re.compile(base_pattern),  # Base profile
            re.compile(f'^filament:{re.escape(profile_name)}\\s{re.escape(printer_suffix)}($|\\s|@)')  # Printer-specific
        ]
    else:
        patterns = [re.compile(base_pattern)]
    
    for section in config.sections():
        for pattern in patterns:
            if pattern.match(section):
                matches.append(section)
                break
    
    return matches

def get_inherited_value(config, section_name, key):
    """Get a value from a section, following inheritance."""
    # Keep track of visited sections to avoid infinite recursion
    visited = set()
    
    def _get_value(section):
        if section in visited:
            return None
        visited.add(section)
        
        # Get direct value
        value = config[section].get(key)
        if value is not None:
            return value
            
        # Check inheritance
        inherits = config[section].get('inherits')
        if inherits:
            # Split multiple inheritance (comma-separated)
            for parent in inherits.split(';'):
                parent = parent.strip()
                # Handle wildcards in parent names
                if parent.startswith('*') and parent.endswith('*'):
                    parent_pattern = f'^filament:{parent}$'
                else:
                    parent_pattern = f'^filament:{re.escape(parent)}($|\\s@)'
                
                # Find all matching parent sections
                for potential_parent in config.sections():
                    if re.match(parent_pattern, potential_parent):
                        value = _get_value(potential_parent)
                        if value is not None:
                            return value
        
        return None
    
    return _get_value(section_name)

def get_filament_config(filament_profile, printer=None):
    """Get filament configuration from PrusaSlicer official profiles."""
    try:
        # Use the latest PrusaSlicer settings file
        config_file = get_latest_config_file()
        if config_file is None:
            return None
            
        # Read the config file
        config = configparser.ConfigParser()
        config.read(config_file)
        
        # Find all matching sections
        matching_sections = find_matching_sections(config, filament_profile, printer)
        
        if not matching_sections:
            print(f"Error: No filament profiles found matching '{filament_profile}'", file=sys.stderr)
            return None
            
        if len(matching_sections) > 1:
            print(f"Found multiple matching profiles:", file=sys.stderr)
            for section in matching_sections:
                print(f"  - {section}", file=sys.stderr)
        
        # Prefer printer-specific profile if available
        if printer and printer in SUPPORTED_PRINTERS:
            printer_suffix = SUPPORTED_PRINTERS[printer]
            printer_specific = [s for s in matching_sections if printer_suffix in s]
            if printer_specific:
                section_name = min(printer_specific, key=len)
            else:
                section_name = min(matching_sections, key=len)
        else:
            section_name = min(matching_sections, key=len)
            
        print(f"Using profile: {section_name}", file=sys.stderr)
        
        # Extract temperature setting with inheritance
        temp = get_inherited_value(config, section_name, 'temperature')
        if temp is None:
            print(f"Error: No temperature setting found in profile '{section_name}' or its inherited profiles", file=sys.stderr)
            return None
            
        # Get first value if comma-separated
        temp = temp.split(',')[0].strip()
        
        # Find matching print profile for layer height
        print_profile = f"print:0.20mm QUALITY {printer_suffix}" if printer else "print:0.20mm QUALITY"
        if print_profile in config:
            layer_height = config[print_profile].get('layer_height', '0.2')
            print(f"Using layer height from profile {print_profile}: {layer_height}", file=sys.stderr)
        else:
            layer_height = '0.2'  # Default to 0.2mm if profile not found
            print(f"Print profile {print_profile} not found, using default layer height: {layer_height}", file=sys.stderr)
        
        material_config = {
            'temperature': temp,
            'layer_height': layer_height
        }
        
        print("Material configuration:", file=sys.stderr)
        for key, value in material_config.items():
            print(f"  {key} = {value}", file=sys.stderr)
            
        return material_config
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: get_material_config.py <filament_profile> [printer]", file=sys.stderr)
        print("Supported printers:", ", ".join(SUPPORTED_PRINTERS.keys()), file=sys.stderr)
        sys.exit(1)
    
    printer = sys.argv[2] if len(sys.argv) > 2 else None
    config = get_filament_config(sys.argv[1], printer)
    if config:
        print(json.dumps(config))
    else:
        sys.exit(1) 