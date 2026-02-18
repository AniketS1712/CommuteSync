"""
CommuteSync AI Demo - Full Pipeline Runner
==========================================
Runs all 4 AI models end-to-end:
  1. Generate synthetic dataset
  2. Model 1: Commute Overlap Clustering
  3. Model 2: Meeting Point Suggestion
  4. Model 3: User Acceptance Prediction
  5. Model 4: Notification Timing Optimization

Usage:
    python run_pipeline.py
"""

import os
import sys
import time

# ── Add project root to path ──────────────────────────────────────────────────
ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)

DATA_PATH = os.path.join(ROOT, 'data', 'dummy_commute_data.csv')


def section(title):
    print(f"\n{'═'*60}")
    print(f"  {title}")
    print(f"{'═'*60}")


# ── Step 0: Generate Dataset ──────────────────────────────────────────────────
section("STEP 0: Generating Synthetic Dataset")
os.chdir(os.path.join(ROOT, 'data'))
exec(open(os.path.join(ROOT, 'data', 'generate_data.py')).read())
os.chdir(ROOT)


# ── Step 1: Commute Overlap Prediction ───────────────────────────────────────
section("STEP 1: Commute Overlap Prediction (DBSCAN Clustering)")
t0 = time.time()
from models.commute_overlap_model import run as run_overlap
df_sample, labels, pairs_df = run_overlap(DATA_PATH, sample_size=800)
print(f"  ✓ Done in {time.time()-t0:.1f}s")


# ── Step 2: Meeting Point Suggestion ─────────────────────────────────────────
section("STEP 2: Optimal Meeting Point Suggestion")
t0 = time.time()
from models.meeting_point_model import run as run_meeting
suggestions = run_meeting(pairs_df)
print(f"  ✓ Done in {time.time()-t0:.1f}s")


# ── Step 3: User Acceptance Prediction ───────────────────────────────────────
section("STEP 3: User Acceptance Prediction (LR / RF / XGBoost)")
t0 = time.time()
from models.acceptance_prediction_model import run as run_acceptance
models, summary = run_acceptance(DATA_PATH)
print(f"  ✓ Done in {time.time()-t0:.1f}s")


# ── Step 4: Notification Timing Optimization ──────────────────────────────────
section("STEP 4: Notification Timing Optimization (XGBoost + Prophet)")
t0 = time.time()
from models.notification_timing_model import run as run_notification
xgb_model, prophet_model, mae, rmse = run_notification(DATA_PATH)
print(f"  ✓ Done in {time.time()-t0:.1f}s")


# ── Summary ───────────────────────────────────────────────────────────────────
section("PIPELINE COMPLETE — Summary")
print(f"""
  Dataset       : {DATA_PATH}
  Users         : 5000
  
  Model 1 (Clustering)
    Clusters found : {len(set(labels)) - (1 if -1 in labels else 0)}
    Matched pairs  : {len(pairs_df)}
  
  Model 2 (Meeting Points)
    Suggestions    : {len(suggestions)}
  
  Model 3 (Acceptance)
{summary.to_string(index=False)}
  
  Model 4 (Notification Timing)
    XGBoost MAE    : {mae:.2f} mins
    XGBoost RMSE   : {rmse:.2f} mins
  
  Outputs saved in: outputs/
""")
