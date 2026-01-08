USE UFCStage
GO

CREATE TABLE Fights (
    fight_id        INT IDENTITY(1,1) PRIMARY KEY,
    event_name      VARCHAR(255) NOT NULL,
    r_fighter       VARCHAR(255) NOT NULL,
    b_fighter       VARCHAR(255) NOT NULL,
    winner          VARCHAR(255),
    weight_class    VARCHAR(100),
    method          VARCHAR(100),
    finish_round    INT,
    total_rounds    INT,  
    time_sec        INT,
    referee         VARCHAR(255),
    
    -- Red Fighter Stats
    r_sig_str       INT,
    r_sig_str_att   INT,
    r_sig_str_acc   DECIMAL(5,2),
    r_str           INT,
    r_str_att       INT,
    r_str_acc       DECIMAL(5,2),
    r_td            INT,
    r_td_att        INT,
    r_td_acc        DECIMAL(5,2),
    r_sub_att       INT,

    -- Blue Fighter Stats
    b_sig_str       INT,
    b_sig_str_att   INT,
    b_sig_str_acc   DECIMAL(5,2),
    b_str           INT,
    b_str_att       INT ,
    b_str_acc       DECIMAL(5,2),
    b_td            INT,
    b_td_att        INT,
    b_td_acc        DECIMAL(5, 2),
    b_sub_att       INT,
);

CREATE TABLE Events (
	eventID INT IDENTITY(1, 1) PRIMARY KEY,
	eventName VARCHAR(255) NOT NULL,
	eventDate DATE,
	eventLocation VARCHAR(255),
	ppv_buys FLOAT
);

CREATE TABLE Fighters (
    fighterID INT IDENTITY(1,1) PRIMARY KEY,
    fighterName VARCHAR(255) NOT NULL,
    nickname VARCHAR(255),
    wins INT NOT NULL,
    losses INT NOT NULL,
    draws INT NOT NULL,
    height_cm FLOAT,
    weight_in_kg FLOAT,
    reach_in_cm FLOAT,
    stance VARCHAR(50),
    date_of_birth DATE, 
    significant_strikes_landed_per_minute FLOAT,
    significant_striking_accuracy FLOAT,
    significant_strikes_absorbed_per_minute FLOAT,
    significant_strike_defence FLOAT,
    average_takedowns_landed_per_15_minutes FLOAT,
    takedown_accuracy FLOAT,
    takedown_defense FLOAT,
    average_submissions_attempted_per_15_minutes FLOAT
);