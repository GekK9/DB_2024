--use master
--go

--IF DB_ID(N'lab8') IS NOT NULL
--	DROP DATABASE lab8;
--GO

--CREATE DATABASE lab8
--ON (NAME = lab8_dat, FILENAME = "C:\BD\lab8\lab8dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab8_log, FILENAME = "C:\BD\lab7\lab8log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

use lab8
go


IF OBJECT_ID(N'Players') is NOT NULL
	DROP TABLE Players;
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
		('Drew', 'breussoippauprusso-3159@yopmail.com', 'dAE8', 51, '12/07/2023'),
		('Kathilla', 'leiyauhefraku-4167@yopmail.com', '-26eY_2bxX5', 0, '8/02/2023'),
		('Uesdemus', 'bropreibonnedda-5770@yopmail.com', '-Ed8eORDn1', 9876, '30/09/2016'),
		('Hoenic', 'fofiyannaje-7957@yopmail.com', '-927diQdOn', 22, '24/12/2022'),
		('frrride', 'aghjaje-1457@yopmail.com', '-hd27dhre63n', 13452, '12/05/2023'),
		('agoonViper', 'jhgfdnnaje-75367757@yopmail.com', '-97654gOn', 2532, '20/10/2018'),
		('Heqttt', 'fofiyannaje-2155@yopmail.com', '-9iQdOn', 22522, '11/02/2019'); 
GO

SELECT * FROM Players;
GO

if OBJECT_ID(N'get_age', 'FN') is not null
    DROP FUNCTION get_age;
GO
CREATE FUNCTION get_age(@createDate int)
    RETURNS INT
    WITH EXECUTE AS CALLER
    AS
    BEGIN
		DECLARE @current_date datetime = GETDATE();
        DECLARE @current_year INT, @age INT;
 
        SET @current_year = YEAR(@current_date);
        SET @age = @current_year - @createDate;
    
        RETURN @age;
    END
GO

IF OBJECT_ID(N'FiveYearsAgoTrue', N'FN') is not null
    DROP FUNCTION dbo.FiveYearsAgoTrue;
GO
CREATE FUNCTION dbo.FiveYearsAgoTrue(@compare_what INT)
    RETURNS INT
    WITH EXECUTE AS CALLER
    AS
    BEGIN
        DECLARE @answ INT;
 
       IF @compare_what >= 5
            SET @answ = 1;
        ELSE 
            SET @answ = 0;
 
        RETURN @answ;
    END
GO
 
if OBJECT_ID(N'dbo.sub_proc', N'P') is not null
    DROP PROCEDURE dbo.sub_proc 
GO

CREATE PROCEDURE dbo.sub_proc
    @curs CURSOR VARYING OUTPUT
AS
    SET NOCOUNT ON;
    SET @curs = CURSOR
    SCROLL STATIC FOR               
        SELECT user_login, email, dbo.get_age(YEAR(registration_date)) 
        FROM Players;
    OPEN @curs;
GO

--Создать хранимую процедуру, вызывающую процедуру п.1., 
--осуществляющую прокрутку возвращаемого курсора и выводящую сообщения, 
--сформированные из записей при выполнении условия, заданного еще одной пользовательской функцией.
 
if OBJECT_ID(N'dbo.external_proc', N'P') is not null
    DROP PROCEDURE dbo.external_proc
GO
CREATE PROCEDURE dbo.external_proc
AS
    DECLARE @ext_curs CURSOR;
    DECLARE @t_user_login VARCHAR(254);
    DECLARE @t_email VARCHAR(35);
    DECLARE @t_age INT;
	DECLARE @Count INT = 0;
 
    EXEC dbo.sub_proc @curs = @ext_curs OUTPUT;
 
    FETCH NEXT FROM @ext_curs INTO @t_user_login, @t_email, @t_age;
    PRINT 'First Fetch: "' + @t_user_login + ' | ' + @t_email + ' ||| ' +  CAST(@t_age AS VARCHAR) + '"'
	PRINT '      Players:';
	PRINT '-----------------------------'
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF (dbo.FiveYearsAgoTrue(@t_age) = 1)
		BEGIN
            PRINT @t_user_login + ' | ' + @t_email + ' | 5-ти летний герой | На проекте уже(' + CAST(@t_age AS VARCHAR) + ')'
			SET @Count = @Count + 1
		END
        FETCH NEXT FROM @ext_curs
        INTO @t_user_login, @t_email, @t_age;
    END
	PRINT '-----------------------------'
	PRINT 'Total Players with 5years ' + CAST(@Count AS VARCHAR);
    CLOSE @ext_curs;
    DEALLOCATE @ext_curs;
GO

EXEC dbo.external_proc
GO
 
 
--Модифицировать хранимую процедуру п.2. таким образом, 
--чтобы выборка формировалась с помощью табличной функции.
 
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.get_FiveYearsAgoPlayers') 
    AND xtype IN (N'FN', N'IF', N'TF'))
    DROP FUNCTION dbo.get_FiveYearsAgoPlayers
GO

CREATE functiON dbo.get_FiveYearsAgoPlayers()

    RETURNS @tt TABLE
    (	
		user_login varchar(254),
		email NVARCHAR(254),
        donate_points int,
        Age INT
    )
    AS
    BEGIN
        INSERT @tt
            SELECT user_login, email, donate_points, dbo.get_age(YEAR(registration_date))
            FROM Players
            WHERE dbo.FiveYearsAgoTrue(dbo.get_age(YEAR(registration_date))) = 1
        RETURN
    END
GO
 
ALTER PROCEDURE dbo.sub_proc
    @curs CURSOR VARYING OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @curs = CURSOR
    SCROLL STATIC FOR
        SELECT user_login, email, donate_points, Age
        FROM dbo.get_FiveYearsAgoPlayers();
    OPEN @curs;
END
GO
 
DECLARE @another_curs CURSOR;
 
EXEC dbo.sub_proc @curs = @another_curs OUTPUT;
FETCH NEXT FROM @another_curs;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    FETCH NEXT FROM @another_curs;
END

CLOSE @another_curs;
DEALLOCATE @another_curs;
GO