use master;
go
if DB_ID (N'lab14_1') is not null
	drop database lab14_1;
go
create database lab14_1
go


use master;
go
if DB_ID (N'lab14_2') is not null
	drop database lab14_2;
go
create database lab14_2
go


--1.Создать в базах данных п.1. горизонтально фрагментированные таблицы.

use lab14_1;
go
if OBJECT_ID(N'dbo.products', N'U') is not null
    drop table dbo.products;
go
create table dbo.products (
	item_number	int  not null,
	name_of_product varchar(254),
	PRIMARY KEY (item_number),
    );
go


use lab14_2;
go
if OBJECT_ID(N'dbo.products', N'U') is not null
    drop table dbo.products;
go
create table dbo.products (
	item_number	int  not null,
    price money,
	PRIMARY KEY (item_number),
    );
go
 
--2.Создать необходимые элементы базы данных (представления, триггеры), 
	--обеспечивающие работу с данными вертикально фрагментированных таблиц (выборку, вставку, изменение, удаление).

use lab14_2;
go

if OBJECT_ID(N'vertical_dist_v', N'V') is not null
    drop view vertical_dist_v;
go

create view vertical_dist_v as
    select one.item_number,  one.name_of_product, two.price
        from lab14_1.dbo.products as one,
            lab14_2.dbo.products as two
        where one.item_number = two.item_number
go
 
 

--INSERT

if OBJECT_ID(N'dbo.dist_ins', N'TR') is not null
    drop trigger dbo.dist_ins
go
create trigger dbo.dist_ins
    on dbo.vertical_dist_v
    instead of insert
    as
    begin
 
        insert into lab14_1.dbo.products(item_number, name_of_product )
            select item_number, name_of_product
                from inserted
 
        insert into lab14_2.dbo.products(item_number, price)
            select item_number, price
                from inserted
    end
go
 
insert into dbo.vertical_dist_v values
    (1, 'Milk', 60),
	(2, 'Сheese', 100),
	(3, 'Chocolate', 70),
	(4, 'Bread', 40),
	(5, 'Potato', 20);
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.products
select * from lab14_2.dbo.products
 
 

--DELETE

if OBJECT_ID(N'dbo.dist_del', N'TR') is not null
    drop trigger dbo.dist_del
go
create trigger dbo.dist_del
    on dbo.vertical_dist_v
    instead of delete
    as
    begin
       
        delete lab14_1.dbo.products
            where item_number in (select d.item_number
                from deleted as d)
 
        delete lab14_2.dbo.products
            where item_number in (select d.item_number
                from deleted as d)
    end
go
 
delete dbo.vertical_dist_v
    where name_of_product = 'potato'
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.products
select * from lab14_2.dbo.products
 
 

--UPDATE

if OBJECT_ID(N'dbo.dist_upd', N'TR') is not null
    drop trigger dbo.dist_upd
go
create trigger dbo.dist_upd
    on dbo.vertical_dist_v
    instead of update
    as
    begin
 
        if UPDATE(item_number)
            raiserror('[UPD TRIGGER]: "item_number" cant be modidfied', 16, 1)
        else
        begin
 
            update lab14_1.dbo.products
                
 
            update lab14_2.dbo.products
                set products.price = (select price from inserted where inserted.item_number = products.item_number)
                    where products.item_number = (select item_number from inserted where inserted.item_number = products.item_number)
        end
    end
go
 
update dbo.vertical_dist_v
    set price = '65'
    where name_of_product = 'milk'
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.products
select * from lab14_2.dbo.products