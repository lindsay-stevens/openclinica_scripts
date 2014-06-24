-- from: http://stackoverflow.com/questions/6777456/get-the-list-all-index-names-its-column-names-and-its-table-name-of-a-postgresq
-- must run this on the foreign server

SELECT 
'CREATE INDEX ' || indname || ' ON ' || indrelid 
|| ' USING ' || indam || ' (' || array_to_string(indkey_names, ',') || ');'

FROM (

SELECT i.relname as indname,
       i.relowner as indowner,
       idx.indrelid::regclass,
       am.amname as indam,
       idx.indkey,
       ARRAY(
       SELECT pg_get_indexdef(idx.indexrelid, k + 1, true)
       FROM generate_subscripts(idx.indkey, 1) as k
       ORDER BY k
       ) as indkey_names,
       idx.indexprs IS NOT NULL as indexprs,
       idx.indpred IS NOT NULL as indpred
FROM   pg_index as idx
JOIN   pg_class as i
ON     i.oid = idx.indexrelid
JOIN   pg_am as am
ON     i.relam = am.oid
JOIN   pg_namespace as ns
ON     ns.oid = i.relnamespace
AND    ns.nspname = ANY(current_schemas(false)) ) as sub