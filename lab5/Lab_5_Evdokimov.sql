USE master;
GO

IF DB_ID (N'lab5') IS NOT NULL
	DROP DATABASE lab5;
GO

CREATE DATABASE lab5
	ON (NAME = lab5_dat, FILENAME = "C:\BD\lab5\lab5dat.mdf",
		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
	LOG ON (NAME = lab5_log, FILENAME = "C:\BD\lab5\lab5log.ldf",
		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
GO

USE lab5;
GO

IF OBJECT_ID(N'Players') IS NOT NULL
	DROP TABLE Players;
GO

CREATE TABLE Players 
	(
	User_login varchar(20) PRIMARY KEY NOT NULL,
	Email varchar(254) UNIQUE NOT NULL,
	Donate_points int NOT NULL,
	Registration_Date datetime NOT NULL
	)
GO

ALTER DATABASE lab5 
	ADD FILEGROUP lab5_filegroup;
GO
ALTER DATABASE lab5
	ADD FILE 
	(
	NAME = 'alter_lab5_dat',
	FILENAME = 'C:\BD\lab5\alter_lab5_dat.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5%)
TO FILEGROUP lab5_filegroup;
GO

ALTER DATABASE lab5
MODIFY FILEGROUP lab5_filegroup DEFAULT;
GO

IF OBJECT_ID(N'Maps') IS NOT NULL
	DROP TABLE Maps;
GO

CREATE TABLE Maps
	(
	map_code int PRIMARY KEY NOT NULL IDENTITY(1,1),
	map_name varchar(45) NOT NULL UNIQUE
	)
GO

select * from sys.filegroups

select * from Maps;
select * from Players;
GO

ALTER DATABASE Lab5
	MODIFY	FILEGROUP [primary] DEFAULT;
GO

IF OBJECT_ID(N'maps_copy') is NOT NULL
	DROP TABLE maps_copy;
GO

SELECT *
INTO dbo.Maps_copy 
FROM Maps  
GO  

alter database lab5
    remove file alter_lab5_dat
	
go

drop table maps;
go

alter database lab5
    remove filegroup Lab5_filegroup;
go

select * from sys.filegroups
GO
--sp_help Maps;
--GO
--sp_help Players;


CREATE SCHEMA Lab5_schema;
GO

ALTER SCHEMA Lab5_schema TRANSFER maps_copy;
GO

DROP TABLE lab5_schema.maps_copy;
GO

DROP SCHEMA lab5_schema;
GO
