-- runtime on 2014-03-13 with 299423 rows in 1530ms
-- runtime on 2014-04-14 with 167854 rows in 1295ms

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

SELECT
  COALESCE (parents.study_id,study.study_id,NULL) AS parent_study_id
, ss.study_id
, ss.study_subject_id
, se.study_event_id
, ec.event_crf_id
, igm.item_group_id
, id.item_data_id 

FROM item_data as id

INNER JOIN event_crf as ec
on ec.event_crf_id=id.event_crf_id

INNER JOIN item_group_metadata as igm
ON igm.item_id=id.item_id
AND igm.crf_version_id=ec.crf_version_id

INNER JOIN study_event as se
on se.study_event_id=ec.study_event_id

INNER JOIN study_subject as ss
on ss.study_subject_id=ec.study_subject_id

INNER JOIN study
on study.study_id=ss.study_id

LEFT JOIN (
SELECT study.study_id
FROM study
WHERE 
    study.status_id <> 5
AND study.status_id <> 7
) AS parents
ON parents.study_id=study.parent_study_id

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