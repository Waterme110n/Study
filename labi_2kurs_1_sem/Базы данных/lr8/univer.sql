/*1*/
Create VIEW [Преподаватель]
as select TEACHER[код],TEACHER_NAME[имя преподавателя],GENDER[пол],PULPIT[кафедра] 
from TEACHER

select * from [Преподаватель]

drop View[Преподаватель]

/*2*/
Create View [Количество кафедр] with schemabinding
as select FACULTY_NAME[факультет],count(PULPIT)[кол-во кафедр]
from dbo.FACULTY join dbo.PULPIT
on FACULTY.FACULTY = PULPIT.FACULTY
group by FACULTY_NAME

select * from [Количество кафедр]

alter table dbo.Faculty
drop column Faculty_name

drop View[Количество кафедр]

/*3*/
Create VIEW Аудитории (код,наименование_аудитории)
as select AUDITORIUM_Type,AUDITORIUM
from AUDITORIUM
where AUDITORIUM_TYPE like 'ЛК'

INSERT INTO Аудитории (код, наименование_аудитории)
VALUES ('ЛК', 121);

delete from Аудитории 
where наименование_аудитории = '121'

select * from Аудитории

drop view Аудитории

/*4*/
Create VIEW Лекционные_аудитории (код,наименование_аудитории)
as select AUDITORIUM_Type,AUDITORIUM
from AUDITORIUM
where AUDITORIUM_TYPE like 'ЛК' with check option

INSERT INTO Лекционные_аудитории (код, наименование_аудитории)
VALUES ('ЛД', 505);

delete from AUDITORIUM
where AUDITORIUM.AUDITORIUM = '505'

select * from Лекционные_аудитории

drop view Лекционные_аудитории

/*5*/
Create view Дисциплины (код,наименование_дисциплины,код_кафедры)
as select Top 15 SUBJECT,SUBJECT_NAME,PULPIT
From SUBJECT Order by PULPIT

select * from Дисциплины

drop view Дисциплины

/*8**/
Select [Понедельник],[Вторник],[Среда],[Четверг]
From
(Select IDGROUP,DAY_OF_WEEK,CLASS
from TIMETABLE
) as SourseTable
pivot 
(
count(idgroup)
for day_of_week in ([Понедельник],[Вторник],[Среда],[Четверг])
) as finalPivotTable 
Order by CLASS 