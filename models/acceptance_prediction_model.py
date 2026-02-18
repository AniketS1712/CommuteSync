"""
acceptance_prediction_model.py
-------------------------------
Model 3: User Acceptance Prediction
-------------------------------------
Predicts whether a user will accept a carpool suggestion.

Features:
  - overlap_score         : spatial-temporal overlap between user pairs
  - time_diff_minutes     : difference in commute times
  - dist_home_office_km   : distance from home to office
  - past_acceptance_rate  : historical acceptance rate
  - commute_duration_min  : estimated travel time

Target: accepted (0 or 1)

Models trained & compared:
  - Logistic Regression
  - Random Forest (with GridSearchCV)
  - XGBoost (if available)

Outputs:
  - model_reports/acceptance_model_comparison.csv
  - model_reports/acceptance_roc_curves.png
  - model_reports/acceptance_feature_importance.png
"""

import os
import sys
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

from sklearn.model_selection import train_test_split, GridSearchCV, StratifiedKFold
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.metrics import roc_curve, auc

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from utils.evaluation_metrics import classification_report_dict, print_classification_report

try:
    import xgboost as xgb
    HAS_XGB = True
except ImportError:
    HAS_XGB = False

DATA_PATH  = os.path.join(os.path.dirname(__file__), "..", "data", "dummy_commute_data.csv")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs", "model_reports")
MODELS_DIR = os.path.join(os.path.dirname(__file__), "..", "outputs", "model_reports")
os.makedirs(OUTPUT_DIR, exist_ok=True)

FEATURE_COLS = [
    "overlap_score",
    "time_diff_minutes",
    "dist_home_office_km",
    "past_acceptance_rate",
    "commute_duration_min",
    "day_of_week",
]
TARGET_COL = "accepted"


def load_and_prepare(path: str):
    """Load CSV, select features and target, split into train/test."""
    df = pd.read_csv(path)
    X = df[FEATURE_COLS].copy()
    y = df[TARGET_COL].copy()
    return train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)


def build_models():
    """
    Return a dict of model pipelines to train and compare.
    Each pipeline = StandardScaler + Classifier.
    """
    models = {
        "Logistic Regression": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", LogisticRegression(max_iter=500, random_state=42, C=1.0))
        ]),
        "Random Forest": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", RandomForestClassifier(n_estimators=200, max_depth=8,
                                            min_samples_leaf=10, random_state=42, n_jobs=-1))
        ]),
        "Gradient Boosting": Pipeline([
            ("scaler", StandardScaler()),
            ("clf", GradientBoostingClassifier(n_estimators=150, learning_rate=0.08,
                                                max_depth=4, random_state=42))
        ]),
    }
    if HAS_XGB:
        models["XGBoost"] = Pipeline([
            ("scaler", StandardScaler()),
            ("clf", xgb.XGBClassifier(
                n_estimators=200, learning_rate=0.08, max_depth=5,
                use_label_encoder=False, eval_metric="logloss",
                random_state=42, n_jobs=-1
            ))
        ])
    return models


def tune_random_forest(X_train, y_train) -> RandomForestClassifier:
    """
    Run GridSearchCV on Random Forest for hyperparameter tuning.
    Returns best estimator (without scaler for feature importance access).
    """
    print("  🔧 Tuning Random Forest with GridSearchCV …")
    param_grid = {
        "n_estimators": [100, 200],
        "max_depth":    [5, 8, None],
        "min_samples_leaf": [5, 10],
    }
    cv = StratifiedKFold(n_splits=3, shuffle=True, random_state=42)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_train)

    rf = RandomForestClassifier(random_state=42, n_jobs=-1)
    gs = GridSearchCV(rf, param_grid, cv=cv, scoring="roc_auc", n_jobs=-1, verbose=0)
    gs.fit(X_scaled, y_train)

    print(f"     Best params : {gs.best_params_}")
    print(f"     Best CV AUC : {gs.best_score_:.4f}")
    return gs.best_estimator_, scaler


def plot_roc_curves(results: dict, X_test, y_test):
    """Plot ROC curves for all models."""
    fig, ax = plt.subplots(figsize=(9, 7))
    ax.plot([0, 1], [0, 1], "k--", lw=1.2, label="Random (AUC = 0.50)")

    for name, (model, report) in results.items():
        if hasattr(model, "predict_proba"):
            proba = model.predict_proba(X_test)[:, 1]
        else:
            proba = model.decision_function(X_test)
        fpr, tpr, _ = roc_curve(y_test, proba)
        roc_auc_val = auc(fpr, tpr)
        ax.plot(fpr, tpr, lw=2, label=f"{name} (AUC = {roc_auc_val:.4f})")

    ax.set_xlabel("False Positive Rate", fontsize=12)
    ax.set_ylabel("True Positive Rate", fontsize=12)
    ax.set_title("ROC Curves — Acceptance Prediction Models", fontsize=13, fontweight="bold")
    ax.legend(loc="lower right", fontsize=10)
    ax.grid(alpha=0.3)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "acceptance_roc_curves.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📈 ROC curves saved → {path}")


def plot_feature_importance(rf_model, feature_names: list):
    """Bar chart of Random Forest feature importances."""
    importances = rf_model.feature_importances_
    indices = np.argsort(importances)[::-1]
    sorted_features = [feature_names[i] for i in indices]
    sorted_imp       = importances[indices]

    fig, ax = plt.subplots(figsize=(9, 5))
    colors = sns.color_palette("Blues_r", len(sorted_features))
    ax.barh(sorted_features[::-1], sorted_imp[::-1], color=colors[::-1])
    ax.set_xlabel("Importance", fontsize=11)
    ax.set_title("Random Forest — Feature Importances", fontsize=13, fontweight="bold")
    ax.grid(axis="x", alpha=0.3)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "acceptance_feature_importance.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📊 Feature importance chart saved → {path}")


def plot_comparison_bar(report_df: pd.DataFrame):
    """Side-by-side bar chart comparing model metrics."""
    metrics = ["accuracy", "precision", "recall", "f1_score", "roc_auc"]
    metrics = [m for m in metrics if m in report_df.columns]
    
    report_df_plot = report_df.set_index("model")[metrics]
    ax = report_df_plot.plot(kind="bar", figsize=(12, 6), colormap="Set2", edgecolor="white")
    ax.set_title("Model Comparison — Acceptance Prediction", fontsize=13, fontweight="bold")
    ax.set_ylabel("Score")
    ax.set_xticklabels(ax.get_xticklabels(), rotation=20, ha="right")
    ax.set_ylim(0, 1.05)
    ax.legend(loc="upper right", fontsize=9)
    ax.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, "acceptance_model_comparison_chart.png")
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  📊 Model comparison chart saved → {path}")


def run() -> dict:
    """Main pipeline for Model 3."""
    print("\n" + "="*60)
    print("  MODEL 3: User Acceptance Prediction")
    print("="*60)

    # 1. Data
    X_train, X_test, y_train, y_test = load_and_prepare(DATA_PATH)
    print(f"  Train: {len(X_train)} | Test: {len(X_test)}")
    print(f"  Acceptance rate (train): {y_train.mean():.2%}")

    # 2. Tune RF separately for feature importance extraction
    best_rf, rf_scaler = tune_random_forest(X_train, y_train)

    # 3. Train all models
    models = build_models()
    results = {}

    for name, pipeline in models.items():
        print(f"\n  Training {name} …")
        pipeline.fit(X_train, y_train)
        y_pred = pipeline.predict(X_test)
        y_prob = pipeline.predict_proba(X_test)[:, 1] if hasattr(pipeline, "predict_proba") else None
        report = classification_report_dict(y_test, y_pred, y_prob)
        print_classification_report(name, report)
        results[name] = (pipeline, report)

    # 4. Save comparison table
    rows = [{"model": name, **report} for name, (_, report) in results.items()]
    report_df = pd.DataFrame(rows)
    csv_path = os.path.join(OUTPUT_DIR, "acceptance_model_comparison.csv")
    report_df.to_csv(csv_path, index=False)
    print(f"\n  💾 Report saved → {csv_path}")

    # 5. Plots
    plot_roc_curves(results, X_test, y_test)
    plot_feature_importance(best_rf, FEATURE_COLS)
    plot_comparison_bar(report_df)

    # 6. Save best model
    best_name = report_df.sort_values("roc_auc", ascending=False).iloc[0]["model"]
    best_pipeline = results[best_name][0]
    model_path = os.path.join(MODELS_DIR, "acceptance_model_best.joblib")
    joblib.dump(best_pipeline, model_path)
    print(f"  🏆 Best model ({best_name}) saved → {model_path}")

    return {"reports": report_df, "best_model_name": best_name}


if __name__ == "__main__":
    run()
