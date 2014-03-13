-- runtime on 2014-03-13 with 299423 rows in 34410ms

WITH raw_defs AS (
SELECT
  COALESCE (parents.study_id,study.study_id,NULL) as parent_study_id
, study.study_id
, ss.study_subject_id
, sed.study_event_definition_id
, se.study_event_id
, crf.crf_id
, cv.crf_version_id
, edc.event_definition_crf_id
, edc.parent_id as edc_parent_id
, edc.study_id as edc_study_id
, ig.item_group_id
, ifm.item_form_metadata_id
, i.item_id
, id.item_data_id

FROM study

LEFT JOIN (
SELECT study.study_id
FROM study
WHERE study.status_id <> 5 -- removed
AND study.status_id <> 7 -- auto-removed
) as parents
ON parents.study_id=study.parent_study_id

INNER JOIN study_subject as ss
ON ss.study_id=study.study_id

INNER JOIN study_event as se
ON se.study_subject_id=ss.study_subject_id

INNER JOIN study_event_definition as sed
ON sed.study_event_definition_id=se.study_event_definition_id

INNER JOIN event_definition_crf as edc
ON edc.study_event_definition_id=se.study_event_definition_id

INNER JOIN event_crf as ec
ON se.study_event_id = ec.study_event_id
AND ec.study_subject_id = ss.study_subject_id

INNER JOIN crf_version as cv
ON cv.crf_version_id=ec.crf_version_id
AND cv.crf_id = edc.crf_id

INNER JOIN crf
ON crf.crf_id=cv.crf_id
AND crf.crf_id=edc.crf_id

INNER JOIN item_group as ig
ON ig.crf_id=crf.crf_id

INNER JOIN item_group_metadata as igm
ON igm.item_group_id=ig.item_group_id
AND igm.crf_version_id=cv.crf_version_id

INNER JOIN item_form_metadata as ifm
ON cv.crf_version_id = ifm.crf_version_id

INNER JOIN item as i
ON i.item_id=ifm.item_id
AND i.item_id=igm.item_id

INNER JOIN item_data as id
ON id.item_id=i.item_id
AND id.event_crf_id=ec.event_crf_id

WHERE
    study.status_id <> 5 -- removed
AND study.status_id <> 7 -- auto-removed
AND ss.status_id <> 5
AND ss.status_id <> 7
AND se.status_id <> 5
AND se.status_id <> 7
AND ec.status_id <> 5
AND ec.status_id <> 7
AND sed.status_id <> 5
AND sed.status_id <> 7
AND edc.status_id <> 5
AND edc.status_id <> 7
AND cv.status_id <> 5
AND cv.status_id <> 7
AND crf.status_id <> 5
AND crf.status_id <> 7
AND ig.status_id <> 5
AND ig.status_id <> 7
AND i.status_id <> 5
AND i.status_id <> 7
AND id.status_id <> 5
AND id.status_id <> 7
), 
 edc_site_defs as (
SELECT * FROM raw_defs
WHERE 
    edc_study_id = study_id
AND edc_parent_id IS NOT NULL
)
SELECT sub.* 
FROM (
SELECT * FROM edc_site_defs
UNION ALL
SELECT * FROM raw_defs
WHERE edc_parent_id IS NULL
AND item_data_id NOT IN (
SELECT item_data_id
FROM edc_site_defs)
) as sub

