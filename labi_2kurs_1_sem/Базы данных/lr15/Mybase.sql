drop trigger TR_AUDIT
create table TR_AUDIT
(
	ID int identity,
	ST varchar(20)
	check (ST in ('INS','DEL','UPD')),
	TRN varchar(50),
	C varchar(300)
	)
	
go
drop trigger TR_voditel_INS
go
create trigger TR_voditel_INS
							on Водитель after INSERT
as declare @a1 varchar(20),@a2 varchar(20), @a3 varchar(20),@a4 varchar(10), @in varchar(300);
print 'операция втавки';
set @a1 = (select [Фамилия] from inserted);
set @a2 = rtrim((select [Имя] from inserted));
set @a3 = rtrim((select [Отчество] from inserted));
set @a4 = rtrim((select [Индекс_Водителя] from inserted));
set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' '+ @a4 ;
insert into TR_AUDIT(ST,TRN,C) values ('INS','TR_voditel_INS',@in);
return;
insert into  Водитель (Фамилия,  Имя, Отчество, Индекс_Водителя )
                       values  ('Очумекович','Виталий', 'Степанович', '11'); 
  select * from TR_AUDIT

  drop trigger TR_voditel_del
  go
	create trigger TR_voditel_del on Водитель after DELETE
as declare @a1 varchar(3),@a2 varchar(20), @a3 varchar(1),@a4 varchar(10), @in varchar(300);
print 'операция удаления';
set @a1 = (select [Фамилия] from inserted);
set @a2 = rtrim((select [Имя] from inserted));
set @a3 = rtrim((select [Отчество] from inserted));
set @a4 = rtrim((select [Индекс_Водителя] from inserted));
set @in = @a1 + ' ' + @a2 + ' ' + @a3 + ' '+ @a4 ;
insert into TR_AUDIT(ST,TRN,C) values ('DEL','TR_voditel_del',@in);
return;
delete  from Водитель where Фамилия like '%очу%'
select * from TR_AUDIT
go