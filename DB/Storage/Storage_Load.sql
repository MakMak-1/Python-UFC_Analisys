USE UFCStorage
GO

-- Процедура для завантаження суддів
CREATE OR ALTER PROCEDURE LoadDimReferee
AS
BEGIN
    INSERT INTO dim_Referee (name)
	SELECT DISTINCT referee
	FROM UFCStage.dbo.Fights
	WHERE (NOT referee IS NULL) AND referee NOT IN (SELECT name FROM dim_Referee)
END;
GO

-- Процедура для завантаження стійок
CREATE OR ALTER PROCEDURE LoadDimStance
AS
BEGIN
	INSERT INTO dim_Stance (stance)
	SELECT DISTINCT stance
	FROM UFCStage.dbo.Fighters
	WHERE NOT stance IS NULL AND stance NOT IN (SELECT stance FROM dim_Stance)
END;
GO

-- Процедура для завантаження типів завершення бою
CREATE PROCEDURE LoadDimFinishType
AS
BEGIN
    INSERT INTO dim_FinishType (finishType)
	SELECT DISTINCT method
	FROM UFCStage.dbo.Fights
	WHERE NOT method IS NULL AND method NOT IN (SELECT finishType FROM dim_FinishType)
END;
GO

-- Процедура для завантаження дат
CREATE OR ALTER PROCEDURE LoadDimDate
AS
BEGIN
    INSERT INTO dim_Date (date, year, month, day, dateID)
	SELECT 
	DISTINCT eventDate, YEAR(eventDate) AS eventYear, MONTH(eventDate) AS eventMonth, DAY(eventDate) AS eventDay,
	YEAR(eventDate) * 10000 + MONTH(eventDate) * 100 + DAY(eventDate) AS dateID
	FROM 
	(
		SELECT eventDate 
		FROM UFCStage.dbo.Events
		UNION
		SELECT date_of_birth
		FROM UFCStage.dbo.Fighters
	) AS t
	WHERE NOT eventDate IS NULL AND YEAR(eventDate) * 10000 + MONTH(eventDate) * 100 + DAY(eventDate) NOT IN (SELECT dateID FROM dim_Date);
END;
GO

-- Процедура для завантаження подій
CREATE OR ALTER PROCEDURE LoadDimEvent
AS
BEGIN
    INSERT INTO dim_Event (eventName, location, eventDateID, ppv_buys)
	SELECT eventName, eventLocation, dateID, ppv_buys
	FROM UFCStage.dbo.Events
	INNER JOIN dim_Date ON eventDate = dim_Date.date
	WHERE eventName NOT IN (SELECT eventName FROM dim_Event)
END;
GO

-- Процедура для завантаження бійців
CREATE OR ALTER PROCEDURE LoadDimFighter
AS
BEGIN
    SET NOCOUNT ON;

    MERGE INTO dim_Fighter AS target
    USING (
        SELECT 
            f.fighterName, f.nickname, f.wins, f.losses, f.draws, f.height_cm,  f.weight_in_kg, f.reach_in_cm, 
            ds.stanceID, f.significant_striking_accuracy, f.significant_strike_defence, f.takedown_accuracy, 
            f.takedown_defense, f.average_submissions_attempted_per_15_minutes, dd.dateID
        FROM UFCStage.dbo.Fighters AS f
        LEFT JOIN dim_Stance AS ds ON f.stance = ds.stance
        LEFT JOIN dim_Date AS dd ON f.date_of_birth = dd.date
    ) AS source
    ON target.name = source.fighterName

    WHEN MATCHED AND (
        target.nickname <> source.nickname OR
        target.wins <> source.wins OR
        target.losses <> source.losses OR
        target.draws <> source.draws OR
        target.height <> source.height_cm OR
        target.weight <> source.weight_in_kg OR
        target.reach <> source.reach_in_cm OR
        target.stanceID <> source.stanceID OR
        target.sigStrAcc <> source.significant_striking_accuracy OR
        target.sigStrDef <> source.significant_strike_defence OR
        target.tdAcc <> source.takedown_accuracy OR
        target.tdDef <> source.takedown_defense OR
        target.avgSubAtt <> source.average_submissions_attempted_per_15_minutes OR
        target.dateOfBirth <> source.dateID
    )
    THEN
        UPDATE SET
            nickname = source.nickname,
            wins = source.wins,
            losses = source.losses,
            draws = source.draws,
            height = source.height_cm,
            weight = source.weight_in_kg,
            reach = source.reach_in_cm,
            stanceID = source.stanceID,
            sigStrAcc = source.significant_striking_accuracy,
            sigStrDef = source.significant_strike_defence,
            tdAcc = source.takedown_accuracy,
            tdDef = source.takedown_defense,
            avgSubAtt = source.average_submissions_attempted_per_15_minutes,
            dateOfBirth = source.dateID

    WHEN NOT MATCHED BY TARGET THEN
        INSERT 
        VALUES (
            source.fighterName, source.nickname, source.wins, source.losses, source.draws, source.height_cm, 
            source.weight_in_kg, source.reach_in_cm, source.stanceID, source.significant_striking_accuracy, 
            source.significant_strike_defence, source.takedown_accuracy, source.takedown_defense, 
            source.average_submissions_attempted_per_15_minutes, source.dateID
        );
END;
GO

-- Процедура для завантаження боїв
CREATE OR ALTER  PROCEDURE LoadFactFight
AS
BEGIN
    INSERT INTO fact_Fight 
	SELECT 
		eventID, refereeID, finishTypeID, 
		dim_Fighter_red.fighterID AS figterRedID, 
		dim_Fighter_blue.fighterID AS figterBlueID, 
		CASE 
			WHEN winner = 'Blue' THEN 'B'
			WHEN winner = 'Red' THEN 'R'
			WHEN winner = 'Draw' THEN 'D'
		END AS winner,
		total_rounds,
		finish_round,
		time_sec,
		r_sig_str,
		r_sig_str_att,
		r_sig_str_acc,
		r_str,
		r_str_att,
		r_str_acc,
		r_td,
		r_td_att,
		r_td_acc,
		r_sub_att,
		b_sig_str,
		b_sig_str_att,
		b_sig_str_acc,
		b_str,
		b_str_att,
		b_str_acc,
		b_td,
		b_td_att,
		b_td_acc,
		b_sub_att
	FROM UFCStage.dbo.Fights
	LEFT JOIN dim_Event ON event_name = eventName
	LEFT JOIN dim_Referee ON referee = dim_Referee.name
	LEFT JOIN dim_FinishType ON method = finishType
	LEFT JOIN dim_Fighter ON r_fighter = dim_Fighter.name
	LEFT JOIN dim_Fighter AS dim_Fighter_red ON r_fighter = dim_Fighter_red.name
	LEFT JOIN dim_Fighter AS dim_Fighter_blue ON b_fighter = dim_Fighter_blue.name
	WHERE NOT EXISTS
	(
		SELECT 1
		FROM fact_Fight AS f
		WHERE f.eventID = dim_Event.eventID AND f.fighterRedID = dim_Fighter_red.fighterID AND f.fighterBlueID = dim_Fighter_blue.fighterID
	) AND NOT dim_Fighter_red.fighterID IS NULL AND NOT dim_Fighter_blue.fighterID IS NULL;
END;
GO

CREATE OR ALTER PROCEDURE LoadAllData
AS
BEGIN
    EXEC LoadDimReferee;
    EXEC LoadDimStance;
    EXEC LoadDimFinishType;
    EXEC LoadDimDate;
    EXEC LoadDimEvent;
    EXEC LoadDimFighter;
    EXEC LoadFactFight;
END;
GO