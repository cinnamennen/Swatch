#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import List, Dict

def find_configs() -> List[Path]:
    """Find all test configurations."""
    config_dir = Path("tests/fixtures/configs")
    return list(config_dir.glob("*.json"))

def run_pipeline(config_file: Path, work_dir: Path) -> bool:
    """Run the pipeline with a specific configuration."""
    print(f"\nTesting pipeline with {config_file.stem}...")
    
    # Read config to get material info for output
    with open(config_file) as f:
        config = json.load(f)
    
    # Create stage-specific work directories
    stage_dirs = {
        "base": work_dir / config_file.stem / "base",
        "modifier": work_dir / config_file.stem / "modifier",
        "validation": work_dir / config_file.stem / "validation"
    }
    for dir in stage_dirs.values():
        dir.mkdir(parents=True, exist_ok=True)
    
    # Run pipeline stages
    try:
        # Generate base model
        print("\nGenerating base model...")
        result = subprocess.run([
            "python3", "scripts/pipeline.py",
            "--config", str(config_file),
            "--work-dir", str(stage_dirs["base"])
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Base model generation failed:")
            print(result.stderr)
            return False
            
        # Validate base model
        base_model = next(stage_dirs["base"].glob("*.3mf"))
        result = subprocess.run([
            "python3", "scripts/validate.py",
            "base", str(base_model)
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Base model validation failed:")
            print(result.stdout)
            return False
            
        # Add modifier
        print("\nAdding modifier...")
        result = subprocess.run([
            "python3", "scripts/pipeline.py",
            "--config", str(config_file),
            "--work-dir", str(stage_dirs["modifier"]),
            "--from-stage", "MODIFIER"
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Modifier addition failed:")
            print(result.stderr)
            return False
            
        # Validate modified model
        modified_model = next(stage_dirs["modifier"].glob("*_modified.3mf"))
        result = subprocess.run([
            "python3", "scripts/validate.py",
            "modifier", str(modified_model)
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("Modified model validation failed:")
            print(result.stdout)
            return False
            
        # Final validation with PrusaSlicer
        print("\nValidating with PrusaSlicer...")
        result = subprocess.run([
            "python3", "scripts/pipeline.py",
            "--config", str(config_file),
            "--work-dir", str(stage_dirs["validation"]),
            "--from-stage", "VALIDATION"
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("PrusaSlicer validation failed:")
            print(result.stderr)
            return False
            
        print(f"\n✅ Pipeline successful for {config_file.stem}")
        return True
        
    except Exception as e:
        print(f"Pipeline failed: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Test pipeline with all configurations')
    parser.add_argument('--work-dir', type=Path, default=Path("tests/tmp"),
                      help='Working directory for test files')
    parser.add_argument('--keep-temp', action='store_true',
                      help='Keep temporary files')
    args = parser.parse_args()
    
    # Find all test configurations
    configs = find_configs()
    if not configs:
        print("No test configurations found in tests/fixtures/configs/")
        return 1
        
    print(f"Found {len(configs)} test configurations")
    
    # Create work directory
    args.work_dir.mkdir(parents=True, exist_ok=True)
    
    # Run tests
    results = {}
    for config in configs:
        results[config.stem] = run_pipeline(config, args.work_dir)
        
    # Print summary
    print("\nTest Summary:")
    print("-" * 40)
    success = True
    for config, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{config:25} {status}")
        success = success and result
        
    # Cleanup
    if not args.keep_temp and args.work_dir.exists():
        import shutil
        shutil.rmtree(args.work_dir)
        
    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main()) 