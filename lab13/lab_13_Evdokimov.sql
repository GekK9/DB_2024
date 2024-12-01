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
if OBJECT_ID(N'dbo.characters', N'U') is not null
    drop table dbo.characters;
go
create table dbo.characters (
	id_character int  PRIMARY KEY,
	Nickname varchar(50) NOT NULL,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,
	CONSTRAINT CHK_id_characters
                CHECK (id_character <= 5)
    );
go


use lab13_2;
go
if OBJECT_ID(N'dbo.characters', N'U') is not null
    drop table dbo.characters;
go
create table dbo.characters (
	id_character int  PRIMARY KEY,
	Nickname varchar(50) NOT NULL,
	In_game_balance int NOT NULL,
	Race varchar(10)  NOT NULL,

	CONSTRAINT CHK_id_characters
                CHECK (id_character > 5)
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
	select * from lab13_1.dbo.characters
	union all					
	select * from lab13_2.dbo.characters
go



insert horizontal_dist_v values
		(1,'Uetreyn', 236236326, 'Elf'),
		(2,'Blffiton', 2345 , 'Orc'),
		(3,'Arian', 622637 , 'Human'),
		(4,'Zani', 3245867, 'Ogre'),
		(5,'Oning', 854 , 'Treant'),
		(6,'Lien', 78645123 , 'Human'),
		(7,'Koshanerg', 255645198 , 'Ogre'),
		(8,'Ghim', 8451 , 'Orc'),
		(9,'Gralillo', 12554 , 'ELf'),
		(10,'Ullanchen', 0 , 'Human'),
		(11,'Zani', 3245867, 'Ogre'); 
GO


update  horizontal_dist_v
set id_character = 104 
where id_character = 4
go

select * from horizontal_dist_v

update horizontal_dist_v
	set In_game_balance = '11111'
	where id_character = 1

delete horizontal_dist_v
	where Nickname = 'Ghim'

select * from lab13_1.dbo.characters;
select * from lab13_2.dbo.characters;