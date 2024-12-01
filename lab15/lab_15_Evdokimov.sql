SET NOCOUNT ON;
GO
USE Lab15_1
GO

IF OBJECT_ID(N'Players') is NOT NULL
	DROP TABLE Players;
GO

CREATE TABLE Players
	(
	user_login varchar(20) PRIMARY KEY NOT NULL,
	Email  varchar(254) NOT NULL UNIQUE,
	status int NOT NULL DEFAULT 0
	);
GO


INSERT INTO Players(user_login, email, status)
	VALUES
		('Drew', 'breussoippauprusso-3159@yopmail.com',1),
		('Kathilla', 'leiyauhefraku-4167@yopmail.com',0),
		('Uesdemus', 'bropreibonnedda-5770@yopmail.com',1),
		('Hoenic', 'fofiyannaje-7957@yopmail.com', 1),
		('frrride', 'aghjaje-1457@yopmail.com', 1),
		('agoonViper', 'jhgfdnnaje-75367757@yopmail.com', 0),
		('Heqttt', 'nowizeitretu-6395@yopmail.com', 1); 
GO

IF OBJECT_ID(N'PlayersDel') is NOT NULL
	DROP TRIGGER PlayersDel
GO

CREATE TRIGGER PlayersDel
    ON Players
    AFTER DELETE AS
BEGIN
    DELETE FROM [Lab15_2].[dbo].Characters WHERE user_login IN (SELECT user_login FROM deleted)
END
GO

IF OBJECT_ID(N'PlayersUpd') is NOT NULL
	DROP TRIGGER PlayersUpd
GO

CREATE TRIGGER PlayersUpd
ON Players
INSTEAD OF UPDATE AS
BEGIN
	IF UPDATE(user_login)
	BEGIN
		RAISERROR('[UPD TRIGGER]: user_login cant upd', 15, -1);
	END
		IF UPDATE(email)
		BEGIN
			UPDATE Players
			SET email = (SELECT email FROM inserted WHERE inserted.user_login = Players.user_login)
			WHERE user_login = (SELECT user_login FROM inserted WHERE inserted.user_login = Players.user_login);
		END
	END;
GO



select * from Players
go
update Players set email = email
go
select * from Players
go


USE Lab15_2
GO

IF OBJECT_ID(N'Characters') is NOT NULL
	DROP TABLE Characters
GO

CREATE TABLE Characters
	(
	Nickname varchar(50) NOT NULL primary key,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,
	user_login varchar(20)
	);
GO

INSERT INTO Characters(Nickname, in_game_balance, race, user_login)
	VALUES
		('Uetreyn', 236236326, 'Elf','Drew'),
		('Blffiton', 2345 , 'Orc','frrride'),
		('Metusosam', 7654765 , 'Human','Heqttt'),
		('Avadon', 345697 , 'Human','Kathilla'),
		('Ina', 98765 , 'Treant','Heqttt'),
		('Tand', 0 , 'Murloc','agoonViper'),
		('Nggely', 8765543 , 'Human','Kathilla'),
		('Oning', 854 , 'Treant','agoonViper'),
		('Lien', 78645123 , 'Human','Uesdemus'),
		('Koshanerg', 255645198 , 'Ogre','Uesdemus'),
		('Ghim', 8451 , 'Orc','Uesdemus'),
		('Gralillo', 12554 , 'ELf','Kathilla'),
		('Ullanchen', 0 , 'Human','agoonViper'),
		('Zani', 3245867, 'Ogre','Hoenic'); 
GO

CREATE TRIGGER CharactersIns
    ON Characters
    INSTEAD OF INSERT AS
BEGIN
    IF EXISTS(SELECT Nickname FROM inserted WHERE inserted.Nickname IN (SELECT Nickname FROM [lab15_2].DBO.Characters))
		BEGIN
            RAISERROR('[INS TRIGGER]: Characters is already available', 11, 1)
		END
	ELSE BEGIN
			IF EXISTS (SELECT Nickname FROM inserted WHERE user_login NOT IN (SELECT user_login FROM [lab15_1].[dbo].Players))
			BEGIN
				RAISERROR('[INS TRIGGER]: first add Players', 11, 1)
				END
			ELSE 
				BEGIN
					INSERT INTO Characters
						SELECT
							i.Nickname,
							i.In_game_balance,
							i.race,
							i.user_login
							FROM inserted AS i
		END	
		END
END
	
GO


IF OBJECT_ID(N'CharactersUpd') is NOT NULL
	DROP TRIGGER CharactersUpd
GO


CREATE TRIGGER CharactersUpd
	ON Characters
INSTEAD OF UPDATE AS
	BEGIN
	 IF UPDATE(user_login)
		RAISERROR('[UPD TRIGGER]: user_login cant upd', 15, -1)
	 ELSE IF UPDATE(in_game_balance)
		UPDATE Characters
		Set In_game_balance = (select In_game_balance from inserted where inserted.user_login = user_login)
										where user_login = (select user_login from inserted where inserted.user_login = user_login)
	END
GO

select * from Characters
update Characters set user_login = 'sssooe'

select * from Characters


USE lab15_3
GO

IF OBJECT_ID(N'PlayersCharacters') is NOT NULL
	DROP VIEW PlayersCharacters
GO

CREATE VIEW PlayersCharacters
AS
  SELECT  S.user_login, S.email, P.Nickname, P.Race,p.In_game_balance
  FROM [lab15_1].[dbo].Players AS S INNER JOIN [lab15_2].[dbo].Characters P on S.user_login = P.user_login
GO


SELECT * FROM PlayersCharacters

SELECT * FROM [Lab15_1].[DBO].Players

SELECT * FROM [Lab15_2].[DBO].Characters
GO


UPDATE [Lab15_1].[DBO].Players
	SET user_login = 'reazon'
		where user_login = 'agoonViper'
GO

UPDATE [Lab15_1].[DBO].Players
	SET email = 'ghhhff43@gmail.com'
		where user_login = 'agoonViper';
GO

UPDATE [Lab15_1].[DBO].Players
	SET email = 'g345543@gmail.com', user_login = 'kitok'
		where user_login = 'frrride';
GO

INSERT [LAB15_2].[DBO].Characters
VALUES
		('hiiir', 236236326, 'Elf','Drew')
GO

INSERT [LAB15_2].[DBO].Characters
VALUES
		('Uetreyn', 236236326, 'Orc','Drew')
GO

INSERT [LAB15_2].[DBO].Characters
VALUES
		('Uetreyn', 236236326, 'Elf','frrride')
GO


SELECT * FROM PlayersCharacters

SELECT * FROM [Lab15_1].[DBO].Players

SELECT * FROM [Lab15_2].[DBO].Characters
GO