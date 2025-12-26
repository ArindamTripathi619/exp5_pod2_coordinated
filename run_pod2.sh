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

# Setup Ollama and llama3 model
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Setting up Ollama and llama3 model..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
    echo "✓ Ollama installed"
else
    echo "✓ Ollama already installed"
fi

# Start Ollama service
if ! pgrep -x "ollama" > /dev/null; then
    echo "Starting Ollama service..."
    nohup ollama serve > /tmp/ollama_pod2.log 2>&1 &
    sleep 5
    echo "✓ Ollama service started"
else
    echo "✓ Ollama service already running"
fi

# Pull llama3 model if not present
if ! ollama list | grep -q "llama3"; then
    echo "Pulling llama3 model (this may take 5-10 minutes)..."
    ollama pull llama3
    echo "✓ llama3 model downloaded"
else
    echo "✓ llama3 model already available"
fi

echo ""

# Validate code
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Validating code structure..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python3 validate_experiment5.py

if [ $? -ne 0 ]; then
    echo "❌ VALIDATION FAILED! Check code structure."
    exit 1
fi
echo ""

# Run experiment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Running Experiment 5 - COORDINATED Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏱️  Start time: $(date)"
echo ""

# Create results directory if it doesn't exist
mkdir -p results

# Determine if running in background or foreground
BACKGROUND=${BACKGROUND:-false}

if [ "$BACKGROUND" = "true" ]; then
    echo "🔄 Starting experiment in BACKGROUND mode..."
    echo "   Log file: results/experiment.log"
    echo "   PID file: results/experiment.pid"
    echo ""
    
    # Run in background with nohup
    nohup python3 run_experiment5_coordination.py \
        --config coordinated \
        --output results/exp5_coordinated.db \
        --trials 5 > results/experiment.log 2>&1 &
    
    EXPERIMENT_PID=$!
    echo $EXPERIMENT_PID > results/experiment.pid
    
    echo "✅ Experiment started in background!"
    echo "   Process ID: $EXPERIMENT_PID"
    echo ""
    echo "📋 To monitor progress:"
    echo "   tail -f results/experiment.log"
    echo ""
    echo "📊 To check status:"
    echo "   ps aux | grep $EXPERIMENT_PID"
    echo ""
    echo "📈 To watch trace count:"
    echo "   watch -n 10 'sqlite3 results/exp5_coordinated.db \"SELECT COUNT(*) FROM execution_traces\"'"
    echo ""
    echo "⏹️  To stop (if needed):"
    echo "   kill $EXPERIMENT_PID"
    echo ""
    echo "Expected completion: ~45 minutes"
    echo "You can safely disconnect - the experiment will continue running."
    echo ""
    exit 0
    
else
    echo "▶️  Running experiment in FOREGROUND mode..."
    echo "   (Set BACKGROUND=true to run in background)"
    echo ""
    
    python3 run_experiment5_coordination.py \
        --config coordinated \
        --output results/exp5_coordinated.db \
        --trials 5 2>&1 | tee results/experiment.log

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
        echo "  • Log:      results/experiment.log"
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
        echo "  1. Download these files from this pod:"
        echo "     • results/exp5_coordinated.db"
        echo "     • results/exp5_coordinated_summary.json"
        echo ""
        echo "  2. Wait for Pod 1 (isolated) to complete"
        echo ""
        echo "  3. Compare results: isolated vs coordinated"
        echo ""
        
    else
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  ❌ EXPERIMENT FAILED - POD 2                  ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Exit code: ${EXIT_CODE}"
        echo "Check results/experiment.log for error details"
        exit ${EXIT_CODE}
    fi
fi

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
