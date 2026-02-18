# CommuteSync AI — Ideathon Demo

> **Smart Carpooling Powered by 4 AI Models**

CommuteSync uses machine learning to intelligently match commuters in Delhi, suggest optimal meeting points, predict whether users will accept suggestions, and time notifications for maximum impact.

---

## 🏗️ Project Structure

```
CommuteSync_AI_Demo/
├── data/
│   ├── generate_dataset.py       ← Synthetic dataset generator
│   └── dummy_commute_data.csv    ← 5,000 user synthetic dataset
├── models/
│   ├── commute_overlap_model.py  ← Model 1: Overlap clustering
│   ├── meeting_point_model.py    ← Model 2: Meeting point suggestion
│   ├── acceptance_prediction_model.py ← Model 3: Acceptance prediction
│   └── notification_timing_model.py   ← Model 4: Notification timing
├── utils/
│   ├── geo_utils.py              ← Haversine, centroid, normalization
│   └── evaluation_metrics.py    ← Reusable metrics for all models
├── outputs/
│   ├── cluster_visuals/          ← Cluster maps & matched pair plots
│   ├── meeting_point_maps/       ← Per-group meeting point maps
│   └── model_reports/            ← CSVs, charts, saved models (.joblib)
├── notebooks/
│   └── demo_visualization.ipynb ← Jupyter demo notebook
├── run_all.py                    ← Master pipeline (runs everything)
└── requirements.txt
```

---

## 🚀 Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run the full pipeline
python run_all.py

# Or run individual models
python models/commute_overlap_model.py
python models/meeting_point_model.py
python models/acceptance_prediction_model.py
python models/notification_timing_model.py
```

---

## 🤖 Model Details

### Model 1 — Commute Overlap Prediction

| Item | Detail |
|---|---|
| Algorithm | DBSCAN (HDBSCAN if installed) |
| Features | home lat/lon + commute time (normalized) |
| Evaluation | Silhouette Score, Davies–Bouldin Index |
| Output | Cluster labels + matched pair CSV |

Uses `normalize_coords_for_clustering()` to combine spatial and temporal dimensions into a unified feature space. DBSCAN finds dense regions of users who live near each other AND depart at similar times.

**Outputs:** `outputs/cluster_visuals/cluster_map.png`, `matched_pairs.png`, `matched_pairs.csv`

---

### Model 2 — Optimal Meeting Point Suggestion

| Item | Detail |
|---|---|
| Algorithm | Geographic centroid + Delhi transit hub ranking |
| Scoring | avg distance, fairness (std/mean), max distance |
| Visualization | Static matplotlib map + folium HTML (if available) |

For each matched group, the model evaluates the geographic centroid and 12 known Delhi transit hubs as meeting point candidates, scoring each on proximity, fairness, and accessibility.

**Outputs:** `outputs/meeting_point_maps/meeting_point_group_N.png`

---

### Model 3 — User Acceptance Prediction

| Item | Detail |
|---|---|
| Task | Binary classification (accept / decline) |
| Algorithms | Logistic Regression, Random Forest, Gradient Boosting, XGBoost* |
| Tuning | GridSearchCV (3-fold StratifiedKFold) on Random Forest |
| Metrics | Accuracy, Precision, Recall, F1, ROC-AUC |

**Features used:**
- `overlap_score` — spatial-temporal similarity
- `time_diff_minutes` — commute time alignment
- `dist_home_office_km` — route length
- `past_acceptance_rate` — user history
- `commute_duration_min` — trip time
- `day_of_week` — weekday effect

**Outputs:** `outputs/model_reports/acceptance_roc_curves.png`, `acceptance_model_comparison.csv`, `acceptance_model_best.joblib`

---

### Model 4 — Notification Timing Optimization

| Item | Detail |
|---|---|
| Task | Regression (predict optimal notification minutes) |
| Algorithms | Ridge Regression (baseline), Gradient Boosting, XGBoost* |
| Metrics | MAE, RMSE |

Predicts the optimal time (minutes since midnight) to send a carpool notification so the user is most likely to be available and receptive.

**Example:** User departs at 08:30 on Monday → suggested notification: **07:22**

**Outputs:** `outputs/model_reports/notification_timing_residuals.png`, `notification_timing_predictions.png`, `notification_model_best.joblib`

---

## 📊 Dataset

`dummy_commute_data.csv` — 5,000 synthetic Delhi commuters:

| Column | Description |
|---|---|
| `user_id` | Unique identifier (U00000–U04999) |
| `home_lat/lon` | Random coordinates within Delhi bounding box |
| `office_lat/lon` | Random destination coordinates |
| `commute_time` | Departure time (HH:MM), 07:00–10:30 |
| `commute_time_minutes` | Numeric departure time |
| `overlap_score` | Spatial-temporal overlap with neighbors (0–1) |
| `time_diff_minutes` | Time gap from nearest match |
| `accepted` | Binary: did user accept carpool suggestion? |
| `past_acceptance_rate` | Historical acceptance rate |
| `optimal_notify_minutes` | Ground truth for Model 4 |
| `day_of_week` | 0=Monday, 6=Sunday |
| `response_time_lag_min` | How fast user typically responds |

---

## 🛠️ Tech Stack

| Library | Role |
|---|---|
| `pandas`, `numpy` | Data manipulation |
| `scikit-learn` | DBSCAN, classification, regression, GridSearchCV |
| `xgboost` | Gradient boosted trees (optional) |
| `hdbscan` | Density-based clustering (optional) |
| `matplotlib`, `seaborn` | Static visualizations |
| `folium` | Interactive maps (optional) |
| `joblib` | Model serialization |

`*` = optional dependency; graceful fallback if not installed

---

## 📁 Outputs Reference

```
outputs/
├── cluster_visuals/
│   ├── cluster_map.png           ← Color-coded user clusters
│   ├── matched_pairs.png         ← Lines between matched users
│   └── matched_pairs.csv         ← Detailed match data
├── meeting_point_maps/
│   ├── meeting_point_group_0.png ← Group 0 map
│   ├── meeting_point_group_1.png
│   └── meeting_point_group_2.png
└── model_reports/
    ├── acceptance_model_comparison.csv
    ├── acceptance_model_comparison_chart.png
    ├── acceptance_roc_curves.png
    ├── acceptance_feature_importance.png
    ├── acceptance_model_best.joblib
    ├── notification_timing_report.csv
    ├── notification_timing_residuals.png
    ├── notification_timing_predictions.png
    ├── notification_feature_importance.png
    └── notification_model_best.joblib
```

---

*Built for Ideathon 2025 — CommuteSync Team*
