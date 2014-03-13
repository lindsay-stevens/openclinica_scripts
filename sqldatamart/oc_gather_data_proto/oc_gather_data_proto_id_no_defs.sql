-- runtime on 2014-03-13 with 299423 rows in 1530ms

SELECT
  COALESCE (parents.study_id,study.study_id,NULL) AS parent_study_id
, ss.study_id
, ss.study_subject_id
, se.study_event_id
, ec.event_crf_id
, igm.item_group_id
, id.item_data_id 

FROM item_data as id

INNER JOIN (
SELECT DISTINCT
  item_group_id
, item_id
FROM item_group_metadata
) AS igm
ON igm.item_id=id.item_id

INNER JOIN event_crf as ec
on ec.event_crf_id=id.event_crf_id

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
AND id.status_id <> 7;