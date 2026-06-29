ALTER SESSION SET "_oracle_script" = TRUE;

CREATE TABLESPACE TS_OPA
DATAFILE 'TS_OPA.dbf'
SIZE 7M
AUTOEXTEND ON
NEXT 5M
MAXSIZE 30M;

CREATE TEMPORARY TABLESPACE TS_OPA_TEMP
TEMPFILE 'TS_OPA_TEMP.dbf'
SIZE 5M
AUTOEXTEND ON
NEXT 3M
MAXSIZE 20M;

SELECT tablespace_name
FROM dba_tablespaces;   

SELECT tablespace_name, file_name
FROM dba_data_files;

CREATE ROLE RL_OPACORE;

GRANT CREATE SESSION TO RL_OPACORE;
GRANT CREATE TABLE TO RL_OPACORE;
GRANT CREATE VIEW TO RL_OPACORE;
GRANT CREATE PROCEDURE TO RL_OPACORE;


Select * from dba_roles where role like 'RL_OPACORE';
Select * from DBA_SYS_PRIVS where grantee = 'RL_OPACORE'

Create profile PF_OPACORE LIMIT
Password_life_time 180
Sessions_per_user 3
Failed_login_attempts 7
Password_lock_time 1
Password_reuse_time 10
Password_grace_time default
Connect_time 180
Idle_time 30;


Select * FROM DBA_PROFILES; 
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'PF_OPACORE'; 
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'DEFAULT'; 


CREATE USER OPACORE 
DEFAULT TABLESPACE TS_OPA
TEMPORARY TABLESPACE TS_OPA_TEMP
PROFILE PF_OPACORE
ACCOUNT UNLOCK;
grant create session to OPACORE;

ALTER USER OPACORE IDENTIFIED BY PashA2005;

ALTER USER OPACORE QUOTA 2M ON TS_OPA;
grant create table to OPACORE;

INSERT INTO OPA_T (id, name, age, email)
VALUES (1, 'John Doe', 25, 'john.doe@example.com');

INSERT INTO OPA_T (id, name, age, email)
VALUES (2, 'Jane Smith', 30, 'jane.smith@example.com');

CREATE TABLE OPA_T (
  id INT,
  name VARCHAR(255),
  age INT,
  email VARCHAR(255)
);

ALTER TABLESPACE TS_OPA OFFLINE;

ALTER TABLESPACE TS_OPA ONLINE;

drop table OPA_T;
select * from OPA_T;











