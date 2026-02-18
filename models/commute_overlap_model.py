"""
commute_overlap_model.py
------------------------
Model 1: Commute Overlap Prediction
------------------------------------
Clusters users by spatial-temporal proximity using DBSCAN (or HDBSCAN if
available). Identifies overlapping commute pairs/groups and visualizes them.

Algorithm overview:
  1. Load user coordinates + commute times
  2. Build a combined feature space: (lat_km, lon_km, time_scaled)
  3. Run DBSCAN clustering
  4. Evaluate with Davies–Bouldin Index and Silhouette Score
  5. Extract matched pairs within each cluster
  6. Visualize clusters and matched pairs on a map
"""

import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from sklearn.cluster import DBSCAN
from sklearn.metrics import davies_bouldin_score, silhouette_score
from sklearn.preprocessing import StandardScaler
from itertools import combinations

# Optional: HDBSCAN
try:
    import hdbscan as hdbscan_lib
    HAS_HDBSCAN = True
except ImportError:
    HAS_HDBSCAN = False

# project root on path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.geo_utils import haversine_distance, normalize_coords_for_clustering, minutes_to_time

# ── paths ──────────────────────────────────────────────────────────────────────
DATA_PATH   = os.path.join(os.path.dirname(__file__), "..", "data", "dummy_commute_data.csv")
OUTPUT_DIR  = os.path.join(os.path.dirname(__file__), "..", "outputs", "cluster_visuals")
os.makedirs(OUTPUT_DIR, exist_ok=True)


def load_data(sample_n: int = 500) -> pd.DataFrame:
    """Load dataset and optionally sample for performance."""
    df = pd.read_csv(DATA_PATH)
    if sample_n and sample_n < len(df):
        df = df.sample(n=sample_n, random_state=42).reset_index(drop=True)
    return df


def build_feature_matrix(df: pd.DataFrame) -> np.ndarray:
    """
    Construct a scaled feature matrix combining home coordinates and commute time.
    Uses StandardScaler to normalize each feature to zero mean / unit variance.
    """
    features = normalize_coords_for_clustering(
        lats=df["home_lat"].values,
        lons=df["home_lon"].values,
        times_minutes=df["commute_time_minutes"].values,
        spatial_weight=1.0,
        temporal_weight=2.0   # give time slightly more weight
    )
    scaler = StandardScaler()
    return scaler.fit_transform(features), scaler


def run_dbscan(X: np.ndarray, eps: float = 0.35, min_samples: int = 4):
    """
    Run DBSCAN clustering on the scaled feature matrix.

    Args:
        X:           Scaled feature matrix.
        eps:         Neighborhood radius (in scaled units).
        min_samples: Min neighbors to form a core point.

    Returns:
        labels array (-1 = noise).
    """
    db = DBSCAN(eps=eps, min_samples=min_samples, n_jobs=-1)
    labels = db.fit_predict(X)
    return labels


def run_hdbscan(X: np.ndarray, min_cluster_size: int = 10):
    """Run HDBSCAN if available (better for variable-density clusters)."""
    clusterer = hdbscan_lib.HDBSCAN(
        min_cluster_size=min_cluster_size,
        metric="euclidean",
        prediction_data=True
    )
    labels = clusterer.fit_predict(X)
    return labels


def evaluate_clustering(X: np.ndarray, labels: np.ndarray) -> dict:
    """
    Compute clustering quality metrics, ignoring noise points.

    Returns dict with silhouette_score and davies_bouldin_index.
    """
    mask = labels != -1
    n_clusters = len(set(labels[mask]))
    metrics = {"n_clusters": n_clusters, "n_noise": int((labels == -1).sum())}

    if n_clusters >= 2 and mask.sum() >= n_clusters + 1:
        try:
            metrics["silhouette_score"]      = round(silhouette_score(X[mask], labels[mask], sample_size=1000), 4)
            metrics["davies_bouldin_index"]  = round(davies_bouldin_score(X[mask], labels[mask]), 4)
        except Exception as e:
            metrics["silhouette_score"]     = None
            metrics["davies_bouldin_index"] = None
    return metrics


def extract_matched_pairs(df: pd.DataFrame, labels: np.ndarray,
                           time_window_min: int = 15,
                           max_dist_km: float = 5.0) -> pd.DataFrame:
    """
    Within each cluster, find user pairs whose commute times differ by at most
    `time_window_min` minutes AND whose homes are within `max_dist_km`.

    Returns a DataFrame of matched pairs with their overlap metrics.
    """
    df = df.copy()
    df["cluster"] = labels
    pairs = []

    for cluster_id in sorted(set(labels)):
        if cluster_id == -1:
            continue
        group = df[df["cluster"] == cluster_id]
        if len(group) < 2:
            continue

        for (i, r1), (i2, r2) in combinations(group.iterrows(), 2):
            td = abs(r1["commute_time_minutes"] - r2["commute_time_minutes"])
            if td > time_window_min:
                continue
            dist = haversine_distance(
                r1["home_lat"], r1["home_lon"],
                r2["home_lat"], r2["home_lon"]
            )
            if dist > max_dist_km:
                continue
            pairs.append({
                "cluster":    cluster_id,
                "user_1":     r1["user_id"],
                "user_2":     r2["user_id"],
                "time_diff":  td,
                "home_dist_km": round(dist, 3),
                "overlap_prob": round(1 - td / time_window_min * 0.5 - dist / max_dist_km * 0.5, 4)
            })

    return pd.DataFrame(pairs)


def plot_clusters(df: pd.DataFrame, labels: np.ndarray, title: str = "Commute Clusters"):
    """
    Scatter plot of users color-coded by cluster on a lat/lon map.
    Noise points (label = -1) shown in grey.
    """
    unique_labels = sorted(set(labels))
    cmap = cm.get_cmap("tab20", max(len(unique_labels), 1))

    fig, ax = plt.subplots(figsize=(12, 9))
    for idx, label in enumerate(unique_labels):
        mask = labels == label
        color = "lightgrey" if label == -1 else cmap(idx)
        alpha = 0.4 if label == -1 else 0.75
        size  = 10 if label == -1 else 25
        lbl   = "Noise" if label == -1 else f"Cluster {label}"
        ax.scatter(
            df["home_lon"].values[mask],
            df["home_lat"].values[mask],
            c=[color], alpha=alpha, s=size, label=lbl
        )

    ax.set_title(title, fontsize=14, fontweight="bold")
    ax.set_xlabel("Longitude")
    ax.set_ylabel("Latitude")
    if len(unique_labels) <= 15:
        ax.legend(loc="upper right", fontsize=7, ncol=2)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "cluster_map.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📍 Cluster map saved → {path}")


def plot_matched_pairs(df: pd.DataFrame, pairs: pd.DataFrame, max_pairs: int = 60):
    """
    Draw lines between matched user pairs on a lat/lon scatter plot.
    """
    fig, ax = plt.subplots(figsize=(12, 9))
    ax.scatter(df["home_lon"], df["home_lat"], c="steelblue", alpha=0.3, s=15, label="Users")

    sample_pairs = pairs.head(max_pairs)
    df_indexed = df.set_index("user_id")
    for _, row in sample_pairs.iterrows():
        try:
            u1 = df_indexed.loc[row["user_1"]]
            u2 = df_indexed.loc[row["user_2"]]
            ax.plot(
                [u1["home_lon"], u2["home_lon"]],
                [u1["home_lat"], u2["home_lat"]],
                "r-", alpha=0.35, lw=0.8
            )
        except KeyError:
            continue

    ax.set_title(f"Matched Carpool Pairs (top {len(sample_pairs)})", fontsize=14, fontweight="bold")
    ax.set_xlabel("Longitude")
    ax.set_ylabel("Latitude")
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "matched_pairs.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  🔗 Matched pairs map saved → {path}")


def run(use_hdbscan: bool = False, sample_n: int = 500) -> dict:
    """
    Main pipeline for Model 1.

    Args:
        use_hdbscan: Use HDBSCAN instead of DBSCAN (if available).
        sample_n:    Number of users to cluster (performance control).

    Returns:
        dict with metrics and matched pairs DataFrame.
    """
    print("\n" + "="*60)
    print("  MODEL 1: Commute Overlap Prediction")
    print("="*60)

    # 1. Load & prepare
    df = load_data(sample_n=sample_n)
    print(f"  Loaded {len(df)} users for clustering")

    X, scaler = build_feature_matrix(df)

    # 2. Cluster
    if use_hdbscan and HAS_HDBSCAN:
        print("  Using HDBSCAN clustering …")
        labels = run_hdbscan(X, min_cluster_size=8)
    else:
        print("  Using DBSCAN clustering  …")
        labels = run_dbscan(X, eps=0.4, min_samples=5)

    # 3. Evaluate
    metrics = evaluate_clustering(X, labels)
    print(f"  Clusters found : {metrics['n_clusters']}")
    print(f"  Noise points   : {metrics['n_noise']}")
    if metrics.get("silhouette_score") is not None:
        print(f"  Silhouette     : {metrics['silhouette_score']}")
        print(f"  Davies–Bouldin : {metrics['davies_bouldin_index']}")

    # 4. Extract matches
    pairs = extract_matched_pairs(df, labels, time_window_min=15, max_dist_km=5.0)
    print(f"  Matched pairs  : {len(pairs)}")

    # 5. Save pairs CSV
    pairs_path = os.path.join(OUTPUT_DIR, "matched_pairs.csv")
    pairs.to_csv(pairs_path, index=False)

    # 6. Visualize
    plot_clusters(df, labels, title="CommuteSync — User Clusters (Delhi)")
    if not pairs.empty:
        plot_matched_pairs(df, pairs)

    metrics["matched_pairs"] = pairs
    return metrics


if __name__ == "__main__":
    result = run(use_hdbscan=HAS_HDBSCAN, sample_n=500)
    print("\n  Top 5 matched pairs:")
    print(result["matched_pairs"].head(5).to_string(index=False))
