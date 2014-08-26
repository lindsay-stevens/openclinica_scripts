-- seems to improve performance
DROP INDEX IF EXISTS i_item_form_metadata_item_id;
CREATE INDEX i_item_form_metadata_item_id
  ON item_form_metadata
  USING btree
  (item_id);

DROP INDEX IF EXISTS i_user_account_user_id;
CREATE INDEX i_user_account_user_id
  ON user_account
  USING btree
  (user_id);

-- make a new schema for the tables to go in

DROP SCHEMA IF EXISTS dm CASCADE;
CREATE SCHEMA dm;

-- 01 query (clinicaldata with site eventdefs)

CREATE MATERIALIZED VIEW dm.edc_study_def AS SELECT * FROM (
SELECT
  COALESCE (parents.name,study.name,'no parent study') as study_name
, study.oc_oid as site_oid
, study.name as site_name
, sub.unique_identifier as subject_person_id
, ss.oc_oid as subject_oid
, ss.label as subject_id
, ss.study_subject_id
, ss.secondary_label as subject_secondary_label
, sub.date_of_birth as subject_date_of_birth
, sub.gender as subject_sex
, sub.subject_id as subject_id_seq
, ss.enrollment_date as subject_enrol_date
, sub.unique_identifier as person_id
, ss.owner_id as ss_owner_id
, ss.update_id as ss_update_id
, sed.oc_oid as event_oid
, sed.ordinal as event_order
, sed.name as event_name
, se.study_event_id
, se.sample_ordinal as event_repeat
, se.date_start as event_start
, se.date_end as event_end
, ses.name as event_status 
, se.owner_id as se_owner_id
, se.update_id as se_update_id
, crf.oc_oid as crf_parent_oid
, crf.name as crf_parent_name
, cv.name as crf_version
, cv.oc_oid as crf_version_oid
, edc.required_crf as crf_is_required
, edc.double_entry as crf_is_double_entry
, edc.hide_crf as crf_is_hidden
, edc.null_values as crf_null_values
, edc.status_id as edc_status_id
, ec.event_crf_id
, ec.date_created as crf_date_created
, ec.date_updated as crf_last_update
, ec.date_completed as crf_date_completed
, ec.date_validate as crf_date_validate
, ec.date_validate_completed as crf_date_validate_completed
, ec.owner_id as ec_owner_id
, ec.update_id as ec_update_id
, CASE 
	WHEN ses.subject_event_status_id IN (5,6,7) --stopped,skipped,locked
		THEN 'locked'
	WHEN cv.status_id <> 1 --available
		THEN 'locked'
	WHEN ec.status_id = 1 --available
		THEN 'initial data entry'
	WHEN ec.status_id = 2 --unavailable
		THEN
		CASE 
			WHEN edc.double_entry = TRUE
				THEN 'validation completed'
			WHEN edc.double_entry = FALSE
				THEN 'data entry complete'
			ELSE 'unhandled'
		END
	WHEN ec.status_id = 4 --pending
		THEN
		CASE 
			WHEN ec.validator_id <> 0 --default zero, blank if event_crf created by insertaction
				THEN 'double data entry'
			WHEN ec.validator_id = 0
				THEN 'initial data entry complete'
			ELSE 'unhandled'
		END
	ELSE ec_s.name
  END as crf_status
, ec.validator_id
, ec.sdv_status as crf_sdv_status
, ec_ale_sdv.audit_date as crf_sdv_status_last_updated
, ec.sdv_update_id
, ec.interviewer_name as crf_interviewer_name
, ec.date_interviewed as crf_interview_date
, sct.label as crf_section_label
, sct.title as crf_section_title
, ig.oc_oid as item_group_oid
, ig.name as item_group_name
, id.ordinal as item_group_repeat
, ifm.ordinal as item_form_order
, ifm.question_number_label as item_question_number
, i.oc_oid as item_oid
, i.units as item_units
, idt.code as item_data_type
, rt.name as item_response_type
, ( CASE
	WHEN rs.label IN ('text','textarea')
		THEN NULL
	ELSE rs.label
	END) as item_response_set_label
, rs.response_set_id as item_response_set_id
, rs.version_id as item_response_set_version
, i.name as item_name
, i.description as item_description
, id.value as item_value
, id.date_created as item_value_created
, id.date_updated as item_value_last_updated
, id.owner_id as id_owner_id
, id.update_id as id_update_id
, id.item_data_id

FROM study

	LEFT JOIN (
		SELECT study.*
		FROM study
		WHERE study.status_id NOT IN (5,7) --removed, auto-removed
		) as parents
	ON parents.study_id=study.parent_study_id

	INNER JOIN study_subject as ss
	ON ss.study_id=study.study_id

	INNER JOIN subject as sub
	ON sub.subject_id=ss.subject_id

	INNER JOIN study_event as se
	ON se.study_subject_id=ss.study_subject_id

		INNER JOIN study_event_definition as sed
		ON sed.study_event_definition_id=se.study_event_definition_id

		INNER JOIN subject_event_status as ses
		ON ses.subject_event_status_id=se.subject_event_status_id

		INNER JOIN event_definition_crf as edc
		ON edc.study_event_definition_id=se.study_event_definition_id

		INNER JOIN event_crf as ec
		ON se.study_event_id = ec.study_event_id
		AND ec.study_subject_id = ss.study_subject_id

			INNER JOIN status as ec_s
			ON ec.status_id = ec_s.status_id

			LEFT JOIN (
				SELECT 
				  ale.event_crf_id
				, max(ale.audit_date) as audit_date
				FROM audit_log_event ale
				WHERE ale.event_crf_id IS NOT NULL
					AND ale.audit_log_event_type_id=32 -- event crf sdv status
				GROUP BY ale.event_crf_id
				) as ec_ale_sdv
			ON ec_ale_sdv.event_crf_id=ec.event_crf_id

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

						INNER JOIN item_data_type as idt
						ON idt.item_data_type_id=i.item_data_type_id

					INNER JOIN response_set as rs
					ON rs.response_set_id=ifm.response_set_id
					AND rs.version_id=ifm.crf_version_id
					
						INNER JOIN response_type as rt
						ON rs.response_type_id=rt.response_type_id

				INNER JOIN "section" as sct
				ON sct.crf_version_id=cv.crf_version_id
				AND sct.section_id=ifm.section_id

				INNER JOIN item_data as id
				ON id.item_id=i.item_id
				AND id.event_crf_id=ec.event_crf_id

WHERE
	    study.status_id NOT IN (5,7) --removed, auto-removed
	AND ss.status_id NOT IN (5,7)
	AND se.status_id NOT IN (5,7)
	AND ec.status_id NOT IN (5,7)
	AND sed.status_id NOT IN (5,7)
	AND edc.status_id NOT IN (5,7)
	AND cv.status_id NOT IN (5,7)
	AND crf.status_id NOT IN (5,7)
	AND ig.status_id NOT IN (5,7)
	AND i.status_id NOT IN (5,7)
	AND sct.status_id NOT IN (5,7)
	AND id.status_id NOT IN (5,7)
-- the following conditions result in site level event definitions
	AND edc.study_id = study.study_id
	AND edc.parent_id IS NOT NULL
	) as edc_study_def_src;

CREATE INDEX i_edc_study_def_item_data_id
  ON dm.edc_study_def
  USING btree
  (item_data_id);

ANALYZE dm.edc_study_def;

-- 02 query (study level eventdefs)

CREATE MATERIALIZED VIEW dm.cd_no_labels AS SELECT * FROM (
SELECT dm.edc_study_def.* FROM dm.edc_study_def
UNION ALL
SELECT
  COALESCE (parents.name,study.name,'no parent study') as study_name
, study.oc_oid as site_oid
, study.name as site_name
, sub.unique_identifier as subject_person_id
, ss.oc_oid as subject_oid
, ss.label as subject_id
, ss.study_subject_id
, ss.secondary_label as subject_secondary_label
, sub.date_of_birth as subject_date_of_birth
, sub.gender as subject_sex
, sub.subject_id as subject_id_seq
, ss.enrollment_date as subject_enrol_date
, sub.unique_identifier as person_id
, ss.owner_id as ss_owner_id
, ss.update_id as ss_update_id
, sed.oc_oid as event_oid
, sed.ordinal as event_order
, sed.name as event_name
, se.study_event_id
, se.sample_ordinal as event_repeat
, se.date_start as event_start
, se.date_end as event_end
, ses.name as event_status 
, se.owner_id as se_owner_id
, se.update_id as se_update_id
, crf.oc_oid as crf_parent_oid
, crf.name as crf_parent_name
, cv.name as crf_version
, cv.oc_oid as crf_version_oid
, edc.required_crf as crf_is_required
, edc.double_entry as crf_is_double_entry
, edc.hide_crf as crf_is_hidden
, edc.null_values as crf_null_values
, edc.status_id as edc_status_id
, ec.event_crf_id
, ec.date_created as crf_date_created
, ec.date_updated as crf_last_update
, ec.date_completed as crf_date_completed
, ec.date_validate as crf_date_validate
, ec.date_validate_completed as crf_date_validate_completed
, ec.owner_id as ec_owner_id
, ec.update_id as ec_update_id
, CASE 
	WHEN ses.subject_event_status_id IN (5,6,7) --stopped,skipped,locked
		THEN 'locked'
	WHEN cv.status_id <> 1 --available
		THEN 'locked'
	WHEN ec.status_id = 1 --available
		THEN 'initial data entry'
	WHEN ec.status_id = 2 --unavailable
		THEN
		CASE 
			WHEN edc.double_entry = TRUE
				THEN 'validation completed'
			WHEN edc.double_entry = FALSE
				THEN 'data entry complete'
			ELSE 'unhandled'
		END
	WHEN ec.status_id = 4 --pending
		THEN
		CASE 
			WHEN ec.validator_id <> 0 --default zero, blank if event_crf created by insertaction
				THEN 'double data entry'
			WHEN ec.validator_id = 0
				THEN 'initial data entry complete'
			ELSE 'unhandled'
		END
	ELSE ec_s.name
  END as crf_status
, ec.validator_id
, ec.sdv_status as crf_sdv_status
, ec_ale_sdv.audit_date as crf_sdv_status_last_updated
, ec.sdv_update_id
, ec.interviewer_name as crf_interviewer_name
, ec.date_interviewed as crf_interview_date
, sct.label as crf_section_label
, sct.title as crf_section_title
, ig.oc_oid as item_group_oid
, ig.name as item_group_name
, id.ordinal as item_group_repeat
, ifm.ordinal as item_form_order
, ifm.question_number_label as item_question_number
, i.oc_oid as item_oid
, i.units as item_units
, idt.code as item_data_type
, rt.name as item_response_type
, ( CASE
	WHEN rs.label IN ('text','textarea')
		THEN NULL
	ELSE rs.label
	END) as item_response_set_label
, rs.response_set_id as item_response_set_id
, rs.version_id as item_response_set_version
, i.name as item_name
, i.description as item_description
, id.value as item_value
, id.date_created as item_value_created
, id.date_updated as item_value_last_updated
, id.owner_id as id_owner_id
, id.update_id as id_update_id
, id.item_data_id

FROM study

	LEFT JOIN (
		SELECT study.*
		FROM study
		WHERE study.status_id NOT IN (5,7) --removed, auto-removed
		) as parents
	ON parents.study_id=study.parent_study_id

	INNER JOIN study_subject as ss
	ON ss.study_id=study.study_id

	INNER JOIN subject as sub
	ON sub.subject_id=ss.subject_id

	INNER JOIN study_event as se
	ON se.study_subject_id=ss.study_subject_id

		INNER JOIN study_event_definition as sed
		ON sed.study_event_definition_id=se.study_event_definition_id

		INNER JOIN subject_event_status as ses
		ON ses.subject_event_status_id=se.subject_event_status_id

		INNER JOIN event_definition_crf as edc
		ON edc.study_event_definition_id=se.study_event_definition_id

		INNER JOIN event_crf as ec
		ON se.study_event_id = ec.study_event_id
		AND ec.study_subject_id = ss.study_subject_id

			INNER JOIN status as ec_s
			ON ec.status_id = ec_s.status_id

			LEFT JOIN (
				SELECT 
				  ale.event_crf_id
				, max(ale.audit_date) as audit_date
				FROM audit_log_event ale
				WHERE ale.event_crf_id IS NOT NULL
					AND ale.audit_log_event_type_id=32 -- event crf sdv status
				GROUP BY ale.event_crf_id
				) as ec_ale_sdv
			ON ec_ale_sdv.event_crf_id=ec.event_crf_id

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

						INNER JOIN item_data_type as idt
						ON idt.item_data_type_id=i.item_data_type_id

					INNER JOIN response_set as rs
					ON rs.response_set_id=ifm.response_set_id
					AND rs.version_id=ifm.crf_version_id
					
						INNER JOIN response_type as rt
						ON rs.response_type_id=rt.response_type_id

				INNER JOIN "section" as sct
				ON sct.crf_version_id=cv.crf_version_id
				AND sct.section_id=ifm.section_id

				INNER JOIN item_data as id
				ON id.item_id=i.item_id
				AND id.event_crf_id=ec.event_crf_id

WHERE
	    study.status_id NOT IN (5,7) --removed, auto-removed
	AND ss.status_id NOT IN (5,7)
	AND se.status_id NOT IN (5,7)
	AND ec.status_id NOT IN (5,7)
	AND sed.status_id NOT IN (5,7)
	AND edc.status_id NOT IN (5,7)
	AND cv.status_id NOT IN (5,7)
	AND crf.status_id NOT IN (5,7)
	AND ig.status_id NOT IN (5,7)
	AND i.status_id NOT IN (5,7)
	AND sct.status_id NOT IN (5,7)
	AND id.status_id NOT IN (5,7)
-- the follow conditions result in study level event definitions
	AND edc.parent_id IS NULL
	AND id.item_data_id NOT IN (
		SELECT dm.edc_study_def.item_data_id 
		FROM dm.edc_study_def)
	) as cd_no_labels_src;

ANALYZE dm.cd_no_labels;

-- 03 query (split response sets to rows)

CREATE MATERIALIZED VIEW dm.response_sets AS SELECT * FROM (

SELECT DISTINCT ON (rs_split.version_id, rs_split.label, rs_split.options_values_split) 
  rs_split.version_id
, rs_split.response_set_id
, rs_split.label
, rs_split.options_values_split
, replace (rs_split.options_text_clean_split, '###' , ',') item_value_label
	FROM ( 
	SELECT 
	  rs_clean.version_id
	, rs_clean.response_set_id
	, rs_clean.label 
	, trim (both FROM regexp_split_to_table(rs_clean.options_values, E',')) as options_values_split
	, trim (both FROM regexp_split_to_table(rs_clean.options_text_clean, E',')) as options_text_clean_split
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
	) rs_split ) response_sets_src;

ANALYZE dm.response_sets;

-- 04 query (multi values)

CREATE MATERIALIZED VIEW dm.cd_no_labels_multi_values AS SELECT * FROM
(
SELECT 
  cd_no_labels_multi.study_name
, cd_no_labels_multi.site_oid
, cd_no_labels_multi.site_name
, cd_no_labels_multi.subject_person_id
, cd_no_labels_multi.subject_oid
, cd_no_labels_multi.subject_id
, cd_no_labels_multi.study_subject_id
, cd_no_labels_multi.subject_secondary_label
, cd_no_labels_multi.subject_date_of_birth
, cd_no_labels_multi.subject_sex
, cd_no_labels_multi.subject_id_seq
, cd_no_labels_multi.subject_enrol_date
, cd_no_labels_multi.person_id
, cd_no_labels_multi.ss_owner_id
, cd_no_labels_multi.ss_update_id
, cd_no_labels_multi.event_oid
, cd_no_labels_multi.event_order
, cd_no_labels_multi.event_name
, cd_no_labels_multi.study_event_id
, cd_no_labels_multi.event_repeat
, cd_no_labels_multi.event_start
, cd_no_labels_multi.event_end
, cd_no_labels_multi.event_status
, cd_no_labels_multi.se_owner_id
, cd_no_labels_multi.se_update_id
, cd_no_labels_multi.crf_parent_oid
, cd_no_labels_multi.crf_parent_name
, cd_no_labels_multi.crf_version
, cd_no_labels_multi.crf_version_oid
, cd_no_labels_multi.crf_is_required
, cd_no_labels_multi.crf_is_double_entry
, cd_no_labels_multi.crf_is_hidden
, cd_no_labels_multi.crf_null_values
, cd_no_labels_multi.edc_status_id
, cd_no_labels_multi.event_crf_id
, cd_no_labels_multi.crf_date_created
, cd_no_labels_multi.crf_last_update
, cd_no_labels_multi.crf_date_completed
, cd_no_labels_multi.crf_date_validate
, cd_no_labels_multi.crf_date_validate_completed
, cd_no_labels_multi.ec_owner_id
, cd_no_labels_multi.ec_update_id
, cd_no_labels_multi.crf_status
, cd_no_labels_multi.validator_id
, cd_no_labels_multi.crf_sdv_status
, cd_no_labels_multi.crf_sdv_status_last_updated
, cd_no_labels_multi.sdv_update_id
, cd_no_labels_multi.crf_interviewer_name
, cd_no_labels_multi.crf_interview_date
, cd_no_labels_multi.crf_section_label
, cd_no_labels_multi.crf_section_title
, cd_no_labels_multi.item_group_oid
, cd_no_labels_multi.item_group_name
, cd_no_labels_multi.item_group_repeat
, cd_no_labels_multi.item_form_order
, cd_no_labels_multi.item_question_number
, CASE
   WHEN cd_no_labels_multi.item_value = ''
    THEN cd_no_labels_multi.item_oid
   WHEN cd_no_labels_multi.item_value <> ''
    THEN cd_no_labels_multi.item_oid || '_' || cd_no_labels_multi.item_value
   ELSE 'unhandled'
  END as item_oid
, cd_no_labels_multi.item_units
, cd_no_labels_multi.item_data_type
, cd_no_labels_multi.item_response_type
, cd_no_labels_multi.item_response_set_label
, cd_no_labels_multi.item_response_set_id
, cd_no_labels_multi.item_response_set_version
, CASE
   WHEN cd_no_labels_multi.item_value = ''
    THEN cd_no_labels_multi.item_name
   WHEN cd_no_labels_multi.item_value <> ''
    THEN cd_no_labels_multi.item_name || '_' || cd_no_labels_multi.item_value
   ELSE 'unhandled'
  END item_name
, cd_no_labels_multi.item_description
, cd_no_labels_multi.item_value
, cd_no_labels_multi.item_value_created
, cd_no_labels_multi.item_value_last_updated
, cd_no_labels_multi.id_owner_id
, cd_no_labels_multi.id_update_id
, cd_no_labels_multi.item_data_id
, cd_no_labels_multi.item_oid as item_oid_multi_orig

FROM 
(
SELECT
  cd_no_labels.study_name
, cd_no_labels.site_oid
, cd_no_labels.site_name
, cd_no_labels.subject_person_id
, cd_no_labels.subject_oid
, cd_no_labels.subject_id
, cd_no_labels.study_subject_id
, cd_no_labels.subject_secondary_label
, cd_no_labels.subject_date_of_birth
, cd_no_labels.subject_sex
, cd_no_labels.subject_id_seq
, cd_no_labels.subject_enrol_date
, cd_no_labels.person_id
, cd_no_labels.ss_owner_id
, cd_no_labels.ss_update_id
, cd_no_labels.event_oid
, cd_no_labels.event_order
, cd_no_labels.event_name
, cd_no_labels.study_event_id
, cd_no_labels.event_repeat
, cd_no_labels.event_start
, cd_no_labels.event_end
, cd_no_labels.event_status
, cd_no_labels.se_owner_id
, cd_no_labels.se_update_id
, cd_no_labels.crf_parent_oid
, cd_no_labels.crf_parent_name
, cd_no_labels.crf_version
, cd_no_labels.crf_version_oid
, cd_no_labels.crf_is_required
, cd_no_labels.crf_is_double_entry
, cd_no_labels.crf_is_hidden
, cd_no_labels.crf_null_values 
, cd_no_labels.edc_status_id
, cd_no_labels.event_crf_id
, cd_no_labels.crf_date_created
, cd_no_labels.crf_last_update
, cd_no_labels.crf_date_completed
, cd_no_labels.crf_date_validate
, cd_no_labels.crf_date_validate_completed
, cd_no_labels.ec_owner_id
, cd_no_labels.ec_update_id
, cd_no_labels.crf_status
, cd_no_labels.validator_id
, cd_no_labels.crf_sdv_status
, cd_no_labels.crf_sdv_status_last_updated
, cd_no_labels.sdv_update_id
, cd_no_labels.crf_interviewer_name
, cd_no_labels.crf_interview_date
, CAST(cd_no_labels.crf_section_label AS varchar(255)) -- stored as 2000
, cd_no_labels.crf_section_title
, cd_no_labels.item_group_oid
, cd_no_labels.item_group_name
, cd_no_labels.item_group_repeat
, cd_no_labels.item_form_order
, cd_no_labels.item_question_number
, cd_no_labels.item_oid
, cd_no_labels.item_units
, cd_no_labels.item_data_type
, cd_no_labels.item_response_type
, cd_no_labels.item_response_set_label
, cd_no_labels.item_response_set_id
, cd_no_labels.item_response_set_version
, cd_no_labels.item_name
, cd_no_labels.item_description
, regexp_split_to_table(cd_no_labels.item_value, E',') as item_value
, cd_no_labels.item_value_created
, cd_no_labels.item_value_last_updated
, cd_no_labels.id_owner_id
, cd_no_labels.id_update_id
, cd_no_labels.item_data_id
FROM dm.cd_no_labels
WHERE cd_no_labels.item_response_type IN ('multi-select','checkbox')
) as cd_no_labels_multi
) as cd_no_labels_multi_values_src;

ANALYZE dm.cd_no_labels_multi_values;

CREATE MATERIALIZED VIEW dm.cd_no_labels_multi_join AS SELECT * FROM (
SELECT 
  cd_no_labels.*
, NULL as item_oid_multi_orig
FROM dm.cd_no_labels
WHERE cd_no_labels.item_response_type NOT IN ('multi-select','checkbox') 
UNION ALL
SELECT 
  cd_no_labels_multi_values.*
FROM dm.cd_no_labels_multi_values
) as cd_no_labels_multi_join_src;

ANALYZE dm.cd_no_labels_multi_join;

-- 05 query (all of the above with value labels and user names)

CREATE MATERIALIZED VIEW dm.clinicaldata AS SELECT * FROM (

SELECT 
  dm.cd_no_labels_multi_join.*
, ua_ss_o.user_name as subject_owned_by_user
, ua_ss_u.user_name as subject_last_updated_by_user
, ua_se_o.user_name as event_owned_by_user
, ua_se_u.user_name as event_last_updated_by_user
, ua_ec_o.user_name as crf_owned_by_user
, ua_ec_u.user_name as crf_last_updated_by_user
, ua_ec_v.user_name as crf_validated_by_user
, CURRENT_TIMESTAMP as warehouse_timestamp
, ( CASE 
	WHEN dm.cd_no_labels_multi_join.crf_sdv_status IS FALSE 
		THEN NULL
	WHEN dm.cd_no_labels_multi_join.crf_sdv_status IS TRUE
		THEN ua_ec_s.user_name
	ELSE 'unhandled'
	END ) as crf_sdv_by_user
, ua_id_o.user_name as item_value_owned_by_user
, ua_id_u.user_name as item_value_last_updated_by_user
, dm.response_sets.item_value_label
, (CASE 
	WHEN dm.response_sets.item_value_label is null
		THEN dm.cd_no_labels_multi_join.item_value
	WHEN dm.response_sets.item_value_label is not null
		THEN dm.cd_no_labels_multi_join.item_value || '###' || dm.response_sets.item_value_label
	ELSE NULL
  END) as item_value_label_concat
FROM dm.cd_no_labels_multi_join 
LEFT JOIN dm.response_sets 
ON  dm.response_sets.version_id = dm.cd_no_labels_multi_join.item_response_set_version
AND dm.response_sets.response_set_id = dm.cd_no_labels_multi_join.item_response_set_id
AND dm.response_sets.options_values_split = dm.cd_no_labels_multi_join.item_value 

LEFT JOIN user_account ua_ss_o
ON ua_ss_o.user_id = dm.cd_no_labels_multi_join.ss_owner_id

LEFT JOIN user_account ua_ss_u
ON ua_ss_u.user_id = dm.cd_no_labels_multi_join.se_update_id

LEFT JOIN user_account ua_se_o
ON ua_se_o.user_id = dm.cd_no_labels_multi_join.se_owner_id

LEFT JOIN user_account ua_se_u
ON ua_se_u.user_id = dm.cd_no_labels_multi_join.se_update_id

LEFT JOIN user_account ua_ec_o
ON ua_ec_o.user_id = dm.cd_no_labels_multi_join.ec_owner_id

LEFT JOIN user_account ua_ec_u
ON ua_ec_u.user_id = dm.cd_no_labels_multi_join.ec_update_id

LEFT JOIN user_account ua_ec_v
ON ua_ec_v.user_id = dm.cd_no_labels_multi_join.validator_id

LEFT JOIN user_account ua_ec_s
ON ua_ec_s.user_id = dm.cd_no_labels_multi_join.sdv_update_id

LEFT JOIN user_account ua_id_o
ON ua_id_o.user_id = dm.cd_no_labels_multi_join.id_owner_id

LEFT JOIN user_account ua_id_u
ON ua_id_u.user_id = dm.cd_no_labels_multi_join.id_update_id
) cd_rs_join;

CREATE INDEX i_dm_clinicaldata_study_name_item_group_oid 
 ON dm.clinicaldata 
 USING btree 
 (study_name, item_group_oid);

ANALYZE dm.clinicaldata;

-- 06 query (metadata without items for multi values)

CREATE MATERIALIZED VIEW dm.metadata_no_multi AS SELECT * FROM (

SELECT
  ( CASE
	WHEN parents.name is not null
		THEN parents.name
	ELSE study.name
	END) as study_name
, study.oc_oid as site_oid
, study.name as site_name
, sed.oc_oid as event_oid
, sed.ordinal as event_order
, sed.name as event_name
, sed.repeating as event_repeating
, crf.oc_oid as crf_parent_oid
, crf.name as crf_parent_name
, cv.name as crf_version
, cv.oc_oid as crf_version_oid
, edc.required_crf as crf_is_required
, edc.double_entry as crf_is_double_entry
, edc.hide_crf as crf_is_hidden
, edc.null_values as crf_null_values
, sct.label as crf_section_label
, sct.title as crf_section_title
, ig.oc_oid as item_group_oid
, ig.name as item_group_name
, ifm.ordinal as item_form_order
, i.oc_oid as item_oid
, i.units as item_units
, idt.code as item_data_type
, rt.name as item_response_type
, ( CASE
	WHEN rs.label IN ('text','textarea')
		THEN NULL
	ELSE rs.label
	END) as item_response_set_label
, rs.response_set_id as item_response_set_id
, rs.version_id as item_response_set_version
, ifm.question_number_label as item_question_number
, i.name as item_name
, i.description as item_description

FROM study

	INNER JOIN study_event_definition as sed
	ON sed.study_id=study.study_id

	INNER JOIN event_definition_crf as edc
	ON edc.study_event_definition_id=sed.study_event_definition_id

	INNER JOIN crf_version as cv
	ON cv.crf_id = edc.crf_id 

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

	INNER JOIN "section" as sct
	ON sct.crf_version_id=cv.crf_version_id
	AND sct.section_id=ifm.section_id	

	INNER JOIN response_set as rs
	ON rs.response_set_id=ifm.response_set_id
	AND rs.version_id=ifm.crf_version_id
	
	INNER JOIN response_type as rt
	ON rs.response_type_id=rt.response_type_id

	INNER JOIN item as i
	ON i.item_id=ifm.item_id 
	AND i.item_id=igm.item_id 

	INNER JOIN item_data_type as idt
	ON idt.item_data_type_id=i.item_data_type_id

	LEFT JOIN (
		SELECT
		  study.study_id
		, study.oc_oid
		, study.name
		FROM study
		) as parents
	ON parents.study_id=study.parent_study_id

WHERE edc.parent_id IS NULL
	AND study.status_id NOT IN (5,7) --removed, auto-removed
	AND sed.status_id NOT IN (5,7)
	AND edc.status_id NOT IN (5,7)
	AND cv.status_id NOT IN (5,7)
	AND crf.status_id NOT IN (5,7)
	AND ig.status_id NOT IN (5,7)
	AND i.status_id NOT IN (5,7)
	AND sct.status_id NOT IN (5,7)
 ) as metadata_no_multi_src;

ANALYZE dm.metadata_no_multi;

-- 07 (metadata with items for multi values)

CREATE MATERIALIZED VIEW dm.metadata AS SELECT * FROM (
SELECT
  metadata_no_multi.study_name
, metadata_no_multi.site_oid
, metadata_no_multi.site_name
, metadata_no_multi.event_oid
, metadata_no_multi.event_order
, metadata_no_multi.event_name
, metadata_no_multi.event_repeating
, metadata_no_multi.crf_parent_oid
, metadata_no_multi.crf_parent_name
, metadata_no_multi.crf_version
, metadata_no_multi.crf_version_oid
, metadata_no_multi.crf_is_required
, metadata_no_multi.crf_is_double_entry
, metadata_no_multi.crf_is_hidden
, metadata_no_multi.crf_null_values
, CAST(metadata_no_multi.crf_section_label AS varchar(255)) -- stored as 2000 but isn't
, metadata_no_multi.crf_section_title
, metadata_no_multi.item_group_oid
, metadata_no_multi.item_group_name
, metadata_no_multi.item_form_order
, CASE
   WHEN metadata_no_multi.item_response_type NOT IN ('multi-select','checkbox')
    THEN metadata_no_multi.item_oid
   WHEN metadata_no_multi.item_response_type IN ('multi-select','checkbox')
    THEN mv.item_oid
   ELSE 'unhandled'
  END as item_oid
, metadata_no_multi.item_units
, metadata_no_multi.item_data_type
, metadata_no_multi.item_response_type
, metadata_no_multi.item_response_set_label
, metadata_no_multi.item_response_set_id
, metadata_no_multi.item_response_set_version
, metadata_no_multi.item_question_number
, CASE
   WHEN metadata_no_multi.item_response_type NOT IN ('multi-select','checkbox')
    THEN metadata_no_multi.item_name
   WHEN metadata_no_multi.item_response_type IN ('multi-select','checkbox')
    THEN mv.item_name
   ELSE 'unhandled'
  END as item_name
, metadata_no_multi.item_description 
FROM dm.metadata_no_multi
LEFT JOIN (
	SELECT 
	  mnm.item_oid as item_oid_orig
	 ,mnm.item_oid || '_' || dm.response_sets.options_values_split as item_oid
	 ,mnm.item_name || '_' || dm.response_sets.options_values_split as item_name
	FROM dm.response_sets
	LEFT JOIN (
	 SELECT DISTINCT ON (dm.metadata_no_multi.item_oid)
	   dm.metadata_no_multi.item_oid
	  ,dm.metadata_no_multi.item_name
	  ,dm.metadata_no_multi.item_response_set_id
	  ,dm.metadata_no_multi.item_response_set_version
	 FROM dm.metadata_no_multi 
	 WHERE dm.metadata_no_multi.item_response_type IN ('multi-select','checkbox')
	) as mnm
	ON mnm.item_response_set_id=dm.response_sets.response_set_id
	AND mnm.item_response_set_version=dm.response_sets.version_id
    UNION ALL
    SELECT DISTINCT ON (dm.metadata_no_multi.item_oid)
	   dm.metadata_no_multi.item_oid as item_oid_orig
      ,dm.metadata_no_multi.item_oid
	  ,dm.metadata_no_multi.item_name
	 FROM dm.metadata_no_multi 
	 WHERE dm.metadata_no_multi.item_response_type IN ('multi-select','checkbox')
) AS mv
ON mv.item_oid_orig = metadata_no_multi.item_oid
) as metadata_src;

ANALYZE dm.metadata;

-- 08 query (distinct subjects)

CREATE MATERIALIZED VIEW dm.subjects as SELECT * FROM (
SELECT 
  DISTINCT ON (study_name, subject_id)
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
FROM
  dm.clinicaldata) as s_src;

ANALYZE dm.subjects;

-- 09 query (distinct event crfs by subject)

CREATE MATERIALIZED VIEW dm.subject_event_crf_status as SELECT * FROM (
SELECT
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
  dm.clinicaldata) as secs_src;

ANALYZE dm.subject_event_crf_status;

-- 10 query (distinct subjects, event crfs)

CREATE MATERIALIZED VIEW dm.subject_event_crf_expected as SELECT * FROM (
SELECT 
  s.study_name
, s.site_oid
, s.subject_id
, e.event_oid
, e.crf_parent_name
FROM 
  (SELECT DISTINCT 
    clinicaldata.study_name
  , clinicaldata.site_oid
  , clinicaldata.site_name
  , clinicaldata.subject_id 
  FROM dm.clinicaldata)  AS s
  , 
  (SELECT DISTINCT
    metadata.study_name
  , metadata.event_oid
  , metadata.crf_parent_name
  FROM dm.metadata)  AS e
  WHERE s.study_name = e.study_name) as sece_src;

ANALYZE dm.subject_event_crf_expected;

-- 11 query (join subject event crf status with expected)

CREATE MATERIALIZED VIEW dm.subject_event_crf_join as SELECT * FROM (
SELECT 
  e.study_name
, e.site_oid
, s.site_name
, s.subject_person_id
, s.subject_oid
, e.subject_id
, s.study_subject_id
, s.subject_secondary_label
, s.subject_date_of_birth
, s.subject_sex
, s.subject_enrol_date
, s.person_id
, s.subject_owned_by_user
, s.subject_last_updated_by_user
, e.event_oid
, s.event_order
, s.event_name
, s.event_repeat
, s.event_start
, s.event_end
, CASE WHEN s.event_status IS NOT NULL
   THEN s.event_status
   ELSE 'not scheduled'
  END as event_status
, s.event_owned_by_user
, s.event_last_updated_by_user
, s.crf_parent_oid
, e.crf_parent_name
, s.crf_version
, s.crf_version_oid
, s.crf_is_required
, s.crf_is_double_entry
, s.crf_is_hidden
, s.crf_null_values
, s.crf_date_created
, s.crf_last_update
, s.crf_date_completed
, s.crf_date_validate
, s.crf_date_validate_completed
, s.crf_owned_by_user
, s.crf_last_updated_by_user
, s.crf_status
, s.crf_validated_by_user
, s.crf_sdv_status
, s.crf_sdv_status_last_updated
, s.crf_sdv_by_user
, s.crf_interviewer_name
, s.crf_interview_date
FROM 
  dm.subject_event_crf_expected as e
LEFT JOIN
  dm.subject_event_crf_status as s
ON
  s.subject_id = e.subject_id
AND
  s.event_oid = e.event_oid
AND
  s.crf_parent_name = e.crf_parent_name) as secj_src;

ANALYZE dm.subject_event_crf_join;

-- 12 query (discrepancy notes all)

CREATE MATERIALIZED VIEW dm.discrepancy_notes_all as SELECT * FROM (

SELECT 
  sua.discrepancy_note_id
, sua.study_name
, sua.site_name
, sua.subject_id
, sua.event_name
, sua.crf_parent_name
, sua.crf_section_label
, sua.item_description
, sua.column_name
, dn.parent_dn_id
, dn.entity_type
, dn.description
, dn.detailed_notes
, dn.date_created
, CAST (CASE WHEN dn.discrepancy_note_type_id = 1
            THEN 'Failed Validation Check'
       WHEN dn.discrepancy_note_type_id = 2
            THEN 'Annotation'
       WHEN dn.discrepancy_note_type_id = 3
            THEN 'Query'
       WHEN dn.discrepancy_note_type_id = 4
            THEN 'Reason for Change'
       ELSE 'unhandled'
  END AS varchar(23)) as discrepancy_note_type
, rs.name as resolution_status
, ua.user_name as discrepancy_note_owner
FROM (

SELECT DISTINCT ON (didm.discrepancy_note_id)
  didm.discrepancy_note_id
, didm.column_name
, cd.study_name
, cd.site_name
, cd.subject_id
, cd.event_name
, cd.crf_parent_name
, cd.crf_section_label
, cd.item_description
FROM dn_item_data_map as didm
INNER JOIN dm.clinicaldata as cd
  ON cd.item_data_id = didm.item_data_id

UNION ALL

SELECT DISTINCT ON (decm.discrepancy_note_id)
  decm.discrepancy_note_id
, decm.column_name
, cd.study_name
, cd.site_name
, cd.subject_id
, cd.event_name
, cd.crf_parent_name
, Null as crf_section_label
, Null as item_description
FROM dn_event_crf_map as decm
INNER JOIN dm.clinicaldata as cd
  ON cd.event_crf_id = decm.event_crf_id

UNION ALL

SELECT DISTINCT ON (dsem.discrepancy_note_id)
  dsem.discrepancy_note_id
, dsem.column_name
, cd.study_name
, cd.site_name
, cd.subject_id
, cd.event_name
, Null as crf_parent_name
, Null as crf_section_label
, Null as item_description
FROM dn_study_event_map as dsem
INNER JOIN dm.clinicaldata as cd
  ON cd.study_event_id = dsem.study_event_id

UNION ALL

SELECT DISTINCT ON (dssm.discrepancy_note_id)
  dssm.discrepancy_note_id
, dssm.column_name
, cd.study_name
, cd.site_name
, cd.subject_id
, Null as event_name
, Null as crf_parent_name
, Null as crf_section_label
, Null as item_description
FROM dn_study_subject_map as dssm
INNER JOIN dm.clinicaldata as cd
  ON cd.study_subject_id = dssm.study_subject_id

UNION ALL

SELECT DISTINCT ON (dsm.discrepancy_note_id)
  dsm.discrepancy_note_id
, dsm.column_name
, cd.study_name
, cd.site_name
, cd.subject_id
, Null as event_name
, Null as crf_parent_name
, Null as crf_section_label
, Null as item_description
FROM dn_subject_map as dsm
INNER JOIN dm.clinicaldata as cd
  ON cd.subject_id_seq = dsm.subject_id

) as sua
INNER JOIN discrepancy_note as dn
  ON dn.discrepancy_note_id = sua.discrepancy_note_id
INNER JOIN resolution_status as rs
  ON rs.resolution_status_id = dn.resolution_status_id
INNER JOIN user_account as ua
  ON ua.user_id = dn.owner_id

) as dn_src;

ANALYZE dm.discrepancy_notes_all;

-- 13 query (discrepancy notes parent)

CREATE MATERIALIZED VIEW dm.discrepancy_notes_parent AS SELECT * FROM (
SELECT 
  sub.discrepancy_note_id
, sub.study_name
, sub.site_name
, sub.subject_id
, sub.event_name
, sub.crf_parent_name
, sub.crf_section_label
, sub.item_description
, sub.column_name
, sub.parent_dn_id
, sub.entity_type
, sub.description
, sub.detailed_notes
, sub.date_created
, sub.discrepancy_note_type
, sub.resolution_status
, sub.discrepancy_note_owner
, CASE WHEN sub.resolution_status IN ('Closed', 'Not Applicable')
            THEN NULL
       WHEN sub.resolution_status IN ('New', 'Updated', 'Resolution Proposed')
            THEN CURRENT_DATE - sub.date_created
       ELSE NULL
  END as days_open
, CASE WHEN sub.resolution_status IN ('Closed', 'Not Applicable')
            THEN NULL
       WHEN sub.resolution_status IN ('New', 'Updated', 'Resolution Proposed')
            THEN CURRENT_DATE - (SELECT max(alldates.date_created) FROM 
		(SELECT date_created FROM discrepancy_note as dn 
		  WHERE dn.parent_dn_id = sub.discrepancy_note_id UNION ALL 
		 SELECT date_created FROM discrepancy_note as dn 
		  WHERE dn.parent_dn_id = sub.parent_dn_id UNION ALL 
		 SELECT date_created FROM discrepancy_note as dn 
		  WHERE dn.discrepancy_note_id = sub.discrepancy_note_id) as alldates)
       ELSE NULL
  END as days_since_update
FROM dm.discrepancy_notes_all as sub
WHERE sub.parent_dn_id IS NULL
GROUP BY
  sub.discrepancy_note_id
, sub.study_name
, sub.site_name
, sub.subject_id
, sub.event_name
, sub.crf_parent_name
, sub.crf_section_label
, sub.item_description
, sub.column_name
, sub.parent_dn_id
, sub.entity_type
, sub.description
, sub.detailed_notes
, sub.date_created
, sub.discrepancy_note_type
, sub.resolution_status
, sub.discrepancy_note_owner
) as dnp_src;

ANALYZE dm.discrepancy_notes_parent;

-- 14 query (subject groups)

CREATE MATERIALIZED VIEW dm.subject_groups AS SELECT * FROM (

SELECT 
  sub.study_name
, sub.site_name
, sub.subject_id
, gct.name as group_class_type
, sgc.name as group_class_name
, sg.name as group_name
, sg.description as group_description
FROM dm.subjects as sub
INNER JOIN subject_group_map as sgm
  ON sgm.study_subject_id = sub.study_subject_id
LEFT JOIN study_group as sg
  ON sg.study_group_id = sgm.study_group_id
LEFT JOIN study_group_class as sgc
  ON sgc.study_group_class_id = sgm.study_group_class_id
LEFT JOIN group_class_types as gct
  ON gct.group_class_type_id = sgc.group_class_type_id) as sg_src;

ANALYZE dm.subject_groups;

-- 15 query (response set labels)

CREATE MATERIALIZED VIEW dm.response_set_labels AS SELECT * FROM (

SELECT DISTINCT
  md.study_name
, md.crf_parent_name
, md.crf_version
, md.item_group_oid
, md.item_group_name
, md.item_form_order
, md.item_oid
, md.item_name
, md.item_description
, rs.version_id
, rs.label
, rs.options_values_split
, rs.item_value_label
FROM dm.metadata_no_multi as md
INNER JOIN dm.response_sets as rs
ON rs.version_id = md.item_response_set_version
AND rs.label = md.item_response_set_label
ORDER BY
  md.study_name
, md.crf_parent_name
, md.crf_version
, md.item_group_oid
, md.item_form_order
, rs.version_id
, rs.label
, rs.options_values_split) as rsl_src;

ANALYZE dm.response_set_labels;

-- 16 query (user accounts and roles)

CREATE MATERIALIZED VIEW dm.user_account_roles AS (
SELECT
  ua.user_name
 ,ua.first_name
 ,ua.last_name
 ,ua.email
 ,ua.date_created AS account_created
 ,ua.date_updated AS account_last_updated
 ,ua_status.name AS account_status
 ,COALESCE (parents.unique_identifier,study.unique_identifier,'no parent study') AS role_study_code
 ,COALESCE (parents.name,study.name,'no parent study') AS study_name
 ,CASE
   WHEN parents.unique_identifier is not null
   THEN study.unique_identifier
  END AS role_site_code
 ,CASE
   WHEN parents.name is not null
   THEN study.name
  END AS role_site_name
-- role_name_ui renames internal role names to what is seen in OpenClinica UI
-- renaming only for roles which are used at Kirby Institute (add others if needed)
 ,CASE 
    WHEN 
         parents.name is null
    THEN
      CASE
        WHEN role_name='admin'
        THEN 'administrator'
        WHEN role_name='coordinator'
        THEN 'study data manager'
        WHEN role_name='monitor'
        THEN 'study monitor'
        WHEN role_name='ra'
        THEN 'study data entry person'
        ELSE role_name
      END
    WHEN 
         parents.name is not null
    THEN
      CASE
        WHEN role_name='ra'
        THEN 'clinical research coordinator'
        WHEN role_name='monitor'
        THEN 'site monitor'
        WHEN role_name='Data Specialist'
        THEN 'site investigator'
        ELSE role_name
      END
  END AS role_name_ui
 ,sur.date_created AS role_created
 ,sur.date_updated AS role_last_updated
 ,sur_status.name AS role_status
FROM user_account AS ua 
LEFT JOIN study_user_role AS sur 
  ON  ua.user_name = sur.user_name
LEFT JOIN study
  ON  study.study_id = sur.study_id
LEFT JOIN study as parents
  ON  parents.study_id=study.parent_study_id
LEFT JOIN status AS ua_status
  ON ua.status_id=ua_status.status_id
LEFT JOIN status AS sur_status
  ON sur.status_id=sur_status.status_id
)