OpenClinica Community Data Mart
===============================

Dependencies
------------

1.  Windows OS (tested with Server 2008 R2, 64-bit, and Windows 7)
2.  Postgres (tested with 9.2.2, 64-bit)
3.  Postgres ODBC drivers (tested with 9.02.0100, both 32-bit and 64-bit installed)
4.  7-zip
5.  Access Runtime (tested with 2010, 32-bit) or MS Office

Package
-------

1.  oc\_warehousing sql script (generates datasets for all studies)
2.  oc\_access\_processor database (in order to edit it, you need a copy of MS Office)
3.  Batch script which restores a daily production backup into the target server, then executes the sql script and Access database.

Features
--------

### Description

The aims of this project include:

-   Availability of all data in the OpenClinica database in SQL without needing to go through the ODM XML extract as an intermediate data source, or being limited by what it includes.
-   Availability of all related code for customisation and bug fixing. The code that generates ODM XML is open source but the code for OpenClinica Enterprise Data Mart is not.

The provided SQL script and Access database process the data in an OpenClinica database into a set of study metadata tables, as well as a table per item group with the data pivoted such that variables are in their own column.

### Output

1.  A schema is created for each study.
2.  A role is created for each schema; the role has access to only that schema. These roles are intended to limit the scope of database connections in order to avoid mistakes, rather than as a security measure.
3.  A table is created for each item group.
4.  In each item group table, a column is created for each item in the item group. An accompanying column is created for the item if it uses response options. If the item uses multi-choice, this pair of columns is created for each response where there is value.
5.  Additional tables are created with the following data:
    1.  clinicaldata: a denormalised dataset which is transformed into item group data
    2.  metadata: a denormalised dataset which is used for the item group table definitions
    3.  subjects: distinct subjects (source: a)
    4.  subject\_event\_crf\_status: distinct subject/event/crf info (a)
    5.  subject\_event\_crf\_expected: subjects (a) and event crfs (b) cross joined
    6.  subject\_event\_crf\_join: expected (e) and status (d) left joined
    7.  discrepancy\_notes\_parent: parent DNs on all entity types, age if not closed or n/a
    8.  discrepancy\_notes\_all: all DNs on all entity types
    9.  subject\_groups: subject group assignments
    10. response\_set\_labels: code value / label pairs

### Changes since 2013-06-18

#### Warehousing Script

Completed:

-   fixed duplicates issue caused by \>1 SDV status change (now takes most recent)
-   added crf\_section\_label and renamed crf\_section to crf\_section\_title
-   replaced event\_status logic to show just subject\_event\_status.name
-   replaced crf\_status logic based on dates with logic from openclinica interface
-   add analyze after each table, this speeds up creation of dm.clinicaldata
-   add index to user\_account.user\_id
-   add filters to clinicaldata so that no removed entities are included (subjects, crfs, etc)
-   split cd\_no\_labels into two steps so that the site event definitions are retrieved correctly
-   added handling for multi-valued fields - these get flattened with response value like item\_oid\_44
-   added owner\_id and update\_id for subject, study event, event crf and item with user account name
-   added extra tables with information beyond that in metadata and clinicaldata

To do:

-   Null value handling: At the moment null codes in non-text are dropped when the data is transformed because it is the wrong type (OC Data Mart doesn't handle null codes either).

Installation Part 1
-------------------

1.  Install the Access Runtime on the server (if MS Office not installed already)
2.  Edit postgres configuration (both postgresql.conf and pg\_hba.conf) to allow remote connections, e.g. allow local, all, or allow connections from IPs on your network, etc.
3.  Configure oc\_access\_processor
    1.  Enter details of your postgres database.
    2.  If you want to add to the standard columns in each item group dataset, modify the array in mod\_populate\_rowheaders. Make sure the dimensions in the public rowheaders variable are the same as the number of elements (default 13x2).
4.  Install psqlodbc driver on the server
5.  Create postgres account for the access_processor database. If using a name other than access_processor for the account, change the ownership statements at the end of the warehousing script to refer to the account name.
6.  Use Access to package oc\_access\_processor into an installable runtime file, and install it on the server, or just copy it to the server.
    1.  If using the runtime version of Access, a registry entry is needed to permanently trust the location where the database is running from (with the full version it is possible to save this preference). Without it, a privacy warning will be shown every time the database is opened, halting the process until the warning is manually acknowledged. Required registry key settings are:
        1.  Root - "Current User"
        2.  Key - "Software\\Microsoft\\Office\\14.0\\Access\\Security\\Trusted Locations\\2013-09-20 oc access processor"
            1.  Change the last part according to the application name
        3.  Name - "Path"
        4.  Value - "[DATABASEDIR]"
        5.  Example registry file is included

7.  Modify batch file to suit your file locations. It needs to restore the daily backup (preferably on a different server), run the warehousing script and open the Access database and run the ‘run\_get\_study\_list’ macro. During Step 2 (above) in pg\_hba.conf, either trust local, or use a pgpass file, or temporarily set the pgpassword environment variable (see line 20). This is needed to allow the psql statements to execute without a prompt for a password.
8.  Add scheduled task to run the batch script after the daily backup is run, e.g. 30 mins after.

A log is kept in oc\_access\_processor with the start, stop time for each study processed. It is created automatically the first time. Once the log has 150 or more entries, the oldest 25% are deleted.

Installation Part 2
-------------------

Once set up, the study data will be refreshed every day and ready for use in other programs.

In order to get other Access databases to connect to postgres and get a copy of the study data, do the following:

1.  Ensure that the postgres ODBC drivers are installed on each client machine.
2.  Import the following objects into the Access database(s):
    1.  mod\_make\_locallinked\_table\_list module
    2.  mod\_make\_locallinked\_table module
    3.  mod\_process\_text module
    4.  mod\_object\_exists module
    5.  mod\_open\_pg\_odbc\_conn module
    6.  control\_panel form (remove all the action buttons after import, or alternatively just import the import\_link\_tables macro to call make\_locallinked\_table\_list and give it the study name in double quotes).
    7.  oc\_table\_selection form (this should be hidden)
    8.  odbc\_connection table (this should be hidden)

The ‘import / link tables’ action opens a form that allows a user to select a list of tables from their study schema, and either create corresponding linked tables, or create local table copies of the remote tables. The table list is saved as a query definition (called oc\_tables\_to\_copy). Both actions delete the existing definition with the same name so keep this in mind for any defined relationships.

Known Issues
------------

### Naming Conventions

Naming limitations beyond those imposed by OpenClinica are as follows. The function ‘process\_text’ truncates strings to 45 characters, after removing any non-alphanumeric characters and replacing spaces with underscores.

1.  Study name is run through process\_text, so each study name needs to be unique in the first 45 characters. OpenClinica allows 255 characters. The processed name is used for the role name and password created for each study.
2.  Item name is converted to lowercase, and truncated to 12 characters. OpenClinica allows 255 characters.
    1.  It is assumed that item names are created with maximum 8 alphanumeric characters (underscores allowed) for CDISC / SAS compatibility. Not enforced, it has not been tested what happens when longer item names are used.
    2.  The additional 4 characters are an allowance for multi-value fields. Their item names are modified to add the coded value after an underscore. E.g. item name ‘MYMULTI’ has a coded response 99 which means ‘something’; the item name becomes ‘mymulti\_99’. Longer multi-value codes would need to be unique within the first 3 characters (this has not been tested).

3.  Item description is run through process\_text. OpenClinica allows 4000 characters.
4.  Item variable column names in the item group tables are composed of the processed item name and item description joined together. E.g. item name ‘MYITEM’ description ‘My first OpenClinica item which collects my favourite variable’ will get a column name of ‘myitem\_my\_first\_openclinica\_item\_which\_collects\_my\_f’, which highlights the virtue of short, meaningful item descriptions.

### Null Value Codes

Processing of null value codes has not been added at this stage. If they are used, and the item is not a string, Access will throw a type mismatch error and not insert the value (e.g. failed to insert ‘NI’ into an integer field). At present the transform\_insert\_ig\_data function resumes if a type mismatch errors occurs in the position where they are expected.

A way to look up null codes would be to filter the clinicaldata table for CRFs where null codes are allowed, and filter the item value column for values containing any of those null codes.

To avoid this issue, add an item or response list option to capture why a value is missing instead of using the Null Value code feature, or add an explanation in an annotation discrepancy note.

### Item Group Size

Access cannot process tables or queries with more than 255 columns. Whether or not this is a problem depends on the number of items, how many of them are single-select and how many of them are multi-select.
For example:

-   This is OK: 13 rowheaders + 100 single-select items + 100 code label columns = 213 columns.
-   This is OK: 13 rowheaders + 15 multi-value items with 6 response options each (results in up to 90 columns, depending on responses) + (up to) 90 code label columns = 193 columns.
-   This is OK: 13 rowheaders + 10 date fields + 10 single-select items + 10 integer fields + 10 float fields + 5 multi-value items with 10 response options each (results in up to 50 columns, depending on responses) + (up to) 60 code label columns = 163 columns.

This issue was encountered during development; the easiest solution was to add update queries which serialised the item group items according to their item form order. These update queries have been commented out but
are present and would be required in functions make\_local\_clinicaldata, make\_local\_metadata, make\_local\_item\_metadata.

Future Improvements
-------------------

Some ideas for further improvements include:

### Text Export

Write the data out to an SQL file or a set of CSVs for import to other RDBMS or programs. It is possible to write text files from Access using the Microsoft Scripting Runtime library, the main advantage being that both the DDL and DML statements could be included, like in the Enterprise Data Mart downloadable file. It may be simpler to use Postgres’ COPY function for CSV. Alternatively an ODBC connection could be set up.

### Rewrite for Linux Compatibility

Re-write VBA code in a less reprehensible language that can be run on linux, like java or python.

The main hurdle is reproducing the Access crosstab/pivot function, which could be done at once with an enormous CASE…WHEN-style pivot. This can’t be done from Access because it can’t send SQL statements over 64000 characters long. Postgres has a much larger statement size limit.

Another approach could be to insert the distinct rowheader data, and then add each column using a series of UPDATE statements – which would also avoid / relax the column limit issue, as the limit for Postgres is somewhere between 250 and 1600, depending on the data.

### Add Null Value Code Handling

While I avoid null value codes, some users probably value the feature and would like the null type information to be as usable as the rest of the data. A possible implementation could be to add a column for the null code string for any column where it is present; however this could worsen the issue of Access’ 255 column-per-table limit.
