SELECT
  $$library("DBI") # ensure this package is installed $$ || E'\n'
  || $$library("RPostgreSQL") # ensure this package is installed $$ || E'\n'
  || $$library("rJava") # ensure this package is installed $$ || E'\n'
  || $$library("xlsxjars") # ensure this package is installed $$ || E'\n'
  || $$library("xlsx") # ensure this package is installed $$ || E'\n'
  || $$drv <- dbDriver("PostgreSQL")$$ || E'\n'
  ||
  $$con <- dbConnect(drv,host="",port="",user="",password="",dbname="") # enter your details$$
  || E'\n'
  || $$outdir <<- "directory to put the xlsx files" # must use forward slashes$$
  || E'\n'
  || array_to_string(array_agg(item_group_dataframes.df_statements), E'\n') ||
  E'\n'
  || $$dbDisconnect(con);$$ AS rscript
FROM (
       SELECT
         (av_viewname
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
                  SELECT
                    lower(regexp_replace(
                              regexp_replace(quote_literal(study), $$[^\w\s]$$,
                                             '', 'g'), $$[\s]$$, '_',
                              'g')) AS study
                  /* enter 'Raw Study Name' below */
                  FROM (VALUES ('MY STUDY')) AS study(study)
              )
              SELECT
                schemaname || $$.$$ || viewname AS schema_qual_viewname,
                substr(pg_views.viewname, 4)    AS av_viewname
              FROM pg_views, study_schema_name
              WHERE schemaname = study_schema_name.study
                    AND viewname LIKE 'av_%'
              UNION ALL SELECT
                          schemaname || $$.$$ ||
                          matviewname AS schema_qual_viewname,
                          schemaname || $$_$$ || matviewname
                        FROM pg_matviews, study_schema_name
                        WHERE schemaname = study_schema_name.study
                              /* add any other non-item group matviews wanted to this list */
                              AND matviewname IN ('metadata', 'subjects')
            ) AS case_constructors_trim_label_cols
     ) AS item_group_dataframes