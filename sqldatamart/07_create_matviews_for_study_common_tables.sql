CREATE OR REPLACE FUNCTION execute(TEXT)
  RETURNS VOID AS
  $BODY$BEGIN EXECUTE $1;
  END;$BODY$ LANGUAGE plpgsql;

WITH table_list AS (
    SELECT
      table_list.table_name
    FROM (VALUES
      ('clinicaldata')
      , ('discrepancy_notes_all')
      , ('discrepancy_notes_parent')
      , ('metadata')
      , ('response_set_labels')
      , ('subject_event_crf_expected')
      , ('subject_event_crf_join')
      , ('subject_event_crf_status')
      , ('subject_groups')
      , ('subjects')
      , ('user_account_roles')
         ) AS table_list (table_name)
)
SELECT
  execute(create_statements)
FROM (
       SELECT
         concat(
             $$create materialized view $$ || study_name || $$.$$ ||
             table_list.table_name ||
             $$ as (select * from dm.$$ || table_list.table_name ||
             $$ where study_name=$$ || quote_literal(study_name_raw) || $$);$$
             , CASE WHEN table_list.table_name = 'clinicaldata' THEN
               E'\n' || $$ create index i_$$ || study_name ||
               $$_clinicaldata_item_group_oid on $$ || study_name ||
               $$.clinicaldata USING btree (item_group_oid);$$ END) AS create_statements
       FROM (
              SELECT DISTINCT ON (study_name)
                lower(regexp_replace(
                          regexp_replace(study_name, $$[^\w\s]$$, '', 'g'),
                          $$[\s]$$, '_', 'g')) AS study_name,
                study_name                     AS study_name_raw
              FROM dm.metadata
-- where study_name='Raw Study Name'
            ) AS sub, table_list
       ORDER BY study_name
     ) AS statements;

DROP FUNCTION IF EXISTS execute( TEXT );