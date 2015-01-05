set PGHOST=the report server IP
set PGPORT=the report server port
set PGUSER=the report server (super)user
set PGPASSWORD=the report server (super)user password
set NEWDBNAME=name of the report db to create
set FDWSERVERNAME=a name for the foreign data wrapper server. doesn't need to match anything
set FDWSERVERHOST=the live server host name
set FDWSERVERHOSTADDR=the live server host IP address
set FDWSERVERPORT=the live server port
set FDWSERVERDBNAME=the live server db name
set FDWSERVERUSER=the live server user name
set FDWSERVERPASS=the live server user password
set "SCRIPTDIR=C:\Users\Lstevens\Desktop\sqldatamart\"

set "SCRIPT01=%SCRIPTDIR%01_create_fdw_db.sql"
set "SCRIPT02=%SCRIPTDIR%02_create_fdw_tables.sql"
set "SCRIPT03=%SCRIPTDIR%03_create_matviews_for_fdw_tables.sql"
set "SCRIPT04=%SCRIPTDIR%04_create_fdw_matview_indexes.sql"
set "SCRIPT05=%SCRIPTDIR%05_create_dm_schema_matviews.sql"
set "SCRIPT06=%SCRIPTDIR%06_create_schema_for_each_study.sql"
set "SCRIPT07=%SCRIPTDIR%07_create_matviews_for_study_common_tables.sql"
set "SCRIPT08=%SCRIPTDIR%08_create_matviews_for_study_itemgroups.sql"
set "SCRIPT09=%SCRIPTDIR%09_create_group_role_for_each_study.sql"
set "SCRIPT10=%SCRIPTDIR%10_grant_usage_select_on_study_schema_tables_to_group_role.sql"

C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d postgres -c "CREATE DATABASE %NEWDBNAME%;" -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT01% -v FDWSERVERNAME=%FDWSERVERNAME% -v FDWSERVERHOST=^'%FDWSERVERHOST%^' -v FDWSERVERHOSTADDR=^'%FDWSERVERHOSTADDR%^' -v FDWSERVERPORT=^'%FDWSERVERPORT%^' -v FDWSERVERDBNAME=^'%FDWSERVERDBNAME%^' -v FDWSERVERUSER=^'%FDWSERVERUSER%^' -v FDWSERVERPASS=^'%FDWSERVERPASS%^' -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT02% -v FDWSERVERNAME=%FDWSERVERNAME% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT03% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT04% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT05% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT06% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT07% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT08% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT09% -P pager
C:\"Program Files"\PostgreSQL\9.3\bin\psql -q -h %PGHOST% -p %PGPORT% -d %NEWDBNAME% -f %SCRIPT10% -P pager

pause