/*3*/
SELECT name, open_mode FROM v$pdbs;

/*4*/

ALTER SESSION SET CONTAINER = pavel;

CREATE TABLESPACE pavel
DATAFILE 'TS_OPA_2.dbf'
SIZE 7M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 30M;
  
CREATE ROLE new_pavel_role;
  
CREATE PROFILE new_pavel_profile LIMIT
  FAILED_LOGIN_ATTEMPTS 3
  PASSWORD_LIFE_TIME 90;
  
CREATE USER U1_OPA_PDB IDENTIFIED BY password;
/*5*/
connect U1_OPA_PDB/password@//localhost:1521/pavel as sysdba;
ALTER USER U1_OPA_PDB QUOTA UNLIMITED ON USERS;
GRANT INSERT ON Employees TO U1_OPA_PDB;

CREATE TABLE Employees (
  EmployeeID INT,
  EmployeeName VARCHAR(50)
);

INSERT INTO Employees (EmployeeID, EmployeeName) VALUES (1, 'John Doe');
INSERT INTO Employees (EmployeeID, EmployeeName) VALUES (2, 'Jane Smith');
INSERT INTO Employees (EmployeeID, EmployeeName) VALUES (3, 'Mike Johnson');

drop table Employees
select * from Employees
/*6*/
SELECT username FROM dba_users WHERE username LIKE '%PA%';
SELECT grantee, granted_role FROM dba_role_privs WHERE grantee LIKE 'PA%';
/*7*/

CREATE USER C##OPA IDENTIFIED BY password;
GRANT CREATE SESSION TO C##OPA;
/*8*/
GRANT CREATE TABLE TO C##OPA;
/*10*/
CREATE TABLE Employeeses (
  EmployeeID INT,
  EmployeeName VARCHAR(50)
);

drop table Employeeses

INSERT INTO Employeeses (EmployeeID, EmployeeName) VALUES (1, 'John Doe');
INSERT INTO Employeeses (EmployeeID, EmployeeName) VALUES (2, 'Jane Smith');
INSERT INTO Employeeses (EmployeeID, EmployeeName) VALUES (3, 'Mike Johnson');

ALTER USER U1_OPA_PDB QUOTA UNLIMITED ON USERS;
GRANT INSERT ON Employeeses TO C##OPA;

/*11*/
SELECT object_name, object_type
FROM all_objects
WHERE owner = 'C##OPA';

SELECT object_name, object_type
FROM all_objects
WHERE owner = 'U1_OPA_PDB';

