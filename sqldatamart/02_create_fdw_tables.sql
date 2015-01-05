CREATE FOREIGN TABLE public.ft_archived_dataset_file (archived_dataset_file_id INTEGER, name CHARACTER VARYING(255), dataset_id INTEGER, export_format_id INTEGER, file_reference CHARACTER VARYING(1000), run_time INTEGER, file_size INTEGER, date_created TIMESTAMP(6) WITHOUT TIME ZONE, owner_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'archived_dataset_file', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_event (audit_id INTEGER, audit_date TIMESTAMP WITH TIME ZONE, audit_table CHARACTER VARYING(500), user_id INTEGER, entity_id INTEGER, reason_for_change CHARACTER VARYING(1000), action_message CHARACTER VARYING(4000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_event_context (audit_id INTEGER, study_id INTEGER, subject_id INTEGER, study_subject_id INTEGER, role_name CHARACTER VARYING(200), event_crf_id INTEGER, study_event_id INTEGER, study_event_definition_id INTEGER, crf_id INTEGER, crf_version_id INTEGER, study_crf_id INTEGER, item_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_event_context', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_event_values (audit_id INTEGER, column_name CHARACTER VARYING(255), old_value CHARACTER VARYING(2000), new_value CHARACTER VARYING(2000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_event_values', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_log_event (audit_id INTEGER, audit_date TIMESTAMP WITH TIME ZONE, audit_table CHARACTER VARYING(500), user_id INTEGER, entity_id INTEGER, entity_name CHARACTER VARYING(500), reason_for_change CHARACTER VARYING(1000), audit_log_event_type_id INTEGER, old_value CHARACTER VARYING(4000), new_value CHARACTER VARYING(4000), event_crf_id INTEGER, study_event_id INTEGER, event_crf_version_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_log_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_log_event_type (audit_log_event_type_id INTEGER, name CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_log_event_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_audit_user_login (id INTEGER, user_name CHARACTER VARYING(255), user_account_id INTEGER, login_attempt_date TIMESTAMP WITH TIME ZONE, login_status_code INTEGER, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'audit_user_login', updatable 'false');
CREATE FOREIGN TABLE public.ft_authorities (id INTEGER, username CHARACTER VARYING(50), authority CHARACTER VARYING(50), version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'authorities', updatable 'false');
CREATE FOREIGN TABLE public.ft_completion_status (completion_status_id INTEGER, status_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'completion_status', updatable 'false');
CREATE FOREIGN TABLE public.ft_configuration (id INTEGER, key CHARACTER VARYING(255), value CHARACTER VARYING(255), description CHARACTER VARYING(512), version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'configuration', updatable 'false');
CREATE FOREIGN TABLE public.ft_crf (crf_id INTEGER, status_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(2048), owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, oc_oid CHARACTER VARYING(40), source_study_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'crf', updatable 'false');
CREATE FOREIGN TABLE public.ft_crf_version (crf_version_id INTEGER, crf_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(4000), revision_notes CHARACTER VARYING(255), status_id INTEGER, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, oc_oid CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'crf_version', updatable 'false');
CREATE FOREIGN TABLE public.ft_databasechangelog (id CHARACTER VARYING(63), author CHARACTER VARYING(63), filename CHARACTER VARYING(200), dateexecuted TIMESTAMP WITH TIME ZONE, md5sum CHARACTER VARYING(32), description CHARACTER VARYING(255), comments CHARACTER VARYING(255), tag CHARACTER VARYING(255), liquibase CHARACTER VARYING(10))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'databasechangelog', updatable 'false');
CREATE FOREIGN TABLE public.ft_databasechangeloglock (id INTEGER, locked BOOLEAN, lockgranted TIMESTAMP WITH TIME ZONE, lockedby CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'databasechangeloglock', updatable 'false');
CREATE FOREIGN TABLE public.ft_dataset (dataset_id INTEGER, study_id INTEGER, status_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(2000), sql_statement TEXT, num_runs INTEGER, date_start DATE, date_end DATE, date_created DATE, date_updated DATE, date_last_run DATE, owner_id INTEGER, approver_id INTEGER, update_id INTEGER, show_event_location BOOLEAN, show_event_start BOOLEAN, show_event_end BOOLEAN, show_subject_dob BOOLEAN, show_subject_gender BOOLEAN, show_event_status BOOLEAN, show_subject_status BOOLEAN, show_subject_unique_id BOOLEAN, show_subject_age_at_event BOOLEAN, show_crf_status BOOLEAN, show_crf_version BOOLEAN, show_crf_int_name BOOLEAN, show_crf_int_date BOOLEAN, show_group_info BOOLEAN, show_disc_info BOOLEAN, odm_metadataversion_name CHARACTER VARYING(255), odm_metadataversion_oid CHARACTER VARYING(255), odm_prior_study_oid CHARACTER VARYING(255), odm_prior_metadataversion_oid CHARACTER VARYING(255), show_secondary_id BOOLEAN, dataset_item_status_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dataset', updatable 'false');
CREATE FOREIGN TABLE public.ft_dataset_crf_version_map (dataset_id INTEGER, event_definition_crf_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dataset_crf_version_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dataset_filter_map (dataset_id INTEGER, filter_id INTEGER, ordinal INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dataset_filter_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dataset_item_status (dataset_item_status_id INTEGER, name CHARACTER VARYING(50), description CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dataset_item_status', updatable 'false');
CREATE FOREIGN TABLE public.ft_dataset_study_group_class_map (dataset_id INTEGER, study_group_class_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dataset_study_group_class_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_computed_event (dc_summary_event_id INTEGER, dc_event_id INTEGER, item_target_id INTEGER, summary_type CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_computed_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_event (dc_event_id INTEGER, decision_condition_id INTEGER, ordinal INTEGER, type CHARACTER VARYING(256))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_primitive (dc_primitive_id INTEGER, decision_condition_id INTEGER, item_id INTEGER, dynamic_value_item_id INTEGER, comparison CHARACTER VARYING(3), constant_value CHARACTER VARYING(4000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_primitive', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_section_event (dc_event_id INTEGER, section_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_section_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_send_email_event (dc_event_id INTEGER, to_address CHARACTER VARYING(1000), subject CHARACTER VARYING(1000), body CHARACTER VARYING(4000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_send_email_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_substitution_event (dc_event_id INTEGER, item_id INTEGER, value CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_substitution_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_dc_summary_item_map (dc_summary_event_id INTEGER, item_id INTEGER, ordinal INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dc_summary_item_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_decision_condition (decision_condition_id INTEGER, crf_version_id INTEGER, status_id INTEGER, label CHARACTER VARYING(1000), comments CHARACTER VARYING(3000), quantity INTEGER, type CHARACTER VARYING(3), owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'decision_condition', updatable 'false');
CREATE FOREIGN TABLE public.ft_discrepancy_note (discrepancy_note_id INTEGER, description CHARACTER VARYING(255), discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, detailed_notes CHARACTER VARYING(1000), date_created DATE, owner_id INTEGER, parent_dn_id INTEGER, entity_type CHARACTER VARYING(30), study_id INTEGER, assigned_user_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'discrepancy_note', updatable 'false');
CREATE FOREIGN TABLE public.ft_discrepancy_note_type (discrepancy_note_type_id INTEGER, name CHARACTER VARYING(50), description CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'discrepancy_note_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_age_days (discrepancy_note_id INTEGER, days INTEGER, age INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_age_days', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_event_crf_map (event_crf_id INTEGER, discrepancy_note_id INTEGER, column_name CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_event_crf_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_item_data_map (item_data_id INTEGER, discrepancy_note_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_item_data_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_study_event_map (study_event_id INTEGER, discrepancy_note_id INTEGER, column_name CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_study_event_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_study_subject_map (study_subject_id INTEGER, discrepancy_note_id INTEGER, column_name CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_study_subject_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dn_subject_map (subject_id INTEGER, discrepancy_note_id INTEGER, column_name CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dn_subject_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_dyn_item_form_metadata (id INTEGER, item_form_metadata_id INTEGER, item_id INTEGER, crf_version_id INTEGER, show_item BOOLEAN, event_crf_id INTEGER, version INTEGER, item_data_id INTEGER, passed_dde INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dyn_item_form_metadata', updatable 'false');
CREATE FOREIGN TABLE public.ft_dyn_item_group_metadata (id INTEGER, item_group_metadata_id INTEGER, item_group_id INTEGER, show_group BOOLEAN, event_crf_id INTEGER, version INTEGER, passed_dde INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'dyn_item_group_metadata', updatable 'false');
CREATE FOREIGN TABLE public.ft_event_crf (event_crf_id INTEGER, study_event_id INTEGER, crf_version_id INTEGER, date_interviewed DATE, interviewer_name CHARACTER VARYING(255), completion_status_id INTEGER, status_id INTEGER, annotations CHARACTER VARYING(4000), date_completed TIMESTAMP WITH TIME ZONE, validator_id INTEGER, date_validate DATE, date_validate_completed TIMESTAMP WITH TIME ZONE, validator_annotations CHARACTER VARYING(4000), validate_string CHARACTER VARYING(256), owner_id INTEGER, date_created DATE, study_subject_id INTEGER, date_updated DATE, update_id INTEGER, electronic_signature_status BOOLEAN, sdv_status BOOLEAN, old_status_id INTEGER, sdv_update_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'event_crf', updatable 'false');
CREATE FOREIGN TABLE public.ft_event_definition_crf (event_definition_crf_id INTEGER, study_event_definition_id INTEGER, study_id INTEGER, crf_id INTEGER, required_crf BOOLEAN, double_entry BOOLEAN, require_all_text_filled BOOLEAN, decision_conditions BOOLEAN, null_values CHARACTER VARYING(255), default_version_id INTEGER, status_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, ordinal INTEGER, electronic_signature BOOLEAN, hide_crf BOOLEAN, source_data_verification_code INTEGER, selected_version_ids CHARACTER VARYING(150), parent_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'event_definition_crf', updatable 'false');
CREATE FOREIGN TABLE public.ft_export_format (export_format_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000), mime_type CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'export_format', updatable 'false');
CREATE FOREIGN TABLE public.ft_filter (filter_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(2000), sql_statement CHARACTER VARYING(4000), status_id INTEGER, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'filter', updatable 'false');
CREATE FOREIGN TABLE public.ft_filter_crf_version_map (filter_id INTEGER, crf_version_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'filter_crf_version_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_group_class_types (group_class_type_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'group_class_types', updatable 'false');
CREATE FOREIGN TABLE public.ft_item (item_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(4000), units CHARACTER VARYING(64), phi_status BOOLEAN, item_data_type_id INTEGER, item_reference_type_id INTEGER, status_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, oc_oid CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_data (item_data_id INTEGER, item_id INTEGER, event_crf_id INTEGER, status_id INTEGER, value CHARACTER VARYING(4000), date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, ordinal INTEGER, old_status_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_data', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_data_type (item_data_type_id INTEGER, code CHARACTER VARYING(20), name CHARACTER VARYING(255), definition CHARACTER VARYING(1000), reference CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_data_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_form_metadata (item_form_metadata_id INTEGER, item_id INTEGER, crf_version_id INTEGER, header CHARACTER VARYING(2000), subheader CHARACTER VARYING(240), parent_id INTEGER, parent_label CHARACTER VARYING(120), column_number INTEGER, page_number_label CHARACTER VARYING(5), question_number_label CHARACTER VARYING(20), left_item_text CHARACTER VARYING(4000), right_item_text CHARACTER VARYING(2000), section_id INTEGER, decision_condition_id INTEGER, response_set_id INTEGER, regexp CHARACTER VARYING(1000), regexp_error_msg CHARACTER VARYING(255), ordinal INTEGER, required BOOLEAN, default_value CHARACTER VARYING(4000), response_layout CHARACTER VARYING(255), width_decimal CHARACTER VARYING(10), show_item BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_form_metadata', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_group (item_group_id INTEGER, name CHARACTER VARYING(255), crf_id INTEGER, status_id INTEGER, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, oc_oid CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_group', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_group_metadata (item_group_metadata_id INTEGER, item_group_id INTEGER, header CHARACTER VARYING(255), subheader CHARACTER VARYING(255), layout CHARACTER VARYING(100), repeat_number INTEGER, repeat_max INTEGER, repeat_array CHARACTER VARYING(255), row_start_number INTEGER, crf_version_id INTEGER, item_id INTEGER, ordinal INTEGER, borders INTEGER, show_group BOOLEAN, repeating_group BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_group_metadata', updatable 'false');
CREATE FOREIGN TABLE public.ft_item_reference_type (item_reference_type_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'item_reference_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_measurement_unit (id INTEGER, oc_oid CHARACTER VARYING(40), name CHARACTER VARYING(100), description CHARACTER VARYING(255), version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'measurement_unit', updatable 'false');
CREATE FOREIGN TABLE public.ft_null_value_type (null_value_type_id INTEGER, code CHARACTER VARYING(20), name CHARACTER VARYING(255), definition CHARACTER VARYING(1000), reference CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'null_value_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_blob_triggers (trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), blob_data BYTEA)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_blob_triggers', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_calendars (calendar_name CHARACTER VARYING(200), calendar BYTEA)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_calendars', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_cron_triggers (trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), cron_expression CHARACTER VARYING(120), time_zone_id CHARACTER VARYING(80))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_cron_triggers', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_fired_triggers (entry_id CHARACTER VARYING(95), trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), is_volatile BOOLEAN, instance_name CHARACTER VARYING(200), fired_time BIGINT, priority INTEGER, state CHARACTER VARYING(16), job_name CHARACTER VARYING(200), job_group CHARACTER VARYING(200), is_stateful BOOLEAN, requests_recovery BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_fired_triggers', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_job_details (job_name CHARACTER VARYING(200), job_group CHARACTER VARYING(200), description CHARACTER VARYING(250), job_class_name CHARACTER VARYING(250), is_durable BOOLEAN, is_volatile BOOLEAN, is_stateful BOOLEAN, requests_recovery BOOLEAN, job_data BYTEA)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_job_details', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_job_listeners (job_name CHARACTER VARYING(200), job_group CHARACTER VARYING(200), job_listener CHARACTER VARYING(200))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_job_listeners', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_locks (lock_name CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_locks', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_paused_trigger_grps (trigger_group CHARACTER VARYING(200))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_paused_trigger_grps', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_scheduler_state (instance_name CHARACTER VARYING(200), last_checkin_time BIGINT, checkin_interval BIGINT)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_scheduler_state', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_simple_triggers (trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), repeat_count BIGINT, repeat_interval BIGINT, times_triggered BIGINT)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_simple_triggers', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_trigger_listeners (trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), trigger_listener CHARACTER VARYING(200))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_trigger_listeners', updatable 'false');
CREATE FOREIGN TABLE public.ft_oc_qrtz_triggers (trigger_name CHARACTER VARYING(200), trigger_group CHARACTER VARYING(200), job_name CHARACTER VARYING(200), job_group CHARACTER VARYING(200), is_volatile BOOLEAN, description CHARACTER VARYING(250), next_fire_time BIGINT, prev_fire_time BIGINT, priority INTEGER, trigger_state CHARACTER VARYING(16), trigger_type CHARACTER VARYING(8), start_time BIGINT, end_time BIGINT, calendar_name CHARACTER VARYING(200), misfire_instr SMALLINT, job_data BYTEA)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'oc_qrtz_triggers', updatable 'false');
CREATE FOREIGN TABLE public.ft_openclinica_version (id INTEGER, name CHARACTER VARYING(255), build_number CHARACTER VARYING(1000), version INTEGER, update_timestamp TIMESTAMP WITH TIME ZONE)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'openclinica_version', updatable 'false');
CREATE FOREIGN TABLE public.ft_privilege (priv_id INTEGER, priv_name CHARACTER VARYING(50), priv_desc CHARACTER VARYING(2000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'privilege', updatable 'false');
CREATE FOREIGN TABLE public.ft_resolution_status (resolution_status_id INTEGER, name CHARACTER VARYING(50), description CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'resolution_status', updatable 'false');
CREATE FOREIGN TABLE public.ft_response_set (response_set_id INTEGER, response_type_id INTEGER, label CHARACTER VARYING(80), options_text CHARACTER VARYING(4000), options_values CHARACTER VARYING(4000), version_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'response_set', updatable 'false');
CREATE FOREIGN TABLE public.ft_response_type (response_type_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'response_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_role_privilege_map (role_id INTEGER, priv_id INTEGER, priv_value CHARACTER VARYING(50))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'role_privilege_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule (id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(255), oc_oid CHARACTER VARYING(40), enabled BOOLEAN, rule_expression_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, status_id INTEGER, version INTEGER, study_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_action (id INTEGER, rule_set_rule_id INTEGER, action_type INTEGER, expression_evaluates_to BOOLEAN, message CHARACTER VARYING(255), email_to CHARACTER VARYING(255), owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, status_id INTEGER, version INTEGER, rule_action_run_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_action', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_action_property (id INTEGER, rule_action_id INTEGER, oc_oid CHARACTER VARYING(512), value CHARACTER VARYING(512), version INTEGER, rule_expression_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_action_property', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_action_run (id INTEGER, administrative_data_entry BOOLEAN, initial_data_entry BOOLEAN, double_data_entry BOOLEAN, import_data_entry BOOLEAN, batch BOOLEAN, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_action_run', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_action_run_log (id INTEGER, action_type INTEGER, item_data_id INTEGER, value CHARACTER VARYING(4000), rule_oc_oid CHARACTER VARYING(40), version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_action_run_log', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_expression (id INTEGER, value CHARACTER VARYING(1025), context INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, status_id INTEGER, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_expression', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_set (id INTEGER, rule_expression_id INTEGER, study_event_definition_id INTEGER, crf_id INTEGER, crf_version_id INTEGER, study_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, status_id INTEGER, version INTEGER, item_id INTEGER, item_group_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_set', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_set_audit (id INTEGER, rule_set_id INTEGER, date_updated DATE, updater_id INTEGER, status_id INTEGER, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_set_audit', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_set_rule (id INTEGER, rule_set_id INTEGER, rule_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, status_id INTEGER, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_set_rule', updatable 'false');
CREATE FOREIGN TABLE public.ft_rule_set_rule_audit (id INTEGER, rule_set_rule_id INTEGER, date_updated DATE, updater_id INTEGER, status_id INTEGER, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'rule_set_rule_audit', updatable 'false');
CREATE FOREIGN TABLE public.ft_scd_item_metadata (id INTEGER, scd_item_form_metadata_id INTEGER, control_item_form_metadata_id INTEGER, control_item_name CHARACTER VARYING(255), option_value CHARACTER VARYING(500), message CHARACTER VARYING(3000), version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'scd_item_metadata', updatable 'false');
CREATE FOREIGN TABLE public.ft_section (section_id INTEGER, crf_version_id INTEGER, status_id INTEGER, label CHARACTER VARYING(2000), title CHARACTER VARYING(2000), subtitle CHARACTER VARYING(2000), instructions CHARACTER VARYING(2000), page_number_label CHARACTER VARYING(5), ordinal INTEGER, parent_id INTEGER, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, borders INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'section', updatable 'false');
CREATE FOREIGN TABLE public.ft_status (status_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'status', updatable 'false');
CREATE FOREIGN TABLE public.ft_study (study_id INTEGER, parent_study_id INTEGER, unique_identifier CHARACTER VARYING(30), secondary_identifier CHARACTER VARYING(255), name CHARACTER VARYING(255), summary CHARACTER VARYING(255), date_planned_start DATE, date_planned_end DATE, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, type_id INTEGER, status_id INTEGER, principal_investigator CHARACTER VARYING(255), facility_name CHARACTER VARYING(255), facility_city CHARACTER VARYING(255), facility_state CHARACTER VARYING(20), facility_zip CHARACTER VARYING(64), facility_country CHARACTER VARYING(64), facility_recruitment_status CHARACTER VARYING(60), facility_contact_name CHARACTER VARYING(255), facility_contact_degree CHARACTER VARYING(255), facility_contact_phone CHARACTER VARYING(255), facility_contact_email CHARACTER VARYING(255), protocol_type CHARACTER VARYING(30), protocol_description CHARACTER VARYING(1000), protocol_date_verification DATE, phase CHARACTER VARYING(30), expected_total_enrollment INTEGER, sponsor CHARACTER VARYING(255), collaborators CHARACTER VARYING(1000), medline_identifier CHARACTER VARYING(255), url CHARACTER VARYING(255), url_description CHARACTER VARYING(255), conditions CHARACTER VARYING(500), keywords CHARACTER VARYING(255), eligibility CHARACTER VARYING(500), gender CHARACTER VARYING(30), age_max CHARACTER VARYING(3), age_min CHARACTER VARYING(3), healthy_volunteer_accepted BOOLEAN, purpose CHARACTER VARYING(64), allocation CHARACTER VARYING(64), masking CHARACTER VARYING(30), control CHARACTER VARYING(30), assignment CHARACTER VARYING(30), endpoint CHARACTER VARYING(64), interventions CHARACTER VARYING(1000), duration CHARACTER VARYING(30), selection CHARACTER VARYING(30), timing CHARACTER VARYING(30), official_title CHARACTER VARYING(255), results_reference BOOLEAN, oc_oid CHARACTER VARYING(40), old_status_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_event (study_event_id INTEGER, study_event_definition_id INTEGER, study_subject_id INTEGER, location CHARACTER VARYING(2000), sample_ordinal INTEGER, date_start TIMESTAMP WITH TIME ZONE, date_end TIMESTAMP WITH TIME ZONE, owner_id INTEGER, status_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, subject_event_status_id INTEGER, start_time_flag BOOLEAN, end_time_flag BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_event_definition (study_event_definition_id INTEGER, study_id INTEGER, name CHARACTER VARYING(2000), description CHARACTER VARYING(2000), repeating BOOLEAN, type CHARACTER VARYING(20), category CHARACTER VARYING(2000), owner_id INTEGER, status_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, ordinal INTEGER, oc_oid CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_event_definition', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_group (study_group_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000), study_group_class_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_group', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_group_class (study_group_class_id INTEGER, name CHARACTER VARYING(30), study_id INTEGER, owner_id INTEGER, date_created DATE, group_class_type_id INTEGER, status_id INTEGER, date_updated DATE, update_id INTEGER, subject_assignment CHARACTER VARYING(30))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_group_class', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_module_status (id INTEGER, study_id INTEGER, study INTEGER, crf INTEGER, event_definition INTEGER, subject_group INTEGER, rule INTEGER, site INTEGER, users INTEGER, version INTEGER, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, status_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_module_status', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_parameter (study_parameter_id INTEGER, handle CHARACTER VARYING(50), name CHARACTER VARYING(50), description CHARACTER VARYING(255), default_value CHARACTER VARYING(50), inheritable BOOLEAN, overridable BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_parameter', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_parameter_value (study_parameter_value_id INTEGER, study_id INTEGER, value CHARACTER VARYING(50), parameter CHARACTER VARYING(50))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_parameter_value', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_subject (study_subject_id INTEGER, label CHARACTER VARYING(30), secondary_label CHARACTER VARYING(30), subject_id INTEGER, study_id INTEGER, status_id INTEGER, enrollment_date DATE, date_created DATE, date_updated DATE, owner_id INTEGER, update_id INTEGER, oc_oid CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_subject', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_type (study_type_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_study_user_role (role_name CHARACTER VARYING(40), study_id INTEGER, status_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, user_name CHARACTER VARYING(40))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'study_user_role', updatable 'false');
CREATE FOREIGN TABLE public.ft_subject (subject_id INTEGER, father_id INTEGER, mother_id INTEGER, status_id INTEGER, date_of_birth DATE, gender CHARACTER(1), unique_identifier CHARACTER VARYING(255), date_created DATE, owner_id INTEGER, date_updated DATE, update_id INTEGER, dob_collected BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'subject', updatable 'false');
CREATE FOREIGN TABLE public.ft_subject_event_status (subject_event_status_id INTEGER, name CHARACTER VARYING(255), description CHARACTER VARYING(1000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'subject_event_status', updatable 'false');
CREATE FOREIGN TABLE public.ft_subject_group_map (subject_group_map_id INTEGER, study_group_class_id INTEGER, study_subject_id INTEGER, study_group_id INTEGER, status_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, update_id INTEGER, notes CHARACTER VARYING(255))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'subject_group_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_usage_statistics_data (id INTEGER, param_key CHARACTER VARYING(255), param_value CHARACTER VARYING(1000), update_timestamp TIMESTAMP WITH TIME ZONE, version INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'usage_statistics_data', updatable 'false');
CREATE FOREIGN TABLE public.ft_user_account (user_id INTEGER, user_name CHARACTER VARYING(64), passwd CHARACTER VARYING(255), first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), email CHARACTER VARYING(120), active_study INTEGER, institutional_affiliation CHARACTER VARYING(255), status_id INTEGER, owner_id INTEGER, date_created DATE, date_updated DATE, date_lastvisit TIMESTAMP WITH TIME ZONE, passwd_timestamp DATE, passwd_challenge_question CHARACTER VARYING(64), passwd_challenge_answer CHARACTER VARYING(255), phone CHARACTER VARYING(64), user_type_id INTEGER, update_id INTEGER, enabled BOOLEAN, account_non_locked BOOLEAN, lock_counter INTEGER, run_webservices BOOLEAN)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'user_account', updatable 'false');
CREATE FOREIGN TABLE public.ft_user_role (role_id INTEGER, role_name CHARACTER VARYING(50), parent_id INTEGER, role_desc CHARACTER VARYING(2000))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'user_role', updatable 'false');
CREATE FOREIGN TABLE public.ft_user_type (user_type_id INTEGER, user_type CHARACTER VARYING(50))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'user_type', updatable 'false');
CREATE FOREIGN TABLE public.ft_versioning_map (crf_version_id INTEGER, item_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'versioning_map', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_discrepancy_note (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name CHARACTER VARYING, date_start TIMESTAMP WITH TIME ZONE, crf_name CHARACTER VARYING, status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value CHARACTER VARYING, entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_discrepancy_note', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_event_crf (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name CHARACTER VARYING(2000), date_start TIMESTAMP WITH TIME ZONE, crf_name CHARACTER VARYING(255), status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value TEXT, entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_event_crf', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_item_data (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name CHARACTER VARYING(2000), date_start TIMESTAMP WITH TIME ZONE, crf_name CHARACTER VARYING(255), status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value CHARACTER VARYING(4000), entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_item_data', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_stats (discrepancy_note_id INTEGER, days INTEGER, age INTEGER, total_notes BIGINT, date_created DATE, date_updated DATE)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_stats', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_study_event (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name CHARACTER VARYING(2000), date_start TIMESTAMP WITH TIME ZONE, crf_name TEXT, status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value TEXT, entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_study_event', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_study_subject (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name TEXT, date_start DATE, crf_name TEXT, status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value TEXT, entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_study_subject', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_dn_subject (study_id INTEGER, parent_study_id INTEGER, study_hide_crf BOOLEAN, site_hide_crf BOOLEAN, discrepancy_note_id INTEGER, entity_id INTEGER, column_name CHARACTER VARYING(255), study_subject_id INTEGER, label CHARACTER VARYING(30), ss_status_id INTEGER, discrepancy_note_type_id INTEGER, resolution_status_id INTEGER, site_id CHARACTER VARYING(30), date_created DATE, date_updated DATE, days INTEGER, age INTEGER, event_name TEXT, date_start DATE, crf_name TEXT, status_id INTEGER, item_id INTEGER, entity_name CHARACTER VARYING(255), value TEXT, entity_type CHARACTER VARYING(30), description CHARACTER VARYING(255), detailed_notes CHARACTER VARYING(1000), total_notes BIGINT, first_name CHARACTER VARYING(50), last_name CHARACTER VARYING(50), user_name CHARACTER VARYING(64), owner_first_name CHARACTER VARYING(50), owner_last_name CHARACTER VARYING(50), owner_user_name CHARACTER VARYING(64))
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_dn_subject', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_site_hidden_event_definition_crf (event_definition_crf_id INTEGER, hide_crf BOOLEAN, study_id INTEGER, study_event_id INTEGER, crf_version_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_site_hidden_event_definition_crf', updatable 'false');
CREATE FOREIGN TABLE public.ft_view_study_hidden_event_definition_crf (event_definition_crf_id INTEGER, hide_crf BOOLEAN, study_id INTEGER, study_event_id INTEGER, crf_version_id INTEGER)
SERVER :FDWSERVERNAME OPTIONS (schema_name 'public', table_name 'view_study_hidden_event_definition_crf', updatable 'false');
