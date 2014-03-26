SELECT 
  secs.study_name
, secs.subject_id
, secs.event_name
, secs.event_repeat
, secs.event_status
, secs.crf_parent_name
, secs.crf_status
, pale.new_value as audit_sdv_status
, pua.user_name as audit_sdv_user
, pale.audit_date as audit_sdv_timestamp
, CASE
	WHEN pale.audit_date IS NULL 
	THEN NULL
	ELSE CASE
		WHEN secs.crf_sdv_status_last_updated=pale.audit_date
		THEN 'current'
		WHEN secs.crf_sdv_status_last_updated<>pale.audit_date
		THEN 'history'
		END
  END as audit_sdv_current_or_history
FROM (SELECT
  DISTINCT ON (study_name, subject_id, event_oid, crf_version_oid)
  clinicaldata.study_name
, clinicaldata.site_oid
, clinicaldata.site_name
, clinicaldata.subject_person_id
, clinicaldata.subject_oid
, clinicaldata.subject_id
, clinicaldata.study_subject_id
, clinicaldata.subject_secondary_label
, clinicaldata.subject_date_of_birth
, clinicaldata.subject_sex
, clinicaldata.subject_enrol_date
, clinicaldata.person_id
, clinicaldata.subject_owned_by_user
, clinicaldata.subject_last_updated_by_user
, clinicaldata.event_oid
, clinicaldata.event_order
, clinicaldata.event_name
, clinicaldata.event_repeat
, clinicaldata.event_start
, clinicaldata.event_end
, clinicaldata.event_status
, clinicaldata.event_owned_by_user
, clinicaldata.event_last_updated_by_user
, clinicaldata.event_crf_id
, clinicaldata.crf_parent_oid
, clinicaldata.crf_parent_name
, clinicaldata.crf_version
, clinicaldata.crf_version_oid
, clinicaldata.crf_is_required
, clinicaldata.crf_is_double_entry
, clinicaldata.crf_is_hidden
, clinicaldata.crf_null_values
, clinicaldata.crf_date_created
, clinicaldata.crf_last_update
, clinicaldata.crf_date_completed
, clinicaldata.crf_date_validate
, clinicaldata.crf_date_validate_completed
, clinicaldata.crf_owned_by_user
, clinicaldata.crf_last_updated_by_user
, clinicaldata.crf_status
, clinicaldata.crf_validated_by_user
, clinicaldata.crf_sdv_status
, clinicaldata.crf_sdv_status_last_updated
, clinicaldata.crf_sdv_by_user
, clinicaldata.crf_interviewer_name
, clinicaldata.crf_interview_date
FROM
  dm.clinicaldata) as secs

LEFT JOIN 
	(SELECT * 
	 FROM public.audit_log_event
	 WHERE audit_log_event_type_id=32 --event crf sdv status change 
	) as pale
ON pale.event_crf_id=secs.event_crf_id

LEFT JOIN public.user_account as pua
ON pale.user_id=pua.user_id

ORDER BY 
  secs.study_name
, secs.subject_id
, secs.event_name
, secs.event_repeat
, secs.crf_parent_name
, pale.audit_date DESC