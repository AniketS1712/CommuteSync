"""
CommuteSync AI - Synthetic Dataset Generator
Generates 5000 users with Delhi-based commute data
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import random
import os

np.random.seed(42)
random.seed(42)

DELHI_LAT_MIN, DELHI_LAT_MAX = 28.40, 28.88
DELHI_LON_MIN, DELHI_LON_MAX = 76.84, 77.35
N_USERS = 5000

def generate_commute_time():
    base = datetime(2024, 1, 1, 7, 0)
    delta_minutes = np.random.normal(loc=90, scale=45)
    delta_minutes = np.clip(delta_minutes, 0, 210)
    t = base + timedelta(minutes=float(delta_minutes))
    return t.strftime("%H:%M")

def time_to_minutes(t_str):
    h, m = map(int, t_str.split(":"))
    return h * 60 + m

def haversine_vec(lat1, lon1, lat2, lon2):
    R = 6371
    phi1, phi2 = np.radians(lat1), np.radians(lat2)
    dphi = np.radians(lat2 - lat1)
    dlambda = np.radians(lon2 - lon1)
    a = np.sin(dphi/2)**2 + np.cos(phi1)*np.cos(phi2)*np.sin(dlambda/2)**2
    return 2 * R * np.arcsin(np.sqrt(a))

print("Generating synthetic dataset for 5000 users...")

n_clusters = 80
cluster_lats = np.random.uniform(DELHI_LAT_MIN, DELHI_LAT_MAX, n_clusters)
cluster_lons = np.random.uniform(DELHI_LON_MIN, DELHI_LON_MAX, n_clusters)
home_cluster = np.random.randint(0, n_clusters, N_USERS)
office_cluster = np.random.randint(0, n_clusters, N_USERS)

home_lat = (cluster_lats[home_cluster] + np.random.normal(0, 0.02, N_USERS)).clip(DELHI_LAT_MIN, DELHI_LAT_MAX)
home_lon = (cluster_lons[home_cluster] + np.random.normal(0, 0.02, N_USERS)).clip(DELHI_LON_MIN, DELHI_LON_MAX)
office_lat = (cluster_lats[office_cluster] + np.random.normal(0, 0.02, N_USERS)).clip(DELHI_LAT_MIN, DELHI_LAT_MAX)
office_lon = (cluster_lons[office_cluster] + np.random.normal(0, 0.02, N_USERS)).clip(DELHI_LON_MIN, DELHI_LON_MAX)

commute_times = [generate_commute_time() for _ in range(N_USERS)]
commute_time_minutes = np.array([time_to_minutes(t) for t in commute_times])
commute_distance_km = haversine_vec(home_lat, home_lon, office_lat, office_lon)

# Overlap score based on home cluster proximity and time similarity
overlap_scores = []
for i in range(N_USERS):
    same = np.where(home_cluster == home_cluster[i])[0]
    same = same[same != i]
    if len(same) > 0:
        time_diffs = np.abs(commute_time_minutes[same] - commute_time_minutes[i])
        overlap = np.mean(time_diffs < 15) * 0.7 + np.random.uniform(0, 0.3)
    else:
        overlap = np.random.uniform(0, 0.3)
    overlap_scores.append(min(float(overlap), 1.0))

overlap_score = np.array(overlap_scores)
avg_time_diff = np.where(
    overlap_score > 0.5,
    np.random.exponential(scale=10, size=N_USERS).clip(0, 30),
    np.random.uniform(15, 45, N_USERS)
)

past_acceptance_rate = (
    0.4 * overlap_score +
    0.3 * (1 - avg_time_diff / 60) +
    0.1 * (1 - commute_distance_km.clip(0, 20) / 20) +
    0.2 * np.random.uniform(0, 1, N_USERS)
).clip(0, 1)

acceptance_noise = (past_acceptance_rate + np.random.normal(0, 0.1, N_USERS)).clip(0, 1)
accepted = (np.random.uniform(0, 1, N_USERS) < past_acceptance_rate).astype(int)

day_of_week = np.random.randint(0, 5, N_USERS)
response_time = np.abs(np.where(accepted == 1,
    np.random.normal(8, 5, N_USERS),
    np.random.normal(25, 10, N_USERS))).clip(1, 60)

optimal_notify_offset = np.random.normal(30, 10, N_USERS).clip(10, 60).astype(int)
past_carpools = np.random.poisson(lam=5, size=N_USERS)

df = pd.DataFrame({
    "user_id": [f"U{str(i).zfill(4)}" for i in range(1, N_USERS + 1)],
    "home_lat": home_lat,
    "home_lon": home_lon,
    "office_lat": office_lat,
    "office_lon": office_lon,
    "home_cluster": home_cluster,
    "office_cluster": office_cluster,
    "commute_time": commute_times,
    "commute_time_minutes": commute_time_minutes,
    "commute_distance_km": commute_distance_km,
    "overlap_score": overlap_score,
    "avg_time_diff_minutes": avg_time_diff,
    "past_acceptance_rate": acceptance_noise,
    "accepted": accepted,
    "day_of_week": day_of_week,
    "response_time_minutes": response_time,
    "optimal_notify_offset_min": optimal_notify_offset,
    "past_carpools": past_carpools,
})

out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dummy_commute_data.csv")
df.to_csv(out_path, index=False)
print(f"✅ Dataset saved to: {out_path}")
print(f"   Shape: {df.shape}")
print(f"   Acceptance rate: {df['accepted'].mean():.2%}")
