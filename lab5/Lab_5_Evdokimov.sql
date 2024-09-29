USE LAB5;
GO

IF OBJECT_ID(N'Client') IS NOT NULL
	DROP TABLE Client;
GO

CREATE TABLE Client
	(
	Client_code INT PRIMARY KEY NOT NULL ,
	Name NVARCHAR(80) NOT NULL,
	ADDRESS NCHAR(80) UNIQUE NOT NULL ,
	Phone_number INT UNIQUE NOT NULL
	)
GO

ALTER DATABASE Lab5
	ADD FILEGROUP Lab5_filegroup;
GO

ALTER DATABASE Lab5
	ADD FILE 
	(
	NAME = 'alter_lab5_dat',
	FILENAME = 'C:\BD\lab5\alter_lab5_dat.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%)
TO FILEGROUP Lab5_filegroup;
GO

ALTER DATABASE Lab5
MODIFY FILEGROUP Lab5_filegroup DEFAULT;
GO


IF OBJECT_ID(N'Product') is NOT NULL
	DROP TABLE Product	
GO

CREATE TABLE Product 
	(
	Item_number int PRIMARY KEY NOT NULL,
	Name_of_product NCHAR(50) UNIQUE NOT NULL,
	Price INT,
	);
GO



INSERT INTO Product
VALUES 
(1, 'Milk', 10),
(2, 'bread', 24)
GO


ALTER DATABASE Lab5
	ADD FILEGROUP Lab5_1_filegroup;
GO

ALTER DATABASE Lab5
	ADD FILE 
	(
	NAME = 'alter_lab5_1_dat',
	FILENAME = 'C:\BD\lab5\alter_lab5_1_dat.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%)
TO FILEGROUP Lab5_1_filegroup;
GO


ALTER DATABASE Lab5
MODIFY FILEGROUP Lab5_1_filegroup DEFAULT;
GO

IF OBJECT_ID(N'Product_copy') is NOT NULL
	DROP TABLE product_copy;
GO

SELECT *
INTO dbo.product_copy 
FROM Product  
GO  

SELECT * FROM dbo.product_copy;
GO

sp_help product

DROP TABLE product;
GO


select * from sys.filegroups;
GO

ALTER DATABASE Lab5
	MODIFY	FILEGROUP [primary] DEFAULT;
GO

alter database lab5
    remove file alter_lab5_dat;
go
alter database lab5
    remove filegroup Lab5_filegroup;
go

sp_help product_copy

Select * from product_copy;
GO


DROP TABLE product_copy;
GO

alter database lab5
    remove file alter_lab5_1_dat;
go
alter database lab5
    remove filegroup Lab5_1_filegroup;
go

CREATE SCHEMA Lab5_schema;
GO

ALTER SCHEMA Lab5_schema TRANSFER Client;
GO

DROP TABLE lab5_schema.Client;
GO

DROP SCHEMA lab5_schema;
GO

select * from sys.filegroups;
