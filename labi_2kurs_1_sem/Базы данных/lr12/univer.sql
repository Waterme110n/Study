/*1*/
if  exists (select * from  SYS.OBJECTS        -- таблица X есть?
	            where OBJECT_ID= object_id(N'DBO.Y') )	            
	drop table Y;           
	declare @c int, @flag char = 'c';           -- commit или rollback?
	SET IMPLICIT_TRANSACTIONS  ON   -- включ. режим неявной транзакции
	CREATE table Y(K int );                         -- начало транзакции 
		INSERT Y values (1),(2),(3);
		set @c = (select count(*) from Y);
		print 'количество строк в таблице Y: ' + cast( @c as varchar(2));
		if @flag = 'c'  commit;                   -- завершение транзакции: фиксация 
	          else   rollback;                                 -- завершение транзакции: откат  
      SET IMPLICIT_TRANSACTIONS  OFF   -- выключ. режим неявной транзакции
	
	if  exists (select * from  SYS.OBJECTS       -- таблица X есть?
	            where OBJECT_ID= object_id(N'DBO.Y') )
	print 'таблица Y есть';  
      else print 'таблицы Y нет'

/*2*/
begin try 
	begin tran 
	 insert Progress (IDSTUDENT, SUBJECT, NOTE) values (1024,'КГ','5');
	 insert Progress (IDSTUDENT, SUBJECT, NOTE) values (1025,'КГ','8');
	 delete Progress where Progress.IDSTUDENT = 1025;
	commit tran;
	end try
	begin catch
		print 'Error: ' + case
			when error_number() = 2627 and patindex('%PK_STUDENT%',error_message())>0
			then 'dublicate progress'
			else 'error:' + cast(error_number() as varchar(5))+error_message()
		end;
		if @@TRANCOUNT > 0 rollback tran;
	end catch

	select * from Progress

/*3*/
declare @point varchar(32);
begin try 
	begin tran 
	 insert Progress (IDSTUDENT, SUBJECT, NOTE) values (1024,'КГ','5');
	 set @point = 'p1' save tran @point;
	 insert Progress (IDSTUDENT, SUBJECT, NOTE) values (1025,'КГ,','8');
	 set @point = 'p2' save tran @point;
	 delete Progress where Progress.IDSTUDENT = 1024;
	commit tran;
	end try
	begin catch
		print 'Error: ' + case
			when error_number() = 2627 and patindex('%PK_STUDENT%',error_message())>0
			then 'dublicate progress'
			else 'error:' + cast(error_number() as varchar(5))+error_message()
		end;
		if @@TRANCOUNT > 0
		begin
			print 'контрольная точка:' + @point; 
			rollback tran @point;
			commit tran;
		end;
	end catch

	select * from Progress

/*4*/
set transaction isolation level READ UNCOMMITTED
begin transaction 
	----------------t1-------------
	
	select @@SPID, 'insert PROGRESS' 'result',* from PROGRESS where IDSTUDENT = 1023 ;
	select @@SPID, 'update PROGRESS' 'result',IDSTUDENT,NOTE from PROGRESS where IDSTUDENT = 1022 and NOTE = 8;
	commit;
	
	-----------t2-----------------
--B--
begin transaction 
	select @@SPID
	insert PROGRESS values('КГ', 1026,'06.05.2013',8);
	update PROGRESS set NOTE = 8 where IDSTUDENT = 1022;

	--------t1---------
	--------t2---------
	rollback;
select *  from progress

/*5*/
set transaction isolation level READ COMMITTED
begin transaction
select COUNT(*) from PROGRESS where SUBJECT = N'КГ';
----------------t1---------
----------------t2---------
select N'update PROGRESS'N'result', count(*)
from PROGRESS where SUBJECT = N'СУБД';
commit;

----B----
begin transaction
---------t1-------
update PROGRESS set SUBJECT = N'СУБД'
where SUBJECT = N'КГ'
commit;
------t2----------

/*6*/
    ------A------
set transaction isolation level repeatable read
begin transaction
select IDSTUDENT from PROGRESS where SUBJECT =  N'СУБД';
---------t1-------
---------t2-------
select case 
when IDSTUDENT = 1019 THEN N'insert PROGRESS ' else ''
end N'результат', IDSTUDENT FROM PROGRESS WHERE SUBJECT =  N'СУБД';
commit;

     ------B--------
begin transaction
-----------t1-----------
insert PROGRESS values(N'СУБД', 1030, CAST('2016-01-29' AS DATE), 6)
COMMIT;
-------------t2--------

/*7*/
    ---A---
set transaction isolation level SERIALIZABLE
begin transaction
delete PROGRESS where IDSTUDENT = 1000;
INSERT PROGRESS values(N'СУБД', 1050, CAST('2016-06-12' AS DATE), 7);
update PROGRESS set IDSTUDENT = 1001 WHERE SUBJECT = N'СУБД';
select IDSTUDENT from PROGRESS WHERE SUBJECT = N'СУБД';
------------t1-------
select IDSTUDENT from PROGRESS WHERE SUBJECT = N'СУБД';
commit;

-----B----
begin transaction
delete PROGRESS where IDSTUDENT = 1000;
INSERT PROGRESS values(N'СУБД', 1000, CAST('2016-06-19' AS DATE), 7);
update PROGRESS set IDSTUDENT = 1000 WHERE SUBJECT = N'СУБД';
select IDSTUDENT from PROGRESS WHERE SUBJECT = N'СУБД';
-------------t1-----------
commit;
select IDSTUDENT from PROGRESS WHERE SUBJECT = N'СУБД';
----------------t2-----------
/*8*/

begin tran  
	delete PROGRESS where IDSTUDENT = 1001;
	INSERT PROGRESS values(N'СУБД', 1001, CAST('2016-06-12' AS DATE), 9);
	begin tran 
	update PROGRESS set IDSTUDENT = 1001 WHERE SUBJECT = N'СУБД';
commit   
if @@TRANCOUNT > 0 
rollback;
select
	(select count(*) from progress where IDSTUDENT = 1001) '1001 студент',
	(select count(*) from STUDENT WHERE NAME = 'Силюк Валерия Ивановна')  'Student';
select * from PROGRESS
select * from student 
