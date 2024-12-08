
--use master
--go

--IF DB_ID(N'lab9') IS NOT NULL
--	DROP DATABASE lab9;
--GO

--CREATE DATABASE lab9
--ON (NAME = lab9_dat, FILENAME = "C:\BD\lab9\lab9dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab9_log, FILENAME = "C:\BD\lab9\lab9log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

USE lab9;
GO
SET NOCOUNT ON;
GO

IF OBJECT_ID(N'Characters') is NOT NULL 
	DROP TABLE Characters;
GO

IF OBJECT_ID(N'Players') is NOT NULL
	DROP TABLE Players;
GO

CREATE TABLE Players
	(
	user_login varchar(20) PRIMARY KEY NOT NULL,
	Email  varchar(254) NOT NULL ,
	status int NOT NULL DEFAULT 0
	);
GO



CREATE TABLE Characters
	(
	user_login varchar(20) REFERENCES Players(user_login) NOT NULL,
	Nickname varchar(50) NOT NULL,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,
	PRIMARY KEY(Nickname)
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


IF OBJECT_ID(N'Players_trigger_insert') is NOT NULL
	DROP TRIGGER Players_trigger_insert;
GO

CREATE TRIGGER Players_trigger_insert
ON Players
FOR INSERT 
AS 

	IF EXISTS (
	SELECT * FROM INSERTED
	WHERE (status = 0))
	RAISERROR('[INS TRIGGER]: Added Player with not confirmed email', 15, -1)
GO

IF OBJECT_ID(N'Players_trigger_delete') is NOT NULL
	DROP TRIGGER Players_trigger_delete;
GO

CREATE TRIGGER Players_trigger_delete
ON Players
INSTEAD OF DELETE
AS 
	BEGIN
			DECLARE @Count_del int = 0
            UPDATE Players
			SET email = email + '(not confirmed)',
			@Count_del = @Count_del + 1
			WHERE status = 0;
	END
			print '[DEL TRIGGER]: ' + CAST(@Count_del as varchar) + ' Players with not confirmed email'

GO

IF OBJECT_ID('Players_trigger_update') is NOT NULL
	DROP TRIGGER Players_trigger_update;
GO

CREATE TRIGGER Players_trigger_update
ON Players
for UPDATE
AS 
	print 'Table was updated:';
	print '-------------------';
GO

INSERT INTO Players(user_login, email, status)
	VALUES
		('Otosiahav', 'bibraufoittacro-9954@yopmail.com', 1),
		('Orelinice', 'prusausofoimmi-2767@yopmail.com', 0);
GO

SELECT * FROM Players;
GO

DELETE FROM Players
	WHERE status = 0 
GO

SELECT * FROM Players;
GO

disable trigger Players_trigger_delete on Players;
go
disable trigger Players_trigger_update on Players;
go
disable trigger Players_trigger_insert on Players;
go


	IF OBJECT_ID(N'Character_view', N'V') is NOT NULL
    DROP VIEW Character_view;
GO

CREATE VIEW Character_view AS
    SELECT
		P.user_login AS user_login,
		P.Email AS email,
		P.status AS status,
		C.Nickname AS Nickname,
		C.race AS Race,
		C.in_game_balance AS in_game_Balance
    FROM Players P
    INNER JOIN Characters AS C
        ON P.user_login = C.user_login;
GO

IF OBJECT_ID(N'Character_view_trigger_insert', N'TR') is NOT NULL
    DROP TRIGGER added_Character_view_trigger_insert
GO

CREATE TRIGGER Character_view_trigger_insert
    ON Character_view
    INSTEAD OF INSERT
	AS
    BEGIN
        INSERT INTO Players
			SELECT DISTINCT
			i.user_login,
			i.email,
			i.status
                FROM inserted AS i
                WHERE i.email not in (SELECT email
                    FROM Players)
		
        INSERT INTO Characters
            SELECT	
                    (select User_login from Players as P where i.email = P.email),
					i.nickname,
					i.in_game_Balance,
					i.race
                from inserted as i
				
    end
go

select * from Character_view
GO

select * from Players
GO

insert into Character_view(user_login, email, Nickname, Race, in_game_balance, status)
values
    ( 'Drew', 'breussoippauprusso-3159@yopmail.com', 'Gideon', 'elf', 2352352, 1),
	( 'Drew', 'breussoippauprusso-3159@yopmail.com', 'Gekko',  'murloc', 0, 1);
GO

SELECT * FROM Players;
GO

SELECT * FROM Characters;
GO

SELECT * FROM Character_view;
GO




if OBJECT_ID(N'Character_view_trigger_delete', N'TR') is not null
    drop trigger Character_view_trigger_delete
go
create trigger Character_view_trigger_delete
    on Character_view
    instead of delete
    as
    begin
        delete from Characters
            where Characters.user_login in (select d.user_login
                from deleted as d)
    end
go
 
 
delete from Character_view
    where Character_view.user_login in ('Drew')
GO

select * from Character_view
GO;

select * from Players;
GO
select * from Characters
GO

if OBJECT_ID(N'Character_view_trigger_update', N'TR') is not null
    drop trigger Character_view_trigger_update
go
create trigger Character_view_trigger_update
    on Character_view
    instead of update
    as 
    begin
 
        if UPDATE(user_login)
            RAISERROR('[UPD TRIGGER]: "user_login"," cant be modified', 16, 1);
		
		if UPDATE(email)
			RAISERROR('[UPD TRIGGER]: "email" cant be modified', 16, 1);
END
go	
 
update Character_view
    Set user_login = 'hiiief', email = 'neimmeucafollo-4828@yopmail.com'
		where user_login  = 'Uesdemus';

	
GO


select * from Character_view 
select * from Characters
