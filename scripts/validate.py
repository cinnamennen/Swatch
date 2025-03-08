#!/usr/bin/env python3

import argparse
import json
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, List, Optional

def validate_base_model(model_path: Path) -> List[str]:
    """Validate a base 3MF model file."""
    errors = []
    
    # Check file exists and has correct extension
    if not model_path.exists():
        errors.append(f"File not found: {model_path}")
        return errors
    if model_path.suffix != '.3mf':
        errors.append(f"Invalid file extension: {model_path.suffix}")
        return errors
    
    # Check file size is reasonable (not empty, not too large)
    size = model_path.stat().st_size
    if size == 0:
        errors.append("File is empty")
    if size > 10 * 1024 * 1024:  # 10MB
        errors.append("File is too large (>10MB)")
    
    # Try to extract and validate contents
    import zipfile
    try:
        with zipfile.ZipFile(model_path) as zf:
            # Check required files exist
            required_files = ['3D/3dmodel.model', 'Metadata/Slic3r_PE.config']
            for file in required_files:
                if file not in zf.namelist():
                    errors.append(f"Missing required file: {file}")
            
            # Validate model file structure
            if '3D/3dmodel.model' in zf.namelist():
                with zf.open('3D/3dmodel.model') as f:
                    try:
                        tree = ET.parse(f)
                        root = tree.getroot()
                        
                        # Check for required elements
                        if root.find('.//*{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}resources') is None:
                            errors.append("Missing resources element")
                        if root.find('.//*{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}build') is None:
                            errors.append("Missing build element")
                            
                    except ET.ParseError as e:
                        errors.append(f"Invalid XML structure: {e}")
                        
    except zipfile.BadZipFile:
        errors.append("Not a valid ZIP/3MF file")
    
    return errors

def validate_model_file(model_file: Path) -> List[str]:
    """Validate an extracted model file."""
    errors = []
    
    if not model_file.exists():
        errors.append(f"File not found: {model_file}")
        return errors
    
    try:
        tree = ET.parse(model_file)
        root = tree.getroot()
        
        # Check namespace declarations
        ns = {
            'core': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02',
            'slic3r': 'http://schemas.slic3r.org/3mf/2017/06'
        }
        
        # Validate structure
        resources = root.find('.//core:resources', ns)
        if resources is None:
            errors.append("Missing resources element")
        else:
            # Check for at least one object
            objects = resources.findall('.//core:object', ns)
            if not objects:
                errors.append("No objects found in model")
            
            # Validate each object
            for obj in objects:
                if 'id' not in obj.attrib:
                    errors.append("Object missing required id attribute")
                if 'type' not in obj.attrib:
                    errors.append("Object missing required type attribute")
        
        # Check build section
        build = root.find('.//core:build', ns)
        if build is None:
            errors.append("Missing build element")
        else:
            # Check for at least one item
            items = build.findall('.//core:item', ns)
            if not items:
                errors.append("No items found in build")
            
    except ET.ParseError as e:
        errors.append(f"Invalid XML structure: {e}")
    
    return errors

def validate_metadata(metadata_dir: Path) -> List[str]:
    """Validate metadata files."""
    errors = []
    
    if not metadata_dir.exists():
        errors.append(f"Directory not found: {metadata_dir}")
        return errors
    
    # Check for required files
    config_file = metadata_dir / "Slic3r_PE.config"
    if not config_file.exists():
        errors.append("Missing Slic3r_PE.config")
    else:
        # Validate config file contents
        with open(config_file) as f:
            config = f.read()
            
            # Check for required settings
            required_settings = ['filament_type', 'temperature']
            for setting in required_settings:
                if setting not in config:
                    errors.append(f"Missing required setting: {setting}")
    
    return errors

def validate_modifier(model_path: Path) -> List[str]:
    """Validate a model with modifier."""
    errors = []
    
    if not model_path.exists():
        errors.append(f"File not found: {model_path}")
        return errors
    
    # First run base model validation
    errors.extend(validate_base_model(model_path))
    if errors:
        return errors
    
    # Check for modifier-specific elements
    import zipfile
    with zipfile.ZipFile(model_path) as zf:
        with zf.open('3D/3dmodel.model') as f:
            tree = ET.parse(f)
            root = tree.getroot()
            
            # Check for modifier object
            ns = {
                'core': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02',
                'slic3r': 'http://schemas.slic3r.org/3mf/2017/06'
            }
            
            modifiers = root.findall('.//core:object[@slic3r:modifier="1"]', ns)
            if not modifiers:
                errors.append("No modifier objects found")
            
            # Check modifier mesh
            for modifier in modifiers:
                mesh = modifier.find('.//core:mesh', ns)
                if mesh is None:
                    errors.append("Modifier missing mesh element")
                else:
                    vertices = mesh.find('.//core:vertices', ns)
                    triangles = mesh.find('.//core:triangles', ns)
                    
                    if vertices is None or len(vertices) == 0:
                        errors.append("Modifier mesh has no vertices")
                    if triangles is None or len(triangles) == 0:
                        errors.append("Modifier mesh has no triangles")
    
    return errors

def validate_stage(stage: str, path: Path) -> bool:
    """Validate a specific pipeline stage."""
    validators = {
        'base': validate_base_model,
        'model': validate_model_file,
        'metadata': validate_metadata,
        'modifier': validate_modifier
    }
    
    if stage not in validators:
        print(f"Unknown stage: {stage}")
        return False
    
    errors = validators[stage](path)
    if errors:
        print(f"\nValidation errors for {stage}:")
        for error in errors:
            print(f"  - {error}")
        return False
    
    print(f"\nValidation successful for {stage}")
    return True

def main():
    parser = argparse.ArgumentParser(description='Validate pipeline stages')
    parser.add_argument('stage', choices=['base', 'model', 'metadata', 'modifier'],
                      help='Pipeline stage to validate')
    parser.add_argument('path', type=Path,
                      help='Path to file or directory to validate')
    args = parser.parse_args()
    
    success = validate_stage(args.stage, args.path)
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main()) 