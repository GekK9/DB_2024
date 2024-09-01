Use Lab1;
GO
 
--1.������� ������������� �� ������ ����� �� ������ ������� 6.

IF OBJECT_ID(N'FullAgeClients_INDX_VIEW', N'V') IS NOT NULL
    DROP VIEW FullAgeClients_INDX_VIEW;
GO

IF OBJECT_ID(N'CLients_with_age') is NOT NULL
	DROP TABLE Clients_with_age;
GO

CREATE TABLE Clients_with_age
	(
	Client_code int IDENTITY(1000, 1) PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	Age INT NOT NULL,
	Address NVARCHAR(100) UNIQUE DEFAULT 'Unknown',
	Phone_number NVARCHAR(10) UNIQUE NOT NULL,
		CHECK (LEN(phone_number) = 10),
	);
GO

INSERT INTO  Clients_with_age(Name, Address, Age, Phone_number)
   VALUES 
	('Artem', '294060, �������� �������, ����� �������, ������� ������, 71', 24 , 9502422455),
	('Yan', '783595, ������������� �������, ����� ���������, ����� �������, 40',19 , 9083528814),
	('Nastya', '336490, ��������� �������, ����� ������, ����� ��������, 79',16, 9663241425),
	('Anton','296543, ��������� �������, ����� �������������, ����� ������, 84',17, 9856759952);

GO

IF OBJECT_ID(N'FullAgeClients', N'V') is NOT NULL
    DROP VIEW FullAgeClients;
GO

CREATE VIEW FullAgeClients AS
    SELECT *
    FROM Clients_with_age
    WHERE Age >= 18
GO

SELECT * FROM FullAgeClients
 
--2.������� ������������� �� ������ ����� ����� ��������� ������ ������� 6.
IF OBJECT_ID(N'QtyAvailable_OrderedProduct', N'V') is NOT NULL
    DROP VIEW QtyAvailable_OrderedProduct;
GO

CREATE VIEW QtyAvailable_OrderedProduct AS
    SELECT 
        P.item_number as '�������', 
        P.Name_of_product as '�������� ������', 
        P.QtyAvailable AS '���-�� �� ������',
		O.Volume AS '�������',
		P.QtyAvailable - O.Volume AS '������� �� ������'
    FROM Product P
    INNER JOIN Ordered_product O
        ON P.Item_number = O.Item_number;
GO
 
SELECT * FROM QtyAvailable_OrderedProduct;
GO
 
 
--3.������� ������ ��� ����� �� ������ ������� 6, ������� � ���� �������������� ���������� ����.
IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'ClientsAddresses_INDX')
	DROP INDEX ClientsAddresses_INDX on Clients;
GO

CREATE INDEX ClientsAddresses_INDX
    ON Clients(Client_code)
    INCLUDE (Address);
GO
 
 
--4.������� ��������������� �������������.

CREATE VIEW FullAgeClients_INDX_VIEW
    WITH SCHEMABINDING  
    AS SELECT Client_Code, Name, Age
    FROM dbo.Clients_with_age
    WHERE Age >= 20;
GO


IF EXISTS (SELECT NAME FROM sys.indexes 
            WHERE NAME = N'FullAgeClients_INDX')
    DROP INDEX FullAgeClients_INDX_VIEW ON Client_with_age;
GO

CREATE UNIQUE CLUSTERED INDEX ClientsAddresses_INDX
    on FullAgeClients_INDX_VIEW(Client_code, Name, Age);
GO


SELECT * FROM FullAgeClients_INDX_VIEW;
GO

 SELECT *
FROM sys.indexes
WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = 'Clients_with_age');