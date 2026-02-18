"""
generate_dataset.py
-------------------
Generates a synthetic dataset of 5,000 commuters in Delhi for the
CommuteSync AI prototype. Saves the result to data/dummy_commute_data.csv.

Delhi bounding box (approximate):
  Latitude:  28.40 – 28.88
  Longitude: 76.84 – 77.35
"""

import numpy as np
import pandas as pd
import os
import sys

# ── reproducibility ────────────────────────────────────────────────────────────
SEED = 42
rng  = np.random.default_rng(SEED)

# ── config ─────────────────────────────────────────────────────────────────────
N_USERS      = 5_000
LAT_MIN, LAT_MAX = 28.40, 28.88
LON_MIN, LON_MAX = 76.84, 77.35

# Commute window: 7:00 – 10:30  →  420 – 630 minutes since midnight
TIME_MIN_MIN = 420
TIME_MAX_MIN = 630

# ── helpers ────────────────────────────────────────────────────────────────────
def random_coords(n):
    lats = rng.uniform(LAT_MIN, LAT_MAX, n)
    lons = rng.uniform(LON_MIN, LON_MAX, n)
    return lats, lons

def minutes_to_str(arr):
    return [f"{m // 60:02d}:{m % 60:02d}" for m in arr]

# ── coordinate generation ──────────────────────────────────────────────────────
home_lat, home_lon   = random_coords(N_USERS)
office_lat, office_lon = random_coords(N_USERS)

# Commute times: normally distributed clusters around 7:30, 8:30, 9:30
cluster_centers  = rng.choice([450, 510, 570], size=N_USERS)        # mins
commute_min_raw  = (cluster_centers + rng.normal(0, 20, N_USERS)).astype(int)
commute_minutes  = np.clip(commute_min_raw, TIME_MIN_MIN, TIME_MAX_MIN)

# Commute duration (travel time in minutes)
commute_duration = rng.integers(15, 90, size=N_USERS)

# ── overlap & distance features ────────────────────────────────────────────────
# Spatial overlap score: inverse of home-to-home + office-to-office distance
# (simplified: random but correlated with coord similarity)
overlap_score = rng.uniform(0.0, 1.0, N_USERS)

# Distance from home to office (Euclidean proxy, scaled ~km)
dist_home_office = np.sqrt(
    ((home_lat - office_lat) * 111) ** 2 +
    ((home_lon - office_lon) * 111 * np.cos(np.radians(home_lat))) ** 2
)

# Time difference from nearest matched user (minutes)
time_diff = np.abs(rng.normal(0, 15, N_USERS)).clip(0, 60).astype(int)

# ── acceptance history ─────────────────────────────────────────────────────────
# Acceptance probability: users with high overlap & small time diff accept more
accept_prob = (
    0.4 * overlap_score
    + 0.3 * np.exp(-time_diff / 30)
    + 0.2 * np.exp(-dist_home_office / 20)
    + 0.1 * rng.uniform(0, 1, N_USERS)
)
accept_prob = np.clip(accept_prob / accept_prob.max(), 0.05, 0.95)
accepted = rng.binomial(1, accept_prob, N_USERS)

# ── past acceptance rate (rolling 10-trip average) ─────────────────────────────
past_acceptance_rate = np.clip(accept_prob + rng.normal(0, 0.05, N_USERS), 0, 1)

# ── response times (for notification model) ────────────────────────────────────
# Best response window: 30–90 minutes before commute time
response_offset_min = rng.integers(20, 120, size=N_USERS)           # mins before departure
optimal_notify_min  = np.clip(commute_minutes - response_offset_min, 360, TIME_MAX_MIN)

# Day of week (0=Monday, 6=Sunday); most commutes Mon–Fri
day_of_week = rng.choice([0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 5, 6], size=N_USERS)

# Simulated historical average response time after notification (minutes to open app)
response_time_lag = np.clip(rng.normal(8, 5, N_USERS), 1, 30).round(1)

# ── assemble DataFrame ─────────────────────────────────────────────────────────
df = pd.DataFrame({
    "user_id":              [f"U{i:05d}" for i in range(N_USERS)],
    "home_lat":             home_lat.round(6),
    "home_lon":             home_lon.round(6),
    "office_lat":           office_lat.round(6),
    "office_lon":           office_lon.round(6),
    "commute_time":         minutes_to_str(commute_minutes),          # "HH:MM"
    "commute_time_minutes": commute_minutes,                           # numeric
    "commute_duration_min": commute_duration,
    "dist_home_office_km":  dist_home_office.round(3),
    "overlap_score":        overlap_score.round(4),
    "time_diff_minutes":    time_diff,
    "accepted":             accepted,                                  # target: Model 3
    "past_acceptance_rate": past_acceptance_rate.round(4),
    "optimal_notify_minutes": optimal_notify_min,                     # target: Model 4
    "optimal_notify_time":  minutes_to_str(optimal_notify_min),
    "day_of_week":          day_of_week,                              # 0=Mon
    "response_time_lag_min": response_time_lag,
})

# ── save ───────────────────────────────────────────────────────────────────────
out_path = os.path.join(os.path.dirname(__file__), "dummy_commute_data.csv")
df.to_csv(out_path, index=False)
print(f"✅  Dataset saved → {out_path}  ({len(df):,} rows × {len(df.columns)} cols)")
print(df.head(3).to_string())
print(f"\nAcceptance rate: {df['accepted'].mean():.2%}")

if __name__ == "__main__":
    pass  # already executed on import for pipeline use
