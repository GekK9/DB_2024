--use master
--go

--IF DB_ID(N'lab7') IS NOT NULL
--	DROP DATABASE lab6;
--GO

--CREATE DATABASE lab7
--ON (NAME = lab7_dat, FILENAME = "C:\BD\lab7\lab7dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab7_log, FILENAME = "C:\BD\lab7\lab7log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO


Use Lab7;
GO
 
--1.Создать представление на основе одной из таблиц задания 6.

IF OBJECT_ID(N'Donaters_INDX_VIEW', N'V') IS NOT NULL
    DROP VIEW Donaters_INDX_VIEW;
GO

IF OBJECT_ID(N'Donaters') is NOT NULL
	DROP TABLE Donaters;
GO

IF OBJECT_ID('PlayersSequence') IS NOT NULL
    DROP SEQUENCE PlayersSequence;
GO

CREATE SEQUENCE PlayersSequence
    START WITH 200003
    INCREMENT BY 738;
GO

CREATE TABLE Donaters
	(
	PlayerID int DEFAULT (NEXT VALUE FOR PlayersSequence) UNIQUE,
	user_login varchar(20) PRIMARY KEY NOT NULL,
	Email  varchar(254) NOT NULL,
	Password varchar(30) NOT NULL,
	Donate_points int NOT NULL,
	registration_date date NOT NULL,
	CONSTRAINT CHK_registration_date
		CHECK (registration_date > CONVERT(DATE, '1/1/1990', 103)),
	);
GO

INSERT INTO Donaters(user_login, email, password, donate_points, registration_date)
	VALUES
		('Drew', 'breussoippauprusso-3159@yopmail.com', '-Hxe9ddAE8', 51, '12/07/2023'),
		('Kathilla', 'leiyauhefraku-4167@yopmail.com', '-26eY_2bxX5', 0, '8/02/2023'),
		('Uesdemus', 'bropreibonnedda-5770@yopmail.com', '-Ed8eORDn1', 9876, '30/09/2021'),
		('Hoenic', 'fofiyannaje-7957@yopmail.com', '-927diQdOn', 22, '24/12/2022'); 
GO

IF OBJECT_ID(N'Donaters_', N'V') is NOT NULL
    DROP VIEW Donaters_;
GO

CREATE VIEW Donaters_ AS
    SELECT *
    FROM Donaters
    WHERE Donate_points > 0
GO

SELECT * FROM Donaters
 

 use lab6
 go
--2.Создать представление на основе полей обеих связанных таблиц задания 6.
IF OBJECT_ID(N'PlayersCharacters', N'V') is NOT NULL
    DROP VIEW  PlayersCharacters;
GO

CREATE VIEW PlayersCharacters AS
    SELECT 
        P.user_login as 'Имя пользователя', 
        P.email as 'Почта', 
        P.Donate_points AS 'Донат',
		C.nickname AS 'Ник персонажа',
		C.race AS 'раса персонажа',
		C.in_game_balance AS 'Валюта персонажа'
    FROM players P
    INNER JOIN Characters C
        ON P.user_login = C.user_login;
GO
 
SELECT * FROM PlayersCharacters;
GO
 
 use lab7
 go
 
--3.Создать индекс для одной из таблиц задания 6, включив в него дополнительные неключевые поля.
IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'PlayersPasswords_INDX')
	DROP INDEX PlayersPasswords_INDX on Players;
GO

CREATE INDEX PlayersPasswords_INDX
    ON Donaters(user_login)
    INCLUDE (Password);
GO
 
 
--4.Создать индексированное представление.

CREATE VIEW Donaters_INDX_VIEW
    WITH SCHEMABINDING  
    AS SELECT user_login, Email, Donate_points
    FROM dbo.Donaters
    WHERE Donate_points >= 50;
GO


IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'Donaters_INDX')
    DROP INDEX Donaters_INDX_VIEW ON Donaters_;
GO

CREATE UNIQUE CLUSTERED INDEX Donaters_INDX
    on Donaters_INDX_VIEW(user_login, email, Donate_points);
GO


SELECT * FROM Donaters_INDX_VIEW;
GO

 SELECT *
FROM sys.indexes
WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = 'Donaters');