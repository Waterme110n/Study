select * from OSA_t;

CREATE TABLE OSA_t (
  Number_E NUMBER(3) PRIMARY KEY,
  SecondName VARCHAR2(50)
);

INSERT INTO OSA_T (Number_E, SecondName)
VALUES (12, 'Osadchy');

INSERT INTO OSA_t (Number_E, SecondName)
VALUES (2, 'Galustian');    

INSERT INTO OSA_t (Number_E, SecondName)
VALUES (3, 'Breshneva');    

commit

update OSA_t set Number_E = 1 where Number_E = 12;
update OSA_t set SecondName = 'Karnilovish' where SecondName = 'Galustian';

commit

select * from OSA_t where Number_E < 3;

delete from OSA_t where Number_E = 3
select * from OSA_t;
Rollback

CREATE TABLE OSA_t_child (
    NAME VARCHAR2(50) Primary key,
    age number(3),
    parent_E number(3),
    FOREIGN KEY (parent_E) REFERENCES OSA_t (Number_E)
);

INSERT INTO OSA_t_child (NAME, age, parent_E)
VALUES ('Pavel', 13, 1);

INSERT INTO OSA_t_child (NAME, age, parent_E)
VALUES ('Mixail', 23, 2);

INSERT INTO OSA_t_child (NAME, age, parent_E)
VALUES ('Evelina', 46, 3);
       
select secondname, name, age from OSA_t left join OSA_t_child 
on  OSA_T.Number_E = OSA_T_child.parent_E;
       
select secondname, name, age from OSA_t inner join OSA_t_child 
on  OSA_T.Number_E = OSA_T_child.parent_E;

drop table OSA_t_child;
drop table OSA_t;
