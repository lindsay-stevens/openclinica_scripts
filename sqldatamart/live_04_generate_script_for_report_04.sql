-- from: http://stackoverflow.com/questions/6777456/get-the-list-all-index-names-its-column-names-and-its-table-name-of-a-postgresq
-- must run this on the foreign server

SELECT
  'CREATE INDEX ' || indname || ' ON ' || indrelid
  || ' USING ' || indam || ' (' || array_to_string(indkey_names, ',') || ');'

FROM (

       SELECT
         i.relname                AS indname,
         i.relowner               AS indowner,
         idx.indrelid :: REGCLASS,
         am.amname                AS indam,
         idx.indkey,
         ARRAY(
             SELECT
         pg_get_indexdef(idx.indexrelid, k + 1, TRUE)
             FROM generate_subscripts(idx.indkey, 1) AS k
             ORDER BY k
         )                        AS indkey_names,
         idx.indexprs IS NOT NULL AS indexprs,
         idx.indpred IS NOT NULL  AS indpred
       FROM pg_index AS idx
         JOIN pg_class AS i
           ON i.oid = idx.indexrelid
         JOIN pg_am AS am
           ON i.relam = am.oid
         JOIN pg_namespace AS ns
           ON ns.oid = i.relnamespace
              AND ns.nspname = ANY (current_schemas(FALSE))) AS sub