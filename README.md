# 📊 HR Attrition Prediction & Risk Segmentation

## 🔍 Overview
Employee attrition is a critical business problem impacting cost, productivity, and organizational stability.  
This project builds a predictive model to identify employees at risk of leaving and translates insights into actionable HR strategies.

---

## 📁 Dataset
- **1470 employee records | 23 features**
- Includes:
  - Demographics (Age, Gender, DistanceFromHome)
  - Job details (Department, JobRole, BusinessTravel)
  - Compensation (MonthlyIncome, StockOptionLevel)
  - Satisfaction metrics (JobSatisfaction, WorkLifeBalance)
- **Target Variable:** Attrition (0 = No, 1 = Yes)  
- **Imbalance:** ~16% attrition rate

---

## 🎯 Objective
- Predict employees likely to leave  
- Identify key drivers of attrition  
- Enable proactive, data-driven retention strategies  

---

## ⚙️ Approach

### 🔹 Data Preparation
- Data validation (missing values, duplicates)
- Feature engineering:
  - Tenure segments
  - Income segments
  - High-risk flag

### 🔹 Modeling
- Logistic Regression ✅ *(Final Model)*
- Random Forest
- XGBoost

### 🔹 Optimization
- Class imbalance handling
- **Threshold tuning (focus on recall)**

### 🔹 Evaluation
- ROC-AUC
- Confusion Matrix
- Classification metrics

### 🔹 Explainability
- SHAP analysis to identify key drivers

### 🔹 Business Output
- Risk segmentation:
  - Low Risk
  - Medium Risk
  - High Risk

---

## 🏆 Key Results

| Metric | Logistic Regression |
|-------|--------------------|
| ROC-AUC | ~0.84 |
| Recall (Attrition) | **~87% (after tuning)** |
| Precision | ~32% |

👉 Model optimized to **maximize recall** (catch at-risk employees)

---

## 🧠 Key Insights

- **OverTime** is the strongest predictor of attrition  
- Low income and early tenure significantly increase risk  
- Job satisfaction and work environment play a key role  
- Dataset shows **strong linear relationships**, making Logistic Regression most effective  

---

## 📊 Risk Segmentation

Employees are categorized based on predicted probability:

- **High Risk (~8–10%)** → Immediate action  
- **Medium Risk (~15–20%)** → Monitor & engage  
- **Low Risk (~70%+)** → Stable  

---

## 💼 Business Recommendations

- Reduce excessive overtime workload  
- Improve onboarding for early-tenure employees  
- Optimize compensation for high-risk groups  
- Deploy early warning system for employees with >30% attrition risk  

---

## 🚀 Key Takeaways

- Simpler models can outperform complex ones when data is well-structured  
- Threshold tuning is critical in imbalanced classification problems  
- Predictive models should be used as **decision-support tools**, not automation  

---

## 🛠️ Tech Stack
- Python (Pandas, NumPy)
- Scikit-learn
- XGBoost
- SHAP
- Matplotlib / Seaborn

---

## 📌 Project Highlights
- End-to-end ML pipeline  
- Business-driven feature engineering  
- Threshold optimization (advanced concept)  
- Model explainability with SHAP  
- Actionable HR insights  

---

## Author
Rahul
