"""
notification_timing_model.py
-----------------------------
Model 4: Notification Timing Optimization
------------------------------------------
Predicts the optimal time (in minutes since midnight) to send a carpool
suggestion to each user to maximize acceptance likelihood.

Features:
  - commute_time_minutes   : user's planned departure time
  - day_of_week            : 0=Monday … 6=Sunday
  - past_acceptance_rate   : historical acceptance rate
  - response_time_lag_min  : how long user typically takes to respond (mins)
  - commute_duration_min   : travel duration

Target: optimal_notify_minutes (regression target)

Models:
  - XGBoost Regressor (primary, if available)
  - Gradient Boosting Regressor (fallback)
  - Ridge Regression (baseline)

Evaluation: MAE and RMSE

Outputs:
  - model_reports/notification_timing_report.csv
  - model_reports/notification_timing_residuals.png
  - model_reports/notification_timing_predictions.png
"""

import os
import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.linear_model import Ridge
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.evaluation_metrics import regression_report_dict, print_regression_report
from utils.geo_utils import minutes_to_time

try:
    import xgboost as xgb
    HAS_XGB = True
except ImportError:
    HAS_XGB = False

DATA_PATH  = os.path.join(os.path.dirname(__file__), "..", "data", "dummy_commute_data.csv")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs", "model_reports")
os.makedirs(OUTPUT_DIR, exist_ok=True)

FEATURE_COLS = [
    "commute_time_minutes",
    "day_of_week",
    "past_acceptance_rate",
    "response_time_lag_min",
    "commute_duration_min",
    "overlap_score",
]
TARGET_COL = "optimal_notify_minutes"


def load_and_prepare(path: str):
    """Load and split dataset."""
    df = pd.read_csv(path)
    X = df[FEATURE_COLS]
    y = df[TARGET_COL]
    return train_test_split(X, y, test_size=0.2, random_state=42)


def build_models():
    """Return dict of regression pipelines."""
    models = {
        "Ridge Regression (Baseline)": Pipeline([
            ("scaler", StandardScaler()),
            ("reg", Ridge(alpha=1.0))
        ]),
        "Gradient Boosting": Pipeline([
            ("scaler", StandardScaler()),
            ("reg", GradientBoostingRegressor(
                n_estimators=200, learning_rate=0.08, max_depth=4,
                subsample=0.8, random_state=42
            ))
        ]),
    }
    if HAS_XGB:
        models["XGBoost Regressor"] = Pipeline([
            ("scaler", StandardScaler()),
            ("reg", xgb.XGBRegressor(
                n_estimators=200, learning_rate=0.08, max_depth=4,
                subsample=0.8, random_state=42, n_jobs=-1
            ))
        ])
    return models


def plot_residuals(y_test, y_pred, model_name: str, save_suffix: str = ""):
    """Residual plot for regression diagnostics."""
    residuals = y_test.values - y_pred

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Residuals vs Fitted
    axes[0].scatter(y_pred, residuals, alpha=0.3, s=12, c="steelblue")
    axes[0].axhline(0, color="crimson", lw=1.5, ls="--")
    axes[0].set_xlabel("Predicted (minutes)")
    axes[0].set_ylabel("Residual (minutes)")
    axes[0].set_title(f"{model_name}\nResiduals vs Fitted")
    axes[0].grid(alpha=0.3)

    # Residual distribution
    axes[1].hist(residuals, bins=50, color="steelblue", edgecolor="white", alpha=0.8)
    axes[1].axvline(0, color="crimson", lw=1.5, ls="--")
    axes[1].set_xlabel("Residual (minutes)")
    axes[1].set_ylabel("Count")
    axes[1].set_title("Residual Distribution")
    axes[1].grid(axis="y", alpha=0.3)

    plt.suptitle(f"Notification Timing — {model_name}", fontsize=13, fontweight="bold")
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, f"notification_timing_residuals{save_suffix}.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📉 Residuals plot saved → {path}")


def plot_predictions_vs_actual(y_test, y_pred, model_name: str):
    """Scatter plot of predicted vs actual notification times."""
    fig, ax = plt.subplots(figsize=(8, 7))
    ax.scatter(y_test, y_pred, alpha=0.25, s=10, c="steelblue")
    min_v = min(y_test.min(), y_pred.min()) - 10
    max_v = max(y_test.max(), y_pred.max()) + 10
    ax.plot([min_v, max_v], [min_v, max_v], "r--", lw=1.5, label="Perfect Prediction")
    ax.set_xlabel("Actual Optimal Time (minutes)")
    ax.set_ylabel("Predicted Optimal Time (minutes)")
    ax.set_title(f"Notification Timing — Predicted vs Actual\n({model_name})",
                 fontsize=12, fontweight="bold")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "notification_timing_predictions.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📈 Prediction scatter saved → {path}")


def plot_feature_importance(model_pipeline, feature_names: list, model_name: str):
    """Feature importance bar chart (for tree-based models)."""
    estimator = model_pipeline.named_steps["reg"]
    if not hasattr(estimator, "feature_importances_"):
        return
    importances = estimator.feature_importances_
    indices = np.argsort(importances)

    fig, ax = plt.subplots(figsize=(9, 5))
    colors = sns.color_palette("Greens_r", len(feature_names))
    ax.barh([feature_names[i] for i in indices],
            importances[indices], color=colors[::-1])
    ax.set_xlabel("Importance")
    ax.set_title(f"{model_name} — Feature Importances", fontsize=12, fontweight="bold")
    ax.grid(axis="x", alpha=0.3)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "notification_feature_importance.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📊 Feature importance saved → {path}")


def predict_optimal_time(model_pipeline, user_features: dict) -> str:
    """
    Predict optimal notification time for a single user.

    Args:
        model_pipeline: Trained sklearn pipeline.
        user_features:  Dict with keys matching FEATURE_COLS.

    Returns:
        Optimal notification time as "HH:MM" string.
    """
    row = pd.DataFrame([{col: user_features.get(col, 0) for col in FEATURE_COLS}])
    pred_minutes = model_pipeline.predict(row)[0]
    return minutes_to_time(int(round(pred_minutes)))


def run() -> dict:
    """Main pipeline for Model 4."""
    print("\n" + "="*60)
    print("  MODEL 4: Notification Timing Optimization")
    print("="*60)

    # 1. Data
    X_train, X_test, y_train, y_test = load_and_prepare(DATA_PATH)
    print(f"  Train: {len(X_train)} | Test: {len(X_test)}")
    print(f"  Target range: {int(y_train.min())}–{int(y_train.max())} mins "
          f"({minutes_to_time(int(y_train.min()))}–{minutes_to_time(int(y_train.max()))})")

    # 2. Train models
    models = build_models()
    results = {}

    for name, pipeline in models.items():
        print(f"\n  Training {name} …")
        pipeline.fit(X_train, y_train)
        y_pred = pipeline.predict(X_test)
        report = regression_report_dict(y_test, y_pred)
        print_regression_report(name, report)
        results[name] = (pipeline, report, y_pred)

    # 3. Save comparison table
    rows = [{"model": name, **report} for name, (_, report, _) in results.items()]
    report_df = pd.DataFrame(rows)
    csv_path = os.path.join(OUTPUT_DIR, "notification_timing_report.csv")
    report_df.to_csv(csv_path, index=False)
    print(f"\n  💾 Report saved → {csv_path}")

    # 4. Best model plots
    best_name = report_df.sort_values("mae").iloc[0]["model"]
    best_pipeline, _, best_pred = results[best_name]
    plot_residuals(y_test, best_pred, best_name)
    plot_predictions_vs_actual(y_test, best_pred, best_name)
    plot_feature_importance(best_pipeline, FEATURE_COLS, best_name)

    # 5. Save model
    model_path = os.path.join(OUTPUT_DIR, "notification_model_best.joblib")
    joblib.dump(best_pipeline, model_path)
    print(f"  🏆 Best model ({best_name}) saved → {model_path}")

    # 6. Demo prediction
    demo_user = {
        "commute_time_minutes":  510,   # 8:30 AM
        "day_of_week":           0,     # Monday
        "past_acceptance_rate":  0.65,
        "response_time_lag_min": 7.5,
        "commute_duration_min":  40,
        "overlap_score":         0.72,
    }
    opt_time = predict_optimal_time(best_pipeline, demo_user)
    print(f"\n  🔔 Demo prediction:")
    print(f"     User departs at 08:30 on Monday with 65% acceptance history")
    print(f"     → Optimal notification time: {opt_time}")

    return {"reports": report_df, "best_model_name": best_name}


if __name__ == "__main__":
    run()
