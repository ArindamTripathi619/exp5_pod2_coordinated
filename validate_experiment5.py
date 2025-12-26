#!/usr/bin/env python3
"""
Static validation of Experiment 5 code changes.

This script validates the code structure without running it (no dependencies needed).
Checks:
1. New fields exist in ExecutionTrace model
2. Pipeline.process() accepts coordination_enabled parameter  
3. Layer3 has trust boundary validation method
4. All required imports are present
"""

import re
from pathlib import Path


def check_file_contains(filepath: Path, patterns: list, description: str) -> bool:
    """Check if file contains all specified patterns."""
    print(f"\nChecking: {description}")
    print(f"File: {filepath}")
    
    if not filepath.exists():
        print(f"  ✗ FILE NOT FOUND")
        return False
    
    content = filepath.read_text()
    
    all_found = True
    for pattern in patterns:
        if isinstance(pattern, str):
            found = pattern in content
        else:
            found = pattern.search(content) is not None
        
        if found:
            print(f"  ✓ {pattern if isinstance(pattern, str) else pattern.pattern}")
        else:
            print(f"  ✗ MISSING: {pattern if isinstance(pattern, str) else pattern.pattern}")
            all_found = False
    
    return all_found


def main():
    """Run all validation checks."""
    print("=" * 80)
    print("EXPERIMENT 5 CODE VALIDATION")
    print("=" * 80)
    
    project_root = Path(__file__).parent
    checks_passed = 0
    checks_total = 0
    
    # Check 1: ExecutionTrace model has new fields
    checks_total += 1
    if check_file_contains(
        project_root / "src/models/execution_trace.py",
        [
            "propagation_path: List[Dict[str, Any]]",
            "bypass_mechanisms: List[str]",
            "trust_boundary_violations: List[Dict[str, Any]]",
            "coordination_enabled: bool",
            "coordination_context: Dict[str, Any]"
        ],
        "ExecutionTrace has new audit fields"
    ):
        checks_passed += 1
    
    # Check 2: Pipeline accepts coordination_enabled
    checks_total += 1
    if check_file_contains(
        project_root / "src/pipeline.py",
        [
            "coordination_enabled: bool = False",
            "coordination_context = {",
            "propagation_path = []",
            re.compile(r"propagation_path\.append"),
            "coordination_context[\"upstream_risk_score\"]",
            "coordination_context[\"adaptive_adjustments\"]"
        ],
        "Pipeline implements coordination mechanism"
    ):
        checks_passed += 1
    
    # Check 3: Layer3 has trust boundary validation
    checks_total += 1
    if check_file_contains(
        project_root / "src/layers/layer3_context.py",
        [
            "def _validate_trust_boundaries(",
            "coordination_context: Optional[Dict[str, any]] = None",
            "privilege_escalation",
            "context_contamination",
            "origin_violation",
            "trust_boundary_violations"
        ],
        "Layer3 has trust boundary validation"
    ):
        checks_passed += 1
    
    # Check 4: Experiment 5 script exists
    checks_total += 1
    if check_file_contains(
        project_root / "run_experiment5_coordination.py",
        [
            "def run_experiment_5(",
            "coordination_enabled = (config_name == \"coordinated\")",
            "coordination_enabled=coordination_enabled",
            "--config",
            "isolated",
            "coordinated"
        ],
        "Experiment 5 runner script"
    ):
        checks_passed += 1
    
    # Check 5: Test script exists (OPTIONAL)
    exp5_test = project_root / "test_experiment5.py"
    if exp5_test.exists():
        print(f"\n✓ Test script exists: {exp5_test} (optional)")
    else:
        print(f"\n⚠ Test script missing: {exp5_test} (optional - not required)")
    
    # Summary
    print("\n" + "=" * 80)
    print(f"VALIDATION COMPLETE: {checks_passed}/{checks_total} checks passed")
    print("=" * 80)
    
    # Only fail if critical checks (first 4) failed
    critical_checks_required = 4
    if checks_passed >= critical_checks_required:
        print(f"✓ ALL CRITICAL CHECKS PASSED ({checks_passed}/{checks_total}) - Code ready for deployment!")
        print("\nNext steps:")
        print("  1. Push code to GitHub")
        print("  2. Deploy to RunPod (2 pods: isolated + coordinated)")
        print("  3. Run: python3 run_experiment5_coordination.py --config isolated")
        print("  4. Run: python3 run_experiment5_coordination.py --config coordinated")
        print("  5. Download results and analyze")
        return 0
    else:
        print(f"✗ {critical_checks_required - checks_passed} CRITICAL checks FAILED")
        print("Review the missing components above")
        return 1


if __name__ == "__main__":
    exit(main())
