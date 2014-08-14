CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

with table_list as (
 select table_list.table_name 
 from (values 
   ('clinicaldata')
  ,('discrepancy_notes_all')
  ,('discrepancy_notes_parent')
  ,('metadata')
  ,('response_set_labels')
  ,('subject_event_crf_expected')
  ,('subject_event_crf_join')
  ,('subject_event_crf_status')  
  ,('subject_groups')
  ,('subjects')
  ,('user_account_roles')
  ) as table_list (table_name)
)
SELECT execute(create_statements)
FROM (
select
concat(
$$create materialized view $$ || study_name || $$.$$ || table_list.table_name || 
$$ as (select * from dm.$$ || table_list.table_name || 
$$ where study_name=$$ || quote_literal(study_name_raw) || $$);$$
,CASE WHEN table_list.table_name='clinicaldata' THEN E'\n' || $$ create index i_$$ || study_name ||
$$_clinicaldata_item_group_oid on $$ || study_name || $$.clinicaldata USING btree (item_group_oid);$$ END) as create_statements
from (
select distinct on (study_name) 
lower(regexp_replace(regexp_replace(study_name,$$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g')) as study_name
, study_name as study_name_raw
from dm.metadata
-- where study_name='Raw Study Name'
) as sub, table_list
order by study_name
) AS statements;

DROP FUNCTION IF EXISTS execute(text);