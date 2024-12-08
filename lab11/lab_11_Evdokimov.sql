--use master
--go

--IF DB_ID(N'la11') IS NOT NULL
--	DROP DATABASE lab11;
--GO

--CREATE DATABASE lab11
--ON (NAME = lab11_dat, FILENAME = "C:\BD\lab11\lab11dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab11_log, FILENAME = "C:\BD\lab11\lab11log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

SET NOCOUNT ON;
USE Lab11;
GO

IF OBJECT_ID(N'matches') is NOT NULL
	DROP TABLE matches;
GO

IF OBJECT_ID(N'maps') is NOT NULL
	DROP TABLE maps;
GO

IF OBJECT_ID(N'characters') is NOT NULL
	DROP TABLE characters;
GO



IF OBJECT_ID(N'Players') is NOT NULL
	DROP TABLE players;
GO








CREATE TABLE Players
	(
	user_login varchar(20) PRIMARY KEY NOT NULL,
	Email  varchar(254) NOT NULL,
	Password varchar(30) NOT NULL,
	Donate_points int NOT NULL,
	registration_date date NOT NULL,
	CONSTRAINT CHK_registration_date
		CHECK (registration_date > CONVERT(DATE, '1/1/1990', 103)),
	);
GO

INSERT INTO Players(user_login, email, password, donate_points, registration_date)
	VALUES
		('Drew', 'breussoippauprusso-3159@yahoo.com', '-Hxe9ddAE8', 51, '12/07/2023'),
		('Kathilla', 'leiyauhefraku-4167@gmail.com', '-26eY_2bxX5', 0, '8/02/2023'),
		('Uesdemus', 'bropreibonnedda-5770@yopmail.com', '-Ed8eORDn1', 9876, '30/09/2021'),
		('Hoenic', 'fofiyannaje-7957@yopmail.com', '-927diQdOn', 22, '24/12/2022'); 
GO


CREATE TABLE Characters
	(
	Nickname varchar(45) NOT NULL PRIMARY KEY,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,
	Last_login_date date NOT NULL,
	registration_date date NOT NULL,
	user_login varchar(20) REFERENCES Players(user_login)
    );
GO

INSERT INTO Characters(Nickname, in_game_balance, race, Last_login_date, registration_date, user_login)
	VALUES
		('Uetreyn', 236236326, 'Elf', '12/07/2023','12/07/2023','Drew'),
		('gagae', 3465, 'Elf', '12/07/2023','12/07/2023','Drew'),
		('Blffiton', 2345 , 'Orc','8/02/2023','12/07/2023','Drew'),
		('Arian', 622637 , 'Human','30/09/2021','12/07/2023','Kathilla'),
		('Zani', 3245867, 'Ogre','24/12/2022','12/07/2023','Hoenic'); 
GO


CREATE TABLE Maps 
	(
	Map_code Int IDENTITY(1,1) PRIMARY KEY ,
	Map_name VARCHAR(40) NOT NULL UNIQUE,
	);
GO

INSERT INTO Maps(map_name)
	VALUES ('ChinaTown'),
	('The Great Bridge'),
	('TheDarkTown');
GO

CREATE TABLE Matches
(
	Match_code uniqueidentifier ROWGUIDCOL DEFAULT (newid()) PRIMARY KEY NOT NULL,
	Maps varchar(40) REFERENCES Maps(map_name) NOT NULL,
	Match_duration time NOT NULL,
	Game_mode varchar(15) NOT NULL,
	_Date date DEFAULT getdate() NOT NULL,
	CONSTRAINT CHK_Date
		CHECK (_Date > CONVERT(DATE, '1/1/1990', 103)),
	Result varchar(10) NOT NULL,
	Balance_change int NOT NULL,
	nickname varchar(45) REFERENCES Characters(nickname) NOT NULL
	);
GO

INSERT INTO Matches(maps, Match_duration, Game_mode, _Date, Result, Balance_change, nickname)
	VALUES 
	('The Great Bridge','00:09:52', 'Быстрый', '22/11/2023', 'Победа', +4255, 'Arian'),
	('ChinaTown','00:14:11', 'Рейтинговый', default, 'Поражение', -8765, 'Zani');
GO


IF OBJECT_ID(N'New_balance_after_match') is NOT NULL
	DROP TRIGGER New_balance_after_match;
GO

CREATE TRIGGER New_balance_after_match
ON matches
FOR INSERT
AS 
	UPDATE Characters 
	SET In_game_balance = In_game_balance + summedvalue
	FROM Characters
	JOIN (
		SELECT SUM(Balance_change) as summedvalue, Nickname AS Name
		FROM Matches GROUP BY Nickname
		) s on characters.nickname = Name
GO

select * FROM matches

SELECT * FROM PLAYERS
GO

SELECT * FROM MAPS
GO
SELECT * FROM Characters
GO;

INSERT INTO MATCHES(maps, Match_duration, Game_mode, _Date, Result, Balance_change, nickname)
Values ('The Great Bridge','00:05:32', 'Быстрый', '22/11/2023', 'Победа', -1, 'Zani'),
('TheDarkTown','00:43:12', 'Быстрый', '22/11/2023', 'Ничья', 0, 'Arian'),
('The Great Bridge','00:45:21', 'Быстрый', '22/11/2023', 'Победа', -1, 'Zani'),
('The Great Bridge','00:10:44', 'Быстрый', '22/11/2023', 'Победа', -1, 'Zani');
GO

SELECT * FROM MATCHES
GO
SELECT * FROM Characters
GO;

IF OBJECT_ID(N'Have_character') is NOT NULL 
    DROP FUNCTION Have_character
GO

CREATE FUNCTION Have_character(@user_login varchar(45))
    RETURNS INT
    BEGIN
		DECLARE @result TINYINT;
        IF EXISTS (SELECT 1 FROM Characters WHERE Characters.user_login = @user_login)
			SET @result = 1;
		ELSE
			SET @result = 0;
		
    
        RETURN @result;
    END
GO

ALTER TABLE Players 
	ADD  have_character TINYINT;
GO



UPDATE Players
	SET have_character  = [dbo].have_character(user_login)
GO

SELECT * FROM PLAYERS
GO

IF OBJECT_ID(N'PlayersWithcharacters') is NOT NULL
	DROP PROCEDURE PlayersWithcharacters;
GO

CREATE PROCEDURE PlayersWithcharacters
AS
    SET NOCOUNT ON;
    SELECT *
    FROM Players
	WHERE have_character = 1;
GO

EXEC PlayersWithcharacters;

SELECT * FROM Characters
ORDER BY In_game_balance;
GO


IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'PlayersPasswords_INDX')
	DROP INDEX PlayersPasswords_INDX on Players;
GO

CREATE INDEX PlayersPasswords_INDX
    ON Players(user_login)
    INCLUDE (Password);
GO


DELETE FROM Characters
	WHERE user_login ='drew'  AND race = 'orc'
GO

SELECT * FROM Characters;
GO

SELECT * 
FROM Players
WHERE Donate_points BETWEEN 0 AND 30;
GO

SELECT * FROM Players
WHERE email LIKE '%@yopmail.com%'
GO

SELECT P.User_login, p.email, p.password
FROM players AS p 
WHERE EXISTS  
(SELECT *  
    FROM Characters as c
    WHERE p.user_login = c.user_login) ;  
GO  

SELECT * 
FROM Matches 
WHERE Result IN('Ничья', 'Поражение');
GO

SELECT *
	FROM Characters
	  FULL outer join Matches
		ON Matches.nickname = Characters.nickname
GO

SELECT  *
	FROM Characters
		FULL OUTER JOIN Matches
	ON Matches.nickname = Characters.nickname
	ORDER BY Balance_change ASC
GO

SELECT  *
	FROM Characters
		LEFT OUTER JOIN Matches
	ON Matches.nickname = Characters.nickname
	ORDER BY Balance_change DESC
GO

SELECT  *
	FROM Characters
		right OUTER JOIN Matches
	ON Matches.nickname = Characters.nickname
		WHERE Matches.nickname is NULL
GO




IF OBJECT_ID(N'ViewPlayers') is NOT NULL
	DROP VIEW ViewPlayers;
GO

CREATE VIEW ViewPlayers AS
    SELECT User_login AS 'Логин', 
           CONCAT(SUBSTRING(email, 1, 2), '*****', SUBSTRING(email, LEN(email) - 7, LEN(email))) AS 'Почта',
		   CONCAT(SUBSTRING(Password, 1, 3), '*****', SUBSTRING(Password, LEN(Password) - 2, LEN(Password))) AS 'Номер Пароль'
FROM Players;
GO

SELECT * FROM ViewPlayers;
GO

SELECT Nickname, SUM(In_game_balance) AS 'Баланс всех персонажей' FROM Characters
GROUP BY Nickname
HAVING sum(In_game_balance) > 62689
ORDER BY 'Баланс всех персонажей'
GO

SELECT user_login, MAX(In_game_balance) FROM Characters
GROUP BY user_login;
GO

SELECT user_login, MIN(In_game_balance) FROM Characters
GROUP BY user_login;
GO

SELECT nickname, AVG(Balance_change) from Matches
GROUP BY nickname;
GO

SELECT user_login, COUNT(*) AS 'Кол-во персонажей' from Characters
GROUP BY user_login;
GO

SELECT user_login FROM Players
UNION ALL
SELECT Nickname FROM Characters
GO

SELECT user_login FROM Players
UNION
SELECT Nickname FROM Characters
GO

SELECT user_login FROM Players
INTERSECT 
SELECT Nickname FROM Characters
GO

SELECT user_login FROM Players
EXCEPT
SELECT Nickname FROM Characters
GO

SELECT USER_login, email,
	(SELECT COUNT(*) AS 'Кол-во персонажей' FROM Characters AS o
GROUP BY user_login 
HAVING c.user_login = o.user_login)
FROM Players AS C

GO




