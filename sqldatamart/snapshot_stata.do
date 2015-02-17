/* 
    Makes a snapshot of all study data, exported as Stata dta files.
    Comment out the do command if you want the snapshot script for 
    the nominated study but don't want to run it yet.
    
    Set the following 4 variables. Use forward slashes in paths.
    1. filter_study_name_schema= name of study schema to snapshot.
        e.g. "MY STUDY" would have a schema named: my_study
    2. snapshotdir: file path to put snapshot files in
    3. odbc_string_or_file_dsn_path= the filedsn=path or odbc=string to connect with
    4. data_filter_string: Optional. SQL appended to each SELECT command. 
       Applied to itemgroup tables only. Some examples:
      - Get data only for subjects enrolled before date 2014-01-01:
        LEFT JOIN study_schema_name.subjects AS subj USING (subject_id) WHERE subj.subject_enrol_date < '2014-01-01'::date
      - Get data only if it was entered into events named SCR, BL, W4, W8:
        WHERE event_name IN ('SCR','BL','W4','W8')
       Use single quoting instead of dollar quoting for strings. Dollar quoting 
        is possible but for each dollar sign, Stata requires the SMCL token: {c S|}
*/
/* variables to set start */
local filter_study_name_schema= "cease"
local snapshotdir = "C:/Users/Lstevens/Desktop/testout"
local odbc_string_or_file_dsn_path = "filedsn=//SVR-NAS/Public/VHCRP/General/OpenClinica/11_Reporting/sqldatamart/vhcrp_deployment/clients/ocdm-x64.dsn"
local data_filter_string = ""
/* variables to set end */
local exec1 = "SELECT public.dm_snapshot_code_stata('`filter_study_name_schema''::text"
local exec2 = ",'`snapshotdir''::text"
local exec3 = ",'`odbc_string_or_file_dsn_path''::text"
local exec4 = ",'`data_filter_string''::text)"
odbc load, exec("`exec1'`exec2'`exec3'`exec4'") connectionstring("`odbc_string_or_file_dsn_path'")
outsheet dm_snapshot_code_stata using "`snapshotdir'/snapshot_stata_code.do", nonames noquote replace
clear
do "`snapshotdir'/snapshot_stata_code.do"
