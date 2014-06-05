CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

SELECT execute(create_statements)
FROM (
select 
'grant usage on schema ' || sub.study_name || ' to ' || sub.study_name || '_select;' || E'\n' ||
'grant select on all tables in schema ' || sub.study_name || ' to ' || sub.study_name || '_select;' as create_statements
from (
select distinct on (study_name)  
lower(regexp_replace(regexp_replace(study_name,$$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g')) as study_name
from dm.metadata
-- where study_name='Raw Study Name'
) as sub
) AS statements;

DROP FUNCTION IF EXISTS execute(text);