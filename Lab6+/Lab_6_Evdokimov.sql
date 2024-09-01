USE Lab1;
GO

IF OBJECT_ID(N'Ordered_product') is NOT NULL
	DROP TABLE Ordered_product;
GO

IF OBJECT_ID(N'Product') is NOT NULL
	DROP TABLE Product;
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
	Name NVARCHAR(100) NOT NULL,
	Address NVARCHAR(100) UNIQUE DEFAULT 'Unknown',
	Phone_number NVARCHAR(10) UNIQUE NOT NULL,
		CHECK (LEN(phone_number) = 10),
	);
GO

INSERT INTO  Clients(Name, Address, Phone_number)
   VALUES 
	('Artem', '294060, Тульская область, город Зарайск, бульвар Ленина, 71', 9502422455),
	('Yan', '783595, Волгоградская область, город Раменское, въезд Косиора, 40', 9083528814),
	('Nastya', '336490, Читинская область, город Мытищи, шоссе Гагарина, 79', 9663241425),
	('Anton','296543, Самарская область, город Солнечногорск, шоссе Чехова, 84', 9856759952);

GO
-- Способ 1
SELECT SCOPE_IDENTITY();

GO
-- Способ 2
SELECT @@IDENTITY;

GO
-- Способ 3

SELECT IDENT_CURRENT('CLients');
GO
-- Способ 4
SELECT * FROM Clients;
GO

CREATE TABLE Orders
	(
	ID_of_order uniqueidentifier ROWGUIDCOL DEFAULT (newid()) PRIMARY KEY NOT NULL,
	Number_of_order int IDENTITY UNIQUE,
	Client_code int REFERENCES Clients(Client_code) NOT NULL,
	Date_of_order date NOT NULL,
	CONSTRAINT CHK_Date_of_order
		CHECK (Date_of_order > CONVERT(DATETIME, '1/1/1990', 103)),
	status NVARCHAR(20) DEFAULT 'Обрабатывается' NOT NULL,
		CHECK (status IN('Обрабатывается','Обработан', 'Доставка', 'Выполнен')),
	Comment NVARCHAR(100) DEFAULT 'Нет примечания',
	);
GO


INSERT INTO Orders(Client_code, Date_of_order, status, Comment)
	VALUES
	(1000, '22/11/2023', 'Обработан', 'Самовывоз'),
	(1000, '18/09/2023', 'Выполнен', DEFAULT),
	(1001, '23/11/2023', DEFAULT, 'До двери'),
	(1002, '11/10/2023', 'Выполнен', DEFAULT),
	(1003, '20/11/2023', 'Доставка', 'Срочный заказ');
GO

SELECT * FROM Orders;
GO

SELECT Clients.Client_code, Name, Number_of_order, ID_of_order, status
	FROM Clients, Orders WHERE Clients.Client_code = Orders.Client_code
GO


IF OBJECT_ID('ProductSequence') IS NOT NULL
    DROP SEQUENCE ProductSequence;
GO

CREATE SEQUENCE ProductSequence
    START WITH 200003
    INCREMENT BY 738;
GO

CREATE TABLE Product
	(
	Item_number int DEFAULT (NEXT VALUE FOR ProductSequence) PRIMARY KEY,
	Name_of_product NVARCHAR(80) UNIQUE NOT NULL,
	QtyAvailable smallint,
	Price money NOT NULL,
		CHECK(Price > 0),
	InventoryValue AS QtyAvailable * Price
    );
GO

INSERT INTO Product(Name_of_product, QtyAvailable, Price)
	VALUES
		('Apple', 0, 20),
		('Banana', 100, 45),
		('Milk', 124, 10),
		('Watermelon', 80, 100); 
GO

SELECT * FROM Product;
GO



CREATE TABLE Ordered_product
	(
	ID_of_order uniqueidentifier ROWGUIDCOL REFERENCES Orders(ID_of_order),
	Item_Number int REFERENCES Product(Item_number),
	Volume int NOT NULL,
		CHECK(Volume > 0),
	Total_price money NOT NULL DEFAULT 0,
	PRIMARY KEY(ID_of_order, Item_number)
	);

GO
DECLARE 
	@TypeID uniqueidentifier,
	@TypeID_2 uniqueidentifier

SELECT @TypeID=ID_of_order
FROM Orders
WHERE Number_of_order = 1

SELECT @TypeID_2=ID_of_order
FROM Orders
WHERE Number_of_order = 2

INSERT INTO Ordered_product(ID_of_order, Item_Number, Volume)
	VALUES
		(@TypeID, 200003, 5),
		(@TypeID_2, 200741, 13);
GO

UPDATE Ordered_product
SET Total_price = product.price * Volume
FROM Product
WHERE Product.Item_number = Ordered_product.Item_Number
GO


SELECT * FROM Ordered_product
GO


--ALTER TABLE Ordered_product
--	ADD CONSTRAINT Item_number_FK FOREIGN KEY(item_number) REFERENCES Product(Item_number) ON DELETE CASCADE;

--ALTER TABLE Ordered_product
--	ADD CONSTRAINT ID_of_order_FK FOREIGN KEY(ID_of_order) REFERENCES Orders(ID_of_order) ON DELETE CASCADE;
--GO

--DELETE FROM Product 
--WHERE Item_number = 200003;
--GO

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT Item_number_FK ;

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT ID_of_order_FK;

--GO

--ALTER TABLE Ordered_product
--	ADD CONSTRAINT Item_number_FK FOREIGN KEY(item_number) REFERENCES Product(Item_number) ON DELETE SET NULL;

--ALTER TABLE Ordered_product
--	ADD CONSTRAINT ID_of_order_FK FOREIGN KEY(ID_of_order) REFERENCES Orders(ID_of_order) ON DELETE SET NULL;

--GO

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT Item_number_FK ;

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT ID_of_order_FK;

--GO

--ALTER TABLE Ordered_product
--	ADD CONSTRAINT Item_number_FK FOREIGN KEY(item_number) REFERENCES Product(Item_number) ON DELETE SET DEFAULT;

--ALTER TABLE Ordered_product
--	ADD CONSTRAINT ID_of_order_FK FOREIGN KEY(ID_of_order) REFERENCES Orders(ID_of_order) ON DELETE SET DEFAULT;

--GO

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT Item_number_FK ;

--ALTER TABLE Ordered_product
--	DROP CONSTRAINT ID_of_order_FK;

--GO


--DELETE FROM PRODUCT 
--WHERE item_number = 200003
--GO

--SELECT * FROM PRODUCT;
--GO

--SELECT * FROM Ordered_product
--GO