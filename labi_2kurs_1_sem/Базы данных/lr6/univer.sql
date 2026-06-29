/*1*/
Select AUDITORIUM_TYPE.AUDITORIUM_TYPE,
max(AUDITORIUM_CAPACITY) [Максимальная вместисмость],
min(AUDITORIUM_CAPACITY) [Минимальная вместимость],
AVG(AUDITORIUM_CAPACITY) [Средняя вместимость],
Sum(AUDITORIUM_CAPACITY)[Суммарная вместимость],
Count(*) [Кол-во аудиторий]
From AUDITORIUM inner join AUDITORIUM_TYPE 
on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
Group by AUDITORIUM_TYPE.AUDITORIUM_TYPE

/*3*/
Select * From(select Case 
when PROGRESS.NOTE between 0 and 4 then 'плохо'
when PROGRESS.NOTE between 4 and 7 then 'нормально'
when PROGRESS.NOTE between 7 and 10 then 'хорошо'
else 'не может быть'
end [Отметка],
COUNT(*)[Количество]
From PROGRESS Group by Case 
when PROGRESS.NOTE between 0 and 4 then 'плохо'
when PROGRESS.NOTE between 4 and 7 then 'нормально'
when PROGRESS.NOTE between 7 and 10 then 'хорошо'
else 'не может быть'
end) as T
Order By Case[Отметка]
when 'плохо' then 4
when 'нормально' then 3
when 'хорошо' then 2
when 'не может быть' then 1
else 0
end

/*4*/
Select 
g.YEAR_FIRST,
g.FACULTY,
pr.PROFESSION_NAME,
round(avg(cast(p.Note as float(4))),2) as [средняя оценка]
From PROGRESS p inner join STUDENT s
on p.IDSTUDENT = s.IDSTUDENT
inner join GROUPS g
on  s.IDGROUP = g.IDGROUP 
inner join PROFESSION pr
on g.PROFESSION = pr.PROFESSION
group by g.YEAR_FIRST,g.FACULTY,pr.PROFESSION_NAME
Order By [средняя оценка] DESC

/*5*/
Select 
g.YEAR_FIRST,
g.FACULTY,
pr.PROFESSION_NAME,
round(avg(cast(p.Note as float(4))),2) as [средняя оценка]
From PROGRESS p inner join STUDENT s
on p.IDSTUDENT = s.IDSTUDENT
inner join GROUPS g
on  s.IDGROUP = g.IDGROUP 
inner join PROFESSION pr
on g.PROFESSION = pr.PROFESSION
where p.SUBJECT like 'БД' or p.SUBJECT like 'ОАиП'
group by g.YEAR_FIRST,g.FACULTY,pr.PROFESSION_NAME
Order By [средняя оценка] DESC

/*6*/
Select pr.PROFESSION_NAME, p.SUBJECT,avg(p.NOTE)[Средняя оценка]
From PROGRESS p inner join Student s
on p.IDSTUDENT = s.IDSTUDENT
inner join GROUPS g
on g.IDGROUP = s.IDGROUP
inner join PROFESSION pr
on pr.FACULTY = g.FACULTY
where g.FACULTY like '%ТОВ%'
group by p.SUBJECT,pr.PROFESSION_NAME

/*7*/
Select p.SUBJECT,p.NOTE as [какая оценка], (select Count(*) from STUDENT s
Where  p.IDSTUDENT = s.IDSTUDENT )[Количество]
From PROGRESS p
Group by p.SUBJECT,p.NOTE,p.IDSTUDENT
Having p.NOTE = 8 or p.NOTE = 9
