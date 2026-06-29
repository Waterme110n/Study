/*1*/
use Univer 
exec dbo.SP_HELPINDEX 'auditorium_Type'

Create Table #Vremennaya
(aname varchar(6),
Kol_vo int,
Pol varchar(10)
);

Set nocount on;
Declare @i int = 0;
While @i < 1010
begin
set @i = @i+1;
Insert #Vremennaya(aname,Kol_vo,Pol)
Values (Floor(rand()*1000000),@i,REPLICATE('a',Floor(rand()*10)));
end;

SELECT * FROM #Vremennaya where aname between 10000 and 100000 order by aname 

checkpoint 
DBCC DropCleanBuffers; 

Create clustered index #Vremennaya_A on #Vremennaya(aName asc)
drop index #Vremennaya_A on #vremennaya

drop Table #Vremennaya;

/*2*/
create table #Vremennaya2(
number int,
countInt int
);

set nocount on;
declare @j int=0;
while @j < 10000
begin 
 insert #Vremennaya2(number, countInt) 
 values(FLOOR(10000*rand()),@j)
 set @j = @j + 1;
end;

select * from #Vremennaya2

  CREATE index #Vremennaya2_A on #Vremennaya2(number, countInt)
  drop index #Vremennaya2_A on #vremennaya2

  SELECT * from  #Vremennaya2 where  countInt = 1 and  number > 500

/*3*/

CREATE  index #Vremennaya2_B on #Vremennaya2(number) INCLUDE (countInt)
  drop index #Vremennaya2_B on #vremennaya2

Select countInt from  #Vremennaya2 where number >500


/*4*/

create index #Vrem_Where on #Vremennaya2(number) where (number > 500 and number <1000)
  drop index #Vrem_Where on #vremennaya2
Select number from #Vremennaya2 where number > 500 and number <1000

/*5*/
Use tempdb

create table  #ex
(    
  id int,
  ff int identity(0,2)
);
declare 
@step int = 0;
while @step<1000
begin
insert #ex(id)
values(@step);
if(@step!=1000)
set @step+=1;
end


create index #ex_id on #ex(id);
INSERT top(4000) #EX(id) select id from #EX;

select name[индекс], avg_fragmentation_in_percent[фрагментация(%)]
from sys.dm_db_index_physical_stats(db_id(N'tempdb'),
object_id(N'#ex'), null, null, null)ss
join sys.indexes ii on ss.object_id = ii.object_id and ss.index_id=ii.index_id
where name is not null;

alter index #EX_ID on #EX reorganize;
ALTER index #EX_ID on #EX rebuild with (online = off);

select name[индекс], avg_fragmentation_in_percent[фрагментация(%)]
from sys.dm_db_index_physical_stats(db_id(N'tempdb'),
object_id(N'#ex'), null, null, null)ss
join sys.indexes ii on ss.object_id = ii.object_id and ss.index_id=ii.index_id
where name is not null;
/*6*/
DROP index #EX_ID on #EX;

SET IDENTITY_INSERT #EX ON;

    CREATE index #EX_ID on #EX(id) with (fillfactor = 65);

    INSERT top(50)percent into #EX(id,ff) SELECT id, ff  FROM #EX;
SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'),    
OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss  JOIN sys.indexes ii 
ON ss.object_id = ii.object_id and ss.index_id = ii.index_id  WHERE name is not null;
