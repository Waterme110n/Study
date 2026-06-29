begin try 
  BEGIN TRANSACTION
  INSERT Водитель values  (12312,'Осадчий','Виктор','Петрович',1)
  
  COMMIT TRANSACTION
end try
begin catch
 PRINT 'ошибка: ' + case
      when error_number() = 2627 
    then 'дублирование Водителя'
    else 'неизвестная ошибка' + cast(error_number() as varchar(5)) + error_message() 
    end;
  if @@trancount > 0 rollback tran
end catch
	select * from Водитель
  
--------------------------------------------------------------------

DECLARE @point varchar(32)
begin try
  BEGIN TRANSACTION 
   UPDATE Водитель SET Стаж = 0 WHERE Индекс_Водителя = '12313'
   set @point = 'p1'; save tran @point;
   INSERT Водитель values  (1231,'Осадчий',111,'Петрович',1)
   set @point='p2'; save tran @point;
   delete Водитель where Индекс_Водителя ='12312'
   COMMIT TRANSACTION 
end try
begin catch
    PRINT 'ошибка: ' + case
      when error_number() = 2627 and patindex('%PK_GROUPS', error_message()) > 0
    then 'дублирование enterprises'
    else 'неизвестная ошибка' + cast(error_number() as varchar(5)) + error_message() 
    end;
  if @@trancount > 0 
  begin 
  print 'контрольная точка' + @point
  rollback tran @point
  COMMIT TRANSACTION 
  end 
end catch 
go
	select * from Водитель