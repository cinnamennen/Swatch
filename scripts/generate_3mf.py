#!/usr/bin/env python3

import sys
import json
import subprocess
import platform
from pathlib import Path
from get_material_config import get_filament_config, get_latest_config_file
import re
import traceback
import argparse

def find_openscad():
    """Find OpenSCAD executable with preference for nightly builds."""
    system = platform.system().lower()
    
    if system == 'windows':
        # Windows: Check both Program Files directories
        search_paths = [
            Path(r"C:\Program Files\OpenSCAD (Nightly)"),
            Path(r"C:\Program Files\OpenSCAD"),
            Path(r"C:\Program Files (x86)\OpenSCAD (Nightly)"),
            Path(r"C:\Program Files (x86)\OpenSCAD")
        ]
        executable = "openscad.exe"
        
        print("Searching for OpenSCAD in standard locations:", file=sys.stderr)
        for path in search_paths:
            full_path = path / executable
            print(f"  Checking {full_path}...", file=sys.stderr)
            if path.exists() and full_path.exists():
                return full_path
        
        # Check PATH using where command
        print("\nSearching for OpenSCAD in PATH:", file=sys.stderr)
        result = subprocess.run(["where", "openscad.exe"], capture_output=True, text=True)
        if result.returncode == 0:
            paths = result.stdout.strip().splitlines()
            print(f"  Found in PATH: {paths[0]}", file=sys.stderr)
            return Path(paths[0])
            
    elif system == 'darwin':
        # macOS: Check Applications directory
        search_paths = [
            Path("/Applications/OpenSCAD-nightly.app"),
            Path("/Applications/OpenSCAD.app")
        ]
        executable = "Contents/MacOS/OpenSCAD"
        
        print("Searching for OpenSCAD in Applications:", file=sys.stderr)
        for path in search_paths:
            full_path = path / executable
            print(f"  Checking {full_path}...", file=sys.stderr)
            if path.exists() and full_path.exists():
                return full_path
                
        # Check PATH
        print("\nSearching for OpenSCAD in PATH:", file=sys.stderr)
        result = subprocess.run(["which", "openscad"], capture_output=True, text=True)
        if result.returncode == 0:
            path = result.stdout.strip()
            print(f"  Found in PATH: {path}", file=sys.stderr)
            return Path(path)
    else:
        # Linux: Check common installation directories
        search_paths = [
            Path("/usr/local/bin"),
            Path("/usr/bin"),
            Path(Path.home() / ".local/bin")
        ]
        executables = ["openscad-nightly", "openscad"]
        
        # First check PATH
        print("Searching for OpenSCAD in PATH:", file=sys.stderr)
        for exe in executables:
            result = subprocess.run(["which", exe], capture_output=True, text=True)
            if result.returncode == 0:
                path = result.stdout.strip()
                print(f"  Found in PATH: {path}", file=sys.stderr)
                return Path(path)
        
        # Then check common paths
        print("\nSearching for OpenSCAD in standard locations:", file=sys.stderr)
        for path in search_paths:
            for exe in executables:
                full_path = path / exe
                print(f"  Checking {full_path}...", file=sys.stderr)
                if full_path.exists():
                    return full_path
    
    print("\nOpenSCAD not found in any standard location or PATH.", file=sys.stderr)
    print("Please ensure OpenSCAD is installed and accessible.", file=sys.stderr)
    print("Standard installation paths checked:", file=sys.stderr)
    for path in search_paths:
        print(f"  - {path}", file=sys.stderr)
    return None

def find_prusaslicer():
    """Find PrusaSlicer executable."""
    system = platform.system().lower()
    
    if system == 'windows':
        # Windows: Check Program Files directories
        search_paths = [
            Path(r"C:\Program Files\Prusa3D\PrusaSlicer"),
            Path(r"C:\Program Files (x86)\Prusa3D\PrusaSlicer")
        ]
        executable = "prusa-slicer.exe"
        
        print("Searching for PrusaSlicer in standard locations:", file=sys.stderr)
        for path in search_paths:
            full_path = path / executable
            print(f"  Checking {full_path}...", file=sys.stderr)
            if path.exists() and full_path.exists():
                return full_path
        
        # Check PATH using where command
        print("\nSearching for PrusaSlicer in PATH:", file=sys.stderr)
        result = subprocess.run(["where", "prusa-slicer.exe"], capture_output=True, text=True)
        if result.returncode == 0:
            paths = result.stdout.strip().splitlines()
            print(f"  Found in PATH: {paths[0]}", file=sys.stderr)
            return Path(paths[0])
            
    elif system == 'darwin':
        # macOS: Check Applications directory
        search_paths = [
            Path("/Applications/PrusaSlicer.app")
        ]
        executable = "Contents/MacOS/PrusaSlicer"
        
        print("Searching for PrusaSlicer in Applications:", file=sys.stderr)
        for path in search_paths:
            full_path = path / executable
            print(f"  Checking {full_path}...", file=sys.stderr)
            if path.exists() and full_path.exists():
                return full_path
                
        # Check PATH
        print("\nSearching for PrusaSlicer in PATH:", file=sys.stderr)
        result = subprocess.run(["which", "prusa-slicer"], capture_output=True, text=True)
        if result.returncode == 0:
            path = result.stdout.strip()
            print(f"  Found in PATH: {path}", file=sys.stderr)
            return Path(path)
    else:
        # Linux: Check common installation directories
        search_paths = [
            Path("/usr/local/bin"),
            Path("/usr/bin"),
            Path(Path.home() / ".local/bin")
        ]
        executables = ["prusa-slicer"]
        
        # First check PATH
        print("Searching for PrusaSlicer in PATH:", file=sys.stderr)
        for exe in executables:
            result = subprocess.run(["which", exe], capture_output=True, text=True)
            if result.returncode == 0:
                path = result.stdout.strip()
                print(f"  Found in PATH: {path}", file=sys.stderr)
                return Path(path)
        
        # Then check common paths
        print("\nSearching for PrusaSlicer in standard locations:", file=sys.stderr)
        for path in search_paths:
            for exe in executables:
                full_path = path / exe
                print(f"  Checking {full_path}...", file=sys.stderr)
                if full_path.exists():
                    return full_path
    
    print("\nPrusaSlicer not found in any standard location or PATH.", file=sys.stderr)
    print("Please ensure PrusaSlicer is installed and accessible.", file=sys.stderr)
    print("Standard installation paths checked:", file=sys.stderr)
    for path in search_paths:
        print(f"  - {path}", file=sys.stderr)
    return None

def generate_3mf(material, brand, color, printer_model, print_profile=None, temperature=None, layer_height=None):
    """Generate a 3MF file for the given material configuration.
    
    Args:
        material: Material type (e.g., "PLA", "PETG")
        brand: Brand name (e.g., "Prusament", "Generic")
        color: Color name (e.g., "Galaxy Black", "Natural")
        printer_model: Printer model (e.g., "MK4S", "MK3S+")
        print_profile: Print profile name (e.g., "0.20mm QUALITY MK4S")
        temperature: Optional temperature override
        layer_height: Optional layer height override
    
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Get paths to required executables
        openscad_path = find_openscad()
        prusaslicer_path = find_prusaslicer()
        
        if not openscad_path or not prusaslicer_path:
            return False
            
        # Create output directories if they don't exist
        Path("output/3mf").mkdir(parents=True, exist_ok=True)
        Path("output/gcode").mkdir(parents=True, exist_ok=True)
        
        # Get material configuration
        config = get_filament_config(material, printer_model)
        if not config:
            print(f"Error: Could not get configuration for {material} on {printer_model}", file=sys.stderr)
            return False
            
        # Override config with provided values
        if temperature:
            config['temperature'] = temperature
            
        if layer_height:
            config['layer_height'] = layer_height
            
        # Create safe filename with printer model
        safe_name = f"{brand}_{material}_{color}".replace(" ", "_")
        safe_name = re.sub(r'[^a-zA-Z0-9_-]', '', safe_name)
        
        # Create printer-specific name suffix
        printer_suffix = re.sub(r'[^a-zA-Z0-9_-]', '', printer_model)
        
        # For print profile specific output, extract quality/draft
        profile_suffix = ""
        if print_profile:
            match = re.search(r'(QUALITY|DRAFT)', print_profile)
            if match:
                profile_suffix = f"_{match.group(1).lower()}"
        
        # Generate base 3MF file
        base_3mf = Path(f"output/3mf/{safe_name}.3mf")
        
        print(f"\nGenerating base 3MF...", file=sys.stderr)
        base_cmd = [
            str(openscad_path),
            "-o", str(base_3mf),
            "--export-format", "3mf",
            "--check-parameters", "true",
            "--check-parameter-ranges", "true",
            "--hardwarnings",
            str(Path("swatch/swatch.scad").resolve()),  # Use absolute path
            "-D", f'MATERIAL="{material}"',
            "-D", f'BRAND="{brand}"',
            "-D", f'COLOR="{color}"',
            "-D", f"NOZZLE_TEMP={config.get('temperature', 215)}",
            "-D", f"LAYER_HEIGHT={config.get('layer_height', 0.2)}"
        ]
        
        print(f"Running OpenSCAD: {' '.join(base_cmd)}", file=sys.stderr)
        result = subprocess.run(base_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error generating base 3MF:", file=sys.stderr)
            print(f"Command output:", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print(f"Command error:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
            
        # Generate printer-specific 3MF with ironing enabled
        printer_3mf = Path(f"output/3mf/{safe_name}_{printer_suffix}{profile_suffix}.3mf")
        
        print(f"\nGenerating printer-specific 3MF with ironing...", file=sys.stderr)
        printer_cmd = [
            str(prusaslicer_path),
            "--export-3mf",
            "--repair",
            "--load", str(Path("slicer-profiles/PrusaResearch/2.1.11.ini")),
            "--print-settings", "ironing=1",
            "--print-settings", "ironing_type=top",
            "--print-settings", "ironing_flowrate=15",
            str(base_3mf),
            "--output", str(printer_3mf)
        ]
        
        # Add print profile if provided
        if print_profile:
            printer_cmd.extend(["--print", print_profile])
        
        print(f"Running PrusaSlicer printer-specific conversion: {' '.join(printer_cmd)}", file=sys.stderr)
        result = subprocess.run(printer_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error generating printer-specific 3MF:", file=sys.stderr)
            print(f"Command output:", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print(f"Command error:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
            
        # Clean up base 3MF
        base_3mf.unlink()
            
        # Verify the file exists
        if not printer_3mf.exists():
            print(f"Error: 3MF file not found: {printer_3mf}", file=sys.stderr)
            return False
            
        # Check file size
        file_size = printer_3mf.stat().st_size
        if file_size == 0:
            print(f"Error: 3MF file is empty: {printer_3mf}", file=sys.stderr)
            return False
            
        print(f"3MF file size: {file_size} bytes")
        print(f"Generated 3MF file: {printer_3mf}")
            
        return True
            
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
        return False

def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description='Generate 3MF swatch models')
    parser.add_argument('--material', required=True, help='Material type (e.g., "PLA", "PETG")')
    parser.add_argument('--brand', required=True, help='Brand name (e.g., "Prusament", "Generic")')
    parser.add_argument('--color', required=True, help='Color name (e.g., "Galaxy Black", "Natural")')
    parser.add_argument('--printer', required=True, help='Printer model (e.g., "MK4S", "MK3S+")')
    parser.add_argument('--profile', help='Print profile name (e.g., "0.20mm QUALITY MK4S")')
    parser.add_argument('--temperature', type=float, help='Optional temperature override')
    parser.add_argument('--layer-height', type=float, help='Optional layer height override')
    
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    
    if not generate_3mf(
        material=args.material,
        brand=args.brand,
        color=args.color,
        printer_model=args.printer,
        print_profile=args.profile,
        temperature=args.temperature,
        layer_height=args.layer_height
    ):
        sys.exit(1) 