CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

SELECT execute(create_statements)
FROM (
SELECT ($$CREATE MATERIALIZED VIEW $$ 
    || case_constructors_trim_label_cols.schema_qual_object_name
    || $$ AS SELECT study_name, site_oid, site_name, subject_id, event_oid, 
            event_name, event_order, event_repeat, crf_parent_name, crf_version,
            crf_status, item_group_oid, item_group_repeat,$$
    || array_to_string(array_agg(case_constructors_trim_label_cols.case_constructors_trimmed), ',')
    || case_constructors_trim_label_cols.case_constructors_ig
    ) AS create_statements
  ,($$DROP MATERIALIZED VIEW $$ || case_constructors_trim_label_cols.schema_qual_object_name
   ) AS drop_statements
FROM (
SELECT lower(regexp_replace(regexp_replace(case_constructors.study_name,
        $$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g'))
    || $$.$$
    || case_constructors.item_group_oid
    as schema_qual_object_name ,(
        case_constructors.item_value_constructor
        || CASE 
          WHEN case_constructors.item_response_set_label IS NULL
            THEN ''
          ELSE (
              ', '
              || case_constructors.item_label_constructor
              )
          END
        ) as case_constructors_trimmed
    , ( case_constructors.study_item_group_constructor 
    || $$;$$) as case_constructors_ig
FROM (
  SELECT DISTINCT (
      $$max(case when item_oid=$$
      || quote_literal(item_oid)
      || $$ then (case when item_value = '' then null when item_value = 'NI' 
            then null else cast(item_value as $$
      || CASE 
        WHEN item_data_type IN ('ST','PDATE','FILE')
          THEN $$text$$
        WHEN item_data_type IN ('INT','REAL')
          THEN $$numeric$$
        ELSE item_data_type
        END
      || $$) end) else null end) as $$
      || item_name_hint
      ) AS item_value_constructor
    ,(
      $$max(case when item_oid = $$
      || quote_literal(item_oid)
      || $$ then (case when item_value = '' then null when item_value = 'NI' 
            then null else item_value_label end) else null end) as $$
      || item_name_hint
      || $$_label$$
      ) AS item_label_constructor
    ,(
      $$ FROM $$ 
      || lower(regexp_replace(regexp_replace(quote_literal(study_name),
        $$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g'))
      || $$.clinicaldata WHERE item_group_oid = $$
      || quote_literal(item_group_oid)
      || $$ GROUP BY study_name, site_oid, site_name, subject_id, event_oid, 
            event_name, event_order, event_repeat, crf_parent_name, crf_version,
            crf_status, item_group_oid, item_group_repeat$$
      ) AS study_item_group_constructor
    ,item_group_oid
    ,item_form_order
    ,item_response_set_label
    ,study_name
  FROM (
SELECT DISTINCT study_name
      ,item_group_oid
      ,item_oid
      ,lower(substr(item_name,1,12)
        || $$_$$
        ||  substr(
                regexp_replace(
                    regexp_replace(
                        replace(item_description,'_','') -- remove underscore
                    ,$$[\s]+$$, '_', 'g') -- change space(s) to underscore
                ,$$[^\w]$$,'','g') -- remove non alphanum non underscore
            ,1,45)
        ) as item_name_hint
      ,item_data_type
      -- use max since item_form_order may change between crf versions
      ,max(item_form_order) AS item_form_order
      ,item_response_set_label
    FROM dm.metadata
    -- where study_name='Raw Study Name'
    -- (where or and) item_group_oid='Item Group OID'
GROUP BY study_name
      ,item_group_oid
      ,item_oid
      ,item_name
      ,item_description
      ,item_data_type
      ,item_response_set_label
    ) AS met
  ) AS case_constructors
GROUP BY case_constructors.item_label_constructor
  ,case_constructors.item_response_set_label
  ,case_constructors.item_value_constructor
  ,case_constructors.study_item_group_constructor
  ,case_constructors.item_group_oid
  ,case_constructors.study_name
  ,case_constructors.item_form_order
  ORDER BY case_constructors.item_form_order
  ) AS case_constructors_trim_label_cols
GROUP BY case_constructors_trim_label_cols.schema_qual_object_name
  ,case_constructors_trim_label_cols.case_constructors_ig
  ) AS statements;

DROP FUNCTION IF EXISTS execute(text);