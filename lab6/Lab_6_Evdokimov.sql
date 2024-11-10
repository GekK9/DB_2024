USE master
GO

--IF DB_ID(N'lab6') IS NOT NULL
--	DROP DATABASE lab6;
--GO

--CREATE DATABASE lab6
--ON (NAME = lab6_dat, FILENAME = "C:\BD\lab6\lab6dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab6_log, FILENAME = "C:\BD\lab6\lab6log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

USE lab6

IF OBJECT_ID(N'Matches') IS NOT NULL
	DROP TABLE matches;
GO

IF OBJECT_ID(N'Maps') is NOT NULL
	DROP TABLE Maps;
GO

IF OBJECT_ID(N'Characters') IS NOT NULL
	DROP TABLE Characters;
GO

IF OBJECT_ID(N'Players') IS NOT NULL
	DROP TABLE Players;
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

GO
-- Способ 1
SELECT SCOPE_IDENTITY();

GO
-- Способ 2
SELECT @@IDENTITY;

GO
-- Способ 3

SELECT IDENT_CURRENT('Maps');
GO
-- Способ 4

SELECT * FROM Maps;
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
	);
GO

INSERT INTO Matches(maps, Match_duration, Game_mode, _Date, Result, Balance_change)
	VALUES 
	('The Great Bridge','00:09:52', 'Быстрый', '22/11/2023', 'Победа', +4255),
	('ChinaTown','00:14:11', 'Рейтинговый', default, 'Поражение', -8765);
GO

SELECT * FROM Matches;
GO

IF OBJECT_ID('PlayersSequence') IS NOT NULL
    DROP SEQUENCE PlayersSequence;
GO

CREATE SEQUENCE PlayersSequence
    START WITH 200003
    INCREMENT BY 738;
GO

CREATE TABLE Players
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

INSERT INTO Players(user_login, email, password, donate_points, registration_date)
	VALUES
		('Drew', 'breussoippauprusso-3159@yopmail.com', '-Hxe9ddAE8', 51, '12/07/2023'),
		('Kathilla', 'leiyauhefraku-4167@yopmail.com', '-26eY_2bxX5', 0, '8/02/2023'),
		('Uesdemus', 'bropreibonnedda-5770@yopmail.com', '-Ed8eORDn1', 9876, '30/09/2021'),
		('Hoenic', 'fofiyannaje-7957@yopmail.com', '-927diQdOn', 22, '24/12/2022'); 
GO

SELECT * FROM Players
GO

CREATE TABLE Characters
	(
	Nickname varchar(45) NOT NULL,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,
	Last_login_date date NOT NULL,
	registration_date date NOT NULL,
	user_login varchar(20) REFERENCES Players(user_login) NOT NULL
	PRIMARY KEY(Nickname, user_login)
    );
GO

INSERT INTO Characters(Nickname, in_game_balance, race, Last_login_date, registration_date, user_login)
	VALUES
		('Uetreyn', 236236326, 'Elf', '12/07/2023','12/07/2023','Drew'),
		('Blffiton', 2345 , 'Orc','8/02/2023','12/07/2023','Drew'),
		('Arian', 622637 , 'Human','30/09/2021','12/07/2023','Kathilla'),
		('Zani', 3245867, 'Ogre','24/12/2022','12/07/2023','Hoenic'); 
GO

SELECT * FROM Characters
GO


ALTER TABLE Players
ADD CONSTRAINT FK_Characters_UserLogin
FOREIGN KEY(user_login)
REFERENCES Players(user_login)
ON DELETE NO ACTION;
GO

--попытка удалить игрока приведет к ошибке, так как у него есть связанные персонажи
DELETE FROM Players
WHERE user_login = 'Drew';
GO




UPDATE Players
SET Email = 'newemail@yopmail.com'
WHERE user_login = 'Drew';
GO

ALTER TABLE Players
	DROP CONSTRAINT FK_Characters_UserLogin;
GO

ALTER TABLE Characters
ADD CONSTRAINT FK_Characters_UserLogin
FOREIGN KEY(user_login)
REFERENCES players(user_login)
ON DELETE CASCADE;
GO

--при удалении игрока будут автоматически удалены все его персонажи
DELETE FROM Players
WHERE user_login = 'Hoenic';
GO



UPDATE Characters
SET In_game_balance = 100
WHERE Nickname = 'Arian';
GO

ALTER TABLE Characters
	DROP CONSTRAINT FK_Characters_UserLogin;

GO



ALTER TABLE characters
ADD CONSTRAINT FK_Characters_UserLogin
FOREIGN KEY(user_login)
REFERENCES Players(user_login)
ON DELETE SET NULL;
GO

--при удалении игрока поле user_login в таблице Players юудет ошибка из-за ограничения NOT NULL
DELETE FROM Players
WHERE user_login = 'Kathilla';
GO

UPDATE Players
SET Email = NULL
WHERE user_login = 'Drew';
GO

ALTER TABLE Characters
	DROP CONSTRAINT FK_Characters_UserLogin;

GO

ALTER TABLE Characters
ADD CONSTRAINT FK_Characters_UserLogin
FOREIGN KEY(user_login)
REFERENCES Players(user_login)
ON DELETE SET DEFAULT;
GO
--при удалении игрока поле user_login в таблице Characters будет выводиться ошибка, так как значения по дефолту нету -> NULL, но ограничение NOT NULL
DELETE FROM Players
WHERE user_login = 'Kathilla';
GO

UPDATE Players
SET Donate_points = DEFAULT
WHERE user_login = 'Drew';
GO




