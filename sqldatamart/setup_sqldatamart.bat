set start_time=%time%
set "psql=C:\Program Files\PostgreSQL\9.3\bin\psql"
set PGHOST=127.0.0.1
set PGPORT=myOCDM_Port
set PGUSER=postgres
set PGPASSWORD=thePostgresSuperuserPassword
set foreign_server_host_name=myOCDM_FQDN
set foreign_server_host_address=myOCDM_IP
set foreign_server_port=myOC_Port
set foreign_server_database=myOC_DBname
set foreign_server_user_password=theForeignServer_ocdm_fdw_UserPassword
set foreign_server_openclinica_schema_name=myOC_SchemaName
set "scripts_path=C:\Users\myUserName\Desktop\sqldatamart"

"%psql%" -q  -d postgres -c "CREATE DATABASE openclinica_fdw_db;" -P pager
"%psql%" -q  -d openclinica_fdw_db -c "CREATE SCHEMA openclinica_fdw;" -P pager
"%psql%" -q  -d openclinica_fdw_db -c "ALTER DATABASE openclinica_fdw_db SET search_path = 'openclinica_fdw';"
"%psql%" -q  -d openclinica_fdw_db -f "%scripts_path%"\dm_functions.sql -P pager
"%psql%" -q  -d openclinica_fdw_db -f "%scripts_path%"\dm_build_commands.sql ^
    -v foreign_server_host_name=^'%foreign_server_host_name%^' ^
    -v foreign_server_host_address=^'%foreign_server_host_address%^' ^
    -v foreign_server_port=^'%foreign_server_port%^' ^
    -v foreign_server_database=^'%foreign_server_database%^' ^
    -v foreign_server_user_password=^'%foreign_server_user_password%^' ^
    -v foreign_server_openclinica_schema_name=^'%foreign_server_openclinica_schema_name%^' ^
    -P pager
echo %start_time% %time%
pause