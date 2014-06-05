#Description
Method for setting up remote reporting database running off live data from an OpenClinica instance.
* report db connects to live db using postgres foreign data wrapper
* report db stores live db using materialized views (public schema)
* public schema data aggregated, stored in materialized views in dm schema
* dm schema data aggregated, stored in materialized views in study schemas
* result is one schema per study with a materialized view for each item group in the study

Report db data refreshed in cascading fashion to minimize read locks on final item group matviews (public->dm->study). Read locks means a matview can't be read from while it is being refreshed. Once postgres 9.4 is released, concurrent refreshes can occur which will eliminate read locks altogether.

Performance with an instance with ~400k rows of item_data is 2mins to refresh everything.

#Requirements
01. postgres 9.3
02. pgAgent (for scheduling refresh, alternatively make/use shell scripts)

#Creating a new instance

##On OpenClinica live db:
01. create login role with privileges to select on all tables in public schema
02. in pg_hba.conf, allow connections from report db IP address
    (ensure that server/firewall accepts connections accordingly)

###If the OpenClinica schema has changed since 3.1.4.1
03. generate new script for report_02
04. generate new script for report_04

##On OpenClinica report db:
00. configure and run the setup bat file. this runs steps 01 to 11 below. options are:

* PGHOST=the report server IP
* PGPORT=the report server port
* PGUSER=the report server (super)user
* PGPASSWORD=the report server (super)user password
* NEWDBNAME=name of the report db to create
* FDWSERVERNAME=a name for the foreign data wrapper server. doesn't need to match anything
* FDWSERVERHOST=the live server IP
* FDWSERVERPORT=the live server port
* FDWSERVERDBNAME=the live server db name
* FDWSERVERUSER=the live server user name
* FDWSERVERPASS=the live server user password
* SCRIPTDIR=directory where you put the scripts

01. create db, fdw server with public user mapping to OCPG select role
02. create fdw table for each OCPG table
03. create matview for each fdw table
04. create indexes on each matview
05. create dm schema with materialized views
06. create schema for each study
07. create matviews for study common tables (clinicaldata, metadata, etc)
08. create matviews for each study item group
09. create group role for each study
10. grant usage and select on study schema tables to group role
11. assign roles for relevant schemas to users (perform manually)

#Maintenance Tasks on OpenClinica report db

##Refresh matviews with pgAgent:
01. add pgAgent job to run refresh_matviews query every x minutes
    this refreshes matviews in the public schema, 
    then dm schema (in order of creation per report_05), then all other schemas

##Study definition updates in OpenClinica live db
(uncomment "where item_group_oid='Item Group OID'" in report script):
06. (if CRF updated) drop affected study itemgroup matviews (use execute(drop_statements))
06. (if new CRF or CRF updated) create affected study itemgroup matviews (use execute(create_statements))
10. grant usage and select on study schema tables to group role

##New study added to OpenClinica live db
(uncomment "where study_name='Raw Study Name'" in report scripts):
06. create schema for each study
07. create matviews for study common tables (clinicaldata, metadata, etc)
08. create matviews for each study item group
09. create group role for each study
10. grant usage and select on study schema tables to group role
11. assign roles for relevant schemas to users (perform manually)