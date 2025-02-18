#!/usr/bin/env python3

import sys
import json
import subprocess
import platform
from pathlib import Path
from get_material_config import get_filament_config
from modify_3mf import add_ironing_modifier

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

def generate_3mf(material, brand, color, printer_model):
    """Generate a 3MF file for the given material configuration with ironing modifiers."""
    try:
        # Find OpenSCAD executable
        print("Looking for OpenSCAD installation...", file=sys.stderr)
        openscad_path = find_openscad()
        if not openscad_path:
            print("\nError: OpenSCAD not found. Please:", file=sys.stderr)
            print("1. Install OpenSCAD from https://openscad.org/downloads.html", file=sys.stderr)
            print("2. Make sure it's installed in a standard location or added to PATH", file=sys.stderr)
            print("3. For best results, use the latest nightly build", file=sys.stderr)
            return False
        
        print(f"\nUsing OpenSCAD: {openscad_path}")
        
        # Get material configuration
        config = get_filament_config(material, printer_model)
        if not config:
            print(f"Error: Could not get material config for {material} on {printer_model}", file=sys.stderr)
            return False

        # Generate base filename
        base_name = f"{brand}_{material}_{color}".replace(" ", "_")
        output_dir = Path("output/3mf")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Base 3MF file path
        base_3mf = output_dir / f"{base_name}.3mf"
        
        # Generate OpenSCAD model
        cmd = [
            str(openscad_path),
            "-o", str(base_3mf),
            str(Path("swatch/swatch.scad").resolve()),  # Use absolute path
            "-D", f'MATERIAL="{material}"',  # Escape quotes for OpenSCAD
            "-D", f'BRAND="{brand}"',
            "-D", f'COLOR="{color}"',
            "-D", f"NOZZLE_TEMP={config.get('temperature', 215)}",
            "-D", f"LAYER_HEIGHT={config.get('layer_height', 0.2)}"
        ]
        
        print(f"Running OpenSCAD command: {' '.join(cmd)}", file=sys.stderr)
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error generating OpenSCAD model:", file=sys.stderr)
            print(f"Command output:", file=sys.stderr)
            print(result.stdout, file=sys.stderr)
            print(f"Command error:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
            
        # Check if the file was created
        if not base_3mf.exists():
            print(f"Error: OpenSCAD did not generate the output file: {base_3mf}", file=sys.stderr)
            return False
            
        # Add ironing modifier
        print(f"Adding ironing modifier...")
        if not add_ironing_modifier(base_3mf):
            print("Error adding ironing modifier", file=sys.stderr)
            return False
            
        # Generate printer-specific 3MF
        printer_3mf = output_dir / f"{base_name}_{printer_model}.3mf"
        if base_3mf.exists():
            base_3mf.rename(printer_3mf)
            
        print(f"Successfully generated 3MF: {printer_3mf}")
        return True
        
    except Exception as e:
        print(f"Error generating 3MF: {e}", file=sys.stderr)
        return False

if __name__ == '__main__':
    if len(sys.argv) != 5:
        print("Usage: generate_3mf.py <material> <brand> <color> <printer_model>", file=sys.stderr)
        print("Example: generate_3mf.py 'Prusament PLA' Prusament 'Galaxy Black' MK4S", file=sys.stderr)
        sys.exit(1)
    
    material = sys.argv[1]
    brand = sys.argv[2]
    color = sys.argv[3]
    printer_model = sys.argv[4]
    
    if not generate_3mf(material, brand, color, printer_model):
        sys.exit(1) 