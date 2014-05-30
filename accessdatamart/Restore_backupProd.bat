echo on
REM Set Date 
set day2=%DATE:~0,3%
set day=%DATE:~4,2%
set yyyy=%DATE:~10,4%
set mm=%DATE:~7,2%
set filedate=%day%-%mm%-%yyyy%

REM Set Time
for /f "tokens=1 delims=: " %%h in ('time /T') do set hour=%%h
for /f "tokens=2 delims=: " %%m in ('time /T') do set min=%%m
set filetime=12-00

REM Set Time Stamps
set timestamp=%filedate%--%filetime%
set pgfile=%timestamp%.backup
set tzip=%day2%-%timestamp%.zip
set sdir=\\svr-oc-pSQL8\backup\zips
set zipdir=C:\"Program Files"\7-zip\7z x -mmt
set PGPASSWORD='your clinica account password here'

REM Delete prior backups
C:
cd \oc\backupProd\
del /S /F /Q *.*
rmdir /S /Q backup

REM Check if zip is in directory or not
IF EXIST %sdir%\%tzip% GOTO indir
IF NOT EXIST %sdir%\%tzip% GOTO notindir

REM Extract from directory
:indir
%zipdir% %sdir%\%tzip%
GOTO restore

REM Extract from week2.zip then extract
:notindir
%zipdir% %sdir%\week2.zip %tzip%
%zipdir% %tzip%
GOTO restore

REM Restore data to postgres
:restore
C:\"Program Files"\PostgreSQL\9.2\bin\psql -U clinica -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'openclinica' AND pg_stat_activity.pid <> pg_backend_pid();"
C:\"Program Files"\PostgreSQL\9.2\bin\dropdb -U clinica openclinica
C:\"Program Files"\PostgreSQL\9.2\bin\psql -U clinica -d postgres -c "CREATE DATABASE openclinica WITH ENCODING='UTF8' OWNER=clinica;"
C:\"Program Files"\PostgreSQL\9.2\bin\pg_restore -U clinica -d openclinica < backup\postgres\openclinica-%pgfile%
REM Run warehousing script
C:\"Program Files"\PostgreSQL\9.2\bin\psql --dbname=openclinica -U clinica --file="C:\Users\Lstevens\Desktop\2013-09-17 warehousing script.sql"
REM Open access processor and execute macro run_get_study_list
start "" "C:\Users\Lstevens\Desktop\2013-09-20 oc access processor\2014-03-18 oc access processor.accdb" /x run_get_study_list