#!/usr/bin/env python3

import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
import tempfile
import shutil
import uuid

def add_ironing_settings(settings_elem):
    """Add optimal ironing settings for the swatch top surface."""
    ironing_settings = {
        'ironing': '1',
        'ironing_type': 'top',
        'ironing_speed': '120',
        'ironing_flowrate': '15',
        'ironing_spacing': '0.1',
    }
    
    for key, value in ironing_settings.items():
        setting = ET.SubElement(settings_elem, '{http://schemas.prusa3d.com/model/2021/08}setting')
        setting.set('key', key)
        setting.set('value', value)

def add_ironing_modifier(model_path):
    """Add an ironing modifier to the top surface of a 3MF file."""
    temp_dir = Path(tempfile.mkdtemp())
    
    try:
        # Extract 3MF contents
        with zipfile.ZipFile(model_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        
        # Parse model file
        model_file = temp_dir / '3D' / 'model.model'
        tree = ET.parse(model_file)
        root = tree.getroot()
        
        # Add required namespaces
        ns = {
            'p': 'http://schemas.prusa3d.com/model/2021/08',
            'm': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'
        }
        for prefix, uri in ns.items():
            ET.register_namespace(prefix, uri)
        
        # Find or create resources element
        resources = root.find(f'{{{ns["m"]}}}resources')
        if resources is None:
            resources = ET.SubElement(root, f'{{{ns["m"]}}}resources')
        
        # Create modifier mesh for top surface
        modifier_id = str(uuid.uuid4())
        metadata = ET.SubElement(resources, f'{{{ns["p"]}}}metadata')
        metadata.set('id', modifier_id)
        metadata.set('type', 'modifier')
        
        # Add volume metadata
        volume = ET.SubElement(metadata, f'{{{ns["p"]}}}volume')
        volume.set('type', 'box')
        # Set box to cover just the top surface area
        # Assuming the swatch is oriented with Z as up
        volume.set('min_x', '-50')  # Adjust these values based on your swatch dimensions
        volume.set('min_y', '-50')
        volume.set('min_z', '2.8')  # Slightly below top surface
        volume.set('max_x', '50')
        volume.set('max_y', '50')
        volume.set('max_z', '3.2')  # Slightly above top surface
        
        # Add settings configuration
        settings = ET.SubElement(metadata, f'{{{ns["p"]}}}config')
        add_ironing_settings(settings)
        
        # Save modified file
        tree.write(model_file, xml_declaration=True, encoding='UTF-8')
        
        # Create new 3MF with modifications
        with zipfile.ZipFile(model_path, 'w') as zip_ref:
            for file_path in temp_dir.rglob('*'):
                if file_path.is_file():
                    arc_name = file_path.relative_to(temp_dir)
                    zip_ref.write(file_path, arc_name)
        
        print(f"Successfully added ironing modifier to {model_path}")
        return True
    except Exception as e:
        print(f"Error modifying 3MF: {e}", file=sys.stderr)
        return False
    finally:
        # Clean up temp directory
        shutil.rmtree(temp_dir)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: modify_3mf.py <3mf_file>", file=sys.stderr)
        sys.exit(1)
    
    if not add_ironing_modifier(sys.argv[1]):
        sys.exit(1) 