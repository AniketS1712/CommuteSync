# CommuteSync — Smart Carpooling with AI

> **Intelligent Commuter Matching Powered by Machine Learning**

CommuteSync is a full-stack application combining a **Flutter mobile frontend** with **AI** to intelligently match commuters in Delhi, suggest optimal meeting points, predict acceptance rates, and optimize notification timing for maximum engagement.

**Tech Stack:**
- **Frontend:** Flutter (Android & iOS)
- **Backend:** Python FastAPI / Flask (voice authentication & API)
- **ML:** scikit-learn, XGBoost, TensorFlow

---

## 🏗️ Project Structure

```
CommuteSync/
├── lib/                          ← Flutter frontend (Dart)
│   ├── screens/                  ← UI screens
│   ├── models/                   ← Dart data models
│   ├── widgets/                  ← Reusable widgets
│   └── services/                 ← API calls to backend
├── android/                      ← Android native config
├── ios/                          ← iOS native config
├── web/                          ← Web version (Flutter)
├── backend/                      ← Python API Server
│   ├── main.py                   ← FastAPI/Flask server
│   ├── models/                   ← ML classifiers
│   ├── utils/                    ← Helper utilities
│   ├── dataset/                  ← Training data
│   ├── tests/                    ← Unit tests
│   └── requirements.txt
├── data/                         ← Datasets
│   ├── dummy_commute_data.csv    ← 500 synthetic Delhi users
│   ├── matched_pairs.csv         ← Clustered matches
│   ├── meeting_points.csv        ← Optimal pickup points
│   ├── acceptance_dataset.csv    ← Training data (Model 3)
│   └── optimal_notification_times.csv ← Timing predictions (Model 4)
├── models/                       ← AI Model Implementations
│   ├── commute_overlap_model.py  ← Model 1: Route clustering
│   ├── meeting_point_model.py    ← Model 2: Meeting point suggestion
│   ├── acceptance_prediction_model.py ← Model 3: Acceptance prediction
│   ├── notification_timing_model.py   ← Model 4: Notification timing
│   ├── weights/                  ← Trained model artifacts (.joblib)
│   └── __init__.py
├── utils/                        ← Shared utilities
│   ├── geo_utils.py              ← Haversine distance, clustering helpers
│   └── __init__.py
├── notebooks/                    ← Analysis & visualization
│   ├── commute_overlap_map.html  ← Interactive clusters (Folium)
│   └── meeting_points_map.html   ← Meeting points visualization
├── generate_dataset.py           ← Synthetic dataset generator
├── run_all.py                    ← Master pipeline (runs all models)
├── pubspec.yaml                  ← Flutter dependencies
├── requirements.txt              ← Python dependencies
└── README.md                     ← This file
```

---

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** (for mobile/web)
- **Python 3.8+** (for AI models & backend)
- **Git**

### Installation

#### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/CommuteSync.git
cd CommuteSync
```

#### 2. Setup Python Environment
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### 3. Setup Flutter (Optional for frontend development)
```bash
flutter pub get
flutter run  # Run on emulator/device
```

### Run the AI Pipeline
```bash
# Generate synthetic dataset (500 Delhi commuters)
python generate_dataset.py

# Run all 4 AI models
python run_all.py

# Or run individual models
python models/commute_overlap_model.py
python models/acceptance_prediction_model.py
python models/meeting_point_model.py
python models/notification_timing_model.py
```

### Start Backend Server (if applicable)
```bash
cd backend
python main.py  # Starts API on http://localhost:8000
```

---

## 🤖 AI Models Overview

### Model 1 — Commute Overlap Clustering
**Goal:** Find users with overlapping home locations & departure times

| Aspect | Details |
|---|---|
| Algorithm | K-Means clustering on normalized geo-temporal features |
| Features | home_lat, home_lon, office_lat, office_lon, commute_time_minutes |
| Output | Cluster assignments, matched pairs CSV, Folium map |
| Key Metric | Silhouette Score |

**Outputs:** 
- `data/matched_pairs.csv` — Users with high overlap
- `notebooks/commute_overlap_map.html` — Interactive cluster visualization
- `models/weights/commute_overlap_*.joblib` — Trained KMeans + scaler

---

### Model 2 — Optimal Meeting Point Suggestion
**Goal:** Suggest fair pickup points for commuter groups

| Aspect | Details |
|---|---|
| Algorithm | Geographic centroid calculation + proximity scoring |
| Scoring | Average detour distance, fairness (std/mean), accessibility |
| Output | Pickup/dropoff coordinates, landmark names (via Nominatim) |

**Outputs:**
- `data/meeting_points.csv` — Meeting coordinates & detour distances
- `notebooks/meeting_points_map.html` — Visual routes to pickup points
- `models/weights/meeting_points_data.joblib` — Computed meeting points

---

### Model 3 — Acceptance Prediction
**Goal:** Predict if a user will accept a carpool suggestion (Binary Classification)

| Aspect | Details |
|---|---|
| Algorithms | Random Forest, Logistic Regression |
| Features | overlap_score, time_diff_min, past_acceptance_rate, home_dist_km, office_dist_km |
| Metrics | Accuracy, Precision, Recall, F1, ROC-AUC |
| Tuning | Hyperparameter optimization via GridSearchCV |

**Outputs:**
- `data/acceptance_dataset.csv` — Training labels
- `models/weights/acceptance_*.joblib` — RF + LR models + scaler
- `notebooks/acceptance_evaluation.png` — Confusion matrices & ROC curves

---

### Model 4 — Notification Timing Optimization
**Goal:** Predict the best time to send notifications (Regression)

| Aspect | Details |
|---|---|
| Algorithms | Gradient Boosting, Ridge Regression |
| Target | Optimal notification time (minutes from midnight) |
| Features | commute_time_minutes, past_avg_response, day_of_week, sent_time_minutes, response_std |
| Metrics | MAE (Mean Absolute Error), RMSE, R² |

**Example:** User usually departs 08:30 → Send notification at **07:22** (68 min before)

**Outputs:**
- `data/optimal_notification_times.csv` — Per-user optimal times
- `models/weights/notification_*.joblib` — GBR + Ridge models + scaler
- `notebooks/notification_timing_evaluation.png` — Prediction accuracy plots

---

## 📊 Dataset

**`dummy_commute_data.csv`** — 500 synthetic Delhi area commuters

| Column | Description | Example |
|---|---|---|
| `user_id` | Unique identifier | "U001" |
| `home_lat` | Home latitude (Delhi NCR) | 28.6139 |
| `home_lon` | Home longitude | 77.2090 |
| `office_lat` | Office latitude | 28.5355 |
| `office_lon` | Office longitude | 77.3910 |
| `commute_time` | Departure time (HH:MM) | "08:30" |
| `commute_time_minutes` | Numeric departure time | 510 |
| `past_acceptance_rate` | Historical acceptance probability | 0.75 |
| `acceptance_history` | Past 10 responses (binary string) | "1,0,1,1,1,0,1,1,0,1" |
| `avg_response_time_minutes` | Avg response time | 45 |
| `response_times` | Historical response times | "432,450,465,..." |

---

## 🛠️ Tech Stack

### Backend/ML
| Library | Purpose |
|---|---|
| `pandas`, `numpy` | Data manipulation & matrices |
| `scikit-learn` | KMeans, Logistic Regression, Random Forest |
| `matplotlib`, `seaborn` | Static visualizations |
| `folium` | Interactive maps |
| `geopy` | Reverse geocoding (landmark names) |
| `joblib` | Model persistence |
| `FastAPI` / `Flask` | REST API (optional backend) |

### Frontend
| Framework | Purpose |
|---|---|
| `Flutter` | Cross-platform mobile (Android/iOS/Web) |
| `Dart` | Flutter programming language |
| `Provider` | State management (optional) |
| `http` | API communication |

---

## 📁 Key Output Files

After running `python run_all.py`:

```
data/
├── dummy_commute_data.csv       ← Input dataset
├── matched_pairs.csv            ← Cluster outputs (Model 1)
├── meeting_points.csv           ← Suggested pickups (Model 2)
├── acceptance_dataset.csv       ← Training data (Model 3)
└── optimal_notification_times.csv ← Predictions (Model 4)

models/weights/
├── commute_overlap_kmeans.joblib   ← Model 1 weights
├── commute_overlap_scaler.joblib
├── acceptance_rf.joblib            ← Model 3 weights
├── acceptance_lr.joblib
├── acceptance_scaler.joblib
├── notification_gbr.joblib         ← Model 4 weights
├── notification_ridge.joblib
└── notification_scaler.joblib

notebooks/
├── commute_overlap_map.html     ← Interactive cluster map
└── meeting_points_map.html      ← Interactive meeting point map
```

---

## 🔧 Configuration

### Delhi Geographic Bounds
```python
DELHI_LAT_MIN, DELHI_LAT_MAX = 28.40, 28.88
DELHI_LON_MIN, DELHI_LON_MAX = 76.84, 77.35
```

### Model Parameters
- **Dataset Size:** 500 users (configurable in `generate_dataset.py`)
- **Commute Time Range:** 7:00 AM – 10:30 AM
- **Cluster Centers:** 12 home + 8 office locations across Delhi NCR

---

## 📝 Usage Examples

### Load and Use a Pre-trained Model
```python
import joblib
import pandas as pd

# Load the Random Forest acceptance model
rf_model = joblib.load("models/weights/acceptance_rf.joblib")
scaler = joblib.load("models/weights/acceptance_scaler.joblib")

# Predict acceptance for a new pair
features = [[0.75, 10, 0.8, 2.5, 1.2]]  # overlap, time_diff, acceptance_rate, home_dist, office_dist
probability = rf_model.predict_proba(features)[0][1]
print(f"Acceptance probability: {probability:.1%}")
```

### Call Backend API
```dart
// Flutter example
final response = await http.post(
  Uri.parse('http://localhost:8000/api/predict'),
  body: jsonEncode({'user_a': 'U001', 'user_b': 'U002'}),
);
```

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature`
3. **Commit** changes: `git commit -m "Add feature"`
4. **Push** to branch: `git push origin feature/your-feature`
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

*Built for smart urban mobility. Last updated: February 2026.*


