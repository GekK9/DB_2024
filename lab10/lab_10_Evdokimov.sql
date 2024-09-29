
--Для правильной работы запускать QUERY1 и QUERY2 одновременно с помощью ДВУХ отдельных запросов

QUERY1:
if OBJECT_ID('dbo.cardholders') is not null
    drop table dbo.cardholders
go
create table dbo.cardholders 
(
	id			int,
	name		varchar(35),
	cardtype	varchar(35),
	balance		money,

	PRIMARY KEY (id)
);
go

insert into dbo.cardholders values
	(1, 'Artem', 'Mir', 43444),
	(2, 'Kirill', 'Mastercard', 52222),
	(3, 'Denis', 'VISA', 633252)
go

--uncommited

begin transaction

	select * from dbo.cardholders
	update dbo.cardholders 
		set balance = 90 
		where id = 1
	waitfor delay '00:00:05'
	select * from dbo.cardholders
commit
GO
--read commited

begin transaction
	select * from dbo.cardholders
	update dbo.cardholders 
		set balance = 90 
		where id = 1
	waitfor delay '00:00:05'

	
	select * from dbo.cardholders
commit
GO

-- REPEATABLE 

set transaction isolation level 
	repeatable read
begin transaction
	select * from dbo.cardholders
	waitfor delay '00:00:05'
	select * from dbo.cardholders

	rollback
select * from dbo.cardholders
GO

-- serializable

set transaction isolation level 
	serializable
begin transaction
	select * from dbo.cardholders where id in (1,2)
	waitfor delay '00:00:05'
	select * from dbo.cardholders where id in (1,2)

	rollback
select * from dbo.cardholders
GO

GO

QUERY2:

--READ UNCOMMITED

set transaction isolation level 
	read uncommitted
select * from dbo.cardholders
GO


----READ COMMITED

set transaction isolation level 
	read committed
select * from dbo.cardholders
GO


----REPEATABLE READ

update dbo.cardholders set balance = 90 where id = 3
insert into dbo.cardholders values (9, 'Dasha', 'Visa', 1241442)
GO


----SERIALIZABLE

insert into dbo.cardholders values (13, 'Iongliang', 'UnionPay', 4356456456)
GO
