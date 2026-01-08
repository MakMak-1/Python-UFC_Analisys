This project focuses on predicting the outcomes of UFC (Ultimate Fighting Championship) matches based on historical statistical data and fighter physical attributes.



The main goal is to identify patterns in fighter statistics—such as height, weight, reach, and historical performance—to build a classification model capable of forecasting fight winners.



Key Components:
Data Warehouse Design: Implementation of a data warehouse using a Snowflake topology to store fighter, event, and match data.

ETL Processes: Automated extraction, transformation, and loading of data from multiple open sources, including handling missing values and duplicate records.

Feature Engineering: Conversion of absolute physical parameters into relative differences (e.g., reach_diff, height_diff) to reduce correlation between predictors.

Predictive Analytics: Implementation and comparison of various machine learning models to solve the binary classification task.
