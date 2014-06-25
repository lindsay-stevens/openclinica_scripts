SELECT $$library("DBI") # ensure this package is installed $$ || E'\n'
    || $$library("RPostgreSQL") # ensure this package is installed $$ || E'\n'
    || $$library("rJava") # ensure this package is installed $$ || E'\n'
    || $$library("xlsxjars") # ensure this package is installed $$ || E'\n'
    || $$library("xlsx") # ensure this package is installed $$ || E'\n'
    || $$drv <- dbDriver("PostgreSQL")$$ || E'\n'
    || $$con <- dbConnect(drv,host="",port="",user="",password="",dbname="") # enter your details$$ || E'\n'
    || $$outdir <<- "directory to put the csv files" # must use forward slashes$$ || E'\n'
    || array_to_string(array_agg(item_group_dataframes.df_statements),E'\n') || E'\n'
    || $$dbDisconnect(con);$$ as rscript
FROM (
SELECT (av_viewname
    || $$ <- dbGetQuery(con, statement = "SELECT * FROM $$ 
    || schema_qual_viewname
    || $$");$$ || E'\n' 
    || $$write.xlsx2($$ 
    || av_viewname
    || $$,file=paste(outdir,"$$
    || av_viewname
    || $$.xlsx",sep="/"),sheetName="$$
    || av_viewname
    || $$",col.names=TRUE,row.names=FALSE,append=FALSE)$$
    ) AS df_statements
FROM (
WITH study_schema_name AS (
  SELECT study 
  /* enter study schema name below */
  FROM (VALUES ('mystudy')) AS study(study)
)
SELECT
  schemaname || $$.$$ || viewname as schema_qual_viewname
, substr(pg_views.viewname,4) as av_viewname
FROM pg_views, study_schema_name
WHERE schemaname=study_schema_name.study
AND viewname LIKE 'av_%'
UNION ALL SELECT 
  schemaname || $$.$$ || matviewname AS schema_qual_viewname
, schemaname || $$_$$ || matviewname
FROM pg_matviews, study_schema_name
WHERE schemaname=study_schema_name.study
/* add any other matviews wanted to this list */
AND matviewname IN ('metadata','subjects')
  ) AS case_constructors_trim_label_cols
) as item_group_dataframes