# Introduction

## Overview

This document describes the procedures for setting up and maintaining a data warehouse which provides an interface to data from an OpenClinica database.

## Requirements
The OCDM has been implemented to meet the following requirements for working with OpenClinica data:

- Full access; all data from the database available for investigating study or operational outcomes.
- Convenient retrieval; accessible from any client able to communicate with postgres, data transformed into itemgroup tables.
- Secure retrieval; see section *Security Measures*
- Fast updates and retrieval; materialized views used to cache query results, optimised queries and postgres settings.
- Stability; dynamically generated object definitions are set on database creation, permanent objects allow more convenient permissions management.
- Low maintenance; scheduled tasks refresh data and update the database when new studies are created.

## Security Measures
The following configurations have been implemented to contribute to the confidentiality of study data. These should complement institutional policies that govern responsible handling of study data.

- Domain Service Account for OCDM postgres services; allows the use of SSPI authentication for user connections to the database, and allows control over the level of permissions associated with the account running these services.
- SSPI Authentication to OCDM postgres; allows use of AD password management for single sign on for users on the domain.
- TLS Certificate; allows encrypted connections from remote users, and between OC and OCDM.
- OCDM Connection Configuration; requires secure remote connections from users on the domain, from IP addresses in the domain user IP range. Local admin connections require password authentication.
- OCDM User Management; users granted minimum necessary permissions to perform their role tasks.
- Data Access Logging; all connections and statements submitted to OCDM are logged.

## Assumptions
The following assumptions are made:

- A server with an instance of OpenClinica is already installed and running with TLS enabled (referred to as OC).
- A second server is available for setting up the OpenClinica Data Mart (referred to as OCDM).
- Both servers are running Windows Server, and are on the same Active Directory Domain.
- Firewall settings allow connections from OCDM to OC on the port which the OC postgres server listens on.
- Firewall settings allow connections from domain accounts to OCDM on the port which the OCDM postgres server listens on.

In general, the Windows features used have equivalents in Linux, e.g. SSPI functions similarly to GSSAPI. Setting up the above infrastructure and implementing OCDM on Linux is not in the scope of this document.

## Software Dependencies
The following software was current at the time of writing, and is required to complete the setup:

- Win32 OpenSSL v1.0.0o Light
- Postgresql 9.3.5.
- PgAgent 3.4.0.
- psqlODBC 09_03_0400.

# Setup

## Steps to Complete on OC Server

### Prepare Root Certificate
Before opening a secure connection, a client should check the certificate presented by the server. One of the checks is that it was issued by a trusted certificate. It is common that a CA will issue a certificate using an intermediate certificates that is issued by another certificate, and so on, and these must also be checked.

Windows maintains a certificate store that has common CA root and intermediate certificates, but the libpq library that postgres and psqlODBC use does not currently interact with this store. Libpq currently only accepts one file for a issuing certificate to use for checking the server certificate. When there are intermediate certificates, these must be included in the same file.

- Open the server certificate and inspect the *Certification Path* tab. A copy of all the issuing certificates above the server certificate is required, in PEM format. These should be available on the CA's website.
- Create a file named *root.crt*, and paste in the intermediate certificate(s) and root certificate strings from the issuing certificates, such that the file looks like the following:

```
-----BEGIN CERTIFICATE-----
... intermediate certificate string ...
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
... root certificate string ...
-----END CERTIFICATE-----
```

- Copy this *root.crt* file to the OCDM server, as OCDM will use it when connecting to OC.

### Create a Postgres Login Role for OCDM
In order to retrieve data, OCDM needs to be able to connect to OC, which requires a login user on the OC postgres server. This server to server connection requires password authentication, as it cannot use SSPI.

- Log in to OC postgres as a superuser and run the following commands to create a role with the necessary permissions:

```sql
CREATE ROLE "openclinica_select"
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT CONNECT ON DATABASE openclinica to openclinica_select;
GRANT USAGE ON SCHEMA public to openclinica_select;
GRANT SELECT ON ALL TABLES IN SCHEMA public to openclinica_select;
```

- Run the following commands to create a login role for the connection:

```sql
CREATE ROLE ocdm_fdw WITH LOGIN ENCRYPTED PASSWORD 'aGoodPassword'
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT openclinica_select TO ocdm_fdw;
```

### Update the OC postgres Host Based Authentication file (pg_hba.conf)
- Add a row to allow connections to OC from OCDM (in addition to existing local rows, ensure there is no conflict):

```
# TYPE  DATABASE        USER                 ADDRESS                 METHOD
hostssl openclinica     ocdm_fdw             ocdmIPAddress/32         md5
```

## Steps to Complete on OCDM Server

### Obtain Server TLS Certificate
The following uses OpenSSL for Windows to generate a Certificate Signing Request (CSR).

- Install OpenSSL for Windows (available form Shining Light Productions)
- Open a command prompt and run the following command to generate a CSR (output as *CSR.csr*) and private key (will be output as *server.key*), insert the subject (-subj) parameter details as appropriate:

```
C:\OpenSSL-Win32\bin\openssl.exe req -newkey rsa:4096 -sha512 -nodes -subj "/C=myCountry/ST=myState/L=myLocation/O=myOrg/OU=myOrgUnit/CN=myOCDM_FQDN" -out CSR.csr -keyout server.key
```

- Send the CSR file to a Certificate Authority (CA) and request a certificate. 
- Name the provided certificate file *server.crt*

The secrecy of *server.key* and *server.crt* is very important so do not copy them anywhere outside the server.

### Prepare Root Certificate
As was done for the OC server, a *root.crt* file will be needed for user clients connecting to OCDM.

- Create a *root.crt* file using the OCDM *server.crt* certification path.
- Copy this *root.crt* file to each client, as described in section *User Client Connections*

### Create a Domain Service Account for the OCDM PostgreSQL Services
A domain service account is used for the postgres services, which allows the use of SSPI authentication for user connections to the database, and allows control over the level of permissions associated with the account running these services.

### Install PostgreSQL on OCDM
- Use the Windows installer from postgresql.org.
- Complete the optional installation of pgAgent job scheduler
- Choose a good password for the postgres superuser and keep it secret.

There seemed to be a bug in the postgres installation when using double quote characters in the password. The *data* directory would fail to be created. Use lots of other characters instead.

### Grant Windows Folder Permissions to the Domain Service Account
By default the *data* directory should be created at:

```
C:\Program Files\PostgreSQL\9.3\data 
```

- Put a copy of the OCDM *server.key* and *server.crt*, and the OC *root.crt* in the *data* directory.
- Find the data directory and assign *Full Control* of this directory to the OCDM domain service account. Right-click folder ; Properties ; Security ; Edit ; Add ; enter full domain service account name.

### Change Postgres Service Accounts
- Open services.msc and stop the *postgresql-x64-9.3* service.
- Open the service properties and change Log On to use the domain service account credentials
- Do the same for the *pgAgent* service.
- Remove the user folder that may have been created for the local postgres user during installation, located at:

```
C:\Users\postgres
```

Do not start either service yet, there are more steps to complete.

### Update the pgAgent binPath
The pgAgent installer defaults to the using the postgres superuser for connecting to postgres, to check for and run jobs. The binPath is the command to start the service and must be updated to use the domain service account login role that will be created in postgres. The pgAgent job information is stored in the postgres database that is automatically created on installation.

- Open an administrator command prompt and execute the following command (ensure the details are correct):

```
sc config pgAgent binPath= "C:\Program Files (x86)\pgAgent\bin\pgagent.exe RUN pgAgent host=localhost port=5433 user=myDomainServiceAccountName dbname=postgres"
```

### Update the postgres Host Based Authentication file (pg_hba.conf)
The *pg_hba.conf* file is in the postgres data directory, and allows control over connections to the database server. The following configuration allows local connections for the postgres and domain service account login roles; the former by password and the latter by SSPI. Additionally, secure remote connections from domain users from the domain user IP range are allowed with SSPI.

- Replace the default IPv4 and IPv6 rows with the following:

```
# TYPE  DATABASE        USER                 ADDRESS                 METHOD
host    all             postgres             127.0.0.1/32            md5
host    all             myDomainServiceAccountName             127.0.0.1/32            sspi map=mapsspi include_realm=1 krb_realm=myDomain
hostssl all             all                  domainUserIPRange          sspi map=mapsspi include_realm=1 krb_realm=myDomain
host    all             postgres             ::1/128                 md5
host    all             myDomainServiceAccountName             ::1/128                 sspi map=mapsspi include_realm=1 krb_realm=myDomain
```

SSPI uses the domain credentials of the user to establish authentication, i.e. if the user is currently authenticated with the domain, they are trusted to connect to the database with their domain user name.

### Update the postgres User Name Map file (pg_ident.conf)
The *pg_ident.conf* file is in the postgres data directory, and allows mapping between system and postgres login roles names.

- Add a row to map domain account users to database usernames without the domain part:

```
# MAPNAME       SYSTEM-USERNAME         PG-USERNAME
mapsspi       /^(.*)@myDomain$          \1
```

This means that a client connecting with a domain account name of *myUser*@*myDomain* is mapped to the postgres login role *myUser*. The case of the postgres login role must match the case of the domain account name, e.g. myuser=myuser, Myuser=Myuser, MYUSER=MYUSER.

### Update the postgres Global User Configuration file (postgresql.conf)
The *postgres.conf* file is in the postgres data directory, and allows control over settings that affect the behaviour and performance of the database server.

Settings are disabled by appending a # symbol to the beginning of the line, so remove the # symbol for the lines with the settings shown below. The comments shown here do not need to be added to the *postgresql.conf* file.

- Locate the rows with settings shown below and update the default values (adjust depending on expected connections and available ram, below is for 4GB): 

```
# - Connection Settings -
listen_addresses = '*' # listen to all IP addresses. Controlled further via pg_hba.conf.
port = myOCDM_Port  # port the server listens on, must be unoccupied by other services
max_connections = 10  # set lower limit on the number of connections, mostly for resource consumption

# - Security and Authentication -
ssl = on  # allow use of ssl
ssl_cert_file = 'server.crt'  # name of server cert file in data directory (for OCDM)
ssl_key_file = 'server.key'  # name of server key file in data directory (for OCDM)
ssl_ca_file = 'root.crt' # name of cert trust chain file in data directory (from OC)

# - Memory -
shared_buffers = 1024MB  # raised ram for caching (ram / 4)
temp_buffers = 512MB  # raised ram for temp tables (run/refresh mega queries), (ram / 8)
work_mem = 256MB  # raised ram for sorting (ram / (2 * max_connections))
maintenance_work_mem = 512MB  # raised ram for maintenance operations (ram / 8)

# - Checkpoints -
checkpoint_segments = 128  # raised interval to write a checkpoint, every 128 * 16MB = 2GB
checkpoint_completion_target = 0.75  # raised target to finish checkpoint when next one 75% complete

# - Planner Cost Constants -
effective_cache_size = 3072MB  # raised estimate of available ram for caching (3/4 available ram)

# - Other Planner Options -
default_statistics_target = 1000  # raised limit for statistics entries for query planning

# - Where to Log -
log_destination = 'csvlog' # log to csv format so logs can be analysed more easily 
logging_collector = on  # enable logging
log_filename = 'postgresql-%Y-%m-%d.log'  # log daily file names like postgresql-2015-01-20.log
log_rotation_size = 0  # do not rotate log files based on log file size

# - What to Log -
log_connections = on  # log client connections
log_disconnections = on  # log client disconnections
log_duration = on  # log duration of submitted queries
log_statement = 'all'  # log all submitted statements
```

### Start the postgres service (postgresql-x64-9.3)
- Open services.msc and start the *postgresql-x64-9.3* service.

Note that restarting or stopping this service typically causes the pgAgent service to stop as well. When (re)starting this service (not now, but after setup is complete e.g. for server maintenance), the pgAgent service will need to be started as well.

### Create postgres OpenClinica Report Database
The creation of the database is handled by a package of scripts called *sqldatamart*. A batch file accepts settings for the database which are substituted into the scripts where necessary. The setup needs to be run as a superuser because it requires a 'CREATE EXTENSION' statement for the foreign data wrapper, which can only be executed by superusers. 

- Run the sqldatamart batch script with the following settings:

```
set PGHOST=127.0.0.1
set PGPORT=myOCDM_Port
set PGUSER=postgres
set PGPASSWORD=thePostgresSuperuserPassword
set foreign_server_host_name=myOCDM_FQDN
set foreign_server_host_address=myOCDM_IP
set foreign_server_port=myOC_Port
set foreign_server_database=myOC_DBname
set foreign_server_user_password=theForeignServer_ocdm_fdw_UserPassword
set foreign_openclinica_schema_name=myOC_SchemaName
set "scripts_path=C:\Users\myUserName\Desktop\sqldatamart"
```

The *scripts_path* setting is the folder where the sqldatamart scripts have be copied to on the server. See the scripts for documentation on their commands and functions.

### Create a postgres *pgAgent* Role
The pgAgent scheduler user (in this case, the domain service account) requires some permissions on the postgres database to run jobs, as the pgAgent settings are stored in the postgres database. 

- Log in to the postgres database as the postgres superuser and run the following commands to create the *pgAgent* role:

```sql
CREATE ROLE pgagent
    NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
GRANT CONNECT ON DATABASE postgres TO pgagent;
GRANT ALL ON SCHEMA pgagent TO pgagent;
GRANT ALL ON ALL TABLES IN SCHEMA pgagent TO pgagent;
GRANT ALL ON ALL SEQUENCES IN SCHEMA pgagent TO pgagent;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA pgagent TO pgagent;
```

### Create a postgres Login Role for the Domain Service Account
The domain service account will run the scheduled jobs, and perform maintenance on the openclinica_fdw_db database. This role requires *CREATEROLE* privilege as mananging roles is one of the maintenance tasks.

- Run the following commands to create the domain service account user:

```sql
CREATE ROLE myDomainServiceAccountName LOGIN
    NOSUPERUSER INHERIT NOCREATEDB CREATEROLE NOREPLICATION;
GRANT pgagent TO myDomainServiceAccountName;
GRANT dm_admin TO myDomainServiceAccountName;
```

### Start the postgres *pgAgent* service
- Open services.msc and start the *pgAgent* service.

### Create pgAgent Job to Update Database
To keep the data up to date, the materialized views must be refreshed. So that the data is correct, this should be done in the order they were created. The database also needs to be updated when new studies are created. So that this happens automatically:

- create a pgAgent job with the following settings:

```
Name: openclinica_fdw_db_refresh
Enabled: True
Job Class: Data import
Host agent: myOCDM_FQDN
```


- create the following job step for this job:

```
Name: step1_refresh_openclinica_fdw
Enabled: True
Connection Type: Local
Database: openclinica_fdw_db
Kind: SQL
On Error: Fail
Definition: TABLE dm.refresh_matviews_openclinica_fdw
```

- create additional job steps with the same settings as above, except for *Name* and *Definition*, as follows:

```
Name: step2_refresh_dm
Definition:
    /* set query planner params for transaction that improve execution time */
    SET LOCAL seq_page_cost = 0.25; /* affects dm.metadata */
    SET LOCAL join_collapse_limit = 1; /* affects dm.clinicaldata */
    TABLE dm.refresh_matviews_dm;
Name: step3_refresh_study
Definition: TABLE dm.refresh_matviews_study
Name: step4_build_new_studies
Definition: TABLE dm.build_new_study
```

- create a schedule for the pgAgent job, with the following settings:

```
Name: openclinica_fdw_db_refresh_schedule
Enabled: True
Start: theCurrentDate
End: Blank
Days: All
Month Days: All
Months: All
Hours: All
Minutes: 30
```

The scheduled frequency should be adjusted depending on the time the job takes to complete, and how much performance impact there is on the live server.

# OCDM Maintenance

## User Management
A scheduled maintenance task will handle most login role and permission management. Sometimes these tasks will need to be performed manually, which can be done as described in this section.

### Creating Login Roles
In order for a domain account user to connect to the database, a matching postgres login role must be created. The case of the postgres login role must match the case of the domain account name, e.g. myuser=myuser, Myuser=Myuser, MYUSER=MYUSER.

Only the postgres superuser and the Domain Service Account have permission to create new login roles. The *CREATEROLE* permission allows privilege escalation so should be available to as few users as possible. For example a *NOCREATEDB CREATEROLE* role can create a *CREATEDB CREATEROLE* role.

- Log in to the OCDM server as the postgres user and create a login role using the following command:

```sql
CREATE ROLE "myDomainAccountName" LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
```

This allows the domain account user to connect to the database. The ability to retrieve data depends on the permissions granted to the account, as described below.

### Login Role Permissions
Users should be granted access only to active studies that they are working on. Each user may be given access to multiple studies as required. 

- Grant permission to access study data using the following command:

```sql
GRANT dm_study_my_study_schema_name TO "myDomainAccountName";
```

- Revoke permission to access study data using the following command:

```sql
REVOKE dm_study_my_study_schema_name FROM "myDomainAccountName";
```

### Administrator Permissions
A user should only be an administrator if they are required to create new or modify existing objects in the database; or grant or revoke study or administrator access to another login role.

- Grant administrator permissions using the following command:

```sql
GRANT dm_admin TO "myDomainAccountName" WITH ADMIN OPTION;
```

- Revoke administrator permissions using the following command:

```sql
REVOKE dm_admin FROM "myDomainAccountName";
```

The build commands are run by the postgres superuser with the *dm_admin* group role, so any member login role will own practically all objects in the *openclinica_fdw_db* database. This also means that *dm_admin* members can access all study data. Users requiring access to all study data but who do not require administrator privileges should have access to each study granted separately.

## Creating Custom Queries

### General Policy

If a query is created that would be useful for all studies, this should ideally be added to the *sqldatamart* scripts and the database rebuilt. Rebuilding the database involves dropping the openclinica_fdw_db database and re-running the *sqldatamart* batch script. 

Existing objects must not be modified directly; any bug should be addressed in the *sqldatamart* scripts that generate the objects and the database rebuilt.

Custom queries deemed useful for study data quality checks or analysis may be created by an administrator user as required. For example:

- queries to reshape data from a layout required for presentation, e.g. collapse itemgroups AE1 to AE50 into one AE group, or collapse columns pg1x/pg1y to pg50x/pg50y into pgindex/pgx/pgy.

- queries to summarise data for checking data quality or study outcomes, e.g. estimated date of infection, duplicated concomitant medications entries.  

### Storage

In case the database needs to be rebuilt for a bug fix or new feature, any custom queries created in the database should be saved centrally so that the queries can be re-created in the new database.

## Postgres Logs

### Analysis
The logs generated by OCDM postgres are in csv format for easier loading into postgres or other analysis tool. The postgres documentation includes instructions on loading postgres csv logs into postgres.

### Rotation
The pgAgent service will check for jobs every 5 seconds which generates a ~10MB of log data each day; with some additional minimal traffic this will translate in to a ~10GB per year. Therefore a policy for periodically archiving, summarising and/or deleting logs should be put in place.

# Setup for User Client Connections

## ODBC Connections
Many applications can use ODBC to communicate with postgres, such as MS Office, LibreOffice, Stata, SAS, etc. LibreOffice includes the necessary ODBC and JDBC drivers; however most other applications will require a driver to be installed, in this case psqlODBC.

### Install psqlODBC Driver
The installer should install both 32bit (*PostgreSQL Unicode*) and 64bit (*PostgreSQL Unicode(x64)*) drivers on a 64bit system, or just 32bit on a 32bit system. The release cycle for psqlODBC generally follows that of postgres which is approximately annually, so clients should update their version accordingly.

When creating a connection, the driver bits should only be relevant if the application is 32bit, as a 32bit application will not be able to use the 64bit driver. 64bit applications are usually able to use either the 64bit or 32bit driver.

- Install using the windows installer from postgresql.org.

#### Viewing ODBC Driver Details on Windows
On Windows 7 64bit, the default ODBC driver viewer (Start ; Programs ; Administrative Tools ; Data Sources (ODBC)) shows only the 64bit drivers, using the following executable:

```
C:\Windows\SysWOW64\odbcad32.exe
```

To view the 32bit driver, use the 32bit driver manager at:

```
C:\Windows\System32\odbcad32.exe
```

### Create Copy of OCDM postgres TLS Certificate
To facilitate secure connections, clients require a copy of the *root.crt* file to verify the OCDM server certificate.

- Copy the OCDM *root.crt* to the following directory, substituting *ClientUserName* for the client user name:

```
C:\Users\ClientUserName\AppData\Roaming\postgresql\root.crt
```

### Create hosts Record for OCDM postgres
This step may not be required in your environment. MS Access seems to be sensitive to DNS lookup timeout when initiating an ODBC connection. A workaround is to provide the machine with the IP matching the OCDM FQDN by adding a *hosts* file record. The suitability of this workaround depends on the stability of the IP address - if it static then it should not need to be updated after being created once per machine.

The IP address and server names are stable so this should only need to be done once per user. The hosts file is usually in the following directory:

```
C:\Windows\System32\drivers\etc\hosts
```

- Run following command in an administrator command prompt to add the record to the end of the hosts file:

```
echo     myOCDM_IP    myOCDM_FQDN>> C:\Windows\System32\drivers\etc\hosts
```

### ODBC Connections
Most applications that can use ODBC will accept and ODBC string to define the connection parameters. FileDSNs can provide the same parameters, but have the advantage of being able to be centrally managed.

In the following examples, to use the 64bit driver, use the driver name "PostgreSQL Unicode(x64)"; for 32bit, use the driver name "PostgreSQL Unicode".

#### ODBC Connection Strings
ODBC connection strings use the following syntax (adjust each parameter as appropriate):

```
"DRIVER={PostgreSQL Unicode(x64)};DATABASE=openclinica_fdw_db;SERVER=myOCDM_FQDN;PORT=myOCDM_port;SSLmode=verify-full;TextAsLongVarchar=0;UseDeclareFetch=1"
```

#### ODBC FileDSNs
FileDSNs use the following syntax (adjust each parameter as appropriate):

- Create a file named *ocdm-x64.dsn* that contains the following text:

```
[ODBC]
DATABASE=openclinica_fdw_db
DRIVER=PostgreSQL Unicode(x64)
SERVER=myOCDM_FQDN
PORT=myOCDM_Port
SSLmode=verify-full
TextAsLongVarchar=0
UseDeclareFetch=1
```

- Do the same for the 32 bit driver, create a file named *ocdm-x86.dsn*, with the following difference:

```
DRIVER=PostgreSQL Unicode
```

- Use a reference to the appropriate FileDSN in ODBC connection string as follows:

```
"FILEDSN=\\path\to\ocdm-x64.dsn"
```

#### SAS ODBC Syntax
The following command creates an ODBC connection to OCDM with a creates a LIBREF to *myStudyName* (insert File DSN reference string, or ODBC connection string):

```sas
LIBNAME myStudyNameLibName ODBC SCHEMA=myStudyNameSchemaName
NOPROMPT="fileDSN reference string, or ODBC connection string";
RUN;
```

The *SCHEMA* instruction informs SAS that references to objects in that library refer to objects in the specified schema, so that only the view name needs to be specified when writing SET statements (as shown in the following example).

The created library may only show views in the myStudyNameSchemaName schema, but not materialized views. These can still be accessed by name, for example the following command copies the contents of the *subjects* materialized view to the *work* library:

```sas
DATA work.subjects; SET myStudyNameLibName.subjects; RUN;
```

#### Stata ODBC Syntax
The following command creates an ODBC connection to OCDM and copies the contents of the *subjects* materialized view for *myStudyName* (insert File DSN reference string, or ODBC connection string):

```stata
odbc load, table("myStudyNameSchemaName.subjects") noquote connectionstring("fileDSN reference string, or ODBC connection string")
```

#### Microsoft Office
MS Office ODBC connection strings require a prefix of "ODBC;". Generally, it is easier to create the connection by browsing to the FileDSN, particularly for MS Excel.

In MS Access, pass-through queries accept an ODBC connection string in the property sheet. Alternatively, select the fileDSN location and Access will insert the equivalent ODBC connection string for the pass-through query. Linked tables can also be created by selecting the fileDSN location.

# General Information

## Common Dataset Guides

### Metadata
The metadata dataset contains information about the configuration of the study. 

There may be minor differences between the corresponding values for some event definition parameters in the clinicaldata dataset. The clinicaldata dataset shows the site setting whereas metadata only shows the study settings.

#### Column descriptions
- study_name: the name of the study
- study_status: the current status of the study - available = open, frozen = data locked but discrepancy note changes allowed, locked = no changes allowed
- study_date_created: date the study was created
- study_date_updated: date the study was last updated
- site_oid: unique identifier for site belonging to the study
- site_name: name of the site
- event_oid: unique identifier for the event definition belonging to the study
- event_order: order of the event within the study
- event_name: name of the event
- event_date_created: date event definition created
- event_date_updated: date event definition last updated
- event_repeating: whether the event can be completed more than once - true or 1 = yes, false or 0 = no
- crf_parent_oid: unique identifier for the form definition belonging to the event
- crf_parent_name: name of the form definition
- crf_parent_date_created: date form definition was created
- crf_parent_date_updated: date form definition was last updated
- crf_version: name of the crf version
- crf_version_oid: unique identifier for the version of the form definition
- crf_version_date_created: date the form definition version was created
- crf_version_date_updated: date the form definition version was last updated
- crf_is_required: in the named event, whether the form must be completed for the event to be completed (can be configured per site)
- crf_is_double_entry: in the named event, whether the form requires double data entry (can be configured per site)
- crf_is_hidden: in the named event, whether the form is hidden from site users (can be configured per site)
- crf_null_values: in the named event, what null codes are allowed (these are removed from the data)
- crf_section_label: name of a section of the form definition version
- crf_section_title: title of a section of the form definition version
- item_group_oid: unique identifier for the item group belonging to the form definition
- item_group_name: name of the item group
- item_form_order: order that the item appears within the form definition
- item_oid: unique identifier for the item (multi-valued fields have the value appended to the item_oid_multi_original)
- item_name: name of the item  (multi-valued fields have the value appended to the item_name_multi_original)
- item_oid_multi_original: original item oid for multi-valued items
- item_name_multi_original: original name of the item for multi-valued items
- item_units: item units displayed to users
- item_data_type: item data type (st = string, int/real = numeric, date = date, file/pdate = string)
- item_response_type: item response control type (single-select/radio = single choice drop-down/buttons, text/textarea = small/large text box, checkbox = checkbox(es), multi-select = many choice control, file = file uploader)
- item_response_set_label: name of the item choice list
- item_response_set_id: database id of the item choice list
- item_response_set_version: version of the item choice list
- item_question_number: item question number displayed to user
- item_description: item description (not shown on the form)
- item_header: bold text displayed above the item control on the form
- item_subheader: text displayed above the item control on the form
- item_left_item_text: text displayed on the left of the item control on the form
- item_right_item_text: text displayed on the right of the item control on the form
- item_regexp: regular expression used to perform soft check validation of the submitted item data
- item_regexp_error_msg: error message displayed when the submitted item data fails regexp validation
- item_required: whether the item must be completed for the form to be complete
- item_default_value: default value populated for item before form submission
- item_response_layout: horizontal or vertical layout option for radio or checkbox item controls
- item_width_decimal: optional restriction on item value width and decimal places
- item_show_item: whether the item is shown by default, items are shown if not specified (hidden items shown by scd [simple conditional display] or rules)
- item_scd_item_oid: unique identifier of scd item, whose value dictates whether the item is shown
- item_scd_item_option_value: value of scd item, that causes the item to be shown
- item_scd_item_option_text: value label of scd item, that causes the item to be shown
- item_scd_message: error message displayed when a value is submitted for an item and the scd item value is not equal to item_scd_item_option_value
