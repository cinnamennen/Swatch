#!/usr/bin/env python3

import argparse
import json
import os
import shutil
import subprocess
import sys
import platform
from pathlib import Path
from typing import Dict, Optional
from enum import Enum, auto

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
    return None

def check_dependencies():
    """Check if required external tools are available."""
    missing = []
    
    # Check OpenSCAD
    print("\nChecking OpenSCAD installation...")
    openscad_path = find_openscad()
    if not openscad_path:
        missing.append("OpenSCAD: Required for model generation. Please install from https://openscad.org/downloads.html")
    else:
        print(f"Found OpenSCAD: {openscad_path}")
    
    # Check PrusaSlicer
    print("\nChecking PrusaSlicer installation...")
    prusaslicer_path = find_prusaslicer()
    if not prusaslicer_path:
        missing.append("PrusaSlicer: Required for model validation. Please install from https://www.prusa3d.com/prusaslicer/")
    else:
        print(f"Found PrusaSlicer: {prusaslicer_path}")
    
    if missing:
        print("\nMissing Dependencies:", file=sys.stderr)
        for msg in missing:
            print(f"  - {msg}", file=sys.stderr)
        return False
    return True

class PipelineStage(Enum):
    """Enumeration of pipeline stages for checkpointing."""
    BASE_MODEL = auto()
    MODEL_FILE = auto()
    METADATA = auto()
    BASE_3MF = auto()
    MODIFIER = auto()
    VALIDATION = auto()

class StageStatus:
    """Track status and outputs of a pipeline stage."""
    def __init__(self, stage: PipelineStage):
        self.stage = stage
        self.completed = False
        self.output_file = None
        self.timestamp = None

class SwatchPipeline:
    def __init__(self, config: Dict, work_dir: Optional[Path] = None):
        """Initialize the pipeline with configuration."""
        self.config = config
        self.work_dir = Path(work_dir) if work_dir else Path("tests/tmp")
        self.validation_dir = Path("tests/validation")
        self.fixtures_dir = Path("tests/fixtures")
        self.checkpoint_file = self.work_dir / "checkpoint.json"
        
        # Find required executables
        self.openscad_path = find_openscad()
        self.prusaslicer_path = find_prusaslicer()
        
        if not self.openscad_path:
            raise RuntimeError("OpenSCAD not found")
        if not self.prusaslicer_path:
            raise RuntimeError("PrusaSlicer not found")
            
        print(f"Using OpenSCAD: {self.openscad_path}")
        print(f"Using PrusaSlicer: {self.prusaslicer_path}")
        
        # Initialize stage tracking
        self.stages = {
            PipelineStage.BASE_MODEL: StageStatus(PipelineStage.BASE_MODEL),
            PipelineStage.MODEL_FILE: StageStatus(PipelineStage.MODEL_FILE),
            PipelineStage.METADATA: StageStatus(PipelineStage.METADATA),
            PipelineStage.BASE_3MF: StageStatus(PipelineStage.BASE_3MF),
            PipelineStage.MODIFIER: StageStatus(PipelineStage.MODIFIER),
            PipelineStage.VALIDATION: StageStatus(PipelineStage.VALIDATION)
        }
        
        # Ensure directories exist
        self.work_dir.mkdir(parents=True, exist_ok=True)
        self.validation_dir.mkdir(parents=True, exist_ok=True)
        for subdir in ["base", "modifier", "pipeline"]:
            (self.validation_dir / subdir).mkdir(exist_ok=True)
            
        # Load checkpoint if exists
        self.load_checkpoint()

    def save_checkpoint(self):
        """Save current pipeline state to checkpoint file."""
        checkpoint = {
            "config": self.config,
            "stages": {
                stage.name: {
                    "completed": status.completed,
                    "output_file": str(status.output_file) if status.output_file else None,
                    "timestamp": status.timestamp
                }
                for stage, status in self.stages.items()
            }
        }
        with open(self.checkpoint_file, 'w') as f:
            json.dump(checkpoint, f, indent=2)

    def load_checkpoint(self):
        """Load pipeline state from checkpoint file if it exists."""
        if not self.checkpoint_file.exists():
            return
            
        try:
            with open(self.checkpoint_file) as f:
                checkpoint = json.load(f)
                
            # Verify config matches
            if checkpoint["config"] != self.config:
                print("Warning: Checkpoint config differs from current config, ignoring checkpoint")
                return
                
            # Restore stage status
            for stage_name, stage_data in checkpoint["stages"].items():
                stage = PipelineStage[stage_name]
                self.stages[stage].completed = stage_data["completed"]
                self.stages[stage].output_file = Path(stage_data["output_file"]) if stage_data["output_file"] else None
                self.stages[stage].timestamp = stage_data["timestamp"]
                
            print("Restored pipeline state from checkpoint")
        except Exception as e:
            print(f"Warning: Failed to load checkpoint: {e}")

    def should_run_stage(self, stage: PipelineStage, force: bool = False) -> bool:
        """Determine if a stage should be run based on checkpoint state."""
        if force:
            return True
            
        status = self.stages[stage]
        if not status.completed:
            return True
            
        if status.output_file and not status.output_file.exists():
            return True
            
        return False

    def mark_stage_complete(self, stage: PipelineStage, output_file: Optional[Path] = None):
        """Mark a stage as complete and save checkpoint."""
        import time
        self.stages[stage].completed = True
        self.stages[stage].output_file = output_file
        self.stages[stage].timestamp = time.time()
        self.save_checkpoint()

    def generate_base_model(self, force: bool = False) -> Path:
        """Phase 1, Stage 1: Generate base 3D model using OpenSCAD."""
        stage = PipelineStage.BASE_MODEL
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return self.stages[stage].output_file
            
        print("Generating base model...")
        
        output_file = self.validation_dir / "base" / f"{self.config['material']}_{self.config['brand']}_{self.config['color']}_base.3mf"
        
        cmd = [
            str(self.openscad_path),
            "-o", str(output_file),
            "--export-format", "3mf",
            "--check-parameters", "true",
            "--check-parameter-ranges", "true",
            "--hardwarnings",
            "--enable", "manifold",
            "--enable", "lazy-union",
            "--enable", "fast-csg",
            "swatch/swatch.scad",
            "-D", f"MATERIAL=\"{self.config['material']}\"",
            "-D", f"BRAND=\"{self.config['brand']}\"",
            "-D", f"COLOR=\"{self.config['color']}\"",
            "-D", f"NOZZLE_TEMP={self.config['nozzle_temp']}"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error generating base model: {result.stderr}", file=sys.stderr)
            raise RuntimeError("Base model generation failed")
            
        if not output_file.exists():
            raise FileNotFoundError(f"Expected output file {output_file} not found")
            
        print(f"Base model generated: {output_file}")
        self.mark_stage_complete(stage, output_file)
        return output_file

    def create_model_file(self, base_model: Path, force: bool = False) -> Path:
        """Phase 1, Stage 2: Extract and validate model file structure."""
        stage = PipelineStage.MODEL_FILE
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return self.stages[stage].output_file
            
        print("Creating model file...")
        
        extract_dir = self.work_dir / "model_extract"
        extract_dir.mkdir(exist_ok=True)
        
        # Extract the 3MF
        subprocess.run(["unzip", "-o", str(base_model), "-d", str(extract_dir)], 
                     capture_output=True)
        
        model_file = extract_dir / "3D" / "3dmodel.model"
        if not model_file.exists():
            raise FileNotFoundError("Model file not found in 3MF")
            
        # Validate XML structure
        result = subprocess.run(["xmllint", "--format", str(model_file)],
                              capture_output=True, text=True)
        if result.returncode != 0:
            print(f"XML validation failed: {result.stderr}", file=sys.stderr)
            raise ValueError("Invalid XML structure")
            
        self.mark_stage_complete(stage, model_file)
        return model_file

    def generate_metadata(self, base_model: Path, force: bool = False) -> Path:
        """Phase 1, Stage 3: Generate and validate metadata."""
        stage = PipelineStage.METADATA
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return self.stages[stage].output_file
            
        print("Generating metadata...")
        
        metadata_dir = self.work_dir / "metadata"
        metadata_dir.mkdir(exist_ok=True)
        
        # Create basic metadata
        config_file = metadata_dir / "Slic3r_PE.config"
        with open(config_file, "w") as f:
            f.write(f"""# Slicer config for {self.config['material']} {self.config['brand']} {self.config['color']}
filament_type = {self.config['material']}
temperature = {self.config['nozzle_temp']}
""")
        
        self.mark_stage_complete(stage, metadata_dir)
        return metadata_dir

    def assemble_base_3mf(self, model_file: Path, metadata_dir: Path, force: bool = False) -> Path:
        """Phase 1, Stage 4: Create the base 3MF archive."""
        stage = PipelineStage.BASE_3MF
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return self.stages[stage].output_file
            
        print("Assembling base 3MF...")
        
        output_file = self.validation_dir / "base" / f"{self.config['material']}_{self.config['brand']}_{self.config['color']}_assembled.3mf"
        
        # Create new 3MF
        with subprocess.Popen(["zip", "-r", str(output_file), "."], 
                            cwd=self.work_dir) as proc:
            proc.wait()
            
        if not output_file.exists():
            raise FileNotFoundError("Failed to create 3MF archive")
            
        self.mark_stage_complete(stage, output_file)
        return output_file

    def add_modifier(self, base_3mf: Path, force: bool = False) -> Path:
        """Phase 2: Add modifier to the base model."""
        stage = PipelineStage.MODIFIER
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return self.stages[stage].output_file
            
        print("Adding modifier...")
        
        output_file = self.validation_dir / "modifier" / f"{self.config['material']}_{self.config['brand']}_{self.config['color']}_modified.3mf"
        
        cmd = [
            "python3",
            "scripts/modify_3mf.py",
            "--input", str(base_3mf),
            "--output", str(output_file),
            "--work-dir", str(self.work_dir / "modifier")
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error adding modifier: {result.stderr}", file=sys.stderr)
            raise RuntimeError("Modifier addition failed")
            
        self.mark_stage_complete(stage, output_file)
        return output_file

    def validate_final_model(self, modified_3mf: Path, force: bool = False) -> bool:
        """Validate the final model using PrusaSlicer."""
        stage = PipelineStage.VALIDATION
        
        if not self.should_run_stage(stage, force):
            print(f"Skipping {stage.name} (using checkpoint)")
            return True
            
        print("Validating final model...")
        
        # Export to 3MF to verify structure
        verify_file = self.validation_dir / "pipeline" / f"{self.config['material']}_{self.config['brand']}_{self.config['color']}_verified.3mf"
        
        cmd = [
            str(self.prusaslicer_path),
            "--export-3mf",
            "--output", str(verify_file),
            str(modified_3mf)
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        success = result.returncode == 0
        
        if success:
            self.mark_stage_complete(stage, verify_file)
            
        return success

    def cleanup(self, keep_checkpoint: bool = True):
        """Clean up temporary files."""
        if self.work_dir.exists():
            temp_checkpoint = None
            if keep_checkpoint and self.checkpoint_file.exists():
                # Move checkpoint to temp location
                temp_checkpoint = Path(str(self.checkpoint_file) + '.tmp')
                shutil.copy2(self.checkpoint_file, temp_checkpoint)
                
            # Remove work directory
            shutil.rmtree(self.work_dir)
            
            if keep_checkpoint and temp_checkpoint:
                # Restore checkpoint
                self.work_dir.mkdir(parents=True, exist_ok=True)
                shutil.move(temp_checkpoint, self.checkpoint_file)

def main():
    parser = argparse.ArgumentParser(description='Swatch generation pipeline')
    parser.add_argument('--config', '-c', required=True, help='Configuration file')
    parser.add_argument('--work-dir', '-w', help='Working directory')
    parser.add_argument('--keep-temp', action='store_true', help='Keep temporary files')
    parser.add_argument('--force', '-f', action='store_true', help='Force all stages to run')
    parser.add_argument('--from-stage', choices=[s.name for s in PipelineStage], 
                      help='Start from specific stage')
    parser.add_argument('--skip-dependency-check', action='store_true',
                      help='Skip checking for external dependencies')
    args = parser.parse_args()

    if not args.skip_dependency_check and not check_dependencies():
        print("Missing required dependencies. Please install them and try again.", file=sys.stderr)
        return 1

    try:
        with open(args.config) as f:
            config = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading config: {e}", file=sys.stderr)
        return 1

    pipeline = SwatchPipeline(config, args.work_dir)

    try:
        # Determine which stages to run
        start_stage = PipelineStage[args.from_stage] if args.from_stage else PipelineStage.BASE_MODEL
        force_remaining = False
        
        # Phase 1: Base Model Generation
        if force_remaining or start_stage == PipelineStage.BASE_MODEL:
            base_model = pipeline.generate_base_model(args.force)
            force_remaining = True
        else:
            base_model = pipeline.stages[PipelineStage.BASE_MODEL].output_file
            
        if force_remaining or start_stage == PipelineStage.MODEL_FILE:
            model_file = pipeline.create_model_file(base_model, args.force)
            force_remaining = True
        else:
            model_file = pipeline.stages[PipelineStage.MODEL_FILE].output_file
            
        if force_remaining or start_stage == PipelineStage.METADATA:
            metadata_dir = pipeline.generate_metadata(base_model, args.force)
            force_remaining = True
        else:
            metadata_dir = pipeline.stages[PipelineStage.METADATA].output_file
            
        if force_remaining or start_stage == PipelineStage.BASE_3MF:
            base_3mf = pipeline.assemble_base_3mf(model_file, metadata_dir, args.force)
            force_remaining = True
        else:
            base_3mf = pipeline.stages[PipelineStage.BASE_3MF].output_file

        # Phase 2: Modifier Addition
        if force_remaining or start_stage == PipelineStage.MODIFIER:
            modified_3mf = pipeline.add_modifier(base_3mf, args.force)
            force_remaining = True
        else:
            modified_3mf = pipeline.stages[PipelineStage.MODIFIER].output_file

        # Validation
        if force_remaining or start_stage == PipelineStage.VALIDATION:
            if pipeline.validate_final_model(modified_3mf, args.force):
                print("Pipeline completed successfully!")
                return 0
            else:
                print("Validation failed!", file=sys.stderr)
                return 1
        else:
            print("Pipeline completed successfully (using checkpoints)!")
            return 0

    except Exception as e:
        print(f"Pipeline failed: {e}", file=sys.stderr)
        return 1

    finally:
        if not args.keep_temp:
            pipeline.cleanup(keep_checkpoint=True)

if __name__ == '__main__':
    sys.exit(main()) 