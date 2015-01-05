CREATE OR REPLACE FUNCTION execute(TEXT)
  RETURNS VOID AS
  $BODY$BEGIN EXECUTE $1;
  END;$BODY$ LANGUAGE plpgsql;

SELECT
  execute(create_statements)
FROM (
       SELECT
         $$create materialized view public.$$
         --the substring part is to trim off the expected 'ft_' fdw table prefix
         || substring(foreign_table_name, 4) || $$ as (select * from  $$
         || foreign_table_name || $$);$$ AS create_statements
       FROM information_schema.foreign_tables
     ) AS statements;

DROP FUNCTION IF EXISTS execute( TEXT );