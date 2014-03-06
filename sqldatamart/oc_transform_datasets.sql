CREATE OR REPLACE FUNCTION execute(text) returns void as $BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;
SELECT execute(CONCAT (
    'CREATE VIEW '
    ,regexp_replace(regexp_replace(s.study_name,'[^\w\s]', '', 'g'),'[\s]', '_', 'g')
    ,'.view_'
    ,s.item_group_oid 
    ,' AS SELECT subject_id, event_oid, event_order, event_repeat, crf_version_oid, item_group_oid, item_group_repeat,'
    ,string_agg(CONCAT (
        s.item_value_constructor
        ,CASE 
          WHEN s.item_response_set_label IS NULL
            THEN NULL
          ELSE CONCAT (
              ', '
              ,s.item_label_constructor
              )
          END
        ), ', ')
    ,s.study_item_group_constructor
    ))
/* delete the views created above
CONCAT (
    'DELETE VIEW '
    ,regexp_replace(regexp_replace(s.study_name,'[^\w\s]', '', 'g'),'[\s]', '_', 'g')
    ,'.view_'
    ,s.item_group_oid 
*/
FROM (
  SELECT DISTINCT CONCAT (
      'max(case when item_oid = '''
      ,item_oid
      ,''' then (case when item_value = '''' then null when item_value = ''NI'' then null else cast(item_value as '
      ,CASE 
        WHEN item_data_type IN ('ST','PDATE','FILE')
          THEN 'text'
	WHEN item_data_type IN ('INT','REAL')
	  THEN 'numeric'
        ELSE item_data_type
        END
      ,') end) else null end) as '
      ,lower(item_oid)
      ) AS item_value_constructor
    ,CONCAT (
      'max(case when item_oid = '''
      ,item_oid
      ,''' then (case when item_value = '''' then null else item_value_label end) else null end) as '
      ,lower(item_oid)
      ,'_label'
      ) AS item_label_constructor
    ,CONCAT (
      ' FROM dm.clinicaldata WHERE study_name = '''
      ,study_name
      ,''' AND item_group_oid = '''
      ,item_group_oid
      ,''' GROUP BY subject_id, event_oid, event_order, event_repeat, crf_version_oid, item_group_oid, item_group_repeat ORDER BY subject_id, event_order'
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
      ,max(item_form_order) as item_form_order
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
  ) AS s
GROUP BY s.study_item_group_constructor
  ,s.item_group_oid
  ,s.study_name;

DROP FUNCTION IF EXISTS execute(text);