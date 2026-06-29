/*1*/
use OSA_MyBase_3 
exec dbo.SP_HELPINDEX 'Водитель'

Select * from Водитель

SELECT * FROM Водитель where Стаж between 5 and 8 

/*2*/

select * from Водитель

  CREATE index #Vremennaya2_A on Водитель(Стаж, индекс_водителя)
  drop index #Vremennaya2_A on Водитель

  SELECT * from  Водитель where  Стаж = 6 and  индекс_водителя > 500

/*3*/

CREATE  index #Vremennaya2_B on Водитель(Стаж) INCLUDE (индекс_водителя)
  drop index #Vremennaya2_B on Водитель

Select Стаж from  Водитель where индекс_водителя >500

SELECT name [Индекс], avg_fragmentation_in_percent [Фрагментация (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'OSA_mybase_3'), 
OBJECT_ID(N'Водитель'), NULL, NULL, NULL) ss  JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id  WHERE name is not null;