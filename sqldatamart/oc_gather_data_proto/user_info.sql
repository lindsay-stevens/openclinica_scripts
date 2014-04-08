SELECT
  ua.user_name
, ua.first_name
, ua.last_name
, ua.institutional_affiliation
, ut.user_type
, uas.name as user_status
, ua.date_created as user_created
, ua.date_updated as user_updated
, sur.oid
, COALESCE (parents.name,study.name,'no parent study') as role_study
, study.name as role_study_access
, sur.role_name 
, surs.name as role_status
, sur.date_created as role_created
, sur.date_updated as role_updated

FROM user_account as ua

LEFT JOIN status as uas
ON uas.status_id=ua.status_id

LEFT JOIN user_type as ut
ON ut.user_type_id=ua.user_type_id

LEFT JOIN study_user_role as sur
ON sur.user_name=ua.user_name

LEFT JOIN status as surs
ON surs.status_id=sur.status_id

LEFT JOIN study
ON study.study_id=sur.study_id

LEFT JOIN (
 SELECT study.*
 FROM study
 ) as parents
ON parents.study_id=study.parent_study_id

WHERE sur.study_id IS NOT NULL

ORDER BY
  ua.user_name
, role_study