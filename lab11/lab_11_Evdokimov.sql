SET NOCOUNT ON;
USE Lab11;
GO

IF OBJECT_ID(N'Ordered_product') is NOT NULL
	DROP TABLE Ordered_product;
GO

IF OBJECT_ID(N'Orders') is NOT NULL
	DROP TABLE Orders;
GO

IF OBJECT_ID(N'Product') is NOT NULL
	DROP TABLE Product;
GO

IF OBJECT_ID(N'Supplier') is NOT NULL
	DROP TABLE Supplier;
GO

IF OBJECT_ID(N'Shop') is NOT NULL
	DROP TABLE Shop;
GO

IF OBJECT_ID(N'Clients') is NOT NULL
	DROP TABLE Clients;
GO

CREATE TABLE Clients (
	Client_code INT IDENTITY(1, 1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Address VARCHAR(100) DEFAULT 'Unknown',
	Phone_number CHAR(11) NOT NULL UNIQUE,
		CHECK (LEN(Phone_number) = 11)
)
GO

INSERT INTO  Clients(Name, Address, Phone_number)
   VALUES 
	('Artem', '294060, Тульская область, город Зарайск, бульвар Ленина, 71', 89502422455),
	('Yan', '783595, Волгоградская область, город Раменское, въезд Косиора, 40', 89083528814),
	('Nastya', '336490, Читинская область, город Мытищи, шоссе Гагарина, 79', 89663241425),
	('Anton','296543, Самарская область, город Солнечногорск, шоссе Чехова, 84', 89856759952),
	('Ekaterina','574925, Волгоградская область, город Лотошино, спуск Бухарестская, 04', 89889350352),
	('Anton', '919966, Оренбургская область, город Серебряные Пруды, пр. Космонавтов, 21', 89501222500);

GO

CREATE TABLE Shop (
	Company_code INT NOT NULL PRIMARY KEY,
	Company_name VARCHAR(50) NOT NULL,
	Address VARCHAR(100) NOT NULL,
	Shop_email VARCHAR(254) NOT NULL,
	Contact_number CHAR(11) NOT NULL,
)
GO

INSERT INTO  Shop(Company_code, Company_name, Address, Shop_email, Contact_number)
   VALUES 
	(34634346,'OOO ОПТ ПРОДУКТЫ СПБ', '294060, Ленинградская область, город Санкт-Петербург, бульвар Ленина, 71','Opt_Products@opt.ru', '89633422455')
GO

CREATE TABLE Supplier (
	Supplier_code INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	Address VARCHAR(100) NOT NULL,
	Phone CHAR(11) NOT NULL UNIQUE,
		CHECK (LEN(Phone) = 11),
)
GO

INSERT INTO  Supplier(Address, Phone)
   VALUES 
	('641533, Орловская область, город Можайск, бульвар Домодедовская, 23','89152052653'),
	('350334, Волгоградская область, город Балашиха, шоссе Сталина, 79','89820152345'),
	('241983, Читинская область, город Люберцы, въезд Гоголя, 43','89872526828'),
	('466485, Магаданская область, город Волоколамск, пл. Ленина, 39','89876578877'),
	('463061, Иркутская область, город Луховицы, пл. Ладыгина, 63','89512481411'),
	('250211, Ярославская область, город Мытищи, проезд Ленина, 11','89242621734')
GO

CREATE TABLE Product (
	Item_Number INT NOT NULL PRIMARY KEY,
	Name_of_product VARCHAR(50) NOT NULL,
	Price money NOT NULL,
		CHECK (price > 0),
	Supplier_code INT FOREIGN KEY REFERENCES Supplier(Supplier_code) ON DELETE CASCADE,
)
GO
INSERT Product VALUES
	(235, 'Milk', 60, 1),
	(124, 'Сheese', 100, 1),
	(373, 'Chocolate', 70, 2),
	(6262, 'Bread', 40, 3),
	(2626, 'Potato', 20, 4),
	(5252, 'Eggs', 120, 6),
	(23425, 'Bananas', 140, 5);

GO


CREATE TABLE Orders (
	Number_of_order INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	Date_of_order date NOT NULL ,
		CONSTRAINT CHK_Date_of_order
		CHECK (Date_of_order > CONVERT(DATETIME, '1/1/1990', 103)),
	Price_of_order money,
	status NVARCHAR(20) DEFAULT 'Обрабатывается' NOT NULL,
		CHECK (Status IN('Обрабатывается','Обработан', 'Доставка', 'Выполнен')),
	Client_code INT FOREIGN KEY REFERENCES Clients(Client_code) ON DELETE NO ACTION,
	Company_code INT FOREIGN KEY REFERENCES Shop(Company_code) ON DELETE NO ACTION DEFAULT 34634346,
)
GO


INSERT Orders (date_of_order, status, client_Code)
	VALUES
		(GETDATE(), 'Обрабатывается', 3),
		('14/02/2023', 'Выполнен', 3),
		('18/07/2023', 'Выполнен', 2),
		('17/12/2023', 'Доставка', 1),
		('18/12/2023', 'Обработан', 4)
GO


CREATE TABLE Ordered_product (
	Number_of_order INT REFERENCES Orders(number_of_order) ON DELETE CASCADE,
	Item_number INT REFERENCES Product(Item_number),
	Volume INT NOT NULL,
	Total_price money NOT NULL DEFAULT 0,
	PRIMARY KEY(number_of_order, Item_number)
)
GO

INSERT Ordered_product (number_of_order, Item_number, Volume)
	VALUES
		(4, 235, 4),
		(4, 6262, 1),
		(3, 235, 3),
		(3, 6262, 3),
		(3, 2626, 2),
		(1, 235, 1),
		(1, 373, 3),
		(2, 124, 7),
		(2, 235, 12),
		(5, 124, 6),
		(5,6262, 1)
GO

IF OBJECT_ID(N'Update_price_of_order_if_ordered_product_deleted') is NOT NULL
	DROP TRIGGER Update_price_of_order_if_ordered_product_deleted;
GO

CREATE TRIGGER Update_price_of_order_if_ordered_product_deleted
ON Ordered_product
FOR DELETE
AS 
	UPDATE Orders 
	SET Price_of_order = summedValue
	FROM Orders
	JOIN (
		SELECT SUM(Total_price) as summedvalue, Number_of_order AS NumOrd
		FROM Ordered_product GROUP BY Number_of_order
		) s on Orders.Number_of_order = NumOrd
GO




UPDATE Ordered_product
	SET Total_price = product.price * Volume
	FROM Product
	WHERE Product.Item_number = Ordered_product.Item_Number
GO

IF OBJECT_ID(N'Have_Orders') is NOT NULL 
    DROP FUNCTION Have_Orders
GO

CREATE FUNCTION Have_Orders(@ClientCode INT)
    RETURNS INT
    BEGIN
		DECLARE @result TINYINT;
        IF EXISTS (SELECT 1 FROM Orders WHERE Orders.Client_code = @ClientCode)
			SET @result = 1;
		ELSE
			SET @result = 0;
		
    
        RETURN @result;
    END
GO


UPDATE Orders 
	SET Price_of_order = summedValue
	FROM Orders
	INNER JOIN (
		SELECT SUM(Total_price) as summedvalue, Number_of_order AS NumOrd
		FROM Ordered_product GROUP BY Number_of_order
		) s on Orders.Number_of_order = NumOrd
GO



ALTER TABLE Clients 
	ADD  have_orders TINYINT;
GO

UPDATE Clients
	SET have_orders  = [dbo].Have_Orders(Client_code)
GO

SELECT * FROM Clients;
GO

IF OBJECT_ID(N'ClientsWithOrders') is NOT NULL
	DROP PROCEDURE ClientsWithOrders;
GO

CREATE PROCEDURE ClientsWithOrders
AS
    SET NOCOUNT ON;
    SELECT *
    FROM Clients
	WHERE have_orders = 1;
GO

EXEC ClientsWithOrders;

SELECT * FROM Orders
ORDER BY Price_of_order;
GO

SELECT * FROM Ordered_product;
GO	

SELECT * FROM Orders;
GO

IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'ClientsAddresses_INDX')
	DROP INDEX ClientsAddresses_INDX on Clients;
GO

CREATE INDEX ClientsAddresses_INDX
    ON Clients(Client_code)
    INCLUDE (Address);
GO


DELETE FROM Ordered_product
	WHERE Number_of_order = 1 AND Item_number = 235
GO

SELECT * FROM Product;
GO

SELECT * FROM Orders;
GO

SELECT * 
FROM Orders
WHERE Price_of_order BETWEEN 600 AND 1500;
GO

SELECT * FROM Clients
WHERE Address LIKE '%Волгоградская%'
GO

SELECT c.Client_code, C.name, c.Phone_number
FROM Clients AS C  
WHERE EXISTS  
(SELECT *  
    FROM Orders as o
    WHERE c.Client_code = o.Client_code) ;  
GO  

SELECT * 
FROM Orders 
WHERE status IN('Выполнен', 'Доставка');
GO

SELECT * FROM Ordered_product;
GO	


SELECT DISTINCT Name_of_product AS 'Наименование', Ordered_product.Item_number AS 'Артикль', Price AS 'Цена'
	FROM Ordered_product
		FULL OUTER JOIN Product
		ON Product.Item_number = Ordered_product.Item_number
GO

SELECT  *
	FROM Ordered_product
		FULL OUTER JOIN Product
		ON Product.Item_number = Ordered_product.Item_number
		ORDER BY total_price ASC
GO

SELECT *
	FROM Ordered_product
		LEFT OUTER JOIN Product
		ON Product.Item_number = Ordered_product.Item_number
		ORDER BY total_price DESC
GO

SELECT *
	FROM Ordered_product
		RIGHT OUTER JOIN Product
		ON Product.Item_number = Ordered_product.Item_number
		WHERE Number_of_order is NULL
GO




IF OBJECT_ID(N'ViewClients') is NOT NULL
	DROP VIEW ViewClients;
GO

CREATE VIEW ViewClients AS
    SELECT Client_code AS 'Код клиента', 
           name AS 'Имя клиента',
           CONCAT(SUBSTRING(address, 1, 2), '*****', SUBSTRING(address, LEN(Address) - 7, LEN(address))) AS 'Адрес',
		   CONCAT(SUBSTRING(Phone_number, 1, 3), '*****', SUBSTRING(Phone_number, LEN(Phone_number) - 2, LEN(Phone_number))) AS 'Номер телефона'
FROM Clients;
GO

SELECT * FROM ViewClients;
GO

SELECT * FROM Orders;
GO

SELECT Client_code, SUM(Price_of_order) AS 'Сумма покупок' FROM orders
GROUP BY client_code
HAVING sum(Price_of_order) > 400
ORDER BY 'Сумма покупок'
GO

SELECT item_number, MAX(volume) FROM Ordered_product
GROUP BY Item_number;
GO

SELECT item_number, MIN(volume) FROM Ordered_product
GROUP BY Item_number;
GO


SELECT item_number, AVG(total_price) from Ordered_product
GROUP BY Item_number;
GO

SELECT item_number, COUNT(*) from Ordered_product
GROUP BY Item_number;
GO

SELECT Name FROM Clients
UNION ALL
SELECT Name_of_product FROM Product
GO

SELECT Name FROM Clients
UNION
SELECT Name_of_product FROM Product
GO

SELECT Name FROM Clients
INTERSECT
SELECT Name_of_product FROM Product
GO

SELECT Name FROM Clients
EXCEPT
SELECT Name_of_product FROM Product
GO

SELECT Name, client_code,
	(SELECT SUM(Price_of_order) AS 'Сумма покупок' FROM orders AS o
GROUP BY client_code 
HAVING c.Client_code = o.client_code)
FROM Clients AS C

GO

IF OBJECT_ID(N'New_and_Old_Clients') is NOT NULL
	DROP TABLE New_and_Old_Clients;
GO

CREATE TABLE New_and_Old_Clients
	(
		Client_code INT IDENTITY(1, 1) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Address VARCHAR(100) DEFAULT 'Unknown',
	Phone_number CHAR(11) NOT NULL UNIQUE,
		CHECK (LEN(Phone_number) = 11),
	);
GO

INSERT INTO  New_and_Old_Clients(Name, Address, Phone_number)
   VALUES 
	('Arut', '257980, Пензенская область, город Раменское, спуск Гоголя, 40', 89059145732),
	('Kirill','689435, Астраханская область, город Дмитров, бульвар Ломоносова, 14', 89867425722),
	('Sergei', '475207, Сахалинская область, город Шатура, пл. Ломоносова, 46', 89852645222),
	('Milana','560643, Ростовская область, город Ногинск, наб. Сталина, 27', 89087458824),
	('Oksana','482782, Липецкая область, город Видное, наб. Балканская, 95', 89025678824)
GO

INSERT INTO New_and_Old_Clients(name, address, phone_number)
	SELECT name, address, phone_number FROM Clients		
GO

SELECT * FROM New_and_Old_Clients;
GO


