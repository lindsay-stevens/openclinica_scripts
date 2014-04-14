-- runtime on 2014-04-14 with 167854 rows in 6271ms

CREATE INDEX i_item_group_metadata_itemid_crfversionid
  ON item_group_metadata
  USING btree
   (item_id, crf_version_id);

CREATE INDEX i_item_data_eventcrfid_itemid_status_live_notblank
  ON item_data
  USING btree
   (event_crf_id, item_id)
  WHERE status_id <> 5 
   AND status_id <> 7 
   AND value::text <> ''::text;

WITH parents AS (
SELECT 
  study.study_id
, study.name
FROM study
WHERE 
    study.status_id <> 5
AND study.status_id <> 7
)
,
 response_label AS (
SELECT DISTINCT ON (rs_split.version_id, rs_split.label, rs_split.option_value) 
  rs_split.version_id
, rs_split.response_set_id
, rs_split.label
, rs_split.option_value
, replace (rs_split.option_value_label, '###' , ',') option_value_label
	FROM ( 
	SELECT 
	  rs_clean.version_id
	, rs_clean.response_set_id
	, rs_clean.label 
	, trim (both FROM regexp_split_to_table(rs_clean.options_values, E',')) as option_value
	, trim (both FROM regexp_split_to_table(rs_clean.options_text_clean, E',')) as option_value_label
		FROM ( 
		SELECT 
		  response_type_id
		, version_id
		, response_set_id
		, options_values
		, response_set.label
		, replace ( options_text, E'\\,' , '###') as options_text_clean
		FROM response_set 
		) rs_clean
		where rs_clean.response_type_id IN (3,5,6,7)
	) as rs_split)

SELECT
  COALESCE (parents.name,study.name,NULL) AS study_name
, study.name AS site_name
, ss.label AS subject_id
, sed.oc_oid AS event_oid
, sed.ordinal AS event_order
, se.sample_ordinal AS event_repeat
, crfv.oc_oid AS crf_version_oid
, ig.oc_oid AS item_group_oid
, id.ordinal AS item_group_repeat
, item.oc_oid AS item_oid
, id.value AS item_value
, rs.option_value_label AS item_value_label

FROM item_data AS id

INNER JOIN event_crf AS ec
ON ec.event_crf_id=id.event_crf_id

INNER JOIN crf_version AS crfv
ON crfv.crf_version_id=ec.crf_version_id

INNER JOIN item
ON item.item_id=id.item_id

INNER JOIN item_group_metadata AS igm
ON igm.item_id=item.item_id
AND igm.crf_version_id=ec.crf_version_id

INNER JOIN item_form_metadata AS ifm
ON ifm.item_id=item.item_id
AND ifm.crf_version_id=ec.crf_version_id

INNER JOIN item_group AS ig
ON ig.item_group_id=igm.item_group_id

INNER JOIN study_event AS se
ON se.study_event_id=ec.study_event_id

INNER JOIN study_event_definition AS sed
ON sed.study_event_definition_id=se.study_event_definition_id

INNER JOIN study_subject AS ss
on ss.study_subject_id=ec.study_subject_id

INNER JOIN study
on study.study_id=ss.study_id

LEFT JOIN parents
ON parents.study_id=study.parent_study_id

LEFT JOIN response_label AS rs
ON rs.response_set_id=ifm.response_set_id
AND rs.version_id=ifm.crf_version_id
AND id.value=rs.option_value

WHERE 
    study.status_id <> 5
AND study.status_id <> 7
AND ss.status_id <> 5
AND ss.status_id <> 7
AND se.status_id <> 5
AND se.status_id <> 7
AND ec.status_id <> 5
AND ec.status_id <> 7
AND id.status_id <> 5
AND id.status_id <> 7
AND id.value <> '';