/*1*/
Select Водитель.Стаж,
max(Номер_маршрута) [Максимальный],
min(Номер_маршрута) [Минимальная],
AVG(Номер_маршрута) [Средняя],
Sum(Номер_маршрута)[Суммарная],
Count(*) [Кол-во]
From Водитель inner join Перевозки
on Водитель.Индекс_Водителя = Перевозки.Индекс_водителя
Group by Водитель.Стаж

/*3*/
Select * From(select Case 
when Водитель.Стаж between 0 and 4 then 'малый'
when Водитель.Стаж between 4 and 7 then 'средний'
when Водитель.Стаж between 7 and 10 then 'длительный'
else 'очень длительный'
end [Стаж],
COUNT(*)[Количество]
From Водитель Group by Case 
when Водитель.Стаж between 0 and 4 then 'малый'
when Водитель.Стаж between 4 and 7 then 'средний'
when Водитель.Стаж between 7 and 10 then 'длительный'
else 'очень длительный'
end) as T
Order By Case[Стаж]
when 'малый' then 4
when 'средний' then 3
when 'длительный' then 2
when 'очень длительный' then 1
else 0
end

/*4*/
Select 
p.Отчество,
round(avg(cast(p.Стаж as float(4))),2) as [средний стаж]
From Водитель p inner join Перевозки s
on p.Индекс_Водителя = s.Индекс_водителя
inner join Маршрут g
on  s.Номер_маршрута = g.Номер_маршрута 
group by p.Отчество
Order By [средний стаж] DESC

/*5*/
Select 
p.Отчество,
round(avg(cast(p.Стаж as float(4))),2) as [средний стаж]
From Водитель p inner join Перевозки s
on p.Индекс_Водителя = s.Индекс_водителя
inner join Маршрут g
on  s.Номер_маршрута = g.Номер_маршрута 
where s.Дата_отправки like '2023-09-20' or s.Дата_отправки like '2023-09-23'
group by p.Отчество
Order By [средний стаж] DESC

/*6*/
Select p.Отчество, avg(p.Стаж)[Средняя оценка]
From Водитель p inner join Перевозки s
on p.Индекс_Водителя = s.Индекс_водителя
inner join Маршрут g
on  s.Номер_маршрута = g.Номер_маршрута 
where s.Дата_отправки like '2023-09-23'
group by p.Отчество

/*7*/
Select p.Название_маршрута,p.Дальность, (select Count(*) from Перевозки s
Where  p.Номер_маршрута = s.Номер_маршрута )[Количество]
From Маршрут p
Group by p.Название_маршрута ,p.Номер_маршрута,p.Дальность
Having p.Дальность >10 and p.Дальность <20
