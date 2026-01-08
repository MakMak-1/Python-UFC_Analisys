# UFC Fight Result Prediction

This project focuses on predicting the outcomes of **UFC (Ultimate Fighting Championship)** matches based on historical statistical data and fighter attributes.

## Project Overview

The primary objective is to build a classification model capable of forecasting fight winners by identifying patterns in fighter statistics-such as height, weight, reach, and historical performance-and using them as predictors.

### Key Tasks:
* **Data Warehouse Design:** Implementing a data warehouse using a **Snowflake topology** with at least one fact table (`fact_Fight`) and multiple dimension tables (`dim_Fighter`, `dim_Event`, etc.).
* **Stage Zone Implementation:** Designing and implementing a staging area to facilitate clean data ingestion.
* **ETL Implementation:** Automating the extraction, transformation, and loading of data from five distinct sources using SQL procedures and Python scripts.
* **Feature Engineering:** Calculating relative differences between fighter parameters (e.g., `reach_diff`, `height_diff`, `win_ratio_diff`) to improve predictive accuracy and reduce predictor correlation.
* **Predictive Modeling:** Developing and evaluating machine learning models for binary classification to predict the winner.

---

## Technology Stack

* **Database Management:** Microsoft SQL Server Management Studio (SSMS).
* **Programming Language:** Python.
* **Key Libraries:**
    * `pandas` and `numpy`: For data manipulation and processing.
    * `BeautifulSoup` and `requests`: For web scraping.
    * `scikit-learn`: For machine learning models, hyperparameter tuning (GridSearchCV), and metrics.
    * `sqlalchemy`: For database connectivity.

---

## Data Sources

The project integrates data from five primary sources:
1.  **UFC Fights (1996–2024):** Complete match dataset from Kaggle.
2.  **UFC Event Details:** Event history from GitHub.
3.  **Fighter Statistics:** Detailed attributes of UFC athletes from Kaggle.
4.  **PPV Buy Rates:** Historical pay-per-view performance from GitHub.
5.  **MMA Figures:** Web-scraped data from Tapology.

---

## Model Performance

Four models were trained and evaluated based on metrics such as Accuracy, Precision, Recall, and AUC:

| Model | Train Acc | Test Acc | Test AUC |
| :--- | :--- | :--- | :--- |
| **Dummy Classifier** | 0.50 | 0.50 | 0.50 |
| **K-Nearest Neighbors (KNN)** | 0.99 | 0.59 | 0.59 |
| **Logistic Regression** | **0.69** | **0.70** | **0.70** |
| **Random Forest** | 0.85 | 0.69 | 0.69 |

**Conclusion:** The **Logistic Regression** model was selected as the most effective, outperforming others in seven out of eight evaluated efficiency criteria.

---

## Practical Application

The model can be used by event organizers to ensure **fight fairness** during matchmaking. By minimizing the probability difference between two fighters, organizers can create more unpredictable, competitive, and exciting matchups.
