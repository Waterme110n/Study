create function COUNT_Voditels(@faculty varchar(20)) returns int
as begin declare @rc int = 0;
set @rc = (select count(Имя) from Водитель 
where Фамилия = @faculty);
return @rc; 
end

declare @f int = dbo.COUNT_Voditels('Осадчий');
print 'Кол-во водителей = ' + cast(@f as varchar(4));
go

drop function COUNT_Voditels

create function FFACPUL (@ff varchar(20), @pp varchar(20)) returns table
as return 
select F.Фамилия , P.Номер_перевозки from Водитель F 
	left join Перевозки P on P.Индекс_водителя = F.Индекс_водителя
		where F.Фамилия = isnull(@ff,F.Фамилия)
		and   P.Номер_перевозки = isnull(@pp, P.Номер_перевозки);
select * from dbo.FFACPUL(NULL,NULL);
select * from dbo.FFACPUL('Никитин',NULL);
select * from dbo.FFACPUL(NULL,123);
select * from dbo.FFACPUL('Карпович',403);

drop function FFACPUL
