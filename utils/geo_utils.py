"""
geo_utils.py
------------
Utility functions for geographic computations used across CommuteSync models.
Includes Haversine distance, centroid calculation, and coordinate normalization.
"""

import numpy as np
import math


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great-circle distance between two points on Earth using the
    Haversine formula.

    Args:
        lat1, lon1: Latitude and longitude of point 1 (in decimal degrees).
        lat2, lon2: Latitude and longitude of point 2 (in decimal degrees).

    Returns:
        Distance in kilometers.
    """
    R = 6371.0  # Earth's radius in kilometers

    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


def haversine_matrix(coords: np.ndarray) -> np.ndarray:
    """
    Compute pairwise Haversine distance matrix for an array of (lat, lon) coordinates.

    Args:
        coords: numpy array of shape (N, 2) with columns [lat, lon].

    Returns:
        Distance matrix of shape (N, N) in kilometers.
    """
    n = len(coords)
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = haversine_distance(coords[i, 0], coords[i, 1], coords[j, 0], coords[j, 1])
            dist_matrix[i, j] = d
            dist_matrix[j, i] = d
    return dist_matrix


def geographic_centroid(lats: list, lons: list) -> tuple:
    """
    Calculate the geographic centroid (mean center) of a set of coordinates.

    Args:
        lats: List of latitude values.
        lons: List of longitude values.

    Returns:
        (centroid_lat, centroid_lon) tuple.
    """
    return float(np.mean(lats)), float(np.mean(lons))


def weighted_midpoint(lats: list, lons: list, weights: list = None) -> tuple:
    """
    Calculate a weighted midpoint based on optional weights (e.g., user priority).

    Args:
        lats: List of latitude values.
        lons: List of longitude values.
        weights: Optional list of weights. Defaults to equal weighting.

    Returns:
        (weighted_lat, weighted_lon) tuple.
    """
    if weights is None:
        weights = [1.0] * len(lats)
    weights = np.array(weights, dtype=float)
    weights /= weights.sum()
    return float(np.dot(weights, lats)), float(np.dot(weights, lons))


def time_to_minutes(time_str: str) -> int:
    """
    Convert a time string (HH:MM) to minutes since midnight.

    Args:
        time_str: Time in "HH:MM" format.

    Returns:
        Integer minutes since midnight.
    """
    h, m = map(int, time_str.split(":"))
    return h * 60 + m


def minutes_to_time(minutes: int) -> str:
    """
    Convert minutes since midnight back to HH:MM string.

    Args:
        minutes: Integer minutes since midnight.

    Returns:
        Time string in "HH:MM" format.
    """
    h = minutes // 60
    m = minutes % 60
    return f"{h:02d}:{m:02d}"


def normalize_coords_for_clustering(lats: np.ndarray, lons: np.ndarray,
                                     times_minutes: np.ndarray,
                                     spatial_weight: float = 1.0,
                                     temporal_weight: float = 0.5) -> np.ndarray:
    """
    Combine spatial (lat/lon) and temporal (commute time) features into a
    normalized feature matrix suitable for clustering.

    Args:
        lats: Array of latitudes.
        lons: Array of longitudes.
        times_minutes: Array of commute times in minutes.
        spatial_weight: Scaling factor for spatial features.
        temporal_weight: Scaling factor for temporal features (in km-equivalent).

    Returns:
        Feature matrix of shape (N, 3).
    """
    # Convert degrees to approximate km (1 degree lat ≈ 111 km)
    lat_km = lats * 111.0 * spatial_weight
    lon_km = lons * 111.0 * np.cos(np.radians(lats.mean())) * spatial_weight
    # Scale time: each minute ≈ temporal_weight km equivalent
    time_scaled = times_minutes * temporal_weight / 60.0
    return np.column_stack([lat_km, lon_km, time_scaled])
