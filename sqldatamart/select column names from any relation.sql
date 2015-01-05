SELECT
  pg_namespace.nspname,
  pg_class.relname,
  pg_attribute.attnum,
  pg_attribute.attname
FROM pg_attribute
  LEFT JOIN pg_class
    ON pg_class.oid = pg_attribute.attrelid
  LEFT JOIN pg_namespace
    ON pg_class.relnamespace = pg_namespace.oid
WHERE pg_namespace.nspname = 'myschemaname'
      --AND    pg_class.relname LIKE 'criteria for relation names'
      AND pg_attribute.attnum > 0
      AND NOT pg_attribute.attisdropped
ORDER BY
  pg_namespace.nspname
  , pg_class.relname
  , pg_attribute.attnum