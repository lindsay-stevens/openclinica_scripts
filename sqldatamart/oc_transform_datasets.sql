CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

SELECT execute($$CREATE VIEW $$ 
    || case_constructors_trim_label_cols.schema_qual_object_name
    || $$ AS SELECT subject_id, event_oid, event_order, event_repeat, 
        crf_version_oid, item_group_oid, item_group_repeat,$$
    || array_to_string(array_agg(case_constructors_trim_label_cols.case_constructors_trimmed), ',')
    || case_constructors_trim_label_cols.case_constructors_ig)
    /* Quote out the above and do the following instead if you want to remove 
    execute($$DROP VIEW $$ || case_constructors_trim_label_cols.schema_qual_object_name)
    */
FROM (
SELECT lower(regexp_replace(regexp_replace(quote_literal(case_constructors.study_name),
        $$[^\w\s]$$, '', 'g'),$$[\s]$$, '_', 'g'))
    || $$.view_$$
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
      || lower(item_oid)
      ) AS item_value_constructor
    ,(
      $$max(case when item_oid = $$
      || quote_literal(item_oid)
      || $$ then (case when item_value = '' then null when item_value = 'NI' 
            then null else item_value_label end) else null end) as $$
      || lower(item_oid)
      || $$_label$$
      ) AS item_label_constructor
    ,(
      $$ FROM dm.clinicaldata WHERE study_name=$$
      || quote_literal(study_name)
      || $$ AND item_group_oid = $$
      || quote_literal(item_group_oid)
      || $$ GROUP BY subject_id, event_oid, event_order, event_repeat, 
            crf_version_oid, item_group_oid, item_group_repeat$$
      ) AS study_item_group_constructor
    ,item_group_oid
    ,item_form_order
    ,item_response_set_label
    ,study_name
  FROM (
SELECT DISTINCT study_name
      ,item_group_oid
      ,item_oid
      ,item_data_type
      -- use max since item_form_order may change between crf versions
      ,max(item_form_order) AS item_form_order
      ,item_response_set_label
    FROM dm.metadata
GROUP BY study_name
      ,item_group_oid
      ,item_oid
      ,item_data_type
      ,item_response_set_label
    ) AS met
  ORDER BY item_group_oid
    ,item_form_order
  ) AS case_constructors
GROUP BY case_constructors.item_label_constructor
  ,case_constructors.item_response_set_label
  ,case_constructors.item_value_constructor
  ,case_constructors.study_item_group_constructor
  ,case_constructors.item_group_oid
  ,case_constructors.study_name
  ) AS case_constructors_trim_label_cols
GROUP BY case_constructors_trim_label_cols.schema_qual_object_name
  ,case_constructors_trim_label_cols.case_constructors_ig;

DROP FUNCTION IF EXISTS execute(text);