#!/usr/bin/env python3
"""
Experiment 5: Coordinated vs Isolated Defense

This experiment directly tests RQ3: Does inter-layer coordination improve defense effectiveness?

Configuration:
- Config A (ISOLATED): Layers operate independently (coordination_enabled=False)
- Config B (COORDINATED): Layers share information and adapt (coordination_enabled=True)

Both configs use the FULL defense stack (all 5 layers enabled) with "good" isolation mode.
This isolates the effect of coordination from the effect of individual layers.

Expected Results:
- If coordination helps: Config B should have lower ASR than Config A
- Propagation tracking will show how attacks bypass individual layers
- Trust boundary violations will reveal privilege escalation attempts
"""

import sys
import time
import logging
from pathlib import Path
from typing import List, Dict
import json

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from src.config import Config
from src.pipeline import DefensePipeline
from src.database import Database
from src.models import RequestEnvelope, ExecutionTrace
from data.attack_prompts import ATTACK_PROMPTS

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def run_experiment_5(
    output_db: str = "results/exp5_coordination.db",
    num_trials: int = 5,
    config_name: str = "isolated"  # "isolated" or "coordinated"
):
    """
    Run Experiment 5: Coordinated vs Isolated Defense.
    
    Args:
        output_db: Path to output database
        num_trials: Number of trials per attack prompt
        config_name: Either "isolated" or "coordinated"
    """
    
    logger.info(f"=" * 80)
    logger.info(f"EXPERIMENT 5: Coordinated vs Isolated Defense")
    logger.info(f"Configuration: {config_name.upper()}")
    logger.info(f"Trials per attack: {num_trials}")
    logger.info(f"Total attacks: {len(ATTACK_PROMPTS)}")
    logger.info(f"Total traces expected: {len(ATTACK_PROMPTS) * num_trials}")
    logger.info(f"=" * 80)
    
    # Determine coordination setting
    coordination_enabled = (config_name == "coordinated")
    
    # Create results directory if it doesn't exist
    import os
    output_dir = os.path.dirname(output_db)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
        logger.info(f"Results directory ready: {output_dir}")
    
    # Initialize database
    db = Database(output_db)
    
    # Initialize defense pipeline (all layers enabled)
    config = Config.get()
    config.layers.layer1_enabled = True
    config.layers.layer2_enabled = True
    config.layers.layer3_enabled = True
    config.layers.layer4_enabled = True
    config.layers.layer5_enabled = True
    
    pipeline = DefensePipeline(config)
    
    logger.info(f"Defense configuration:")
    logger.info(f"  - All 5 layers: ENABLED")
    logger.info(f"  - Isolation mode: good (role-based separation)")
    logger.info(f"  - Coordination: {'ENABLED' if coordination_enabled else 'DISABLED'}")
    
    # Track statistics
    total_requests = 0
    successful_attacks = 0
    blocked_attacks = 0
    errors = 0
    
    start_time = time.time()
    
    # Process each attack prompt multiple times
    for attack_idx, attack_data in enumerate(ATTACK_PROMPTS):
        attack_type = attack_data["type"]
        attack_prompt = attack_data["prompt"]
        
        logger.info(f"\n[{attack_idx + 1}/{len(ATTACK_PROMPTS)}] Testing: {attack_type}")
        
        for trial in range(num_trials):
            total_requests += 1
            
            # Create request envelope
            request = RequestEnvelope(
                user_input=attack_prompt,
                attack_label=attack_type,
                metadata={
                    "experiment": "exp5_coordination",
                    "config": config_name,
                    "trial": trial + 1,
                    "attack_index": attack_idx
                }
            )
            
            try:
                # Process through pipeline with coordination setting
                trace = pipeline.process(
                    request=request,
                    isolation_mode="good",
                    experiment_id=f"exp5_{config_name}",
                    coordination_enabled=coordination_enabled
                )
                
                # Store in database
                db.store_trace(trace)
                
                # Track outcome
                if trace.attack_successful:
                    successful_attacks += 1
                    logger.debug(f"  Trial {trial + 1}: ATTACK SUCCEEDED")
                else:
                    blocked_attacks += 1
                    logger.debug(f"  Trial {trial + 1}: Attack blocked at {trace.blocked_at_layer}")
                
                # Log coordination insights (only for coordinated mode)
                if coordination_enabled and trace.coordination_context:
                    coord_ctx = trace.coordination_context
                    if coord_ctx.get("adaptive_adjustments"):
                        logger.debug(f"    Adaptive adjustments: {coord_ctx['adaptive_adjustments']}")
                    if coord_ctx.get("trust_boundary_violations"):
                        logger.debug(f"    Trust violations: {len(coord_ctx['trust_boundary_violations'])}")
                
            except Exception as e:
                logger.error(f"  Trial {trial + 1}: ERROR - {e}")
                errors += 1
        
        # Progress update every 10 attacks
        if (attack_idx + 1) % 10 == 0:
            elapsed = time.time() - start_time
            asr = (successful_attacks / total_requests * 100) if total_requests > 0 else 0
            logger.info(f"Progress: {total_requests} traces, ASR={asr:.1f}%, elapsed={elapsed:.1f}s")
    
    # Final statistics
    elapsed_time = time.time() - start_time
    asr = (successful_attacks / total_requests * 100) if total_requests > 0 else 0
    
    logger.info(f"\n" + "=" * 80)
    logger.info(f"EXPERIMENT 5 COMPLETE: {config_name.upper()}")
    logger.info(f"=" * 80)
    logger.info(f"Total traces: {total_requests}")
    logger.info(f"Successful attacks: {successful_attacks}")
    logger.info(f"Blocked attacks: {blocked_attacks}")
    logger.info(f"Errors: {errors}")
    logger.info(f"Attack Success Rate: {asr:.2f}%")
    logger.info(f"Total time: {elapsed_time:.2f}s")
    logger.info(f"Avg time per trace: {elapsed_time / total_requests:.2f}s")
    logger.info(f"Database: {output_db}")
    logger.info(f"=" * 80)
    
    # Export summary JSON
    summary = {
        "experiment": "exp5_coordination",
        "config": config_name,
        "coordination_enabled": coordination_enabled,
        "total_traces": total_requests,
        "successful_attacks": successful_attacks,
        "blocked_attacks": blocked_attacks,
        "errors": errors,
        "attack_success_rate": asr,
        "elapsed_time_seconds": elapsed_time,
        "database": output_db,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
    }
    
    summary_path = Path(output_db).parent / f"exp5_{config_name}_summary.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)
    
    logger.info(f"Summary exported to: {summary_path}")
    
    return summary


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Experiment 5: Coordinated vs Isolated Defense")
    parser.add_argument(
        "--config",
        type=str,
        required=True,
        choices=["isolated", "coordinated"],
        help="Defense configuration: 'isolated' or 'coordinated'"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output database path (default: results/exp5_<config>.db)"
    )
    parser.add_argument(
        "--trials",
        type=int,
        default=5,
        help="Number of trials per attack (default: 5)"
    )
    
    args = parser.parse_args()
    
    # Determine output path
    if args.output is None:
        output_db = f"results/exp5_{args.config}.db"
    else:
        output_db = args.output
    
    # Run experiment
    summary = run_experiment_5(
        output_db=output_db,
        num_trials=args.trials,
        config_name=args.config
    )
    
    print("\n" + "=" * 80)
    print("EXPERIMENT COMPLETE!")
    print(f"Configuration: {args.config}")
    print(f"ASR: {summary['attack_success_rate']:.2f}%")
    print(f"Database: {summary['database']}")
    print("=" * 80)
