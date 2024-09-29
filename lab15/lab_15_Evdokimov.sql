SET NOCOUNT ON;
GO
USE Lab15_1
GO

IF OBJECT_ID(N'Supplier') is NOT NULL
	DROP TABLE Supplier
GO



CREATE TABLE Supplier (
	Supplier_code INT NOT NULL PRIMARY KEY,
	Address VARCHAR(100) NOT NULL,
	Phone CHAR(11) NOT NULL UNIQUE,
		CHECK (LEN(Phone) = 11),
)
GO

INSERT INTO  Supplier(supplier_code, Address, Phone)
   VALUES 
	(1,'641533, Орловская область, город Можайск, бульвар Домодедовская, 23','89152052653'),
	(2,'350334, Волгоградская область, город Балашиха, шоссе Сталина, 79','89820152345'),
	(3,'241983, Читинская область, город Люберцы, въезд Гоголя, 43','89872526828'),
	(4,'466485, Магаданская область, город Волоколамск, пл. Ленина, 39','89876578877'),
	(5,'463061, Иркутская область, город Луховицы, пл. Ладыгина, 63','89512481411'),
	(6,'250211, Ярославская область, город Мытищи, проезд Ленина, 11','89242621734')
GO

IF OBJECT_ID(N'SupplierDel') is NOT NULL
	DROP TRIGGER SupplierDel
GO

CREATE TRIGGER SupplierDel
    ON Supplier
    AFTER DELETE AS
BEGIN
    DELETE FROM [Lab15_2].[dbo].Product WHERE supplier_code IN (SELECT Supplier_code FROM deleted)
END
GO

IF OBJECT_ID(N'SupplierUpd') is NOT NULL
	DROP TRIGGER SupplierUpd
GO

CREATE TRIGGER SupplierUpd
ON Supplier
INSTEAD OF UPDATE AS
BEGIN
	IF UPDATE(supplier_code)
	BEGIN
		RAISERROR('[UPD TRIGGER]: Supplier_code cant upd', 15, -1);
	END
	ELSE 
	BEGIN
		IF UPDATE(Phone)
		BEGIN
			UPDATE Supplier
			SET Phone = (SELECT Phone FROM inserted WHERE inserted.Supplier_code = Supplier.Supplier_code)
			WHERE Supplier_code = (SELECT Supplier_code FROM inserted WHERE inserted.Supplier_code = Supplier.Supplier_code);
		END

		IF UPDATE(address)
		BEGIN
			UPDATE Supplier
			SET address = (SELECT address FROM inserted WHERE inserted.Supplier_code = Supplier.Supplier_code)
			WHERE Supplier_code = (SELECT Supplier_code FROM inserted WHERE inserted.Supplier_code = Supplier.Supplier_code);
		END
	END
END;
GO



select * from Supplier
go
update Supplier set PHONE = PHONE
go
select * from Supplier
go


USE Lab15_2
GO

IF OBJECT_ID(N'Product') is NOT NULL
	DROP TABLE Product
GO

CREATE TABLE Product (
	Item_Number INT NOT NULL PRIMARY KEY,
	Name_of_product VARCHAR(50) NOT NULL,
	Price money NOT NULL,
		CHECK (price > 0),
	Supplier_code INT
)
GO

INSERT Product VALUES
	(1,'Milk', 60, 1),
	(2,'Сheese', 100, 1),
	(3,'Chocolate', 70, 2),
	(4,'Bread', 40, 3),
	(5,'Potato', 20, 4),
	(6,'Eggs', 120, 6),
	(7,'Bananas', 140, 5);

GO

CREATE TRIGGER ProductIns
    ON Product
    INSTEAD OF INSERT AS
BEGIN
    IF EXISTS(SELECT Item_Number FROM inserted WHERE inserted.Item_Number IN (SELECT Item_Number FROM [lab15_2].DBO.Product))
		BEGIN
            RAISERROR('[INS TRIGGER]: Product is already available', 11, 1)
		END
	ELSE BEGIN
			IF EXISTS (SELECT item_number FROM inserted WHERE Supplier_code NOT IN (SELECT Supplier_code FROM [lab15_1].[dbo].Supplier))
			BEGIN
				RAISERROR('[INS TRIGGER]: first add supplier', 11, 1)
				END
			ELSE 
				BEGIN
					INSERT INTO Product
						SELECT
							i.Item_Number,
							i.name_of_product,
							i.price,
							i.supplier_code
							FROM inserted AS i
		END	
		END
END
	
GO


IF OBJECT_ID(N'ProductUpd') is NOT NULL
	DROP TRIGGER ProductUpd
GO


CREATE TRIGGER ProductUpd
	ON Product
INSTEAD OF UPDATE AS
	BEGIN
	 IF UPDATE(Supplier_code)
		RAISERROR('[UPD TRIGGER]: Supplier_code cant upd', 15, -1)
	 ELSE IF UPDATE(Price)
		UPDATE Product
		Set price = (select Price from inserted where inserted.Supplier_code = Supplier_code)
										where Supplier_code = (select Supplier_code from inserted where inserted.Supplier_code = Supplier_code)
	END
GO

select * from Product
update Product set Supplier_code = 1000
select * from Product


USE lab15_3
GO

IF OBJECT_ID(N'SuppliersProducts') is NOT NULL
	DROP VIEW SuppliersProducts
GO

CREATE VIEW SuppliersProducts
AS
  SELECT  S.Supplier_code, S.Address, P.Item_Number, P.Name_of_product,p.Price
  FROM [lab15_1].[dbo].Supplier AS S INNER JOIN [lab15_2].[dbo].Product P on S.Supplier_code = P.Supplier_code
GO


SELECT * FROM SuppliersProducts

SELECT * FROM [Lab15_1].[DBO].Supplier

SELECT * FROM [Lab15_2].[DBO].Product
GO


UPDATE [Lab15_1].[DBO].Supplier
	SET Supplier_code = 8
		where Supplier_code = 4
GO

UPDATE [Lab15_1].[DBO].Supplier
	SET Phone = '89856736695'
		where Supplier_code = 4;
GO
UPDATE [LAB15_1].[DBO].Supplier
	SET Address = '466485, Магаданская область, город Волоколамск, пл. Ленина, 39'
		where Supplier_code = 2
	GO
UPDATE [Lab15_1].[DBO].Supplier
	SET Phone = '89152052623', Supplier_code = 4
		where Supplier_code = 5;
GO

INSERT [LAB15_2].[DBO].Product
VALUES
		(8, 'Milk', 50, 6)
GO

INSERT [LAB15_2].[DBO].Product
VALUES
		(3, 'Milk', 50, 6)
GO

INSERT [LAB15_2].[DBO].Product
VALUES
		(9, 'Milk', 50, 7)
GO


SELECT * FROM SuppliersProducts

SELECT * FROM [Lab15_1].[DBO].Supplier

SELECT * FROM [Lab15_2].[DBO].Product
GO