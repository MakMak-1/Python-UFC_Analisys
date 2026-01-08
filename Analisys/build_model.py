from sqlalchemy import create_engine
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from urllib.parse import quote_plus
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV

# Create the connection string
username = "administrator"
password = "administrator"
server = "DESKTOP-MLG7MPI\MSSQLSERVER01"
database = "UFCStorage"

# Properly encode the connection string
params = quote_plus(
    f"DRIVER=ODBC Driver 17 for SQL Server;"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

query = """
SELECT * 
FROM 
(
	SELECT fightID, fighterRedID, fighterBlueID, winner 
	FROM fact_Fight
) AS t
INNER JOIN 
(
	SELECT 
		fighterID, wins as rWins, losses as rLosses, draws as rDraws, 
		height as rHeight, reach as rReach, weight as rWeight,
		stanceID as rStanceID,
		sigStrAcc as rSigStrAcc, sigStrDef as rSigStrDef, 
		tdAcc as rTdAcc, tdDef as rTdDef, avgSubAtt as rAvgSubAtt,
		dateOfBirth as rDOB
	FROM dim_Fighter
) AS r
ON fighterRedID = r.fighterID
INNER JOIN 
(
	SELECT 
		fighterID, wins as bWins, losses as bLosses, draws as bDraws, 
		height as bHeight, reach as bReach, weight as bWeight,
		stanceID as bStanceID,
		sigStrAcc as bSigStrAcc, sigStrDef as bSigStrDef, 
		tdAcc as bTdAcc, tdDef as bTdDef, avgSubAtt as bAvgSubAtt,
		dateOfBirth as bDOB
	FROM dim_Fighter
) AS b
ON fighterBlueID = b.fighterID

SELECT 
	fighterID, wins as rWins, losses as rLosses, draws as rDraws, 
	height as rHeight, reach as rReach, stanceID as rStanceID,
	sigStrAcc as rSigStrAcc, sigStrDef as rSigStrAcc, 
	tdAcc as rTdAcc, tdDef as rTdDef, avgSubAtt as rAvgSubAtt,
	dateOfBirth as rDOB
FROM dim_Fighter"""

df = pd.read_sql(query, engine)

df['winner'] = df['winner'].replace({'R': 1, 'B': 0})

df['rDOB'] = pd.to_datetime(df['rDOB'].dropna().astype(int).astype(str), format='%Y%m%d', errors='coerce')
df['bDOB'] = pd.to_datetime(df['bDOB'].dropna().astype(int).astype(str), format='%Y%m%d', errors='coerce')

reference_date = pd.to_datetime('2030-06-30')
df['rAge'] = (reference_date - df['rDOB']).dt.days 
df['bAge'] = (reference_date - df['bDOB']).dt.days

df['reach_diff'] = df['rReach'] - df['bReach']
df['height_diff'] = df['rHeight'] - df['bHeight']
df['weight_diff'] = df['rWeight'] - df['bWeight']

df['sig_str_acc_diff'] = df['rSigStrAcc'] - df['bSigStrAcc']
df['sig_str_def_diff'] = df['rSigStrDef'] - df['bSigStrDef']
df['td_acc_diff'] = df['rTdAcc'] - df['bTdAcc']
df['td_def_diff'] = df['rTdDef'] - df['bTdDef']

df['sub_att_diff'] = df['rAvgSubAtt'] - df['bAvgSubAtt']
df['experience_diff'] = (df['rWins'] + df['rLosses'] + df['rDraws']) - (df['bWins'] + df['bLosses'] + df['bDraws'])
df['win_ratio_diff'] = (df['rWins'] / (df['rWins'] + df['rLosses'] + 1)) - (df['bWins'] / (df['bWins'] + df['bLosses'] + 1))

df['age_days_diff'] = df['rAge'] - df['bAge']
df['age_days_diff'] = df['age_days_diff'].fillna(df['age_days_diff'].median())

columns_to_drop = [col for col in df.columns if col.startswith('r') or col.startswith('b')]
X = df.drop(columns=columns_to_drop + ['fightID', 'fighterRedID', 'fighterBlueID', 'fighterID', 'winner'])
y = df['winner']

for i in range(len(X)):
    if np.random.randint(1, 3) == 1:
        continue

    X.loc[i] = -X.loc[i]
    y.loc[i] = 1 - y.loc[i]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

pipe = Pipeline([
    ('scaler', StandardScaler()),  # This step can be turned on/off
    ('logreg', LogisticRegression())
])

params = {
    'scaler': [StandardScaler(), 'passthrough'],
    'logreg__penalty': ['l1', 'l2'],
    'logreg__C': [0.001, 0.01, 0.1, 1, 10, 100],
    'logreg__solver': ['lbfgs', 'liblinear'],
    'logreg__max_iter': [2000]
}

logreg = LogisticRegression(random_state=42)
logreg_grid = GridSearchCV(pipe, params, scoring='accuracy')
logreg_grid.fit(X_train, y_train)
model = logreg_grid.best_estimator_

def find_odds_diff(fighter1, fighter2, model):
    query = f"""
    select *
    from
    (
    select 
    	wins as rWins, losses as rLosses, draws as rDraws, 
    	height as rHeight, reach as rReach, weight as rWeight,
    	stanceID as rStanceID,
    	sigStrAcc as rSigStrAcc, sigStrDef as rSigStrDef, 
    	tdAcc as rTdAcc, tdDef as rTdDef, avgSubAtt as rAvgSubAtt,
    	dateOfBirth as rDOB
    from dim_Fighter
    where name = '{fighter1}'
    ) as r,
    (
    select 
    	wins as bWins, losses as bLosses, draws as bDraws, 
    	height as bHeight, reach as bReach, weight as bWeight,
    	stanceID as bStanceID,
    	sigStrAcc as bSigStrAcc, sigStrDef as bSigStrDef, 
    	tdAcc as bTdAcc, tdDef as bTdDef, avgSubAtt as bAvgSubAtt,
    	dateOfBirth as bDOB
    from dim_Fighter
    where name = '{fighter2}'
    ) as b
    """
    fight = pd.read_sql(query, engine)
    
    fight['rDOB'] = pd.to_datetime(fight['rDOB'].dropna().astype(int).astype(str), format='%Y%m%d', errors='coerce')
    fight['bDOB'] = pd.to_datetime(fight['bDOB'].dropna().astype(int).astype(str), format='%Y%m%d', errors='coerce')

    reference_date = pd.to_datetime('2030-06-30')
    fight['rAge'] = (reference_date - fight['rDOB']).dt.days 
    fight['bAge'] = (reference_date - fight['bDOB']).dt.days 

    X_fight = pd.DataFrame()
    X_fight['height_diff'] = fight['rHeight'] - fight['bHeight']
    X_fight['weight_diff'] = fight['rWeight'] - fight['bWeight']

    X_fight['sig_str_acc_diff'] = fight['rSigStrAcc'] - fight['bSigStrAcc']
    X_fight['sig_str_def_diff'] = fight['rSigStrDef'] - fight['bSigStrDef']
    X_fight['td_acc_diff'] = fight['rTdAcc'] - fight['bTdAcc']
    X_fight['td_def_diff'] = fight['rTdDef'] - fight['bTdDef']
    
    X_fight['sub_att_diff'] = fight['rAvgSubAtt'] - fight['bAvgSubAtt']
    X_fight['experience_diff'] = (fight['rWins'] + fight['rLosses'] + fight['rDraws']) - (fight['bWins'] + fight['bLosses'] + fight['bDraws'])
    X_fight['win_ratio_diff'] = (fight['rWins'] / (fight['rWins'] + fight['rLosses'] + 1)) - (fight['bWins'] / (fight['bWins'] + fight['bLosses'] + 1))
    
    X_fight['age_days_diff'] = fight['rAge'] - fight['bAge']
    X_fight['age_days_diff'] = X_fight['age_days_diff'].fillna(df['age_days_diff'].median())

    probs = model.predict_proba(X_fight)
    return probs[0][1] - probs[0][0]

print(find_odds_diff('Jon Jones', 'Tom Aspinall', model))
print(find_odds_diff('Jon Jones', 'Max Holloway', model))