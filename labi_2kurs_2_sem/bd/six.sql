--1. Определите местоположение файла параметров инстанса. 
SELECT value FROM v$parameter WHERE name = 'spfile';
--2. Убедитесь в наличии этого файла в операционной системе. 


--3. Сформируйте PFILE с именем XXX_PFILE.ORA. Исследуйте его содержимое. Поясните известные вам параметры в файле.
CREATE PFILE = 'OPA_PFILE.ORA' FROM SPFILE;
--4. Измените какой-либо параметр в файле PFILE.
SELECT NAME,VALUE FROM V$PARAMETER where name= 'open_cursors';
ALTER SYSTEM SET OPEN_CURSORS = 350;

--5. 
CREATE SPFILE='C:\oracle\database\SPFILE.ORA' FROM PFILE='C:\oracle\dbhomeXE\database\OPA_PFILE.ORA';
--6.
//shutdown immediate
//startup PFILE='C:\Oracle\dbhomeXE\database\OPA_PFILE.ORA';


--7
//shutdown immediate
//startup
--8
SELECT NAME FROM V$CONTROLFILE;
-- 9
ALTER SYSTEM SET CONTROL_FILES = 'C:\ORACLEDB\DB\ORADATA\XE\CONTROL01.CTL' ,'C:\ORACLEDB\DB\ORADATA\XE\MY.CTL' SCOPE = SPFILE;


--10
SELECT * FROM V$PASSWORDFILE_INFO;

--12. Получите перечень директориев для файлов сообщений и диагностики. 
SELECT * FROM V$DIAG_INFO;


--14. Найдите и исследуйте содержимое трейса, в который вы сбросили управляющий файл.
SELECT * FROM v$diag_info WHERE name = 'Diag Trace';

