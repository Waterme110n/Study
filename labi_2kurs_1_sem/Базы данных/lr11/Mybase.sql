/*1*/
Declare @tv char(50), @t char(300)='';
Declare Discip CURSOR for Select Фамилия from Водитель
Open Discip;
Fetch Discip into @tv;
Print 'фамилии:';
while @@FETCH_STATUS = 0
begin 
set @t = rtrim(@tv)+','+ @t;
fetch Discip into @tv;
end;
print @t;
close Discip;

DEALLOCATE Discip;

/*2*/
DECLARE aud CURSOR LOCAL                            
	             for SELECT оплата from Маршрут;
DECLARE @fv char(50);   
	OPEN aud;	  
	fetch next from aud into @fv; 	
      print '1. '+ @fv;   
      go
 DECLARE @fv char(20);   	
	fetch next from aud into @fv; 	
      print '2. '+ @fv; 


DECLARE aud_G CURSOR global                            
for SELECT оплата from Маршрут;
DECLARE @tv char(50);   
	OPEN aud_G;	  
	fetch next from aud_G into @tv; 		
      print '1. '+ @tv;   
      go 
 DECLARE @fv char(20);   	
	fetch next from aud_G into @fv; 	
      print '2. '+ @fv; 
	  close aud_G;
	  deallocate aud_G;
	  go

/*3*/
 DECLARE @tid varchar(50), @tnm varchar(50), @tgn varchar(50);  
	DECLARE Zakaz CURSOR LOCAL static                              
		 for SELECT Название_маршрута, Номер_маршрута, Дальность 
		       FROM dbo.Маршрут where Название_маршрута Like '%москва%';				   
	open Zakaz;
    	UPDATE Маршрут set Дальность = '20'  where Название_маршрута Like '%москва%';
	FETCH  Zakaz into @tid, @tnm, @tgn; 
		   UPDATE Маршрут SET Дальность = '21' where Название_маршрута Like '%москва%';
	while @@fetch_status = 0                                    
      begin 
          print  @tid + ' '+ @tnm + ' '+ @tgn;      
          fetch Zakaz into @tid, @tnm, @tgn; 
       end;          
   CLOSE  Zakaz;

   DECLARE @tid2 varchar(50), @tnm2 varchar(50), @tgn2 varchar(50);  
	DECLARE Zakaz2 CURSOR LOCAL dynamic                              
		 for SELECT Название_маршрута, Номер_маршрута, Дальность 
		       FROM dbo.Маршрут where Название_маршрута Like '%москва%';				   
	open Zakaz2;
    	UPDATE Маршрут set Дальность = '20'  where Название_маршрута like '%москва%';
	FETCH  Zakaz2 into @tid2, @tnm2, @tgn2; 
		   UPDATE Маршрут SET Дальность = '21' where Название_маршрута like '%москва%';
	while @@fetch_status = 0                                    
      begin 
          print  @tid2 + ' '+ @tnm2 + ' '+ @tgn2;      
          fetch Zakaz2 into @tid2, @tnm2, @tgn2; 
       end;          
   CLOSE  Zakaz2;
   
/*4*/
   DECLARE  @tc int, @rn char(50);  
         DECLARE Primer1 cursor local dynamic SCROLL         
		                for SELECT row_number() over (order by фамилия) N,
	                           Водитель.Имя FROM dbo.Водитель 
	OPEN Primer1; 
	FETCH  First from  Primer1 into @tc, @rn;       
	print 'первый водитель          : ' +  rtrim(@rn);  
	FETCH  Next from  Primer1 into @tc, @rn;       
	print 'следующий водитель          : ' +  rtrim(@rn); 
	FETCH  absolute 3 from  Primer1 into @tc, @rn;       
	print '3 водителя вперед от начала          : ' +  rtrim(@rn); 
	FETCH  absolute -3 from  Primer1 into @tc, @rn;       
	print '3 водителя назад от конца         : ' +  rtrim(@rn); 
	FETCH  relative 2 from  Primer1 into @tc, @rn;       
	print '2 водителя вперед от текущей          : ' +  rtrim(@rn); 
	FETCH  relative -2 from  Primer1 into @tc, @rn;       
	print '2 водителя назад от текущей        : ' +  rtrim(@rn); 
	FETCH  LAST from  Primer1 into @tc, @rn;       
	print 'последний водителя          : ' +  rtrim(@rn);   
	FETCH  prior from  Primer1 into @tc, @rn;       
	print 'предыдущий водителя          : ' +  rtrim(@rn); 
      CLOSE Primer1;
/*5*/
DECLARE @tid3 varchar(50), @tnm3 varchar(50), @tgn3 varchar(50);  
	DECLARE Zakaz3 CURSOR LOCAL dynamic                              
		 for SELECT Название_маршрута, Номер_маршрута, Дальность 
		       FROM dbo.Маршрут where Название_маршрута Like '%минск%';				   
	open Zakaz3;
	FETCH  Zakaz3 into @tid3, @tnm3, @tgn3; 
		   UPDATE Маршрут SET Дальность = '23' where current of zakaz3;
	while @@fetch_status = 0                                    
      begin 
          print  @tid3 + ' '+ @tnm3 + ' '+ @tgn3;      
          fetch Zakaz3 into @tid3, @tnm3, @tgn3; 
       end;          
   CLOSE  Zakaz3;

/*6*/
DECLARE @tid4 varchar(50), @tnm4 varchar(50);
	DECLARE prog CURSOR LOCAL dynamic                         
		 for SELECT Фамилия,Номер_перевозки
		       FROM dbo.Водитель inner join dbo.Перевозки
			   on Водитель.Индекс_Водителя = Перевозки.Индекс_водителя
			   where Номер_перевозки < 3;				   
	open prog;
	fetch prog into @tid4,@tnm4;
	  WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM Водитель WHERE Водитель.Индекс_Водителя = @tid4;
        FETCH NEXT FROM prog INTO @tid4;
    END;
    CLOSE prog;
    DEALLOCATE prog;


DECLARE @IDSTUDENT nvarchar(50), @StudentID nvarchar(50), @Grade INT;
SET @IDSTUDENT = 'Михаил';

DECLARE StudentCursor CURSOR FOR
SELECT Имя, Стаж
FROM Водитель
WHERE Имя = @IDSTUDENT;	

OPEN StudentCursor;
FETCH NEXT FROM StudentCursor INTO @StudentID, @Grade;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Водитель
    SET Стаж = @Grade + 1
    WHERE CURRENT OF StudentCursor;

    FETCH NEXT FROM StudentCursor INTO @StudentID, @Grade;
END;

CLOSE StudentCursor;
DEALLOCATE StudentCursor;