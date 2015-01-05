/* index to improve performance */
DROP INDEX IF EXISTS i_item_form_metadata_item_id;
CREATE INDEX i_item_form_metadata_item_id
ON item_form_metadata
USING BTREE
(item_id);

DROP INDEX IF EXISTS i_user_account_user_id;
CREATE INDEX i_user_account_user_id
ON user_account
USING BTREE
(user_id);

/* make a new schema for the tables to go in */

DROP SCHEMA IF EXISTS dm CASCADE;
CREATE SCHEMA dm;

/* response sets to rows */

CREATE MATERIALIZED VIEW dm.response_sets AS

  SELECT
    DISTINCT ON (rs_split.response_set_id, rs_split.version_id, rs_split.options_values_split)
    rs_split.response_set_id
    , rs_split.version_id
    , rs.label
    , rs_split.options_values_split
    , replace(
          rs_split.options_text_clean_split,
          $$###@#@#$$,
          $$,$$) item_value_label
    , rt.name
  FROM (
         SELECT
           rs_clean.response_set_id
           , rs_clean.version_id
           , trim(BOTH
                  FROM
                  regexp_split_to_table(
                      rs_clean.options_values,
                      $$,$$))                                                AS options_values_split
           , trim(BOTH
                  FROM
                  regexp_split_to_table(
                      rs_clean.options_text_clean,
                      $$,$$))                                                AS options_text_clean_split
         FROM (
                SELECT
                  rs.response_set_id
                  , rs.version_id
                  , rs.options_values
                  , replace(
                        rs.options_text,
                        $$\,$$,
                        $$###@#@#$$) AS options_text_clean
                FROM response_set AS rs) rs_clean) AS rs_split

    LEFT JOIN response_set AS rs
      ON rs.response_set_id = rs_split.response_set_id
         AND rs.version_id = rs_split.version_id

    INNER JOIN response_type AS rt
      ON rs.response_type_id = rt.response_type_id
         AND rt.name IN ('checkbox', 'radio', 'single-select', 'multi-select');


ANALYZE dm.response_sets;

/* clinicaldata */

CREATE MATERIALIZED VIEW dm.clinicaldata AS

  WITH multi_split AS (
      SELECT
        id.item_data_id
        , regexp_split_to_table(id.value, $$,$$) AS split_value
      FROM item_data AS id
        INNER JOIN event_crf ec
          ON ec.event_crf_id = id.event_crf_id
        INNER JOIN item_form_metadata ifm
          ON ifm.crf_version_id = ec.crf_version_id
             AND ifm.item_id = id.item_id
        INNER JOIN response_set rs
          ON rs.response_set_id = ifm.response_set_id
             AND rs.version_id = ifm.crf_version_id
        INNER JOIN response_type rt
          ON rt.response_type_id = rs.response_type_id
      WHERE id.status_id NOT IN (5, 7)
            AND rt.name IN ('checkbox', 'multi-select')
  ), ec_ale_sdv AS (
      SELECT
        ale.event_crf_id
        , max(ale.audit_date) AS audit_date
      FROM audit_log_event ale
      WHERE ale.event_crf_id IS NOT NULL
            AND ale.audit_log_event_type_id = 32 -- event crf sdv status
      GROUP BY ale.event_crf_id)

  SELECT
      COALESCE(parents.name, study.name, 'no parent study') AS study_name
    , study.oc_oid                                          AS site_oid
    , study.name                                            AS site_name
    , sub.unique_identifier                                 AS subject_person_id
    , ss.oc_oid                                             AS subject_oid
    , ss.label                                              AS subject_id
    , ss.study_subject_id
    , ss.secondary_label                                    AS subject_secondary_label
    , sub.date_of_birth                                     AS subject_date_of_birth
    , sub.gender                                            AS subject_sex
    , sub.subject_id                                        AS subject_id_seq
    , ss.enrollment_date                                    AS subject_enrol_date
    , sub.unique_identifier                                 AS person_id
    , ss.owner_id                                           AS ss_owner_id
    , ss.update_id                                          AS ss_update_id
    , sed.oc_oid                                            AS event_oid
    , sed.ordinal                                           AS event_order
    , sed.name                                              AS event_name
    , se.study_event_id
    , se.sample_ordinal                                     AS event_repeat
    , se.date_start                                         AS event_start
    , se.date_end                                           AS event_end
    , ses.name                                              AS event_status
    , se.owner_id                                           AS se_owner_id
    , se.update_id                                          AS se_update_id
    , crf.oc_oid                                            AS crf_parent_oid
    , crf.name                                              AS crf_parent_name
    , cv.name                                               AS crf_version
    , cv.oc_oid                                             AS crf_version_oid
    , edc.required_crf                                      AS crf_is_required
    , edc.double_entry                                      AS crf_is_double_entry
    , edc.hide_crf                                          AS crf_is_hidden
    , edc.null_values                                       AS crf_null_values
    , edc.status_id                                         AS edc_status_id
    , ec.event_crf_id
    , ec.date_created                                       AS crf_date_created
    , ec.date_updated                                       AS crf_last_update
    , ec.date_completed                                     AS crf_date_completed
    , ec.date_validate                                      AS crf_date_validate
    , ec.date_validate_completed                            AS crf_date_validate_completed
    , ec.owner_id                                           AS ec_owner_id
    , ec.update_id                                          AS ec_update_id
    , CASE
      WHEN ses.subject_event_status_id IN (5, 6, 7) --stopped,skipped,locked
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
        WHEN ec.validator_id <>
             0 --default zero, blank if event_crf created by insertaction
        THEN 'double data entry'
        WHEN ec.validator_id = 0
        THEN 'initial data entry complete'
        ELSE 'unhandled'
        END
      ELSE ec_s.name
      END                                                   AS crf_status
    , ec.validator_id
    , ec.sdv_status                                         AS crf_sdv_status
    , ec_ale_sdv.audit_date                                 AS crf_sdv_status_last_updated
    , ec.sdv_update_id
    , ec.interviewer_name                                   AS crf_interviewer_name
    , ec.date_interviewed                                   AS crf_interview_date
    , sct.label                                             AS crf_section_label
    , sct.title                                             AS crf_section_title
    , ig.oc_oid                                             AS item_group_oid
    , ig.name                                               AS item_group_name
    , id.ordinal                                            AS item_group_repeat
    , ifm.ordinal                                           AS item_form_order
    , ifm.question_number_label                             AS item_question_number
    , CASE
      WHEN response_sets.name IN ('checkbox', 'multi-select') AND id.value <> ''
      THEN concat(i.oc_oid, $$_$$, multi_split.split_value)
      ELSE i.oc_oid
      END                                                   AS item_oid
    , CASE
      WHEN response_sets.name IN ('checkbox', 'multi-select') AND id.value <> ''
      THEN i.oc_oid
      ELSE NULL
      END                                                   AS item_oid_multi_orig
    , i.units                                               AS item_units
    , idt.code                                              AS item_data_type
    , response_sets.name                                    AS item_response_type
    , CASE
      WHEN response_sets.label IN ('text', 'textarea')
      THEN NULL
      ELSE response_sets.label
      END                                                   AS item_response_set_label
    , response_sets.response_set_id                         AS item_response_set_id
    , response_sets.version_id                              AS item_response_set_version
    , CASE
      WHEN response_sets.name IN ('checkbox', 'multi-select') AND id.value <> ''
      THEN concat(i.name, $$_$$, multi_split.split_value)
      ELSE i.name
      END                                                   AS item_name
    , i.description                                         AS item_description
    , CASE
      WHEN response_sets.name IN ('checkbox', 'multi-select')
      THEN multi_split.split_value
      ELSE id.value
      END                                                   AS item_value
    , id.date_created                                       AS item_value_created
    , id.date_updated                                       AS item_value_last_updated
    , id.owner_id                                           AS id_owner_id
    , id.update_id                                          AS id_update_id
    , id.item_data_id
    , response_sets.item_value_label
    , ua_ss_o.user_name                                     AS subject_owned_by_user
    , ua_ss_u.user_name                                     AS subject_last_updated_by_user
    , ua_se_o.user_name                                     AS event_owned_by_user
    , ua_se_u.user_name                                     AS event_last_updated_by_user
    , ua_ec_o.user_name                                     AS crf_owned_by_user
    , ua_ec_u.user_name                                     AS crf_last_updated_by_user
    , ua_ec_v.user_name                                     AS crf_validated_by_user
    , CURRENT_TIMESTAMP                                     AS warehouse_timestamp
    , (CASE
       WHEN ec.sdv_status IS FALSE
       THEN NULL
       WHEN ec.sdv_status IS TRUE
       THEN ua_ec_s.user_name
       ELSE 'unhandled'
       END)                                                 AS crf_sdv_by_user
    , ua_id_o.user_name                                     AS item_value_owned_by_user
    , ua_id_u.user_name                                     AS item_value_last_updated_by_user

  FROM study

    LEFT JOIN (
                SELECT
                  study.*
                FROM study
                WHERE study.status_id NOT IN
                      (5, 7) /*removed, auto-removed*/) AS parents
      ON parents.study_id = study.parent_study_id

    INNER JOIN study_subject AS ss
      ON ss.study_id = study.study_id

    INNER JOIN subject AS sub
      ON sub.subject_id = ss.subject_id

    INNER JOIN study_event AS se
      ON se.study_subject_id = ss.study_subject_id

    INNER JOIN study_event_definition AS sed
      ON sed.study_event_definition_id = se.study_event_definition_id

    INNER JOIN subject_event_status AS ses
      ON ses.subject_event_status_id = se.subject_event_status_id

    INNER JOIN event_definition_crf AS edc
      ON edc.study_event_definition_id = se.study_event_definition_id

    INNER JOIN event_crf AS ec
      ON se.study_event_id = ec.study_event_id
         AND ec.study_subject_id = ss.study_subject_id

    INNER JOIN status AS ec_s
      ON ec.status_id = ec_s.status_id

    LEFT JOIN ec_ale_sdv
      ON ec_ale_sdv.event_crf_id = ec.event_crf_id

    INNER JOIN crf_version AS cv
      ON cv.crf_version_id = ec.crf_version_id
         AND cv.crf_id = edc.crf_id

    INNER JOIN crf
      ON crf.crf_id = cv.crf_id
         AND crf.crf_id = edc.crf_id

    INNER JOIN item_group AS ig
      ON ig.crf_id = crf.crf_id

    INNER JOIN item_group_metadata AS igm
      ON igm.item_group_id = ig.item_group_id
         AND igm.crf_version_id = cv.crf_version_id

    INNER JOIN item_form_metadata AS ifm
      ON cv.crf_version_id = ifm.crf_version_id

    INNER JOIN item AS i
      ON i.item_id = ifm.item_id
         AND i.item_id = igm.item_id

    INNER JOIN item_data_type AS idt
      ON idt.item_data_type_id = i.item_data_type_id

    INNER JOIN response_set AS rs
      ON rs.response_set_id = ifm.response_set_id
         AND rs.version_id = ifm.crf_version_id

    INNER JOIN response_type AS rt
      ON rs.response_type_id = rt.response_type_id

    INNER JOIN "section" AS sct
      ON sct.crf_version_id = cv.crf_version_id
         AND sct.section_id = ifm.section_id

    INNER JOIN item_data AS id
      ON id.item_id = i.item_id
         AND id.event_crf_id = ec.event_crf_id

    LEFT JOIN multi_split
      ON multi_split.item_data_id = id.item_data_id

    LEFT JOIN dm.response_sets
      ON response_sets.response_set_id = rs.response_set_id
         AND response_sets.version_id = rs.version_id
         AND response_sets.options_values_split = id.value
         AND id.value != ''

    LEFT JOIN user_account ua_ss_o
      ON ua_ss_o.user_id = ss.owner_id

    LEFT JOIN user_account ua_ss_u
      ON ua_ss_u.user_id = se.update_id

    LEFT JOIN user_account ua_se_o
      ON ua_se_o.user_id = se.owner_id

    LEFT JOIN user_account ua_se_u
      ON ua_se_u.user_id = se.update_id

    LEFT JOIN user_account ua_ec_o
      ON ua_ec_o.user_id = ec.owner_id

    LEFT JOIN user_account ua_ec_u
      ON ua_ec_u.user_id = ec.update_id

    LEFT JOIN user_account ua_ec_v
      ON ua_ec_v.user_id = ec.validator_id

    LEFT JOIN user_account ua_ec_s
      ON ua_ec_s.user_id = ec.sdv_update_id

    LEFT JOIN user_account ua_id_o
      ON ua_id_o.user_id = id.owner_id

    LEFT JOIN user_account ua_id_u
      ON ua_id_u.user_id = id.update_id

  WHERE
    study.status_id NOT IN (5, 7) --removed, auto-removed
    AND ss.status_id NOT IN (5, 7)
    AND se.status_id NOT IN (5, 7)
    AND ec.status_id NOT IN (5, 7)
    AND sed.status_id NOT IN (5, 7)
    AND edc.status_id NOT IN (5, 7)
    AND cv.status_id NOT IN (5, 7)
    AND crf.status_id NOT IN (5, 7)
    AND ig.status_id NOT IN (5, 7)
    AND i.status_id NOT IN (5, 7)
    AND sct.status_id NOT IN (5, 7)
    AND id.status_id NOT IN (5, 7)
    -- the follow conditions result in study level event definitions
    AND
    CASE WHEN
      CASE WHEN edc.parent_id IS NOT NULL THEN edc.event_definition_crf_id =
                                               (
                                                 SELECT
                                                   max(
                                                       edc_max.event_definition_crf_id) edc_max
                                                 FROM
                                                   public.event_definition_crf AS edc_max
                                                 WHERE
                                                   edc_max.study_event_definition_id
                                                   =
                                                   se.study_event_definition_id
                                                   AND
                                                   edc_max.crf_id = crf.crf_id
                                                 GROUP BY
                                                   edc_max.study_event_definition_id,
                                                   edc_max.crf_id) END
    THEN TRUE
    ELSE
      CASE WHEN edc.parent_id IS NULL AND
                (
                  SELECT
                    count(edc_count.event_definition_crf_id) edc_count
                  FROM public.event_definition_crf AS edc_count
                  WHERE edc_count.study_event_definition_id =
                        se.study_event_definition_id
                        AND edc_count.crf_id = crf.crf_id
                  GROUP BY edc_count.study_event_definition_id,
                    edc_count.crf_id) = 1
      THEN
        edc.event_definition_crf_id =
        (
          SELECT
            min(edc_min.event_definition_crf_id) edc_min
          FROM public.event_definition_crf AS edc_min
          WHERE edc_min.study_event_definition_id = se.study_event_definition_id
                AND edc_min.crf_id = crf.crf_id
          GROUP BY edc_min.study_event_definition_id, edc_min.crf_id)
      END
    END
  ORDER BY item_data_id;

ANALYZE dm.clinicaldata;

CREATE INDEX i_dm_clinicaldata_study_name_item_group_oid
ON dm.clinicaldata
USING BTREE
(study_name, item_group_oid);

ANALYZE dm.clinicaldata;

/* metadata without items for multi values */

CREATE MATERIALIZED VIEW dm.metadata_no_multi AS
  SELECT
    *
  FROM (

         SELECT
             (CASE
              WHEN parents.name IS NOT NULL
              THEN parents.name
              ELSE study.name
              END)                     AS study_name
           , study.oc_oid              AS site_oid
           , study.name                AS site_name
           , sed.oc_oid                AS event_oid
           , sed.ordinal               AS event_order
           , sed.name                  AS event_name
           , sed.repeating             AS event_repeating
           , crf.oc_oid                AS crf_parent_oid
           , crf.name                  AS crf_parent_name
           , cv.name                   AS crf_version
           , cv.oc_oid                 AS crf_version_oid
           , edc.required_crf          AS crf_is_required
           , edc.double_entry          AS crf_is_double_entry
           , edc.hide_crf              AS crf_is_hidden
           , edc.null_values           AS crf_null_values
           , sct.label                 AS crf_section_label
           , sct.title                 AS crf_section_title
           , ig.oc_oid                 AS item_group_oid
           , ig.name                   AS item_group_name
           , ifm.ordinal               AS item_form_order
           , i.oc_oid                  AS item_oid
           , i.units                   AS item_units
           , idt.code                  AS item_data_type
           , rt.name                   AS item_response_type
           , (CASE
              WHEN rs.label IN ('text', 'textarea')
              THEN NULL
              ELSE rs.label
              END)                     AS item_response_set_label
           , rs.response_set_id        AS item_response_set_id
           , rs.version_id             AS item_response_set_version
           , ifm.question_number_label AS item_question_number
           , i.name                    AS item_name
           , i.description             AS item_description

         FROM study

           INNER JOIN study_event_definition AS sed
             ON sed.study_id = study.study_id

           INNER JOIN event_definition_crf AS edc
             ON edc.study_event_definition_id = sed.study_event_definition_id

           INNER JOIN crf_version AS cv
             ON cv.crf_id = edc.crf_id

           INNER JOIN crf
             ON crf.crf_id = cv.crf_id
                AND crf.crf_id = edc.crf_id

           INNER JOIN item_group AS ig
             ON ig.crf_id = crf.crf_id

           INNER JOIN item_group_metadata AS igm
             ON igm.item_group_id = ig.item_group_id
                AND igm.crf_version_id = cv.crf_version_id

           INNER JOIN item_form_metadata AS ifm
             ON cv.crf_version_id = ifm.crf_version_id

           INNER JOIN "section" AS sct
             ON sct.crf_version_id = cv.crf_version_id
                AND sct.section_id = ifm.section_id

           INNER JOIN response_set AS rs
             ON rs.response_set_id = ifm.response_set_id
                AND rs.version_id = ifm.crf_version_id

           INNER JOIN response_type AS rt
             ON rs.response_type_id = rt.response_type_id

           INNER JOIN item AS i
             ON i.item_id = ifm.item_id
                AND i.item_id = igm.item_id

           INNER JOIN item_data_type AS idt
             ON idt.item_data_type_id = i.item_data_type_id

           LEFT JOIN (
                       SELECT
                         study.study_id
                         , study.oc_oid
                         , study.name
                       FROM study) AS parents
             ON parents.study_id = study.parent_study_id

         WHERE edc.parent_id IS NULL
               AND study.status_id NOT IN (5, 7) --removed, auto-removed
               AND sed.status_id NOT IN (5, 7)
               AND edc.status_id NOT IN (5, 7)
               AND cv.status_id NOT IN (5, 7)
               AND crf.status_id NOT IN (5, 7)
               AND ig.status_id NOT IN (5, 7)
               AND i.status_id NOT IN (5, 7)
               AND sct.status_id NOT IN (5, 7)) AS metadata_no_multi_src;

ANALYZE dm.metadata_no_multi;

/* metadata with items for multi values */

CREATE MATERIALIZED VIEW dm.metadata AS
  SELECT
    *
  FROM (
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
           , CAST(metadata_no_multi.crf_section_label AS VARCHAR(255))
           , /* stored as 2000 but isn't */
           metadata_no_multi.crf_section_title
           , metadata_no_multi.item_group_oid
           , metadata_no_multi.item_group_name
           , metadata_no_multi.item_form_order
           , CASE
             WHEN metadata_no_multi.item_response_type NOT IN
                  ('multi-select', 'checkbox')
             THEN metadata_no_multi.item_oid
             WHEN metadata_no_multi.item_response_type IN
                  ('multi-select', 'checkbox')
             THEN mv.item_oid
             ELSE 'unhandled'
             END AS item_oid
           , metadata_no_multi.item_units
           , metadata_no_multi.item_data_type
           , metadata_no_multi.item_response_type
           , metadata_no_multi.item_response_set_label
           , metadata_no_multi.item_response_set_id
           , metadata_no_multi.item_response_set_version
           , metadata_no_multi.item_question_number
           , CASE
             WHEN metadata_no_multi.item_response_type NOT IN
                  ('multi-select', 'checkbox')
             THEN metadata_no_multi.item_name
             WHEN metadata_no_multi.item_response_type IN
                  ('multi-select', 'checkbox')
             THEN mv.item_name
             ELSE 'unhandled'
             END AS item_name
           , metadata_no_multi.item_description
         FROM dm.metadata_no_multi
           LEFT JOIN (SELECT
                          mnm.item_oid                          AS item_oid_orig
                        , mnm.item_oid || '_' ||
                          dm.response_sets.options_values_split AS item_oid
                        , mnm.item_name || '_' ||
                          dm.response_sets.options_values_split AS item_name
                      FROM dm.response_sets
                        LEFT JOIN (
                                    SELECT
                                      DISTINCT ON (dm.metadata_no_multi.item_oid)
                                      dm.metadata_no_multi.item_oid
                                      , dm.metadata_no_multi.item_name
                                      , dm.metadata_no_multi.item_response_set_id
                                      , dm.metadata_no_multi.item_response_set_version
                                    FROM dm.metadata_no_multi
                                    WHERE
                                      dm.metadata_no_multi.item_response_type
                                      IN ('multi-select', 'checkbox')) AS mnm
                          ON mnm.item_response_set_id =
                             dm.response_sets.response_set_id
                             AND mnm.item_response_set_version =
                                 dm.response_sets.version_id
                      UNION ALL
                      SELECT DISTINCT ON (dm.metadata_no_multi.item_oid)
                        dm.metadata_no_multi.item_oid AS item_oid_orig
                        , dm.metadata_no_multi.item_oid
                        , dm.metadata_no_multi.item_name
                      FROM dm.metadata_no_multi
                      WHERE dm.metadata_no_multi.item_response_type IN
                            ('multi-select', 'checkbox')) AS mv
             ON mv.item_oid_orig = metadata_no_multi.item_oid) AS metadata_src;

ANALYZE dm.metadata;

/* metadata, showing event and crf info only */
CREATE MATERIALIZED VIEW metadata_event_crf_ig AS
SELECT DISTINCT ON (study_name, event_oid, crf_version_oid)
  study_name, site_oid, site_name, event_oid, event_order, event_name,
       event_repeating, crf_parent_oid, crf_parent_name, crf_version,
       crf_version_oid, crf_is_required, crf_is_double_entry, crf_is_hidden,
       crf_null_values, crf_section_label, crf_section_title, item_group_oid,
       item_group_name
  FROM dm.metadata;

/* metadata, showing crf and item info only */
CREATE MATERIALIZED VIEW metadata_crf_ig_item AS
SELECT DISTINCT  ON (study_name, crf_version_oid, item_oid)
  study_name, site_oid, site_name, crf_parent_oid, crf_parent_name, crf_version,
       crf_version_oid, crf_is_required, crf_is_double_entry, crf_is_hidden,
       crf_null_values, crf_section_label, crf_section_title, item_group_oid,
       item_group_name, item_form_order, item_oid, item_units, item_data_type,
       item_response_type, item_response_set_label, item_response_set_id,
       item_response_set_version, item_question_number, item_name, item_description
  FROM dm.metadata;

/* distinct subjects */

CREATE MATERIALIZED VIEW dm.subjects AS
  SELECT
    *
  FROM (
         SELECT
           DISTINCT ON (study_name, subject_id)
           cd.study_name
           , cd.site_oid
           , cd.site_name
           , cd.subject_person_id
           , cd.subject_oid
           , cd.subject_id
           , cd.study_subject_id
           , cd.subject_secondary_label
           , cd.subject_date_of_birth
           , cd.subject_sex
           , cd.subject_enrol_date
           , cd.person_id
           , cd.subject_owned_by_user
           , cd.subject_last_updated_by_user
         FROM
           dm.clinicaldata as cd) AS s_src;

ANALYZE dm.subjects;

/* distinct event crfs by subject */

CREATE MATERIALIZED VIEW dm.subject_event_crf_status AS
  SELECT
    *
  FROM (
         SELECT
           DISTINCT ON (study_name, subject_id, event_oid, crf_version_oid)
           cd.study_name
           , cd.site_oid
           , cd.site_name
           , cd.subject_person_id
           , cd.subject_oid
           , cd.subject_id
           , cd.study_subject_id
           , cd.subject_secondary_label
           , cd.subject_date_of_birth
           , cd.subject_sex
           , cd.subject_enrol_date
           , cd.person_id
           , cd.subject_owned_by_user
           , cd.subject_last_updated_by_user
           , cd.event_oid
           , cd.event_order
           , cd.event_name
           , cd.event_repeat
           , cd.event_start
           , cd.event_end
           , cd.event_status
           , cd.event_owned_by_user
           , cd.event_last_updated_by_user
           , cd.crf_parent_oid
           , cd.crf_parent_name
           , cd.crf_version
           , cd.crf_version_oid
           , cd.crf_is_required
           , cd.crf_is_double_entry
           , cd.crf_is_hidden
           , cd.crf_null_values
           , cd.crf_date_created
           , cd.crf_last_update
           , cd.crf_date_completed
           , cd.crf_date_validate
           , cd.crf_date_validate_completed
           , cd.crf_owned_by_user
           , cd.crf_last_updated_by_user
           , cd.crf_status
           , cd.crf_validated_by_user
           , cd.crf_sdv_status
           , cd.crf_sdv_status_last_updated
           , cd.crf_sdv_by_user
           , cd.crf_interviewer_name
           , cd.crf_interview_date
         FROM
           dm.clinicaldata as cd) AS secs_src;

ANALYZE dm.subject_event_crf_status;

/* distinct subjects, event crfs */

CREATE MATERIALIZED VIEW dm.subject_event_crf_expected AS
  SELECT
    *
  FROM (
         SELECT
           s.study_name
           , s.site_oid
           , s.subject_id
           , e.event_oid
           , e.crf_parent_name
         FROM
           (
             SELECT DISTINCT
               clinicaldata.study_name
               , clinicaldata.site_oid
               , clinicaldata.site_name
               , clinicaldata.subject_id
             FROM dm.clinicaldata) AS s, (
                                           SELECT DISTINCT
                                             metadata.study_name
                                             , metadata.event_oid
                                             , metadata.crf_parent_name
                                           FROM dm.metadata) AS e
         WHERE s.study_name = e.study_name) AS sece_src;

ANALYZE dm.subject_event_crf_expected;

/* join subject event crf status with expected */

CREATE MATERIALIZED VIEW dm.subject_event_crf_join AS
  SELECT
    *
  FROM (
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
             END AS event_status
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
           dm.subject_event_crf_expected AS e
           LEFT JOIN
           dm.subject_event_crf_status AS s
             ON
               s.subject_id = e.subject_id
               AND
               s.event_oid = e.event_oid
               AND
               s.crf_parent_name = e.crf_parent_name) AS secj_src;

ANALYZE dm.subject_event_crf_join;

/* discrepancy notes all */

CREATE MATERIALIZED VIEW dm.discrepancy_notes_all2 AS
  SELECT
    dn_src.discrepancy_note_id
    , dn_src.study_name
    , dn_src.site_name
    , dn_src.subject_id
    , dn_src.event_name
    , dn_src.crf_parent_name
    , dn_src.crf_section_label
    , dn_src.item_description
    , dn_src.column_name
    , dn_src.parent_dn_id
    , dn_src.entity_type
    , dn_src.description
    , dn_src.detailed_notes
    , dn_src.date_created
    , dn_src.discrepancy_note_type
    , dn_src.resolution_status
    , dn_src.discrepancy_note_owner
  FROM (
         SELECT DISTINCT ON (sua.discrepancy_note_id)
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
           , CASE
             WHEN dn.discrepancy_note_type_id =
                  1 THEN 'Failed Validation Check' :: TEXT
             WHEN dn.discrepancy_note_type_id = 2 THEN 'Annotation' :: TEXT
             WHEN dn.discrepancy_note_type_id = 3 THEN 'Query' :: TEXT
             WHEN dn.discrepancy_note_type_id =
                  4 THEN 'Reason for Change' :: TEXT
             ELSE 'unhandled' :: TEXT
             END :: CHARACTER VARYING(23) AS discrepancy_note_type
           , rs.name                      AS resolution_status
           , ua.user_name                 AS discrepancy_note_owner
         FROM ((((SELECT
                    didm.discrepancy_note_id
                    , didm.column_name
                    , cd.study_name
                    , cd.site_name
                    , cd.subject_id
                    , cd.event_name
                    , cd.crf_parent_name
                    , cd.crf_section_label
                    , cd.item_description
                  FROM dn_item_data_map didm
                    JOIN dm.clinicaldata cd
                      ON cd.item_data_id = didm.item_data_id
                  UNION ALL
                  SELECT
                    decm.discrepancy_note_id
                    , decm.column_name
                    , cd.study_name
                    , cd.site_name
                    , cd.subject_id
                    , cd.event_name
                    , cd.crf_parent_name
                    , NULL :: CHARACTER VARYING AS crf_section_label
                    , NULL :: CHARACTER VARYING AS item_description
                  FROM dn_event_crf_map decm
                    JOIN dm.clinicaldata cd
                      ON cd.event_crf_id = decm.event_crf_id)
                 UNION ALL
                 SELECT
                   dsem.discrepancy_note_id
                   , dsem.column_name
                   , cd.study_name
                   , cd.site_name
                   , cd.subject_id
                   , cd.event_name
                   , NULL :: CHARACTER VARYING AS crf_parent_name
                   , NULL :: CHARACTER VARYING AS crf_section_label
                   , NULL :: CHARACTER VARYING AS item_description
                 FROM dn_study_event_map dsem
                   JOIN dm.clinicaldata cd
                     ON cd.study_event_id = dsem.study_event_id)
                UNION ALL
                SELECT
                  dssm.discrepancy_note_id
                  , dssm.column_name
                  , cd.study_name
                  , cd.site_name
                  , cd.subject_id
                  , NULL :: CHARACTER VARYING AS event_name
                  , NULL :: CHARACTER VARYING AS crf_parent_name
                  , NULL :: CHARACTER VARYING AS crf_section_label
                  , NULL :: CHARACTER VARYING AS item_description
                FROM dn_study_subject_map dssm
                  JOIN dm.clinicaldata cd
                    ON cd.study_subject_id = dssm.study_subject_id)
               UNION ALL
               SELECT
                 dsm.discrepancy_note_id
                 , dsm.column_name
                 , cd.study_name
                 , cd.site_name
                 , cd.subject_id
                 , NULL :: CHARACTER VARYING AS event_name
                 , NULL :: CHARACTER VARYING AS crf_parent_name
                 , NULL :: CHARACTER VARYING AS crf_section_label
                 , NULL :: CHARACTER VARYING AS item_description
               FROM dn_subject_map dsm
                 JOIN dm.clinicaldata cd
                   ON cd.subject_id_seq = dsm.subject_id) sua
           JOIN discrepancy_note dn
             ON dn.discrepancy_note_id = sua.discrepancy_note_id
           JOIN resolution_status rs
             ON rs.resolution_status_id = dn.resolution_status_id
           JOIN user_account ua
             ON ua.user_id = dn.owner_id) dn_src;


ANALYZE dm.discrepancy_notes_all;

/* discrepancy notes parent */

CREATE MATERIALIZED VIEW dm.discrepancy_notes_parent AS
  SELECT
    *
  FROM (
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
             WHEN sub.resolution_status IN
                  ('New', 'Updated', 'Resolution Proposed')
             THEN CURRENT_DATE - sub.date_created
             ELSE NULL
             END AS days_open
           , CASE WHEN sub.resolution_status IN ('Closed', 'Not Applicable')
         THEN NULL
             WHEN sub.resolution_status IN
                  ('New', 'Updated', 'Resolution Proposed')
             THEN CURRENT_DATE - (
               SELECT
                 max(alldates.date_created)
               FROM
                 (SELECT
                    date_created
                  FROM discrepancy_note AS dn
                  WHERE
                    dn.parent_dn_id = sub.discrepancy_note_id
                  UNION ALL
                  SELECT
                    date_created
                  FROM discrepancy_note AS dn
                  WHERE dn.parent_dn_id = sub.parent_dn_id
                  UNION ALL
                  SELECT
                    date_created
                  FROM discrepancy_note AS dn
                  WHERE dn.discrepancy_note_id =
                        sub.discrepancy_note_id) AS alldates)
             ELSE NULL
             END AS days_since_update
         FROM dm.discrepancy_notes_all AS sub
         WHERE sub.parent_dn_id IS NULL
         GROUP BY
           sub.discrepancy_note_id, sub.study_name, sub.site_name,
           sub.subject_id, sub.event_name, sub.crf_parent_name,
           sub.crf_section_label, sub.item_description, sub.column_name,
           sub.parent_dn_id, sub.entity_type, sub.description,
           sub.detailed_notes, sub.date_created, sub.discrepancy_note_type,
           sub.resolution_status, sub.discrepancy_note_owner) AS dnp_src;

ANALYZE dm.discrepancy_notes_parent;

/* subject groups */

CREATE MATERIALIZED VIEW dm.subject_groups AS
  SELECT
    *
  FROM (

         SELECT
           sub.study_name
           , sub.site_name
           , sub.subject_id
           , gct.name       AS group_class_type
           , sgc.name       AS group_class_name
           , sg.name        AS group_name
           , sg.description AS group_description
         FROM dm.subjects AS sub
           INNER JOIN subject_group_map AS sgm
             ON sgm.study_subject_id = sub.study_subject_id
           LEFT JOIN study_group AS sg
             ON sg.study_group_id = sgm.study_group_id
           LEFT JOIN study_group_class AS sgc
             ON sgc.study_group_class_id = sgm.study_group_class_id
           LEFT JOIN group_class_types AS gct
             ON gct.group_class_type_id = sgc.group_class_type_id) AS sg_src;

ANALYZE dm.subject_groups;

/* response set labels */

CREATE MATERIALIZED VIEW dm.response_set_labels AS
  SELECT
    *
  FROM (

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
         FROM dm.metadata_no_multi AS md
           INNER JOIN dm.response_sets AS rs
             ON rs.version_id = md.item_response_set_version
                AND rs.label = md.item_response_set_label
         ORDER BY
           md.study_name, md.crf_parent_name, md.crf_version, md.item_group_oid,
           md.item_form_order, rs.version_id, rs.label,
           rs.options_values_split) AS rsl_src;

ANALYZE dm.response_set_labels;

/* user accounts and roles */
/* role_name_ui renames internal role names to what is seen in OpenClinica UI
renaming only for roles which are used at Kirby Institute (add others if needed) */

CREATE MATERIALIZED VIEW dm.user_account_roles AS (
  SELECT
    ua.user_name
    , ua.first_name
    , ua.last_name
    , ua.email
    , ua.date_created                                       AS account_created
    , ua.date_updated                                       AS account_last_updated
    , ua_status.name                                        AS account_status
    , COALESCE(
          parents.unique_identifier,
          study.unique_identifier,
          'no parent study')                                AS role_study_code
    , COALESCE(parents.name, study.name, 'no parent study') AS study_name
    , CASE
      WHEN parents.unique_identifier IS NOT NULL
      THEN study.unique_identifier
      END                                                   AS role_site_code
    , CASE
      WHEN parents.name IS NOT NULL
      THEN study.name
      END                                                   AS role_site_name
    , CASE
      WHEN
        parents.name IS NULL
      THEN
        CASE
        WHEN role_name = 'admin'
        THEN 'administrator'
        WHEN role_name = 'coordinator'
        THEN 'study data manager'
        WHEN role_name = 'monitor'
        THEN 'study monitor'
        WHEN role_name = 'ra'
        THEN 'study data entry person'
        ELSE role_name
        END
      WHEN
        parents.name IS NOT NULL
      THEN
        CASE
        WHEN role_name = 'ra'
        THEN 'clinical research coordinator'
        WHEN role_name = 'monitor'
        THEN 'site monitor'
        WHEN role_name = 'Data Specialist'
        THEN 'site investigator'
        ELSE role_name
        END
      END                                                   AS role_name_ui
    , sur.date_created                                      AS role_created
    , sur.date_updated                                      AS role_last_updated
    , sur_status.name                                       AS role_status
  FROM user_account AS ua
    LEFT JOIN study_user_role AS sur
      ON ua.user_name = sur.user_name
    LEFT JOIN study
      ON study.study_id = sur.study_id
    LEFT JOIN study AS parents
      ON parents.study_id = study.parent_study_id
    LEFT JOIN status AS ua_status
      ON ua.status_id = ua_status.status_id
    LEFT JOIN status AS sur_status
      ON sur.status_id = sur_status.status_id)