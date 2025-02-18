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
    backup_path = Path(str(model_path) + '.bak')
    
    try:
        # Make a backup of the original file
        shutil.copy2(model_path, backup_path)
        
        # Extract and log 3MF contents
        print("\nAnalyzing 3MF structure:", file=sys.stderr)
        with zipfile.ZipFile(model_path, 'r') as zip_ref:
            file_list = zip_ref.namelist()
            print("Files in 3MF archive:", file=sys.stderr)
            for f in file_list:
                print(f"  - {f}", file=sys.stderr)
            zip_ref.extractall(temp_dir)
        
        # Parse model file
        model_file = temp_dir / '3D' / '3dmodel.model'
        if not model_file.exists():
            print(f"Error: Model file not found at {model_file}", file=sys.stderr)
            return False
            
        # Read original file content to preserve XML declaration and structure
        with open(model_file, 'r', encoding='utf-8') as f:
            original_content = f.read()
            print("\nOriginal XML content:", file=sys.stderr)
            print(original_content, file=sys.stderr)
        
        # Register namespaces before parsing to preserve them
        ns = {
            '': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02',
            'p': 'http://schemas.prusa3d.com/model/2021/08',
            'm': 'http://schemas.microsoft.com/3dmanufacturing/material/2015/02'
        }
        for prefix, uri in ns.items():
            if prefix:
                ET.register_namespace(prefix, uri)
            else:
                ET.register_namespace('', uri)
        
        # Parse the XML while preserving whitespace and comments
        parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
        tree = ET.parse(model_file, parser=parser)
        root = tree.getroot()
        
        # Find or create resources element
        resources = root.find('.//{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}resources')
        if resources is None:
            print("\nNo resources element found, creating new one", file=sys.stderr)
            resources = ET.SubElement(root, '{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}resources')
        else:
            print("\nExisting resources:", file=sys.stderr)
            for child in resources:
                print(f"  - {child.tag}: {child.attrib}", file=sys.stderr)
        
        # Verify mesh exists in resources
        mesh_objects = resources.findall('.//{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}object[@type="model"]')
        if not mesh_objects:
            print("\nError: No mesh objects found in resources", file=sys.stderr)
            return False
            
        # Create modifier mesh for top surface
        modifier_id = str(uuid.uuid4())
        metadata = ET.SubElement(resources, '{http://schemas.prusa3d.com/model/2021/08}metadata')
        metadata.set('id', modifier_id)
        metadata.set('type', 'modifier')
        
        # Add volume metadata
        volume = ET.SubElement(metadata, '{http://schemas.prusa3d.com/model/2021/08}volume')
        volume.set('type', 'box')
        volume.set('min_x', '-50')
        volume.set('min_y', '-50')
        volume.set('min_z', '2.8')
        volume.set('max_x', '50')
        volume.set('max_y', '50')
        volume.set('max_z', '3.2')
        
        # Add settings configuration
        settings = ET.SubElement(metadata, '{http://schemas.prusa3d.com/model/2021/08}config')
        add_ironing_settings(settings)
        
        # Find or create build element
        build = root.find('.//{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}build')
        if build is None:
            print("\nNo build element found, creating new one", file=sys.stderr)
            build = ET.SubElement(root, '{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}build')
        else:
            print("\nExisting build structure:", file=sys.stderr)
            for child in build:
                print(f"  - {child.tag}: {child.attrib}", file=sys.stderr)
        
        # Find and modify the first item
        item = build.find('.//{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}item')
        if item is not None:
            print("\nFound build item:", file=sys.stderr)
            print(f"  Attributes: {item.attrib}", file=sys.stderr)
            
            # Verify item references valid mesh
            object_id = item.get('objectid')
            referenced_mesh = resources.find(f'.//*[@id="{object_id}"]')
            if referenced_mesh is None:
                print(f"\nError: Build item references non-existent mesh object {object_id}", file=sys.stderr)
                return False
                
            # Add modifier reference to the item
            modifier_ref = ET.SubElement(item, '{http://schemas.prusa3d.com/model/2021/08}metadata')
            modifier_ref.set('ref', modifier_id)
        else:
            print("\nError: No build item found to attach modifier to", file=sys.stderr)
            return False
        
        # Write modified XML while preserving declaration and structure
        with open(model_file, 'w', encoding='utf-8') as f:
            # Extract XML declaration from original content
            if '<?xml' in original_content:
                declaration_end = original_content.find('?>') + 2
                xml_declaration = original_content[:declaration_end]
                f.write(xml_declaration + '\n')
            else:
                f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            
            # Write the modified XML tree
            tree.write(f, encoding='unicode', xml_declaration=False)
        
        # Create new 3MF with modifications
        with zipfile.ZipFile(model_path, 'w') as new_zip:
            # Copy all files from the temp directory
            for file_path in temp_dir.rglob('*'):
                if file_path.is_file():
                    arc_name = str(file_path.relative_to(temp_dir)).replace('\\', '/')
                    new_zip.write(file_path, arc_name)
                    print(f"\nAdded to 3MF: {arc_name}", file=sys.stderr)
        
        print(f"\nSuccessfully added ironing modifier to {model_path}")
        return True
        
    except Exception as e:
        print(f"\nError modifying 3MF: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        # Restore backup on error
        if backup_path.exists():
            shutil.copy2(backup_path, model_path)
        return False
    finally:
        # Clean up temp directory and backup
        shutil.rmtree(temp_dir)
        if backup_path.exists():
            backup_path.unlink()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: modify_3mf.py <3mf_file>", file=sys.stderr)
        sys.exit(1)
    
    if not add_ironing_modifier(sys.argv[1]):
        sys.exit(1) 