"""
run_all.py
----------
Master pipeline script for CommuteSync AI Demo.
Runs all 4 models end-to-end and prints a final summary.

Usage:
    python run_all.py
"""

import os
import sys
import time

# Ensure project root is importable
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)

# ── Step 0: Generate dataset ───────────────────────────────────────────────────
print("\n" + "█"*60)
print("  COMMUTESYNC AI DEMO — FULL PIPELINE")
print("█"*60)

print("\n[0/4] Generating synthetic dataset …")
import data.generate_dataset  # executes on import
print("  ✅ Dataset ready")

# ── Model 1 ────────────────────────────────────────────────────────────────────
t0 = time.time()
from models.commute_overlap_model import run as run_overlap, HAS_HDBSCAN
m1_result = run_overlap(use_hdbscan=HAS_HDBSCAN, sample_n=500)
print(f"  ✅ Model 1 done ({time.time()-t0:.1f}s)")

# ── Model 2 ────────────────────────────────────────────────────────────────────
t0 = time.time()
from models.meeting_point_model import run_demo as run_meeting
m2_result = run_meeting(n_groups=3)
print(f"  ✅ Model 2 done ({time.time()-t0:.1f}s)")

# ── Model 3 ────────────────────────────────────────────────────────────────────
t0 = time.time()
from models.acceptance_prediction_model import run as run_acceptance
m3_result = run_acceptance()
print(f"  ✅ Model 3 done ({time.time()-t0:.1f}s)")

# ── Model 4 ────────────────────────────────────────────────────────────────────
t0 = time.time()
from models.notification_timing_model import run as run_notification
m4_result = run_notification()
print(f"  ✅ Model 4 done ({time.time()-t0:.1f}s)")

# ── Summary ────────────────────────────────────────────────────────────────────
print("\n" + "█"*60)
print("  PIPELINE COMPLETE — SUMMARY")
print("█"*60)

print(f"\n  Model 1 (Overlap Clustering):")
print(f"    Clusters found  : {m1_result['n_clusters']}")
print(f"    Matched pairs   : {len(m1_result['matched_pairs'])}")
if m1_result.get("silhouette_score"):
    print(f"    Silhouette      : {m1_result['silhouette_score']}")
    print(f"    Davies-Bouldin  : {m1_result['davies_bouldin_index']}")

print(f"\n  Model 2 (Meeting Points):")
for r in m2_result:
    b = r["best"]
    print(f"    Group {r['group']}: {b['name']} | avg {b['avg_dist_km']} km | score {b['score']:.4f}")

print(f"\n  Model 3 (Acceptance Prediction):")
print(m3_result["reports"].to_string(index=False))
print(f"    Best model: {m3_result['best_model_name']}")

print(f"\n  Model 4 (Notification Timing):")
print(m4_result["reports"].to_string(index=False))
print(f"    Best model: {m4_result['best_model_name']}")

print("\n" + "█"*60)
print("  All outputs saved in outputs/")
print("█"*60 + "\n")
