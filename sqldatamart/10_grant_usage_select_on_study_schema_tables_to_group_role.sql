CREATE OR REPLACE FUNCTION execute(TEXT)
  RETURNS VOID AS
  $BODY$BEGIN EXECUTE $1;
  END;$BODY$ LANGUAGE plpgsql;

SELECT
  execute(create_statements)
FROM (
       SELECT
         'grant usage on schema ' || sub.study_name || ' to ' || sub.study_name
         || '_select;' || E'\n' ||
         'grant select on all tables in schema ' || sub.study_name || ' to ' ||
         sub.study_name || '_select;' AS create_statements
       FROM (
              SELECT DISTINCT ON (study_name)
                lower(regexp_replace(
                          regexp_replace(study_name, $$[^\w\s]$$, '', 'g'),
                          $$[\s]$$, '_', 'g')) AS study_name
              FROM dm.metadata
-- where study_name='Raw Study Name'
            ) AS sub
     ) AS statements;

DROP FUNCTION IF EXISTS execute( TEXT );