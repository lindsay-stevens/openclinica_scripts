CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

SELECT execute(create_statements)
FROM (
select 
'create schema ' || sub.study_name || ';' as create_statements
from (
select distinct on (study_name)  
lower(regexp_replace(regexp_replace(study_name,$$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g')) as study_name
from dm.metadata
-- where study_name='Raw Study Name'
) as sub
) AS statements;

DROP FUNCTION IF EXISTS execute(text);