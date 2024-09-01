USE lab1;
GO


IF OBJECT_ID(N'CLients') is NOT NULL
	DROP TABLE Clients;
GO

CREATE TABLE Clients
	(
	Client_code INT IDENTITY(244244, 414) PRIMARY KEY,
	Name VARCHAR(100) NOT NULL,
	Birthday DATE NOT NULL,
	CONSTRAINT CHK_Date_of_order
		CHECK (Birthday > CONVERT(DATETIME, '1/1/1900', 104)),
	Address VARCHAR(100) UNIQUE DEFAULT 'Unknown',
	Phone_number VARCHAR(10) UNIQUE NOT NULL,
		CHECK (LEN(phone_number) = 10),
	);
GO

INSERT INTO  Clients(Name, Birthday ,Address, PhONe_number)
   VALUES 
	('Artem', '20/05/1995', '294060,  Тульская область, город Зарайск, бульвар Ленина, 71', 9502422455),
	('Yan', '5/08/2004', '783595, Волгоградская область, город Раменское, въезд Косиора, 40', 9083528814),
	('NAStya', '24/12/1976', '336490, Читинская область, город Мытищи, шоссе Гагарина, 79', 9663241425),
	('AntON', '18/07/2000','296543, Самарская область, город Солнечногорск, шоссе Чехова, 84', 9856759952),
	('Ivan', '15/07/1995', '712297, Липецкая область, город Можайск, бульвар Гоголя, 16', 9155225255),
	('Natalia', '23/09/1989', '704096, Саратовская область, город Талдом, спуск Сталина, 81', 9234567890),
	('Alexei', '10/02/2001', '373356, Оренбургская область, город Солнечногорск, наб. Бухарестская, 24', 9345678901),
	('Elena', '05/11/2010', '899790, Белгородская область, город Озёры, пер. Будапештсткая, 61', 9456789012),
	('Svetlana', '20/04/2008', '968414, Тюменская область, город Ногинск, проезд Косиора, 54', 9567890123),
	('Dmitri', '30/12/1988', '977756, Ульяновская область, город Раменское, въезд Сталина, 04', 9678901234),
	('Anna', '02/03/1977', '267232, Смоленская область, город Сергиев Посад, въезд Гоголя, 91', 9789012345),
	('Sergei', '18/08/2006', '380438, Тюменская область, город Орехово-Зуево, шоссе Ломоносова, 31', 9890123456),
	('Yelena', '09/06/2004', '965678, Тамбовская область, город Домодедово, пл. Балканская, 60', 9901234567),
	('Maxim', '14/10/1991', '367833, Брянская область, город Егорьевск, пер. Бухарестская, 02', 9012345678),
	('Tatiana', '07/12/2007', '446162, Иркутская область, город Кашира, проезд 1905 года, 56', 9123456789),
	('Vladimir', '22/05/1980', '068728, Нижегородская область, город Красногорск, спуск Бухарестская, 46', 9234523590);
GO

SELECT * FROM Clients;
GO

if OBJECT_ID(N'get_age', 'FN') is not null
    DROP FUNCTION get_age;
GO
CREATE FUNCTION get_age(@birthday INT)
    RETURNS INT
    WITH EXECUTE AS CALLER
    AS
    BEGIN
		DECLARE @current_date datetime = GETDATE();
        DECLARE @current_year INT, @age INT;
 
        SET @current_year = YEAR(@current_date);
        SET @age = @current_year - @birthday;
    
        RETURN @age;
    END
GO

IF OBJECT_ID(N'FullAgeTrue', N'FN') is not null
    DROP FUNCTION dbo.FullAgeTrue;
GO
CREATE FUNCTION dbo.FullAgeTrue(@compare_what INT)
    RETURNS INT
    WITH EXECUTE AS CALLER
    AS
    BEGIN
        DECLARE @answ INT;
 
       IF (@compare_what > 18)
            SET @answ = 1;
        ELSE 
            SET @answ = 0;
 
        RETURN @answ;
    END
GO
 
if OBJECT_ID(N'ClientsFullAge', N'P') is not null
    DROP PROCEDURE dbo.sub_proc 
GO

CREATE PROCEDURE dbo.sub_proc
    @curs CURSOR VARYING OUTPUT
AS
    SET NOCOUNT ON;
    SET @curs = CURSOR
    SCROLL STATIC FOR               
        SELECT client_code, name, dbo.get_age(YEAR(birthday)) 
        FROM Clients;
    OPEN @curs;
GO

----Создать хранимую процедуру, вызывающую процедуру п.1., 
----осуществляющую прокрутку возвращаемого курсора и выводящую сообщения, 
----сформированные из записей при выполнении условия, заданного еще одной пользовательской функцией.
 
if OBJECT_ID(N'dbo.external_proc', N'P') is not null
    DROP PROCEDURE dbo.external_proc
GO
CREATE PROCEDURE dbo.external_proc
AS
    DECLARE @ext_curs CURSOR;
    DECLARE @t_client_Code VARCHAR(254);
    DECLARE @t_name VARCHAR(35);
    DECLARE @t_age INT;
	DECLARE @Count INT = 0;
 
    EXEC dbo.sub_proc @curs = @ext_curs OUTPUT;
 
    FETCH NEXT FROM @ext_curs INTO @t_client_code, @t_name, @t_age;
    PRINT 'First Fetch: "' + @t_client_code + '| ' + @t_name + '"'
	PRINT '      FullAge clients:';
	PRINT '-----------------------------'
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF (dbo.FullAgeTrue(@t_age) = 1)
		BEGIN
            PRINT @t_client_code + ' | ' + @t_name + ' is FullAge(' + CAST(@t_age AS VARCHAR) + ')'
			SET @Count = @Count + 1
		END
        FETCH NEXT FROM @ext_curs
        INTO @t_client_code, @t_name, @t_age;
    END
	PRINT '-----------------------------'
	PRINT 'Total FullAge clients is ' + CAST(@Count AS VARCHAR);
    CLOSE @ext_curs;
    DEALLOCATE @ext_curs;
GO

EXEC dbo.external_proc
GO
 
 
--Модифицировать хранимую процедуру п.2. таким образом, 
--чтобы выборка формировалась с помощью табличной функции.
 
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.get_FullAgeClient') 
    AND xtype IN (N'FN', N'IF', N'TF'))
    DROP FUNCTION dbo.get_FullAgeClient
GO

CREATE functiON dbo.get_FullAgeClient()

    RETURNS @tt TABLE
    (	
		ClientCode INT,
		Name NVARCHAR(20),
        Address NVARCHAR(254),
        Age INT
    )
    AS
    BEGIN
        INSERT @tt
            SELECT Client_code, Name, Address, dbo.get_age(YEAR(birthday))
            FROM Clients
            WHERE dbo.FullAgeTrue(dbo.get_age(YEAR(birthday))) = 1
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
        SELECT ClientCode, Name, Address, Age
        FROM dbo.get_FullAgeClient();
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