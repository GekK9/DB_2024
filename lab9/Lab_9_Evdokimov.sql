
USE lab9;
GO
SET NOCOUNT ON;
GO

IF OBJECT_ID(N'Orders') is NOT NULL 
	DROP TABLE Orders;
GO

IF OBJECT_ID(N'CLients') is NOT NULL
	DROP TABLE Clients;
GO

CREATE TABLE Clients
	(
	Client_code int IDENTITY(1000, 1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Address NVARCHAR(100) NULL,
	Phone_number char(11) UNIQUE NOT NULL
	);
GO



CREATE TABLE Orders
	(
	Number_of_order int IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	Client_code int REFERENCES Clients(Client_code) NOT NULL,
	Date_of_order date NOT NULL DEFAULT GetDATE(),
	CONSTRAINT CHK_Date_of_order
		CHECK (Date_of_order > CONVERT(DATETIME, '1/1/1990', 103)),
	Price_of_order money NOT NULL 
		CHECK (price_of_order >= 0),
	Status bit NOT NULL DEFAULT '0'
		CHECK (Status IN ('1', '0'))
	);
GO


INSERT INTO  Clients(Name, Address, Phone_number)
   VALUES 
	('Artem', '294060, Тульская область, город Зарайск, бульвар Ленина, 71', '89502422455'),
	('Yan', '783595, Волгоградская область, город Раменское, въезд Косиора, 40','89083528814'),
	('Nastya', '336490, Читинская область, город Мытищи, шоссе Гагарина, 79','89663241425'),
	('Anton','296543, Самарская область, город Солнечногорск, шоссе Чехова, 84','89856759952')

GO

INSERT INTO Orders(Client_code, Date_of_order,Price_of_order, Status)
	VALUES
	(1001, DEFAULT, 2145, DEFAULT),
	(1001,'18/09/2023', 34621, 1),
	(1002, '23/11/2023', 25251, DEFAULT),
	(1003, DEFAULT, 21412, DEFAULT);
GO


IF OBJECT_ID(N'Clients_trigger_insert') is NOT NULL
	DROP TRIGGER Clients_trigger_insert;
GO

CREATE TRIGGER Clients_trigger_insert
ON Clients
FOR INSERT 
AS 

	IF EXISTS (
	SELECT * FROM INSERTED
	WHERE INSERTED.Address is NULL)

	RAISERROR('[INS TRIGGER]: Added Client without address', 15, -1)
GO

IF OBJECT_ID(N'Clients_trigger_delete') is NOT NULL
	DROP TRIGGER Clients_trigger_delete;
GO

CREATE TRIGGER Clients_trigger_delete
ON Clients
INSTEAD OF DELETE
AS 
			DECLARE @Count_del int = 0
            UPDATE Clients
			SET Name = Name + '(UncorrectNumber)',
			@Count_del = @Count_del + 1
			WHERE LEN(phone_number) < 11;
			print '[DEL TRIGGER]: ' + CAST(@Count_del as varchar) + ' Uncorrect numbers'

GO

IF OBJECT_ID('Clients_trigger_update') is NOT NULL
	DROP TRIGGER Clients_trigger_update;
GO

CREATE TRIGGER Clients_trigger_update
ON Clients
for UPDATE
AS 
	print 'Table was updated:';
	print '-------------------';
GO

INSERT INTO  Clients(Name, Phone_number)
   VALUES 
	('Anna','897012345'),
	('Yelena','901234567')

SELECT * FROM Clients;
GO

DELETE FROM Clients
	WHERE LEN(Phone_number)< 11 
GO

SELECT * FROM Clients;
GO

disable trigger Clients_trigger_delete on Clients;
go
disable trigger Clients_trigger_update on Clients;
go
disable trigger Clients_trigger_insert on Clients;
go


	IF OBJECT_ID(N'order_view', N'V') is NOT NULL
    DROP VIEW order_view;
GO

CREATE VIEW order_view AS
    SELECT
		C.Name AS Name,
		O.Number_of_order AS NumOrder,
		C.Address AS Address,
		C.Phone_number AS Phone,
		O.Date_of_order AS Date,
		O.Price_of_order AS Price,
		O.Status AS status
    FROM Clients C
    INNER JOIN Orders O
        ON C.Client_code = O.Client_code;
GO

IF OBJECT_ID(N'order_view_trigger_insert', N'TR') is NOT NULL
    DROP TRIGGER added_order_view_trigger_insert
GO

CREATE TRIGGER Order_view_trigger_insert
    ON order_view
    INSTEAD OF INSERT
	AS
    BEGIN
        INSERT INTO Clients
			SELECT DISTINCT
			i.name,
			i.Address,
			i.phone
                FROM inserted AS i
                WHERE i.Phone not in (SELECT Phone_number
                    FROM Clients)
		
        INSERT INTO Orders
            SELECT	

                    (select Client_code from Clients as C where i.Phone = C.Phone_number),
					i.date,
					i.price,
					i.status
                from inserted as i
				
    end
go

select * from order_view
select * from Clients 

insert into order_view(name, address, phone,date, price, status)
values
    ( 'Yan', '783595, Волгоградская область, город Раменское, въезд Косиора, 40','89083528824',  GetDATE(), 2352352, '0'),
	( 'Yan', '783595, Волгоградская область, город Раменское, въезд Косиора, 40','89083528824',  GetDATE(), 2352353, '0'),
	( 'Yan', '296543, Самарская область, город Солнечногорск, шоссе Чехова, 84', '89083522334', GetDATE(), 98765, '0');
GO
SELECT * FROM Clients;
GO

SELECT * FROM Orders;
GO

SELECT * FROM order_view;
GO




if OBJECT_ID(N'order_view_trigger_delete', N'TR') is not null
    drop trigger order_view_trigger_delete
go
create trigger order_view_trigger_delete
    on order_view
    instead of delete
    as
    begin
        delete from Orders
            where Orders.Number_of_order in (select d.NumOrder
                from deleted as d)
    end
go
 
 
delete from order_view
    where order_view.NumOrder in ('5')
GO

select * from order_view
GO;

select * from Clients;
GO
select * from Orders
GO

if OBJECT_ID(N'order_view_trigger_update', N'TR') is not null
    drop trigger order_view_trigger_update
go
create trigger order_view_trigger_update
    on order_view
    instead of update
    as 
    begin
 
        if UPDATE(NumOrder)
            RAISERROR('[UPD TRIGGER]: "NumOrder"," cant be modified', 16, 1);
		
		else if UPDATE(phone)
			RAISERROR('[UPD TRIGGER]: "phone" cant be modified', 16, 1);

		else if UPDATE(Date)
			RAISERROR('[UPD TRIGGER]: "Date" cant be modified', 16, 1);
        ELSE
		BEGIN
			IF UPDATE(status)
				UPDATE Orders
					SET Status = (select status from inserted where inserted.NumOrder = Orders.Number_of_order)
						where Orders.Number_of_order = (select NumOrder from inserted where inserted.NumOrder= Orders.Number_of_order)
		
			IF UPDATE(price)
				UPDATE Orders
					SET Price_of_order = (select price from inserted where inserted.NumOrder = Orders.Number_of_order)
						where Orders.Number_of_order = (select NumOrder from inserted where inserted.NumOrder= Orders.Number_of_order)
		END
END
go	
 
update order_view
    Set Status = '1', Phone = '89501222365'
		where NumOrder = '6';

	
GO

update order_view 
    set price = 6363636
		where NumOrder = '2';
GO


Select * from order_view;
go

Select * from Orders;
GO

update	order_view 
	set NumOrder = 21	
		WHERE NumOrder = 3
GO
select * from order_view 
select * from Orders
