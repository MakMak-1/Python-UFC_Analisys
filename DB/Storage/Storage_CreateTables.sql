USE UFCStorage
GO

CREATE TABLE dim_Stance (
    stanceID INT IDENTITY(1, 1) PRIMARY KEY,
    stance VARCHAR(20) NOT NULL
);

CREATE TABLE dim_Referee (
    refereeID INT IDENTITY(1, 1) PRIMARY KEY,
    name CHAR(30) NOT NULL
);

CREATE TABLE dim_FinishType (
    finishTypeID INT IDENTITY(1, 1) PRIMARY KEY,
    finishType VARCHAR(30) NOT NULL
);

CREATE TABLE dim_Date (
    dateID INT PRIMARY KEY,
    date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL
);

-- add date
CREATE TABLE dim_Event (
    eventID INT IDENTITY(1, 1) PRIMARY KEY,
    eventName CHAR(100) NOT NULL,
    location CHAR(100) NOT NULL,
	eventDateID INT FOREIGN KEY REFERENCES dim_Date(dateID),
	ppv_buys FLOAT
);

-- add date
CREATE TABLE dim_Fighter (
    fighterID INT IDENTITY(1, 1) PRIMARY KEY,
    name CHAR(30) NOT NULL,
    nickname CHAR(30),
    wins INT,
    losses INT,
    draws INT,
    height INT,
    weight INT,
    reach INT,
    stanceID INT FOREIGN KEY REFERENCES dim_Stance(stanceID),
    sigStrAcc INT,
    sigStrDef INT,
    tdAcc INT,
    tdDef INT,
    avgSubAtt INT,
	dateOfBirth INT FOREIGN KEY REFERENCES dim_Date(dateID),
);

-- remove date
CREATE TABLE fact_Fight (
    fightID INT IDENTITY(1, 1) PRIMARY KEY,
    eventID INT FOREIGN KEY REFERENCES dim_Event(eventID),
    refereeID INT FOREIGN KEY REFERENCES dim_Referee(refereeID),
    finishTypeID INT FOREIGN KEY REFERENCES dim_FinishType(finishTypeID),
    fighterRedID INT FOREIGN KEY REFERENCES dim_Fighter(fighterID),
    fighterBlueID INT FOREIGN KEY REFERENCES dim_Fighter(fighterID),
    winner CHAR(1) CHECK (winner IN ('R', 'B', 'D')), -- R = Red, B = Blue, D = Draw
    totalRounds INT,
    finishRound INT,
    finishTime INT,
    
    -- Red Corner Stats
    rSigStr INT, -- significant strikes amount
    rSigStrAtt INT, -- significant strikes attempts
    rSigStrAcc DECIMAL(5,2), -- significant strikes accuracy
    rStr INT, -- strikes amount
    rStrAtt INT, -- strikes attempts
    rStrAcc DECIMAL(5,2), -- strikes accuracy
    rTd INT, -- takedowns amount
    rTdAtt INT, -- takedowns attempts
    rTdAcc DECIMAL(5,2), -- takedown accuracy
    rSubAtt INT, -- submission attempts

    -- Blue Corner Stats
    bSigStr INT, -- significant strikes amount
    bSigStrAtt INT, -- significant strikes attempts
    bSigStrAcc DECIMAL(5,2), -- significant strikes accuracy
    bStr INT, -- strikes amount
    bStrAtt INT, -- strikes attempts
    bStrAcc DECIMAL(5,2), -- strikes accuracy
    bTd INT, -- takedowns amount
    bTdAtt INT, -- takedowns attempts
    bTdAcc DECIMAL(5,2), -- takedown accuracy
    bSubAtt INT -- submission attempts
);