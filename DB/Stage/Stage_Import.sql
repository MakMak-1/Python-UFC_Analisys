USE UFCStage
GO

BULK INSERT Fights
FROM 'D:\Documents\study\4_semester\DataAnalysis\AD1&2\datasets\Fights.csv'
WITH (
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n', 
    FIRSTROW = 2
);
GO

BULK INSERT Events
FROM 'D:\Documents\study\4_semester\DataAnalysis\ÊÐ\scripts\DB\Stage\Events.csv'
WITH (
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n', 
    FIRSTROW = 2
);
GO

BULK INSERT Fighters
FROM 'D:\Documents\study\4_semester\DataAnalysis\AD1&2\datasets\Fighters.csv'
WITH (
    FIELDTERMINATOR = ';', 
    ROWTERMINATOR = '\n', 
    FIRSTROW = 2
);
GO