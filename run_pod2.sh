#!/bin/bash
# POD 2: Coordinated Configuration (Test - With Coordination)
# This pod tests the defense system with layers SHARING INFORMATION

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     EXPERIMENT 5 - POD 2: COORDINATED (WITH COORDINATION)     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Configuration: COORDINATED"
echo "  • Coordination: ENABLED (test condition)"
echo "  • Layers share coordination_context"
echo "  • Adaptive behavior enabled:"
echo "    - Layer 2 → Layer 3: Risk escalation signals"
echo "    - Layer 3 → Layer 4: Trust violation alerts"  
echo "    - Layer 4 → Layer 5: Enhanced monitoring"
echo "  • Expected traces: 260 (52 attacks × 5 trials)"
echo "  • Runtime: ~45 minutes"
echo ""

# Install dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Installing dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
pip install -q -r requirements.txt
echo "✓ Dependencies installed"
echo ""

# Validate code
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Validating code structure..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python3 validate_experiment5.py

if [ $? -ne 0 ]; then
    echo "❌ VALIDATION FAILED! Check code structure."
    exit 1
fi
echo ""

# Run experiment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Running Experiment 5 - COORDINATED Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏱️  Start time: $(date)"
echo ""

python3 run_experiment5_coordination.py \
    --config coordinated \
    --output results/exp5_coordinated.db \
    --trials 5

EXIT_CODE=$?
echo ""
echo "⏱️  End time: $(date)"
echo ""

# Check results
if [ $EXIT_CODE -eq 0 ]; then
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  ✅ EXPERIMENT COMPLETE - POD 2                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📦 Results Location:"
    echo "  • Database: results/exp5_coordinated.db"
    echo "  • Summary:  results/exp5_coordinated_summary.json"
    echo ""
    
    # Display summary if available
    if [ -f "results/exp5_coordinated_summary.json" ]; then
        echo "📊 Experiment Summary:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat results/exp5_coordinated_summary.json
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    
    echo ""
    echo "📥 NEXT STEPS:"
    echo "  1. Download these 2 files from this pod:"
    echo "     • results/exp5_coordinated.db"
    echo "     • results/exp5_coordinated_summary.json"
    echo ""
    echo "  2. Compare with Pod 1 (isolated) results"
    echo ""
    echo "  3. Run statistical analysis on both datasets"
    echo ""
    
else
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  ❌ EXPERIMENT FAILED - POD 2                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Exit code: ${EXIT_CODE}"
    echo "Check logs above for error details"
    exit ${EXIT_CODE}
fi
