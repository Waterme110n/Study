create procedure PSUBJECT
as 
begin
	declare @k int = (select count(*) from Водитель);
	select Фамилия [Фамилия], Имя [Имя], Отчество [Отчество] from Водитель;
	return @k;
end

declare @d int = 0;
exec @d = PSUBJECT;
PRINT @d ;

drop procedure PSUBJECT


create table #SUBJECT (
Имя nchar(10),
Фамилия nvarchar(100),
Отчество nvarchar(100),
Индекс nvarchar(100),
Стаж nchar(20));
go
ALTER procedure PSUBJECT @p nvarchar(20)
AS
begin
declare @k int = (select count(*) from  Водитель);
select * from Водитель where Фамилия = @p;
end;
GO
insert #SUBJECT exec PSUBJECT @p= N'Осадчий'
insert #SUBJECT exec PSUBJECT @p= N'Карпович'
select * from #SUBJECT 