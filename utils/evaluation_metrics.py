"""
evaluation_metrics.py
---------------------
Reusable evaluation functions for classification and regression models
used across CommuteSync AI components.
"""

import numpy as np
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score,
    f1_score, roc_auc_score, confusion_matrix,
    mean_absolute_error, mean_squared_error
)


def classification_report_dict(y_true, y_pred, y_prob=None) -> dict:
    """
    Compute a comprehensive classification evaluation report.

    Args:
        y_true: Ground-truth binary labels.
        y_pred: Predicted binary labels.
        y_prob: Predicted probabilities for positive class (optional, for AUC).

    Returns:
        Dictionary with accuracy, precision, recall, f1, roc_auc.
    """
    report = {
        "accuracy":  round(accuracy_score(y_true, y_pred), 4),
        "precision": round(precision_score(y_true, y_pred, zero_division=0), 4),
        "recall":    round(recall_score(y_true, y_pred, zero_division=0), 4),
        "f1_score":  round(f1_score(y_true, y_pred, zero_division=0), 4),
    }
    if y_prob is not None:
        try:
            report["roc_auc"] = round(roc_auc_score(y_true, y_prob), 4)
        except Exception:
            report["roc_auc"] = None
    return report


def regression_report_dict(y_true, y_pred) -> dict:
    """
    Compute MAE and RMSE for a regression model.

    Args:
        y_true: Ground-truth continuous values.
        y_pred: Predicted continuous values.

    Returns:
        Dictionary with mae and rmse.
    """
    mae = mean_absolute_error(y_true, y_pred)
    rmse = np.sqrt(mean_squared_error(y_true, y_pred))
    return {
        "mae":  round(float(mae), 4),
        "rmse": round(float(rmse), 4)
    }


def print_classification_report(model_name: str, report: dict):
    """Pretty-print a classification report."""
    print(f"\n{'='*50}")
    print(f"  {model_name} — Evaluation Report")
    print(f"{'='*50}")
    for k, v in report.items():
        print(f"  {k:<12}: {v}")
    print(f"{'='*50}\n")


def print_regression_report(model_name: str, report: dict):
    """Pretty-print a regression report."""
    print(f"\n{'='*50}")
    print(f"  {model_name} — Regression Evaluation")
    print(f"{'='*50}")
    for k, v in report.items():
        print(f"  {k:<6}: {v}")
    print(f"{'='*50}\n")
