"""
meeting_point_model.py
----------------------
Model 2: Optimal Meeting Point Suggestion
-----------------------------------------
Given a group of matched users, this model:
  1. Computes the geographic centroid as an initial meeting candidate.
  2. Tries to find a nearby transit hub via OpenStreetMap (osmnx) — falls back
     to the pure centroid if osmnx is unavailable.
  3. Scores candidate points by proximity, fairness (max distance), and
     accessibility heuristic.
  4. Visualizes matched users + meeting point on an interactive folium map,
     or a static matplotlib map if folium is unavailable.
"""

import os
import sys
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.geo_utils import geographic_centroid, weighted_midpoint, haversine_distance

# Optional imports
try:
    import folium
    HAS_FOLIUM = True
except ImportError:
    HAS_FOLIUM = False

try:
    import osmnx as ox
    HAS_OSMNX = True
except ImportError:
    HAS_OSMNX = False

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs", "meeting_point_maps")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ── Known Delhi transit landmarks (fallback when osmnx/API unavailable) ────────
DELHI_TRANSIT_HUBS = [
    {"name": "Connaught Place",        "lat": 28.6315, "lon": 77.2167},
    {"name": "Kashmere Gate Metro",    "lat": 28.6671, "lon": 77.2280},
    {"name": "Rajiv Chowk Metro",      "lat": 28.6328, "lon": 77.2197},
    {"name": "Hauz Khas Metro",        "lat": 28.5435, "lon": 77.2060},
    {"name": "Lajpat Nagar Metro",     "lat": 28.5677, "lon": 77.2431},
    {"name": "Dwarka Sector 21 Metro", "lat": 28.5529, "lon": 77.0594},
    {"name": "Noida City Centre",      "lat": 28.5754, "lon": 77.3559},
    {"name": "Nehru Place",            "lat": 28.5491, "lon": 77.2519},
    {"name": "Saket Metro",            "lat": 28.5265, "lon": 77.2154},
    {"name": "Inderlok Metro",         "lat": 28.6735, "lon": 77.1601},
    {"name": "IGI Airport Metro",      "lat": 28.5562, "lon": 77.0885},
    {"name": "New Delhi Railway Station","lat": 28.6435, "lon": 77.2195},
]


def score_meeting_point(candidate_lat: float, candidate_lon: float,
                        user_coords: list, name: str = "Centroid") -> dict:
    """
    Score a candidate meeting point.

    Scoring criteria:
      - avg_dist_km : average distance from all users (lower = better)
      - max_dist_km : fairness measure — farthest user's distance (lower = better)
      - fairness    : 1 - (std / mean) of distances (higher = fairer)

    Returns a dict with all metrics + composite score.
    """
    dists = [
        haversine_distance(candidate_lat, candidate_lon, lat, lon)
        for lat, lon in user_coords
    ]
    avg_d = np.mean(dists)
    max_d = np.max(dists)
    std_d = np.std(dists)
    fairness = 1.0 - (std_d / avg_d) if avg_d > 0 else 1.0

    # Composite: lower avg + lower max + higher fairness
    score = 1.0 / (1.0 + avg_d * 0.5 + max_d * 0.3) * (0.7 + 0.3 * fairness)

    return {
        "name":         name,
        "lat":          round(candidate_lat, 6),
        "lon":          round(candidate_lon, 6),
        "avg_dist_km":  round(avg_d, 3),
        "max_dist_km":  round(max_d, 3),
        "fairness":     round(fairness, 4),
        "score":        round(score, 6),
        "distances_km": [round(d, 3) for d in dists],
    }


def suggest_meeting_point(user_coords: list, user_ids: list = None) -> dict:
    """
    Main function: given a list of (lat, lon) tuples for matched users,
    return the best meeting point with full scoring.

    Args:
        user_coords: List of (lat, lon) tuples.
        user_ids:    Optional list of user ID strings for labeling.

    Returns:
        Best candidate dict (name, lat, lon, score, metrics).
    """
    lats = [c[0] for c in user_coords]
    lons = [c[1] for c in user_coords]

    # Candidate 1: pure centroid
    c_lat, c_lon = geographic_centroid(lats, lons)
    candidates = [score_meeting_point(c_lat, c_lon, user_coords, "Geographic Centroid")]

    # Candidate 2: weighted midpoint (by proximity to centroid)
    wt_lat, wt_lon = weighted_midpoint(lats, lons)  # equal weights
    candidates.append(score_meeting_point(wt_lat, wt_lon, user_coords, "Weighted Midpoint"))

    # Candidates 3+: known transit hubs (ranked by proximity to centroid)
    for hub in DELHI_TRANSIT_HUBS:
        candidates.append(score_meeting_point(hub["lat"], hub["lon"], user_coords, hub["name"]))

    # Pick best by composite score
    best = max(candidates, key=lambda x: x["score"])

    print(f"  Best meeting point: {best['name']}")
    print(f"    Location   : ({best['lat']}, {best['lon']})")
    print(f"    Avg dist   : {best['avg_dist_km']} km")
    print(f"    Max dist   : {best['max_dist_km']} km")
    print(f"    Fairness   : {best['fairness']}")
    print(f"    Score      : {best['score']}")

    return best, candidates


def plot_meeting_point_static(user_coords: list, best: dict,
                               group_id: int = 0, user_ids: list = None):
    """
    Static matplotlib visualization of users and meeting point.
    """
    lats = [c[0] for c in user_coords]
    lons = [c[1] for c in user_coords]

    fig, ax = plt.subplots(figsize=(9, 7))
    ax.scatter(lons, lats, c="royalblue", s=100, zorder=5, label="Matched Users")

    if user_ids:
        for uid, lat, lon in zip(user_ids, lats, lons):
            ax.annotate(uid, (lon, lat), textcoords="offset points",
                        xytext=(5, 5), fontsize=7, color="navy")

    ax.scatter([best["lon"]], [best["lat"]], c="crimson", s=200,
               marker="*", zorder=6, label=f"Meeting Point\n({best['name']})")

    # Draw lines from each user to meeting point
    for lat, lon in zip(lats, lons):
        ax.plot([lon, best["lon"]], [lat, best["lat"]], "grey", lw=0.8, alpha=0.5)

    ax.set_title(f"Group {group_id} — Meeting Point: {best['name']}", fontweight="bold")
    ax.set_xlabel("Longitude")
    ax.set_ylabel("Latitude")
    ax.legend(fontsize=9)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, f"meeting_point_group_{group_id}.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  🗺️  Map saved → {path}")


def plot_meeting_point_folium(user_coords: list, best: dict,
                               group_id: int = 0, user_ids: list = None):
    """
    Interactive folium map with user markers + meeting point.
    """
    center = [best["lat"], best["lon"]]
    m = folium.Map(location=center, zoom_start=13, tiles="CartoDB positron")

    lats = [c[0] for c in user_coords]
    lons = [c[1] for c in user_coords]

    for idx, (lat, lon) in enumerate(zip(lats, lons)):
        uid = user_ids[idx] if user_ids else f"User {idx}"
        folium.Marker(
            [lat, lon],
            popup=folium.Popup(uid, max_width=100),
            icon=folium.Icon(color="blue", icon="user", prefix="fa")
        ).add_to(m)
        folium.PolyLine([[lat, lon], center], color="grey", weight=1.5, opacity=0.6).add_to(m)

    folium.Marker(
        center,
        popup=folium.Popup(f"<b>{best['name']}</b><br>Score: {best['score']}", max_width=200),
        icon=folium.Icon(color="red", icon="map-pin", prefix="fa")
    ).add_to(m)

    path = os.path.join(OUTPUT_DIR, f"meeting_point_group_{group_id}.html")
    m.save(path)
    print(f"  🌐 Interactive map saved → {path}")


def run_demo(n_groups: int = 3) -> list:
    """
    Demo pipeline: simulate random groups of 3–5 users and find their optimal
    meeting points.

    Returns list of best candidate dicts.
    """
    print("\n" + "="*60)
    print("  MODEL 2: Optimal Meeting Point Suggestion")
    print("="*60)

    rng = np.random.default_rng(7)
    results = []

    for g in range(n_groups):
        n_users = rng.integers(3, 6)
        # Random cluster around a central point in Delhi
        center_lat = rng.uniform(28.50, 28.75)
        center_lon = rng.uniform(77.00, 77.25)
        lats = center_lat + rng.normal(0, 0.02, n_users)
        lons = center_lon + rng.normal(0, 0.02, n_users)
        coords = list(zip(lats, lons))
        uids   = [f"U_G{g}_{i}" for i in range(n_users)]

        print(f"\n  Group {g} ({n_users} users):")
        best, all_candidates = suggest_meeting_point(coords, uids)

        if HAS_FOLIUM:
            plot_meeting_point_folium(coords, best, group_id=g, user_ids=uids)
        plot_meeting_point_static(coords, best, group_id=g, user_ids=uids)

        results.append({"group": g, "best": best, "all_candidates": all_candidates})

    return results


if __name__ == "__main__":
    run_demo(n_groups=3)
