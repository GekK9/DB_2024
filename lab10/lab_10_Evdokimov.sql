
QUERY1:

if OBJECT_ID('dbo.products') is not null
    drop table dbo.products;
go

create table dbo.products
(
    id int,
    name varchar(50),
    category varchar(50),
    quantity int,
    price int,
    PRIMARY KEY (id)
);
go

insert into dbo.products (id, name, category, quantity, price) values
    (1, 'Milk', 'Milk Products', 100, 10.99),
    (2, 'Water', 'drink', 50, 20.99),
    (3, 'Cheese', 'Milk Products', 200, 5.49);
go

--===========================================
-- READ UNCOMMITTED (грязное чтение)
-- Чтение данных, даже если они изменены в незавершённой транзакции
--===========================================

begin transaction;
select * from dbo.products; 
update dbo.products 
    set quantity = 80 
    where id = 1; 
waitfor delay '00:00:05'; 
select * from dbo.products;
commit;

-- ===========================================
-- READ COMMITTED (подтвержденное чтение)
-- Чтение только тех данных, которые были зафиксированы
-- Изменения в данных после чтения могут быть видны
-- ===========================================

begin transaction;
select * from dbo.products;
update dbo.products 
    set quantity = 70 
    where id = 2;
waitfor delay '00:00:05';
select * from dbo.products;
commit;

-- ===========================================
-- REPEATABLE READ (повторяемое чтение)
-- Повторное чтение данных в транзакции не изменяет их, но новые строки могут быть вставлены
-- ===========================================

set transaction isolation level repeatable read;
begin transaction;
select * from dbo.products where category = 'Milk Products';
waitfor delay '00:00:05';
select * from dbo.products where category = 'Milk Products';
rollback;

-- ===========================================
-- SERIALIZABLE (сериализуемость)
-- Гарантирует, что другие транзакции не могут изменять или вставлять данные, которые 
-- могут быть считаны текущей транзакцией
-- ===========================================

set transaction isolation level serializable;
begin transaction;
select * from dbo.products where category = 'Milk Products';
waitfor delay '00:00:05';
select * from dbo.products where category = 'Milk Products';
rollback;


QUERY2:


-- READ UNCOMMITTED
set transaction isolation level read uncommitted;
select * from dbo.products;

-- READ COMMITTED
set transaction isolation level read committed;
select * from dbo.products;

-- REPEATABLE READ
update dbo.products set quantity = 90 where id = 3;
insert into dbo.products (id, name, category, quantity, price) values (4, 'Egg', 'Eggs', 150, 12.99);

-- SERIALIZABLE
update dbo.products set quantity = 60 where id = 2;
