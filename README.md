# Pod 2: Coordinated Configuration - Complete Standalone Repository

## Overview
This is a **complete standalone repository** for running Experiment 5 - Pod 2 (Coordinated Configuration).

**Configuration**: Layers **share information** and **adapt behavior** through coordination.

## What's Included

```
exp5_pod2_coordinated/
├── run_pod2.sh                    ← Main execution script (RUN THIS!)
├── run_experiment5_coordination.py ← Experiment runner
├── validate_experiment5.py         ← Code validator
├── requirements.txt                ← Python dependencies
├── README.md                       ← This file
├── src/                           ← Source code
│   ├── config.py
│   ├── database.py
│   ├── experiment_runner.py
│   ├── pipeline.py                (coordination_enabled=True for this pod)
│   ├── statistical_analysis.py
│   ├── models/                    ← Data models
│   │   ├── __init__.py
│   │   ├── execution_trace.py     (with coordination fields)
│   │   ├── layer_result.py
│   │   └── request.py
│   └── layers/                    ← Defense layers
│       ├── __init__.py
│       ├── layer1_boundary.py
│       ├── layer2_semantic.py
│       ├── layer3_context.py      (with trust validation & adaptive mode)
│       ├── layer4_llm.py
│       └── layer5_output.py
├── data/                          ← Attack prompts
│   └── attack_prompts.py          (52 attacks)
└── results/                       ← Output directory
    └── (exp5_coordinated.db will be created here)
```

## Quick Start (3 Commands)

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Validate Setup
```bash
python3 validate_experiment5.py
# Should show: 5/5 checks passed
```

### 3. Run Experiment
```bash
bash run_pod2.sh
```

**That's it!** The script will:
- Install dependencies
- Validate code structure (including coordination logic)
- Run 260 experiments (52 attacks × 5 trials)
- Save results to `results/exp5_coordinated.db`
- Generate summary JSON with coordination stats

## Configuration Details

| Setting | Value |
|---------|-------|
| Config name | `coordinated` |
| Coordination | **ENABLED** (True) |
| Layers enabled | All 5 layers |
| Isolation mode | `good` → `strict` (adaptive) |
| Expected traces | 260 |
| Runtime | ~45 minutes |
| Cost | ~$0.66 |

## What Gets Tested

**Coordinated Defense** (With Inter-Layer Communication):

1. **Layer 1 → Layer 2**: Passes risk scores
2. **Layer 2 → Layer 3**: Signals risk escalation
   - If risk > 0.5: Layer 3 escalates mode from "good" → "strict"
3. **Layer 3 → Layer 4**: Alerts trust violations
   - If violations detected: Layer 4 enables enhanced monitoring
4. **Layer 4 → Layer 5**: Triggers stricter validation
   - If upstream risk: Layer 5 lowers threshold (0.7 → 0.5)

**Coordination context shared** between all layers = adaptive defense.

## Output Files

After completion, you'll have:

### 1. `results/exp5_coordinated.db`
SQLite database with 260 execution traces, including:
- `propagation_path` - Layer-by-layer decisions WITH adaptive adjustments
- `trust_boundary_violations` - Privilege escalation, context contamination, etc.
- `coordination_enabled` - True for all traces
- `coordination_context` - **POPULATED** with:
  - `upstream_risk_score`
  - `detected_attack_types`
  - `risk_escalation` (boolean)
  - `adaptive_adjustments` (list of changes made)

### 2. `results/exp5_coordinated_summary.json`
```json
{
  "experiment": "exp5_coordination",
  "config": "coordinated",
  "coordination_enabled": true,
  "total_traces": 260,
  "successful_attacks": <number>,
  "blocked_attacks": <number>,
  "attack_success_rate": <percentage>,
  "elapsed_time_seconds": <time>
}
```

## Key Differences from Pod 1 (Isolated)

| Feature | Pod 1 (Isolated) | Pod 2 (Coordinated) |
|---------|------------------|---------------------|
| Coordination | ❌ OFF | ✅ ON |
| Layer 3 mode | Static ("good") | Adaptive ("good"→"strict") |
| Layer 4 monitoring | Standard | Enhanced (when triggered) |
| Layer 5 threshold | Default (0.7) | Adaptive (0.5 when risk) |
| coordination_context | Empty | Populated |
| adaptive_adjustments | None | Tracked |

## Expected Hypothesis

If coordination helps:
- **Lower ASR** than Pod 1 (isolated)
- **More traces blocked** at earlier layers
- **Adaptive adjustments** visible in logs
- **Statistical significance** (p < 0.001)

## Download These Files

After experiment completes, download:
1. **results/exp5_coordinated.db** (2-5 MB)
2. **results/exp5_coordinated_summary.json** (< 1 KB)

Compare with Pod 1 (isolated) to validate RQ3: Does coordination improve defense?

## Troubleshooting

### Validation Fails
```bash
python3 validate_experiment5.py
# Should specifically check for coordination logic
```

### Coordination Context Empty
- Check that `--config coordinated` is used
- Verify pipeline.py has coordination_enabled parameter
- Check logs for "Coordination enabled" messages

### Missing Dependencies
```bash
pip install pydantic openai anthropic python-dotenv
```

### Slow Execution
- Check GPU: `nvidia-smi`
- Reduce trials: edit `run_pod2.sh` and change `--trials 5` to `--trials 3`

## Manual Execution

If you prefer not to use the script:

```bash
python3 run_experiment5_coordination.py \
    --config coordinated \
    --output results/exp5_coordinated.db \
    --trials 5
```

## System Requirements

- Python 3.8+
- 8GB+ RAM recommended
- GPU optional (speeds up LLM calls)
- 5GB disk space
- Internet connection (for LLM API calls)

## Environment Variables

Required:
- `OPENAI_API_KEY` - For GPT-4 API access

Or alternatively:
- `ANTHROPIC_API_KEY` - For Claude API access

Set in your shell or create `.env` file:
```bash
export OPENAI_API_KEY="your-key-here"
```

## Expected Runtime Breakdown

- Setup & validation: ~2 minutes
- Experiment execution: ~43 minutes
  - Per attack: ~50 seconds
  - Per trial: ~10 seconds
  - Coordination overhead: negligible (<1%)
- Total: ~45 minutes

## Coordination Features to Verify

After completion, check that:
- [x] `coordination_enabled=True` in all traces
- [x] `coordination_context` is populated
- [x] `adaptive_adjustments` list has entries
- [x] Some traces show mode escalation ("good"→"strict")
- [x] Risk escalation events are tracked
- [x] Trust violations trigger enhanced monitoring

## Next Steps

1. **Run this pod** (Pod 2: coordinated)
2. **Compare with Pod 1** (isolated) results
3. **Statistical analysis**:
   - McNemar's test (paired ASR comparison)
   - Cohen's h (effect size)
   - Propagation pattern analysis
4. **Validate RQ3**: Coordination effectiveness empirically proven!

---

**Repository**: Standalone (all code included)  
**Status**: Ready to run  
**Support**: Check parent README or EXPERIMENT5_DEPLOYMENT.md  
**Key Feature**: True inter-layer coordination with adaptive behavior
