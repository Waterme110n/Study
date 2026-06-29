/*1*/
SELECT tablespace_name, contents FROM dba_tablespaces;
/*2*/
SELECT tablespace_name, file_name FROM dba_data_files;
SELECT tablespace_name, file_name FROM dba_temp_files;
SELECT tablespace_name FROM dba_tablespaces WHERE contents = 'UNDO';
/*3*/
SELECT * FROM v$logfile;
SELECT group#,status FROM v$log WHERE status = 'CURRENT';
/*4*/
SELECT group#, member FROM v$logfile;
/*5*/
SELECT group#, sequence#, status, bytes, first_change# FROM v$log;

ALTER SYSTEM SWITCH LOGFILE;
/*6*/
ALTER DATABASE ADD LOGFILE GROUP 5 (
'C:\labi_2kurs_2_sem\bd\4\redo06.log',
'C:\labi_2kurs_2_sem\bd\4\redo061.log',
'C:\labi_2kurs_2_sem\bd\4\redo062.log') SIZE 20m BLOCKSIZE 512;
/*7*/
ALTER DATABASE DROP LOGFILE MEMBER 'C:\labi_2kurs_2_sem\bd\4\redo062.log';
ALTER DATABASE DROP LOGFILE MEMBER 'C:\labi_2kurs_2_sem\bd\4\redo061.log';

ALTER DATABASE DROP LOGFILE GROUP 5;
/*8*/
SELECT name, log_mode FROM v$database;
/*9*/
SELECT MAX(sequence#) AS last_archive_log FROM v$log_history;

/*10,11,12
SELECT open_mode FROM v$database;

shutdown immediate;
startup mount;
alter database noarchivelog;
alter database archivelog;
alter database open;*/


/*13*/
SELECT name FROM v$controlfile;
/*14*/
SELECT TYPE, RECORD_SIZE FROM V$CONTROLFILE_RECORD_SECTION;

