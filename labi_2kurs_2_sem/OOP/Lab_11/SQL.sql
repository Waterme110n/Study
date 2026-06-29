use lab11_oop;

CREATE TABLE consultation
(
    id int PRIMARY KEY IDENTITY(1,1),
    name varchar(200) NOT NULL,
    subject varchar(200) NOT NULL,
    time varchar(50) NOT NULL,
    date date NOT NULL,
    isFree bit NOT NULL
);
drop table consultation;

insert consultation (name, subject, time, date, isFree)
VALUES
('Мущук А.Н.', 'ООП', '11:30', '2023-09-11', 1),
('Барковский Е.В.', 'КЯР', '19:00', '2023-05-01', 1),
('Шиман Д.В.', 'ПСП', '13:00', '2023-07-09', 1);

select * from consultation;
DELETE FROM consultation;