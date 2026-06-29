/*1*/
go

create function COUNT_STUDENTS(@faculty varchar(20)) returns int
as begin declare @rc int = 0;
set @rc = (select count(IDSTUDENT) from STUDENT S join GROUPS G on S.IDGROUP = G.IDGROUP 
							join FACULTY F on G.FACULTY = F.FACULTY 
								where F.FACULTY = @faculty);
return @rc; 
end

declare @f int = dbo.COUNT_STUDENTS('ХТиТ');
print 'Кол-во студентов = ' + cast(@f as varchar(4));
go

alter function COUNT_STUDENTS (@faculty varchar(20) = null, @prof varchar(20) = null)
	returns int
	as begin declare  @rc int = 0;
	if @prof is null
		set @rc =  (select count(IDSTUDENT) from STUDENT S 
						join GROUPS G on S.IDGROUP = G.IDGROUP
						join FACULTY F on G.FACULTY = F.FACULTY 
							where F.FACULTY = @faculty);
	else 
	set @rc =(select count(IDSTUDENT) from STUDENT S 
						join GROUPS G on S.IDGROUP = G.IDGROUP
						where G.PROFESSION = @prof);
	return @rc;
	end;
declare @fp int = dbo.COUNT_STUDENTS(default,'1-36 01 08')
print 'Кол-во студентов = ' + cast(@fp as varchar(4));
go

drop function COUNT_STUDENTS

/*2*/
create function FSUBJECTS (@p VARCHAR(20))
	returns VARCHAR(300)
	as begin 
	declare  @s char(20);
	declare @a varchar(300) = 'дисциплины: ';
	declare CSUBJECTS cursor local
	for select S.SUBJECT from SUBJECT S  
		where S.PULPIT = @p;
	open CSUBJECTS;
	fetch CSUBJECTS into @s;
		while @@FETCH_STATUS = 0
			begin set @a = @a  + RTRIM(@s)+ ',';
			fetch CSUBJECTS into @s;
		end;
	return @a;
	end;
select P.PULPIT, dbo.FSUBJECTS(PULPIT) from PULPIT P

drop function FSUBJECTS

/*3*/
create function FFACPUL (@ff varchar(20), @pp varchar(20))
												returns table
as return 
select F.FACULTY , P.PULPIT from FACULTY F 
	left join PULPIT P on P.FACULTY = F.FACULTY
		where F.FACULTY = isnull(@ff,F.FACULTY)
		and
		P.PULPIT = isnull(@pp, P.PULPIT);
select * from dbo.FFACPUL(NULL,NULL);
select * from dbo.FFACPUL('ИТ',NULL);
select * from dbo.FFACPUL(NULL,'ИСиТ');
select * from dbo.FFACPUL('ИТ','ИСиТ');

drop function FFACPUL

/*4*/
go
create function FCTEACHER(@p varchar(20)) returns int
as begin 
	declare @rc int  = (select count(*) from TEACHER T
			where PULPIT = ISNULL(@p,PULPIT));
			return @rc;
	end;

select PULPIT,dbo.FCTEACHER(PULPIT) [Кол-во преподавателей] from PULPIT
select dbo.FCTEACHER(NULL) [Всего преподавателей] 

go
drop function  FCTEACHER;

/*6*/
go
create function SIX_PULPITS(@f varchar(20)) returns int
as begin declare @rc int = 0;
set @rc = (select count(PULPIT) from PULPIT where PULPIT.FACULTY = @f);
return @rc; 
end;
go
create function SIX_GROUPS(@f varchar(20)) returns int
as begin declare @rc int = 0;
set @rc = (select count(GROUPS.FACULTY) from GROUPS where GROUPS.FACULTY = @f);
return @rc; 
end;
go
create function SIX_PROF(@f varchar(20)) returns int
as begin declare @rc int = 0;
set @rc = (select count(PROFESSION) from PROFESSION where FACULTY = @f );
return @rc; 
end;
go

	create function FACULTY_REPORT(@c int)
	returns @fr table ( [Факультет] varchar(50), [Количество кафедр] int, [Количество групп]  int, [Количество студентов] int, [Количество специальностей] int )
	as begin 
           declare cc CURSOR static for 
	       select FACULTY from FACULTY  where dbo.COUNT_STUDENTS(FACULTY, default) > @c; 
	       declare @f varchar(30);
	       open cc;  
                 fetch cc into @f;
	       while @@fetch_status = 0
	       begin
	            insert @fr values( @f, dbo.SIX_PULPITS(@f), dbo.SIX_GROUPS(@f), dbo.COUNT_STUDENTS(@f, default), dbo.SIX_PROF(@f)); 
	            fetch cc into @f;  
	       end;   
                 return; 
	end;
go

select * from FACULTY_REPORT(17)
go
drop  function SIX_PULPITS

/*7*/
drop PROCEDURE PRINT_REPORT_plus

CREATE PROCEDURE PRINT_REPORT_plus @f CHAR(10) = NULL, @p CHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @FacultyName varchar(50)
    DECLARE @PulpitName varchar(100)
    DECLARE @TeacherCount int
    DECLARE @SubjectsList varchar(max)
    DECLARE @PrevFacultyName varchar(50) = ''
    DECLARE @TotalDepartments int = 0

    DECLARE ReportCursor CURSOR STATIC FOR
    SELECT F.FACULTY, P.PULPIT, dbo.FCTEACHER(P.PULPIT) AS TeacherCount, dbo.FSUBJECTS(P.PULPIT) AS SubjectsList
    FROM dbo.FFACPUL(@f, @p) FP
    JOIN FACULTY F ON FP.FACULTY = F.FACULTY
    JOIN PULPIT P ON FP.PULPIT = P.PULPIT
    ORDER BY F.FACULTY, P.PULPIT

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
        PRINT '      ' + @SubjectsList
        PRINT ''

        SET @TotalDepartments += 1

        FETCH NEXT FROM ReportCursor INTO @FacultyName, @PulpitName, @TeacherCount, @SubjectsList
    END

    CLOSE ReportCursor
    DEALLOCATE ReportCursor

    RETURN @TotalDepartments
END

go

DECLARE @fp INT
EXEC @fp = PRINT_REPORT_plus @f = NULL, @p = NULL
PRINT @fp