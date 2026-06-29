/*1*/
Declare 
	@ch char(3) = 'OPA',
	@varch varchar(1) = 'м',
	@datim datetime,
	@time time,
	@inter int,
	@sint smallint,
	@tint tinyint,
	@num numeric(12,5);

Set @datim = GETDATE();
Select @time = '16:00', @inter = 323,@sint= 23, @tint = 6, @num =1232144.12456

Print @time;
Print @datim;
Print @num;
Print @tint;

Select @varch as Пол, @ch as Инициалы,@inter as Номер_заказа,@sint as Кол_во

/*2*/
Declare 
	@Obsh int = (select CAST( SUM(AUDITORIUM.AUDITORIUM_CAPACITY) as int) from Auditorium),
	@Kolvo int = (select Cast (Count(AUDITORIUM.AUDITORIUM) as int) from Auditorium),
	@avgAud int = (select Cast (AVG(AUDITORIUM.AUDITORIUM_CAPACITY) as int)  from AUDITORIUM),
	@KolvoMensh float,
	@prMensh decimal(5,1)
If @Obsh > 200
begin
	Set @KolvoMensh = (select Count(AUDITORIUM.AUDITORIUM_CAPACITY) from AUDITORIUM where AUDITORIUM_CAPACITY < @avgAud)
	Set @prMensh = (select @KolvoMensh*100/@Kolvo)
	select @Kolvo as Кол_во, @avgAud as Среднее_знач, @KolvoMensh as Меньше_средн, @prMensh as Процент_средн
end
	else If @Obsh < 200
	begin
		Print 'Общая вместимость: ' + ' ' + cast(@Obsh as varchar)
	end

/*3*/
print @@rowcount
print @@VERSION 
print @@SPID 
print @@ERROR 
print @@SERVERNAME 
print @@TRANCOUNT 
print @@FETCH_STATUS 
print @@NESTLEVEL 

/*4*/
Declare @z float,@t int = 2, @x int = 3
	if (@t > @x) set @z = power(sin(@t),2)
	if (@t < @x) set @z = 4*(@t+@x)
	if (@t = @x) set @z = 1 - exp(@x- 2)
	Select @z

Declare @fam nvarchar(100) = 'Осадчий Павел Андреевич',@shortFam nvarchar(100)
	Select @shortFam =
	SUBSTRING(@fam, 1, CHARINDEX(' ', @fam)) +
	SUBSTRING(@fam, CHARINDEX(' ', @fam) + 1 ,1) + '. ' +
	SUBSTRING(@fam, CHARINDEX(' ', @fam,CHARINDEX(' ', @fam)+1) +1,1) + '. '
		
	Print @fam
	Print @shortFam

Declare @todayMonth datetime = getdate(), @NextMonth datetime, @HowMuchYears datetime
	set @NextMonth = DATEADD(MONTH,1,@todayMonth)
	Select STUDENT.NAME as 'ФИО',datediff(Year,Student.bday,@todayMonth),STUDENT.BDAY
	from STUDENT 
	where Month(STUDENT.BDAY) = Month(@NextMonth) 


Select DATENAME(WEEKDAY,PDATE) as 'День  недели'
	from PROGRESS join student
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where SUBJECT like 'СУБД' and IDGROUP = 5

/*5*/
Declare @vsegoM int, @vsegoW int
	Set @vsegoM = (select COUNT(*) from TEACHER where GENDER = 'м') 
	Set @vsegoW = (select COUNT(*) from TEACHER where GENDER = 'ж') 
	If(@vsegoM > @vsegoW)
	begin 
	Print 'мужчин больше чем женщин'
	end;
	else Begin
	Print 'женщин больше чем мужчин'
	end;

/*6*/
Select case
	when NOTE between 0 and 4 then 'Плохо'
	when NOTE between 4 and 7 then 'Удовлетворительно'
	when NOTE between 7 and 10 then 'Отлично'
	else 'не может быть'
	end as 'Оценка'
from GROUPS join STUDENT
	on GROUPS.IDGROUP = STUDENT.IDGROUP
	join PROGRESS 
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.faculty like 'ХТиТ'

/*7*/
Create Table #Vremennaya
(name varchar(6),
Kol_vo int,
Pol varchar(10)
);


Set nocount on;
Declare @i int = 0;
While @i < 10
begin
set @i = @i+1;
Insert #Vremennaya(name,Kol_vo,Pol)
Values (Floor(rand()*1000000),@i,REPLICATE('a',Floor(rand()*10)));
end;

Select * from #Vremennaya

drop Table #Vremennaya;

/*8*/
Declare @nam varchar(50)
	set @nam = 'Павел'
	print @nam
	set @nam = 'Осадчий'
	print @nam
	Return
	set @nam = 'Андреевич'
	print @nam

/*9*/
begin try
	Create table Faculty_02 (a int)
end try
Begin catch
	print ERROR_NUMBER ()
	print Error_message()
	print ERROR_LINE ()
	print ERROR_PROCEDURE ()
	print ERROR_SEVERITY () 
	print ERROR_STATE ()
end catch