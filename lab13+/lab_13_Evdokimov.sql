use master;
go
if DB_ID (N'lab13_1') is not null
	drop database lab13_1;
go
create database lab13_1
go


use master;
go
if DB_ID (N'lab13_2') is not null
	drop database lab13_2;
go
create database lab13_2
go


--2.Создать в базах данных п.1. горизонтально фрагментированные таблицы.
use lab13_1;
go
if OBJECT_ID(N'dbo.products', N'U') is not null
    drop table dbo.products;
go
create table dbo.products (
	item_number	int  not null,
	name_of_product  varchar(254),
    price money,
	PRIMARY KEY (item_number),
	CONSTRAINT CHK_products_item_number
                CHECK (item_number <= 5)
    );
go


use lab13_2;
go
if OBJECT_ID(N'dbo.products', N'U') is not null
    drop table dbo.products;
go
create table dbo.products (
	item_number	int  not null,
   name_of_product   varchar(254),
    price money,
	PRIMARY KEY (item_number),
	CONSTRAINT CHK_products_item_number
                CHECK (item_number > 5)
    );
go



--3.Создать секционированные представления, обеспечивающие работу с данными таблиц 
	--(выборку, вставку, изменение, удаление).
use lab13_1;
go
if OBJECT_ID(N'horizontal_dist_v', N'V') is not null
	drop view horizontal_dist_v;
go
create view horizontal_dist_v as
	select * from lab13_1.dbo.products
	union all					
	select * from lab13_2.dbo.products
go



insert horizontal_dist_v values
	(1, 'Milk', 60),
	(2, 'Сheese', 100),
	(3, 'Chocolate', 70),
	(6, 'Bread', 40),
	(10, 'Potato', 20);

select * from horizontal_dist_v

update horizontal_dist_v
	set name_of_product = 'milk 3.5%'
	where item_number = 1

delete horizontal_dist_v
	where name_of_product = 'potato'

select * from lab13_1.dbo.products;
select * from lab13_2.dbo.products;