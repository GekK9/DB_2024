--use master
--go

--IF DB_ID(N'lab14_1') IS NOT NULL
--	DROP DATABASE lab14_1;
--GO

--CREATE DATABASE lab14_1
--ON (NAME = lab14_1_dat, FILENAME = "C:\BD\lab14_1\lab14_1dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab7_log, FILENAME = "C:\BD\lab14_1\lab14_1log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

--IF DB_ID(N'lab14_2') IS NOT NULL
--	DROP DATABASE lab14_2;
--GO

--CREATE DATABASE lab14_2
--ON (NAME = lab14_2_dat, FILENAME = "C:\BD\lab14_2\lab14_2dat.mdf",
--		SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5%)
--	LOG ON (NAME = lab7_log, FILENAME = "C:\BD\lab14_2\lab14_2log.ldf",
--		SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB); 
--GO

--1.Создать в базах данных п.1. горизонтально фрагментированные таблицы.

use lab14_1;
go
if OBJECT_ID(N'dbo.characters', N'U') is not null
    drop table dbo.characters;
go

create table dbo.characters (
	id_character int  PRIMARY KEY,
	Nickname varchar(50) NOT NULL,
    );
go


use lab14_2;
go
if OBJECT_ID(N'dbo.characters', N'U') is not null
    drop table dbo.characters;
go
create table dbo.characters (
	id_character int  PRIMARY KEY,
	balance_in_game int NOT NULL,
	Race varchar(10)  NOT NULL,
	CONSTRAINT CHK_id_characters
                CHECK (id_character <= 5)
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
    select one.id_character,  one.nickname, two.balance_in_game, two.race
        from lab14_1.dbo.characters as one,
            lab14_2.dbo.characters as two
        where one.id_character = two.id_character
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
 
        insert into lab14_1.dbo.characters(id_character, nickname )
            select id_character, nickname
                from inserted
 
        insert into lab14_2.dbo.characters(id_character, balance_in_game, race)
            select id_character, balance_in_game, race
                from inserted
    end
go
 
insert into dbo.vertical_dist_v values
    (1, 'gera', 60,'human'),
	(2, 'Сfeeeeq', 100, 'orc'),
	(3, 'Chocr', 70, 'elf'),
	(4, 'geert', 40,'elf'),
	(5, 'Posao', 20, 'human');
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.characters
select * from lab14_2.dbo.characters
 
 

--DELETE

if OBJECT_ID(N'dbo.dist_del', N'TR') is not null
    drop trigger dbo.dist_del
go
create trigger dbo.dist_del
    on dbo.vertical_dist_v
    instead of delete
    as
    begin
       
        delete lab14_1.dbo.characters
            where id_character in (select d.id_character
                from deleted as d)
 
        delete lab14_2.dbo.characters
            where id_character in (select d.id_character
                from deleted as d)
    end
go
 
delete dbo.vertical_dist_v
    where nickname = 'gera'
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.characters
select * from lab14_2.dbo.characters
 
 

--UPDATE

if OBJECT_ID(N'dbo.dist_upd', N'TR') is not null
    drop trigger dbo.dist_upd
go
create trigger dbo.dist_upd
    on dbo.vertical_dist_v
    instead of update
    as
    begin
 
        if UPDATE(id_character)
            raiserror('[UPD TRIGGER]: "item_number" cant be modidfied', 16, 1)
        else
        begin
            update lab14_2.dbo.characters
                set characters.balance_in_game = (select balance_in_game from inserted where inserted.id_character = characters.id_character)
                    where characters.id_character = (select id_character from inserted where inserted.id_character = characters.id_character)
        end
    end
go
 
update dbo.vertical_dist_v
    set balance_in_game = '651111'
    where nickname = 'Posao'
 
select * from dbo.vertical_dist_v
select * from lab14_1.dbo.characters
select * from lab14_2.dbo.characters