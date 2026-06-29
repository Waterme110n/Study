/*1*/
Declare @tv char(50), @t char(300)='';
Declare Discip CURSOR for Select SUBJECT_NAME from SUBJECT where PULPIT = 'ИСиТ'
Open Discip;
Fetch Discip into @tv;
Print 'Заказанные товары';
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
	             for SELECT AUDITORIUM_TYPE from AUDITORIUM;
DECLARE @fv char(50);   
	OPEN aud;	  
	fetch next from aud into @fv; 	
      print '1. '+ @fv;   
      go
 DECLARE @fv char(20);   	
	fetch next from aud into @fv; 	
      print '2. '+ @fv; 


DECLARE aud_G CURSOR global                            
for SELECT AUDITORIUM_TYPE from AUDITORIUM;
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
		 for SELECT PULPIT, PULPIT_NAME, FACULTY 
		       FROM dbo.PULPIT where PULPIT_NAME Like '%Лес%';				   
	open Zakaz;
    	UPDATE PULPIT set PULPIT_NAME = 'ЛЕС'  where PULPIT.FACULTY = 'ЛХФ';
	FETCH  Zakaz into @tid, @tnm, @tgn; 
		   UPDATE PULPIT SET PULPIT_NAME = 'Лес измененно' where PULPIT.FACULTY = 'ЛХФ';
	while @@fetch_status = 0                                    
      begin 
          print  @tid + ' '+ @tnm + ' '+ @tgn;      
          fetch Zakaz into @tid, @tnm, @tgn; 
       end;          
   CLOSE  Zakaz;

     DECLARE @tid2 varchar(50), @tnm2 varchar(50), @tgn2 varchar(50);  
	DECLARE Zakazd CURSOR LOCAL dynamic                         
		 for SELECT PULPIT, PULPIT_NAME, FACULTY 
		       FROM dbo.PULPIT where PULPIT_NAME Like '%Лес%';				   
	open Zakazd;
    	UPDATE PULPIT set PULPIT_NAME = 'ЛЕС'  where PULPIT.FACULTY = 'ЛХФ';
	FETCH  Zakazd into @tid2, @tnm2, @tgn2;     
		  UPDATE PULPIT SET PULPIT_NAME += 'Лес измененно' where PULPIT.FACULTY = 'ЛХФ';
	while @@fetch_status = 0                                    
      begin 
          print  @tid2 + ' '+ @tnm2 + ' '+ @tgn2;      
          fetch Zakazd into @tid2, @tnm2, @tgn2; 
       end;          
   CLOSE  Zakazd;

/*4*/
DECLARE  @tc int, @rn char(50);  
         DECLARE Primer1 cursor local dynamic SCROLL         
		                for SELECT row_number() over (order by idstudent) N,
	                           student.NAME FROM dbo.STUDENT 
	OPEN Primer1; 
	FETCH  First from  Primer1 into @tc, @rn;       
	print 'первый ученик          : ' +  rtrim(@rn);  
	FETCH  Next from  Primer1 into @tc, @rn;       
	print 'следующий ученик          : ' +  rtrim(@rn); 
	FETCH  absolute 10 from  Primer1 into @tc, @rn;       
	print '10 учеников вперед от начала          : ' +  rtrim(@rn); 
	FETCH  relative 10 from  Primer1 into @tc, @rn;       
	print '10 учеников от вперед от текущей          : ' +  rtrim(@rn); 
	FETCH  relative -10 from  Primer1 into @tc, @rn;       
	print '10 учеников назад от текущей        : ' +  rtrim(@rn); 
	FETCH  absolute -10 from  Primer1 into @tc, @rn;       
	print '10 учеников назад от конца         : ' +  rtrim(@rn); 
	FETCH  LAST from  Primer1 into @tc, @rn;       
	print 'последний ученик          : ' +  rtrim(@rn);   
	FETCH  prior from  Primer1 into @tc, @rn;       
	print 'предыдущий ученик          : ' +  rtrim(@rn); 
      CLOSE Primer1;

/*5*/
 DECLARE @tid3 varchar(50), @tnm3 varchar(50), @tgn3 varchar(50);  
	DECLARE Zakazv CURSOR LOCAL dynamic                         
		 for SELECT PULPIT, PULPIT_NAME, FACULTY 
		       FROM dbo.PULPIT where PULPIT_NAME Like '%Лес%';				   
	open Zakazv;
	fetch Zakazv into @tid3,@tnm3,@tgn3;
	 UPDATE PULPIT SET PULPIT_NAME = 'Лес 12345 измененно' where current of Zakazv;
	while @@fetch_status = 0                                    
      begin 
          print  @tid3 + ' '+ @tnm3 + ' '+ @tgn3;      
          fetch Zakazv into @tid3, @tnm3, @tgn3; 
       end;          
	 close Zakazv;
/*6*/
DECLARE @tid4 varchar(50), @tnm4 varchar(50);
	DECLARE prog CURSOR LOCAL dynamic                         
		 for SELECT progress.IDSTUDENT, NOTE 
		       FROM dbo.PROGRESS inner join dbo.STUDENT
			   on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
			   where PROGRESS.NOTE < 4;				   
	open prog;
	fetch prog into @tid4,@tnm4;
	  WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM PROGRESS WHERE IDSTUDENT = @tid4;
        FETCH NEXT FROM prog INTO @tid4;
    END;
    CLOSE prog;
    DEALLOCATE prog;

/*6.2*/
DECLARE @IDSTUDENT INT, @StudentID INT, @Grade INT;
SET @IDSTUDENT = 1001;

DECLARE StudentCursor CURSOR FOR
SELECT IDSTUDENT, NOTE
FROM PROGRESS
WHERE IDSTUDENT = @IDSTUDENT;	

OPEN StudentCursor;
FETCH NEXT FROM StudentCursor INTO @StudentID, @Grade;
	
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE PROGRESS
    SET NOTE = @Grade + 1
    WHERE CURRENT OF StudentCursor;

    FETCH NEXT FROM StudentCursor INTO @StudentID, @Grade;
END;

CLOSE StudentCursor;
DEALLOCATE StudentCursor;

/*8*/
DECLARE @FacultyName varchar(50)
DECLARE @PulpitName varchar(100)
DECLARE @TeacherCount int
DECLARE @SubjectsList varchar(max)
DECLARE @PrevFacultyName varchar(50) = ''


DECLARE ReportCursor CURSOR STATIC
FOR
SELECT F.FACULTY, P.PULPIT, COUNT(T.TEACHER) AS TeacherCount, ISNULL((SELECT STRING_AGG(ISNULL(SUBJECT, 'нет'), ', ')
        FROM ( SELECT DISTINCT SUBJECT
               FROM SUBJECT
               WHERE P.PULPIT = SUBJECT.PULPIT) AS DistinctSubjects ), 'нет') AS SubjectsList
FROM FACULTY F
JOIN PULPIT P ON F.FACULTY = P.FACULTY
LEFT JOIN TEACHER T ON P.PULPIT = T.PULPIT
GROUP BY F.FACULTY, P.PULPIT, P.PULPIT  
ORDER BY F.FACULTY, P.PULPIT;

OPEN ReportCursor

FETCH NEXT FROM ReportCursor INTO @FacultyName, @PulpitName, @TeacherCount, @SubjectsList

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @PrevFacultyName != @FacultyName
    BEGIN
        PRINT 'Факультет: ' + @FacultyName
        SET @PrevFacultyName = @FacultyName
    END

    PRINT '  Кафедра: ' + @PulpitName
    PRINT '      Количество преподавателей: ' + CAST(@TeacherCount AS varchar(10))
    PRINT '      Дисциплины: ' + @SubjectsList
    PRINT ''

    FETCH NEXT FROM ReportCursor INTO @FacultyName, @PulpitName, @TeacherCount, @SubjectsList
END

CLOSE ReportCursor
DEALLOCATE ReportCursor
