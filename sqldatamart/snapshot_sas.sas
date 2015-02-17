/* 
    Makes a snapshot of all study data, exported as SAS sas7bdat files.
    Comment out the %INCLUDE command if you want the snapshot script for 
    the nominated study but don't want to run it yet.
    
    Set the following 4 variables. 
    Use forward slashes in paths. If the paths contain 2 or more consecutive spaces,
    comment out the %INCLUDE and manually re-add the spaces to the paths before
    running. SAS compresses these spaces out, even with COMPRESS=NO.
    1. filter_study_name_schema= name of study schema to snapshot.
        e.g. "MY STUDY" would have a schema named: my_study
    2. snapshotdir: file path to put snapshot files in
    3. odbc_string_or_file_dsn_path= the filedsn=path or odbc=string to connect with
    4. data_filter_string: Optional. SQL appended to each SELECT command. 
        Applied to itemgroup tables only. Some examples:
      - Get data only for subjects enrolled before date 2014-01-01:
        LEFT JOIN study_schema_name.subjects AS subj USING (subject_id) WHERE subj.subject_enrol_date < $$2014-01-01$$::date
      - Get data only if it was entered into events named SCR, BL, W4, W8:
        WHERE event_name IN ($$SCR$$,$$BL$$,$$W4$$,$$W8$$)
       SAS can send filters with single or dollar quoting for strings.
*/;
/* variables to set start */;
%LET filter_study_name_schema=;
%LET snapshotdir=;
%LET odbc_string_or_file_dsn_path=;
%LET data_filter_string=;
/* variables to set end */;
LIBNAME snapshot "&snapshotdir"; RUN;
PROC SQL; connect to odbc as pgodbc (NOPROMPT="&odbc_string_or_file_dsn_path");
create table work.snapshot_code as select * from connection to pgodbc
    (SELECT public.dm_snapshot_code_sas(
        $p$&filter_study_name_schema$p$::text,
        $p$&snapshotdir$p$::text,
        $p$&odbc_string_or_file_dsn_path$p$::text,
        $p$&data_filter_string$p$::text
        )
    );
QUIT;
DATA _null_;
SET WORK.SNAPSHOT_CODE;
FILE "&snapshotdir/snapshot_sas_code.sas";
PUT dm_snapshot_code_sas;
RUN;
%INCLUDE "&snapshotdir/snapshot_sas_code.sas";
QUIT;
PROC DATASETS LIBRARY=work;
   DELETE snapshot_code;
RUN;
