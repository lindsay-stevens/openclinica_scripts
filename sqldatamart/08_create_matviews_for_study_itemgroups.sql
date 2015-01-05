CREATE OR REPLACE FUNCTION execute(TEXT)
  RETURNS VOID AS $BODY$ BEGIN EXECUTE $1;
END;$BODY$ LANGUAGE plpgsql;

/* Prepare Item Metadata for building itemgroup matview DDL
* item name hint trimmed to 57 characters to allow for appending '_label'
* most recent definitions used (labels, names, etc)
* if longest item name in study is over 8 characters, use item_oid for colnames
* if study has an item name starting with an integer, use item_oid for colnames
* item_name_hint otherwise removes underscore, changes space to underscore,
    removes non alpahnumeric and non underscore
* in the 'filter_' CTEs, replace null with the desired filter string
*/
WITH
    filter_study_name AS (SELECT
                            ''::text AS fsn), filter_item_group AS (SELECT
                                                           ''::text AS fig), met AS (
    SELECT
      study_name
      , item_group_oid
      , item_oid
      , CASE WHEN length(item_name_hint) >=
                  57 THEN substr(item_name_hint, 1, 57)
        ELSE item_name_hint END      AS item_name_hint
      , item_data_type
      , max(item_form_order)         AS item_form_order
      , max(item_response_set_label) AS item_response_set_label
      , crf_null_values
    FROM (
           SELECT
             study_name
             , item_group_oid
             , item_oid
             , (CASE WHEN (
                            SELECT
                              max(length(item_name))
                            FROM dm.metadata
                            WHERE dm_meta.study_name = metadata.study_name
                            LIMIT 1) > 12
           THEN item_oid
                WHEN (
                       SELECT
                         max(length(item_name))
                       FROM dm.metadata
                       WHERE dm_meta.study_name = metadata.study_name AND
                             item_name ~ '^[0-9].+$'
                       LIMIT 1) > 0
                THEN item_oid
                ELSE
                  concat(
                      lower(substr(item_name, 1, 12)),
                      $$_$$,
                      substr(
                          regexp_replace(
                              regexp_replace(
                                  REPLACE(item_description, '_', ''),
                                  $$[\s]+$$,
                                  '_',
                                  'g')
                              ,
                              $$[^\w]$$,
                              '',
                              'g'),
                          1,
                          45))
                END)                 AS item_name_hint
             , item_data_type
             , max(item_form_order)  AS item_form_order
             , item_response_set_label
             , COALESCE(CASE
                        WHEN count(crf_null_values) > 0
                        THEN quote_literal(trim(BOTH ',' FROM (array_to_string(
                            (
                              SELECT
                                array_agg(
                                    s1.crf_null_values)
                              FROM
                                (
                                  SELECT
                                    DISTINCT
                                    crf_null_values
                                  FROM
                                    dm.metadata AS dms
                                  WHERE
                                    dms.item_group_oid
                                    =
                                    dm_meta.item_group_oid
                                    AND
                                    crf_null_values
                                    !=
                                    '') AS s1),
                            ','))))
                        END, $$''$$) AS crf_null_values
           FROM dm.metadata AS dm_meta, filter_study_name, filter_item_group
          WHERE dm_meta.study_name ~ (CASE WHEN length(filter_study_name.fsn) > 0 THEN 
                                                              fsn ELSE '.+' END) AND
                                                              dm_meta.item_group_oid ~ (CASE WHEN length(filter_item_group.fig) > 0 THEN 
                                                              fig ELSE '.+' END)
           GROUP BY study_name, item_group_oid, item_oid, item_name,
             item_description, item_data_type,
             item_response_set_label) AS namecheck
    GROUP BY study_name, item_group_oid, item_oid, item_name_hint,
      item_data_type, crf_null_values)
SELECT
  execute(statements.create_statements)
FROM (
       SELECT
           concat(
               $$CREATE MATERIALIZED VIEW $$,
               ddl_trim_label_cols.schema_qual_object_name,
               $$ AS SELECT study_name, site_oid, site_name, subject_id, $$,
               $$event_oid, event_name, event_order, event_repeat, $$,
               $$crf_parent_name, crf_version, crf_status, item_group_oid, $$,
               $$item_group_repeat,$$,
               array_to_string(
                   array_agg(ddl_trim_label_cols.ddl_trimmed),
                   ','),
               ddl_trim_label_cols.ddl_ig)                  AS create_statements
         , concat(
               $$DROP MATERIALIZED VIEW $$,
               ddl_trim_label_cols.schema_qual_object_name) AS drop_statements
       FROM (
              SELECT
                  concat(
                      lower(
                          regexp_replace(
                              regexp_replace(
                                  ddl.study_name,
                                  $$[^\w\s]$$,
                                  '',
                                  'g'),
                              $$[\s]$$,
                              '_',
                              'g')),
                      $$.$$,
                      ddl.item_group_oid)         AS schema_qual_object_name
                , concat(ddl.item_value_ddl, CASE
                                             WHEN
                                               ddl.item_response_set_label
                                               IS NULL
                                             THEN ''
                                             ELSE (concat(
                                                 ', ',
                                                 ddl.item_label_ddl))
                                             END) AS ddl_trimmed
                , concat(ddl.ig_ddl, $$;$$)       AS ddl_ig
              FROM (
                     SELECT
                       DISTINCT
                         concat(
                             $$max(case when item_oid=$$,
                             quote_literal(item_oid),
                             $$ then (case when item_value = '' then null when item_value IN ($$,
                             crf_null_values,
                             $$) then null else cast(item_value as $$,
                             CASE
                             WHEN
                               item_data_type
                               IN
                               ('ST', 'PDATE', 'FILE')
                             THEN $$text$$
                             WHEN
                               item_data_type
                               IN
                               ('INT', 'REAL')
                             THEN $$numeric$$
                             ELSE item_data_type
                             END,
                             $$) end) else null end) as $$,
                             item_name_hint)                                     AS item_value_ddl
                       , concat(
                             $$max(case when item_oid = $$,
                             quote_literal(item_oid),
                             $$ then (case when item_value = ''$$,
                             $$ then null when item_value IN ($$,
                             crf_null_values,
                             $$) then null else item_value_label end) $$,
                             $$else null end) as $$,
                             item_name_hint,
                             $$_label$$)                                         AS item_label_ddl
                       , concat(
                             $$ FROM $$,
                             lower(
                                 regexp_replace(
                                     regexp_replace(
                                         quote_literal(study_name),
                                         $$[^\w\s]$$,
                                         '',
                                         'g'),
                                     $$[\s]$$,
                                     '_',
                                     'g')),
                             $$.clinicaldata WHERE item_group_oid = $$,
                             quote_literal(item_group_oid),
                             $$ GROUP BY study_name, site_oid, site_name, $$,
                             $$subject_id, event_oid, $$,
                             $$ event_name, event_order, event_repeat, $$,
                             $$crf_parent_name, crf_version, $$,
                             $$ crf_status, item_group_oid, item_group_repeat$$) AS ig_ddl
                       , item_group_oid
                       , item_form_order
                       , item_response_set_label
                       , study_name
                     FROM met) AS ddl
              GROUP BY ddl.item_label_ddl, ddl.item_response_set_label,
                ddl.item_value_ddl, ddl.ig_ddl, ddl.item_group_oid,
                ddl.study_name, ddl.item_form_order
              ORDER BY
                ddl.item_form_order) AS ddl_trim_label_cols
       GROUP BY ddl_trim_label_cols.schema_qual_object_name,
         ddl_trim_label_cols.ddl_ig) AS statements;

DROP FUNCTION IF EXISTS execute( TEXT );