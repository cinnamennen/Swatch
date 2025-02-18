#!/usr/bin/env python3

import unittest
import json
import sys
from pathlib import Path
import configparser
import re
from get_material_config import get_latest_config_file, get_filament_config

class TestProfiles(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Load configuration and PrusaSlicer config file once for all tests."""
        config_path = Path('config/print_profiles.json')
        cls.assertTrue(config_path.exists(), f"Config file not found at {config_path}")
        
        with open(config_path) as f:
            cls.config = json.load(f)
        
        cls.config_file = get_latest_config_file()
        cls.assertTrue(cls.config_file is not None, "No PrusaSlicer config file found")
        
        print(f"\nUsing PrusaSlicer config: {cls.config_file}")
    
    def find_print_profile(self, profile_name):
        """Check if a print profile exists in the PrusaSlicer config."""
        config = configparser.ConfigParser()
        config.read(self.config_file)
        
        pattern = f'^print:{re.escape(profile_name)}($|\\s@)'
        return any(re.match(pattern, section) for section in config.sections())
    
    def test_print_profiles(self):
        """Test that all configured print profiles exist."""
        for printer, settings in self.config['printer_profiles'].items():
            with self.subTest(printer=printer):
                self.assertTrue(
                    self.find_print_profile(settings['print_profile']),
                    f"Print profile '{settings['print_profile']}' not found for {printer}"
                )
    
    def test_material_profiles(self):
        """Test that all material profiles exist and have temperature settings."""
        # Test default profiles
        for material, base_profile in self.config['material_profiles']['defaults'].items():
            for printer, settings in self.config['printer_profiles'].items():
                # Skip Generic ABS for MK3S printer
                if material == 'ABS' and printer == 'MK3S':
                    continue
                    
                # Try each suffix in order until one works
                found_valid_profile = False
                for suffix in settings['profile_suffixes']:
                    profile_name = f"{base_profile} {suffix}".strip()
                    material_config = get_filament_config(profile_name, printer)
                    if material_config is not None:
                        found_valid_profile = True
                        with self.subTest(material=material, printer=printer, profile=profile_name):
                            self.assertIn(
                                'temperature',
                                material_config,
                                f"No temperature setting found for default {material} on {printer}"
                            )
                            temp = float(material_config['temperature'])
                            self.assertGreater(
                                temp, 150,
                                f"Temperature too low ({temp}°C) for default {material} on {printer}"
                            )
                            self.assertLess(
                                temp, 300,
                                f"Temperature too high ({temp}°C) for default {material} on {printer}"
                            )
                        break
                
                self.assertTrue(
                    found_valid_profile,
                    f"No valid profile found for {material} on {printer} with any suffix"
                )
        
        # Test brand overrides
        for brand, materials in self.config['material_profiles']['brand_overrides'].items():
            for material, base_profile in materials.items():
                for printer, settings in self.config['printer_profiles'].items():
                    # Try each suffix in order until one works
                    found_valid_profile = False
                    for suffix in settings['profile_suffixes']:
                        profile_name = f"{base_profile} {suffix}".strip()
                        material_config = get_filament_config(profile_name, printer)
                        if material_config is not None:
                            found_valid_profile = True
                            with self.subTest(brand=brand, material=material, printer=printer, profile=profile_name):
                                self.assertIn(
                                    'temperature',
                                    material_config,
                                    f"No temperature setting found for {brand} {material} on {printer}"
                                )
                                temp = float(material_config['temperature'])
                                self.assertGreater(
                                    temp, 150,
                                    f"Temperature too low ({temp}°C) for {brand} {material} on {printer}"
                                )
                                self.assertLess(
                                    temp, 300,
                                    f"Temperature too high ({temp}°C) for {brand} {material} on {printer}"
                                )
                            break
                    
                    self.assertTrue(
                        found_valid_profile,
                        f"No valid profile found for {brand} {material} on {printer} with any suffix"
                    )

def print_test_header(test_name):
    """Print a formatted header for test output."""
    print(f"\n{test_name}")
    print("=" * len(test_name))

if __name__ == '__main__':
    # Use TextTestRunner with verbosity=2 for detailed output
    runner = unittest.TextTestRunner(verbosity=2)
    # Create a test suite with our test cases
    suite = unittest.TestLoader().loadTestsFromTestCase(TestProfiles)
    # Run the tests
    result = runner.run(suite)
    # Exit with appropriate status code
    sys.exit(not result.wasSuccessful()) 