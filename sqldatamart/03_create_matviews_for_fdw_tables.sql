CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

SELECT execute(create_statements)
FROM (
select
  $$create materialized view public.$$ 
--the substring part is to trim off the expected 'ft_' fdw table prefix
  || substring(foreign_table_name,4) || $$ as (select * from  $$ 
  || foreign_table_name || $$);$$ as create_statements
from information_schema.foreign_tables
) AS statements;

DROP FUNCTION IF EXISTS execute(text);