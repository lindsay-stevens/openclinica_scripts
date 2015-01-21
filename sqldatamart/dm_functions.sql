CREATE OR REPLACE FUNCTION dm_create_ft_catalog()
    RETURNS VOID AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        WITH table_list AS (
                SELECT
                    table_list.table_name,
                    table_list.table_def
                FROM
                    (
                        VALUES
                            (
                                $$pg_attribute$$,
                                $$ attrelid oid,
                                                attname name,
                                                atttypid oid,
                                                attstattarget integer,
                                                attlen smallint,
                                                attnum smallint,
                                                attndims integer,
                                                attcacheoff integer,
                                                atttypmod integer,
                                                attbyval boolean,
                                                attstorage "char",
                                                attalign "char",
                                                attnotnull boolean,
                                                atthasdef boolean,
                                                attisdropped boolean,
                                                attislocal boolean,
                                                attinhcount integer,
                                                attcollation oid,
                                                attacl aclitem[],
                                                attoptions text[],
                                                attfdwoptions text[]$$
                            )
                            ,
                            (
                                $$pg_class$$,
                                $$  "oid" oid,
                                             relname name,
                                             relnamespace oid,
                                             reltype oid,
                                             reloftype oid,
                                             relowner oid,
                                             relam oid,
                                             relfilenode oid,
                                             reltablespace oid,
                                             relpages integer,
                                             reltuples real,
                                             relallvisible integer,
                                             reltoastrelid oid,
                                             reltoastidxid oid,
                                             relhasindex boolean,
                                             relisshared boolean,
                                             relpersistence "char",
                                             relkind "char"$$
                            )
                            ,
                            (
                                $$pg_namespace$$,
                                $$ "oid" oid,
                                                nspname name$$
                            ),
                            (
                                $$pg_indexes$$,
                                $$ schemaname name,
                                              tablename name,
                                              indexname name,
                                              indexdef text $$)

                    ) AS table_list (table_name, table_def)
        )
        SELECT
            format(
                    $$ CREATE FOREIGN TABLE openclinica_fdw.ft_%1$s (%2$s)
                       SERVER openclinica_fdw_server OPTIONS ( schema_name
                       'pg_catalog', table_name %1$L, updatable 'false' ); $$,
                    table_list.table_name,
                    table_list.table_def
            ) AS create_statements
        FROM
            table_list
        LOOP
            EXECUTE r.create_statements;
        END LOOP;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_ft_openclinica(
    foreign_openclinica_schema_name TEXT DEFAULT $$public$$
)
    RETURNS VOID AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        WITH table_list AS (
                SELECT
                    ft_pg_class.relname AS table_name,
                    array_to_string(
                            array_agg(
                                    concat_ws(
                                            $$ $$,
                                            ft_pg_attribute.attname :: TEXT,
                                            format_type(
                                                    ft_pg_attribute.atttypid,
                                                    ft_pg_attribute.atttypmod
                                            )
                                    )
                                    ORDER
                                    BY
                                    ft_pg_attribute.attnum
                            ),
                            $$, $$
                    )                   AS table_def
                FROM
                    ft_pg_attribute
                    LEFT JOIN
                    ft_pg_class
                        ON ft_pg_class.oid = ft_pg_attribute.attrelid
                    LEFT JOIN
                    ft_pg_namespace
                        ON ft_pg_class.relnamespace = ft_pg_namespace.oid
                WHERE
                    ft_pg_namespace.nspname = foreign_openclinica_schema_name
                    AND NOT ft_pg_attribute.attisdropped
                    AND ft_pg_attribute.attnum > 0
                    AND ft_pg_class.relkind IN ($$v$$, $$r$$)
                GROUP BY
                    ft_pg_namespace.nspname
                    ,
                    ft_pg_class.relname
        )
        SELECT
            format(
                    $$ CREATE FOREIGN TABLE openclinica_fdw.ft_%1$s (%2$s)
                       SERVER openclinica_fdw_server OPTIONS (schema_name %3$L,
                       table_name %1$L, updatable 'false'); $$,
                    table_list.table_name,
                    table_list.table_def,
                    foreign_openclinica_schema_name
            ) AS create_statements
        FROM
            table_list
        LOOP
            EXECUTE r.create_statements;
        END LOOP;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_ft_openclinica_matviews()
    RETURNS VOID AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        WITH table_list AS (
                SELECT
                    pg_class.relname AS table_name
                FROM
                    pg_class
                    LEFT JOIN
                    pg_namespace
                        ON pg_class.relnamespace = pg_namespace.oid
                WHERE
                    pg_namespace.nspname = $$openclinica_fdw$$
                    AND pg_class.relkind = $$f$$
                    AND pg_class.relname NOT LIKE $$ft_pg_%$$
        )
        SELECT
            format(
                    $$ CREATE MATERIALIZED VIEW openclinica_fdw.%2$I AS
                       SELECT * FROM openclinica_fdw.%1$I; $$,
                    table_list.table_name,
                    substring(
                            table_list.table_name,
                            4
                    )
            ) AS create_statements
        FROM
            table_list
        LOOP
            EXECUTE r.create_statements;
        END LOOP;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_ft_openclinica_matview_indexes(
    foreign_openclinica_schema_name TEXT DEFAULT $$public$$
)
    RETURNS VOID AS
    $BODY$
    DECLARE
        r RECORD;
        foreign_openclinica_schema_name ALIAS FOR foreign_openclinica_schema_name;
    BEGIN
        FOR r IN
        WITH table_list AS (
                SELECT
                    DISTINCT
                    ft_pg_indexes.indexdef,
                    ft_pg_indexes.indexname
                FROM
                    ft_pg_indexes
                WHERE
                    ft_pg_indexes.schemaname = foreign_openclinica_schema_name
        )
        SELECT
            replace(
                    table_list.indexdef,
                    format(
                            $$ ON %1$s.$$,
                            foreign_openclinica_schema_name
                    ),
                    $$ ON openclinica_fdw.$$
            ) AS create_statements,
            indexname
        FROM
            table_list
        LOOP
            IF NOT EXISTS(
                    SELECT
                        1
                    FROM
                        pg_indexes
                    WHERE
                        pg_indexes.indexname = r.indexname AND
                        pg_indexes.schemaname = $$openclinica_fdw$$
            ) THEN
                EXECUTE r.create_statements;
            END IF;
        END LOOP;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_response_sets()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.response_sets AS
        SELECT
            rs_opt_text.version_id,
            rs_opt_text.response_set_id,
            rs_opt_text.label,
            rs_opt_text.option_text,
            rs_opt_value.option_value,
            rs_opt_text.option_order
        FROM
            (
                SELECT
                    version_id,
                    response_set_id,
                    label,
                    replace(
                            option_text,
                            $$##@##@##$$,
                            $$,$$
                    ) AS option_text,
                    option_order
                FROM
                    (
                        SELECT
                            version_id,
                            response_set_id,
                            label,
                            trim(
                                    BOTH
                                    FROM
                                    (
                                        option_text_array [
                                        option_order
                                        ]
                                    )
                            ) AS option_text,
                            option_order
                        FROM
                            (
                                SELECT
                                    version_id,
                                    response_set_id,
                                    label,
                                    option_text_array,
                                    generate_subscripts(
                                            option_text_array,
                                            1
                                    ) AS option_order
                                FROM
                                    (
                                        SELECT
                                            version_id,
                                            response_set_id,
                                            label,
                                            string_to_array(
                                                    option_text,
                                                    $$,$$
                                            ) AS option_text_array
                                        FROM
                                            (
                                                SELECT
                                                    version_id,
                                                    response_set_id,
                                                    label,
                                                    replace(
                                                            options_text,
                                                            $$\,$$,
                                                            $$##@##@##$$
                                                    ) AS option_text
                                                FROM
                                                    response_set
                                                WHERE
                                                    response_type_id IN
                                                    (
                                                        3, 5, 6, 7
                                                    )
                                            ) AS rs_text_replace
                                    ) AS rs_opt_array
                            ) AS rs_opt_array_rownum
                    ) AS rs_opt_split
            ) AS rs_opt_text
            INNER JOIN
            (
                SELECT
                    version_id,
                    response_set_id,
                    label,
                    trim(
                            BOTH
                            FROM
                            (
                                option_value_array [
                                option_order
                                ]
                            )
                    ) AS option_value,
                    option_order
                FROM
                    (
                        SELECT
                            version_id,
                            response_set_id,
                            label,
                            option_value_array,
                            generate_subscripts(
                                    option_value_array,
                                    1
                            ) AS option_order
                        FROM
                            (
                                SELECT
                                    version_id,
                                    response_set_id,
                                    label,
                                    string_to_array(
                                            options_values,
                                            $$,$$
                                    ) AS option_value_array
                                FROM
                                    response_set
                                WHERE
                                    response_type_id IN (
                                        3, 5, 6, 7
                                    )
                            ) AS rs_opt_array
                    ) AS rs_opt_array_rownum
            ) AS rs_opt_value
                ON rs_opt_text.version_id = rs_opt_value.version_id
                   AND
                   rs_opt_text.response_set_id = rs_opt_value.response_set_id
                   AND rs_opt_text.option_order = rs_opt_value.option_order
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_metadata()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata AS
    WITH metadata_no_multi AS (
            SELECT
                (
                    CASE
                    WHEN parents.name IS NOT NULL
                    THEN parents.name
                    ELSE study.name
                    END
                )                         AS study_name,
                study.oc_oid              AS site_oid,
                study.name                AS site_name,
                sed.oc_oid                AS event_oid,
                sed.ordinal               AS event_order,
                sed.name                  AS event_name,
                sed.repeating             AS event_repeating,
                crf.oc_oid                AS crf_parent_oid,
                crf.name                  AS crf_parent_name,
                cv.name                   AS crf_version,
                cv.oc_oid                 AS crf_version_oid,
                edc.required_crf          AS crf_is_required,
                edc.double_entry          AS crf_is_double_entry,
                edc.hide_crf              AS crf_is_hidden,
                edc.null_values           AS crf_null_values,
                sct.label                 AS crf_section_label,
                sct.title                 AS crf_section_title,
                ig.oc_oid                 AS item_group_oid,
                ig.name                   AS item_group_name,
                ifm.ordinal               AS item_form_order,
                i.oc_oid                  AS item_oid,
                i.units                   AS item_units,
                idt.code                  AS item_data_type,
                rt.name                   AS item_response_type,
                (
                    CASE
                    WHEN rs.label IN (
                        'text',
                        'textarea'
                    )
                    THEN NULL
                    ELSE rs.label
                    END
                )                         AS item_response_set_label,
                rs.response_set_id        AS item_response_set_id,
                rs.version_id             AS item_response_set_version,
                ifm.question_number_label AS item_question_number,
                i.name                    AS item_name,
                i.description             AS item_description,
                ifm.header                AS item_header,
                ifm.subheader             AS item_subheader,
                ifm.left_item_text        AS item_left_item_text,
                ifm.right_item_text       AS item_right_item_text,
                ifm.regexp                AS item_regexp,
                ifm.regexp_error_msg      AS item_regexp_error_msg,
                ifm.required              AS item_required,
                ifm.default_value         AS item_default_value,
                ifm.response_layout       AS item_response_layout,
                ifm.width_decimal         AS item_width_decimal,
                ifm.show_item             AS item_show_item,
                sim.item_oid              AS item_scd_control_item_oid,
                sim.option_value          AS item_scd_control_item_option_value,
                sim.option_text           AS item_scd_control_item_option_text,
                sim.message               AS item_scd_validation_message
            FROM
                openclinica_fdw.study

                INNER JOIN
                openclinica_fdw.study_event_definition AS sed
                    ON sed.study_id = study.study_id

                INNER JOIN
                openclinica_fdw.event_definition_crf AS edc
                    ON edc.study_event_definition_id =
                       sed.study_event_definition_id

                INNER JOIN
                openclinica_fdw.crf_version AS cv
                    ON cv.crf_id = edc.crf_id

                INNER JOIN
                openclinica_fdw.crf
                    ON crf.crf_id = cv.crf_id
                       AND crf.crf_id = edc.crf_id

                INNER JOIN
                openclinica_fdw.item_group AS ig
                    ON ig.crf_id = crf.crf_id

                INNER JOIN
                openclinica_fdw.item_group_metadata AS igm
                    ON igm.item_group_id = ig.item_group_id
                       AND igm.crf_version_id = cv.crf_version_id

                INNER JOIN
                openclinica_fdw.item_form_metadata AS ifm
                    ON cv.crf_version_id = ifm.crf_version_id

                INNER JOIN
                openclinica_fdw."section" AS sct
                    ON sct.crf_version_id = cv.crf_version_id
                       AND sct.section_id = ifm.section_id

                INNER JOIN
                openclinica_fdw.response_set AS rs
                    ON rs.response_set_id = ifm.response_set_id
                       AND rs.version_id = ifm.crf_version_id

                INNER JOIN
                openclinica_fdw.response_type AS rt
                    ON rs.response_type_id = rt.response_type_id

                INNER JOIN
                openclinica_fdw.item AS i
                    ON i.item_id = ifm.item_id
                       AND i.item_id = igm.item_id

                INNER JOIN
                openclinica_fdw.item_data_type AS idt
                    ON idt.item_data_type_id = i.item_data_type_id

                LEFT JOIN
                (
                    SELECT
                        study.study_id,
                        study.oc_oid,
                        study.name
                    FROM
                        openclinica_fdw.study
                ) AS parents
                    ON parents.study_id = study.parent_study_id

                LEFT JOIN
                (
                    SELECT
                        sim.scd_item_form_metadata_id,
                        sim.control_item_form_metadata_id,
                        sim.message,
                        i.oc_oid AS item_oid,
                        i.status_id,
                        sim.option_value,
                        response_sets.option_text
                    FROM
                        openclinica_fdw.scd_item_metadata AS sim
                        INNER JOIN
                        openclinica_fdw.item_form_metadata AS ifm
                            ON ifm.item_form_metadata_id =
                               sim.control_item_form_metadata_id
                        INNER JOIN
                        openclinica_fdw.item AS i
                            ON ifm.item_id = i.item_id
                        LEFT JOIN
                        dm.response_sets
                            ON ifm.response_set_id =
                               response_sets.response_set_id
                               AND ifm.crf_version_id = response_sets.version_id
                               AND
                               sim.option_value = response_sets.option_value) AS
                sim
                    ON ifm.item_form_metadata_id = sim.scd_item_form_metadata_id
            WHERE
                edc.parent_id IS NULL
                AND study.status_id NOT IN (5, 7) --removed, auto-removed
                AND sed.status_id NOT IN (5, 7)
                AND edc.status_id NOT IN (5, 7)
                AND cv.status_id NOT IN (5, 7)
                AND crf.status_id NOT IN (5, 7)
                AND ig.status_id NOT IN (5, 7)
                AND i.status_id NOT IN (5, 7)
                AND sct.status_id NOT IN (5, 7)
    )

SELECT
    metadata_no_multi.study_name,
    metadata_no_multi.site_oid,
    metadata_no_multi.site_name,
    metadata_no_multi.event_oid,
    metadata_no_multi.event_order,
    metadata_no_multi.event_name,
    metadata_no_multi.event_repeating,
    metadata_no_multi.crf_parent_oid,
    metadata_no_multi.crf_parent_name,
    metadata_no_multi.crf_version,
    metadata_no_multi.crf_version_oid,
    metadata_no_multi.crf_is_required,
    metadata_no_multi.crf_is_double_entry,
    metadata_no_multi.crf_is_hidden,
    metadata_no_multi.crf_null_values,
    CAST(
            metadata_no_multi.crf_section_label
            AS
            VARCHAR(255)
    ) AS crf_section_label,
    metadata_no_multi.crf_section_title,
    metadata_no_multi.item_group_oid,
    metadata_no_multi.item_group_name,
    metadata_no_multi.item_form_order,
    (
        CASE
        WHEN metadata_no_multi.item_response_type NOT IN
             (
                 'multi-select',
                 'checkbox'
             )
        THEN metadata_no_multi.item_oid
        WHEN metadata_no_multi.item_response_type IN
             (
                 'multi-select',
                 'checkbox'
             )
        THEN mv.item_oid
        ELSE 'unhandled'
        END
    ) AS item_oid,
    (
        CASE
        WHEN metadata_no_multi.item_response_type NOT IN
             (
                 'multi-select',
                 'checkbox'
             )
        THEN metadata_no_multi.item_name
        WHEN metadata_no_multi.item_response_type IN
             (
                 'multi-select',
                 'checkbox'
             )
        THEN mv.item_name
        ELSE 'unhandled'
        END
    ) AS item_name,
    mv.item_oid_multi_original,
    mv.item_name_multi_original,
    metadata_no_multi.item_units,
    metadata_no_multi.item_data_type,
    metadata_no_multi.item_response_type,
    metadata_no_multi.item_response_set_label,
    metadata_no_multi.item_response_set_id,
    metadata_no_multi.item_response_set_version,
    metadata_no_multi.item_question_number,
    metadata_no_multi.item_description,
    metadata_no_multi.item_header,
    metadata_no_multi.item_subheader,
    metadata_no_multi.item_left_item_text,
    metadata_no_multi.item_right_item_text,
    metadata_no_multi.item_regexp,
    metadata_no_multi.item_regexp_error_msg,
    metadata_no_multi.item_required,
    metadata_no_multi.item_default_value,
    metadata_no_multi.item_response_layout,
    metadata_no_multi.item_width_decimal,
    metadata_no_multi.item_show_item,
    metadata_no_multi.item_scd_control_item_oid,
    metadata_no_multi.item_scd_control_item_option_value,
    metadata_no_multi.item_scd_control_item_option_text,
    metadata_no_multi.item_scd_validation_message
FROM
    metadata_no_multi
    LEFT JOIN
    (
        SELECT
            mnm.item_oid  AS item_oid_multi_original,
            mnm.item_name AS item_name_multi_original,
            format(
                    $$%1$s_%2$s$$,
                    mnm.item_oid,
                    response_sets.option_value
            )             AS item_oid,
            format(
                    $$%1$s_%2$s$$,
                    mnm.item_name,
                    response_sets.option_value
            )             AS item_name
        FROM
            dm.response_sets
            LEFT JOIN
            (
                SELECT
                    DISTINCT ON (metadata_no_multi.item_oid)
                    metadata_no_multi.item_oid,
                    metadata_no_multi.item_name,
                    metadata_no_multi.item_response_set_id,
                    metadata_no_multi.item_response_set_version
                FROM
                    metadata_no_multi
                WHERE
                    metadata_no_multi.item_response_type
                    IN (
                        'multi-select',
                        'checkbox'
                    )
            ) AS mnm
                ON mnm.item_response_set_id =
                   response_sets.response_set_id
                   AND mnm.item_response_set_version =
                       response_sets.version_id
        UNION ALL
        SELECT
            DISTINCT ON (metadata_no_multi.item_oid)
            metadata_no_multi.item_oid  AS item_oid_multi_original,
            metadata_no_multi.item_name AS item_name_multi_original,
            metadata_no_multi.item_oid,
            metadata_no_multi.item_name
        FROM
            metadata_no_multi
        WHERE
            metadata_no_multi.item_response_type IN
            (
                'multi-select',
                'checkbox'
            )
    ) AS mv
        ON mv.item_oid_multi_original = metadata_no_multi.item_oid
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_metadata_event_crf_ig()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata_event_crf_ig AS
        SELECT
            DISTINCT ON (study_name, event_oid, crf_version_oid)
            study_name
            ,
            site_oid
            ,
            site_name
            ,
            event_oid
            ,
            event_order
            ,
            event_name
            ,
            event_repeating
            ,
            crf_parent_oid
            ,
            crf_parent_name
            ,
            crf_version
            ,
            crf_version_oid
            ,
            crf_is_required
            ,
            crf_is_double_entry
            ,
            crf_is_hidden
            ,
            crf_null_values
            ,
            crf_section_label
            ,
            crf_section_title
            ,
            item_group_oid
            ,
            item_group_name
        FROM
            dm.metadata;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_metadata_crf_ig_item()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata_crf_ig_item AS
        SELECT
            DISTINCT ON (study_name, crf_version_oid, item_oid)
            study_name,
            site_oid,
            site_name,
            crf_parent_oid,
            crf_parent_name,
            crf_version,
            crf_version_oid,
            crf_section_label,
            crf_section_title,
            item_group_oid,
            item_group_name,
            item_form_order,
            item_oid,
            item_name,
            item_oid_multi_original,
            item_name_multi_original,
            item_units,
            item_data_type,
            item_response_type,
            item_response_set_label,
            item_response_set_id,
            item_response_set_version,
            item_question_number,
            item_description,
            item_header,
            item_subheader,
            item_left_item_text,
            item_right_item_text,
            item_regexp,
            item_regexp_error_msg,
            item_required,
            item_default_value,
            item_response_layout,
            item_width_decimal,
            item_show_item,
            item_scd_control_item_oid,
            item_scd_control_item_option_value,
            item_scd_control_item_option_text,
            item_scd_validation_message
        FROM
            dm.metadata;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_clinicaldata()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.clinicaldata AS
        WITH multi_split AS (
                SELECT
                    id.item_data_id
                    ,
                    regexp_split_to_table(
                            id.value,
                            $$,$$) AS split_value
                FROM
                    openclinica_fdw.item_data AS id
                    INNER JOIN
                    openclinica_fdw.event_crf AS ec
                        ON ec.event_crf_id = id.event_crf_id
                    INNER JOIN
                    openclinica_fdw.item_form_metadata AS ifm
                        ON ifm.crf_version_id = ec.crf_version_id
                           AND ifm.item_id = id.item_id
                    INNER JOIN
                    openclinica_fdw.response_set AS rs
                        ON rs.response_set_id = ifm.response_set_id
                           AND rs.version_id = ifm.crf_version_id
                    INNER JOIN
                    openclinica_fdw.response_type AS rt
                        ON rt.response_type_id = rs.response_type_id
                WHERE
                    id.status_id NOT IN (5, 7)
                    AND rt.name IN ('checkbox', 'multi-select')
        ), ec_ale_sdv AS (
                SELECT
                    ale.event_crf_id
                    ,
                    max(
                            ale.audit_date) AS audit_date
                FROM
                    openclinica_fdw.audit_log_event AS ale
                WHERE
                    ale.event_crf_id IS NOT NULL
                    AND ale.audit_log_event_type_id = 32 -- event crf sdv status
                GROUP BY
                    ale.event_crf_id
        )
        SELECT
            COALESCE(
                    parents.name,
                    study.name,
                    'no parent study')    AS study_name
            ,
            study.oc_oid                  AS site_oid
            ,
            study.name                    AS site_name
            ,
            sub.unique_identifier         AS subject_person_id
            ,
            ss.oc_oid                     AS subject_oid
            ,
            ss.label                      AS subject_id
            ,
            ss.study_subject_id
            ,
            ss.secondary_label            AS subject_secondary_label
            ,
            sub.date_of_birth             AS subject_date_of_birth
            ,
            sub.gender                    AS subject_sex
            ,
            sub.subject_id                AS subject_id_seq
            ,
            ss.enrollment_date            AS subject_enrol_date
            ,
            sub.unique_identifier         AS person_id
            ,
            ss.owner_id                   AS ss_owner_id
            ,
            ss.update_id                  AS ss_update_id
            ,
            sed.oc_oid                    AS event_oid
            ,
            sed.ordinal                   AS event_order
            ,
            sed.name                      AS event_name
            ,
            se.study_event_id
            ,
            se.sample_ordinal             AS event_repeat
            ,
            se.date_start                 AS event_start
            ,
            se.date_end                   AS event_end
            ,
            ses.name                      AS event_status
            ,
            se.owner_id                   AS se_owner_id
            ,
            se.update_id                  AS se_update_id
            ,
            crf.oc_oid                    AS crf_parent_oid
            ,
            crf.name                      AS crf_parent_name
            ,
            cv.name                       AS crf_version
            ,
            cv.oc_oid                     AS crf_version_oid
            ,
            edc.required_crf              AS crf_is_required
            ,
            edc.double_entry              AS crf_is_double_entry
            ,
            edc.hide_crf                  AS crf_is_hidden
            ,
            edc.null_values               AS crf_null_values
            ,
            edc.status_id                 AS edc_status_id
            ,
            ec.event_crf_id
            ,
            ec.date_created               AS crf_date_created
            ,
            ec.date_updated               AS crf_last_update
            ,
            ec.date_completed             AS crf_date_completed
            ,
            ec.date_validate              AS crf_date_validate
            ,
            ec.date_validate_completed    AS crf_date_validate_completed
            ,
            ec.owner_id                   AS ec_owner_id
            ,
            ec.update_id                  AS ec_update_id
            ,
            CASE
            WHEN ses.subject_event_status_id IN
                 (5, 6, 7) --stopped,skipped,locked
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
            END                           AS crf_status
            ,
            ec.validator_id
            ,
            ec.sdv_status                 AS crf_sdv_status
            ,
            ec_ale_sdv.audit_date         AS crf_sdv_status_last_updated
            ,
            ec.sdv_update_id
            ,
            ec.interviewer_name           AS crf_interviewer_name
            ,
            ec.date_interviewed           AS crf_interview_date
            ,
            sct.label                     AS crf_section_label
            ,
            sct.title                     AS crf_section_title
            ,
            ig.oc_oid                     AS item_group_oid
            ,
            ig.name                       AS item_group_name
            ,
            id.ordinal                    AS item_group_repeat
            ,
            ifm.ordinal                   AS item_form_order
            ,
            ifm.question_number_label     AS item_question_number
            ,
            CASE
            WHEN rt.name IN ('checkbox', 'multi-select') AND
                 id.value <> ''
            THEN concat(
                    i.oc_oid,
                    $$_$$,
                    multi_split.split_value)
            ELSE i.oc_oid
            END                           AS item_oid
            ,
            CASE
            WHEN rt.name IN ('checkbox', 'multi-select') AND
                 id.value <> ''
            THEN i.oc_oid
            ELSE NULL
            END                           AS item_oid_multi_orig
            ,
            i.units                       AS item_units
            ,
            idt.code                      AS item_data_type
            ,
            rt.name            AS item_response_type
            ,
            CASE
            WHEN response_sets.label IN ('text', 'textarea')
            THEN NULL
            ELSE response_sets.label
            END                           AS item_response_set_label
            ,
            response_sets.response_set_id AS item_response_set_id
            ,
            response_sets.version_id      AS item_response_set_version
            ,
            CASE
            WHEN rt.name IN ('checkbox', 'multi-select') AND
                 id.value <> ''
            THEN concat(
                    i.name,
                    $$_$$,
                    multi_split.split_value)
            ELSE i.name
            END                           AS item_name
            ,
            i.description                 AS item_description
            ,
            CASE
            WHEN rt.name IN ('checkbox', 'multi-select')
            THEN multi_split.split_value
            ELSE id.value
            END                           AS item_value
            ,
            id.date_created               AS item_value_created
            ,
            id.date_updated               AS item_value_last_updated
            ,
            id.owner_id                   AS id_owner_id
            ,
            id.update_id                  AS id_update_id
            ,
            id.item_data_id
            ,
            response_sets.option_text
            ,
            ua_ss_o.user_name             AS subject_owned_by_user
            ,
            ua_ss_u.user_name             AS subject_last_updated_by_user
            ,
            ua_se_o.user_name             AS event_owned_by_user
            ,
            ua_se_u.user_name             AS event_last_updated_by_user
            ,
            ua_ec_o.user_name             AS crf_owned_by_user
            ,
            ua_ec_u.user_name             AS crf_last_updated_by_user
            ,
            ua_ec_v.user_name             AS crf_validated_by_user
            ,
            CURRENT_TIMESTAMP             AS warehouse_timestamp
            ,
            (CASE
             WHEN ec.sdv_status IS FALSE
             THEN NULL
             WHEN ec.sdv_status IS TRUE
             THEN ua_ec_s.user_name
             ELSE 'unhandled'
             END)                         AS crf_sdv_by_user
            ,
            ua_id_o.user_name             AS item_value_owned_by_user
            ,
            ua_id_u.user_name             AS item_value_last_updated_by_user

        FROM
            openclinica_fdw.study

            LEFT JOIN
            (
                SELECT
                    study.*
                FROM
                    openclinica_fdw.study
                WHERE
                    study.status_id NOT IN
                    (5, 7) /*removed, auto-removed*/) AS parents
                ON parents.study_id = study.parent_study_id

            INNER JOIN
            openclinica_fdw.study_subject AS ss
                ON ss.study_id = study.study_id

            INNER JOIN
            openclinica_fdw.subject AS sub
                ON sub.subject_id = ss.subject_id

            INNER JOIN
            openclinica_fdw.study_event AS se
                ON se.study_subject_id = ss.study_subject_id

            INNER JOIN
            openclinica_fdw.study_event_definition AS sed
                ON sed.study_event_definition_id = se.study_event_definition_id

            INNER JOIN
            openclinica_fdw.subject_event_status AS ses
                ON ses.subject_event_status_id = se.subject_event_status_id

            INNER JOIN
            openclinica_fdw.event_definition_crf AS edc
                ON edc.study_event_definition_id = se.study_event_definition_id

            INNER JOIN
            openclinica_fdw.event_crf AS ec
                ON se.study_event_id = ec.study_event_id
                   AND ec.study_subject_id = ss.study_subject_id

            INNER JOIN
            openclinica_fdw.status AS ec_s
                ON ec.status_id = ec_s.status_id

            LEFT JOIN
            ec_ale_sdv
                ON ec_ale_sdv.event_crf_id = ec.event_crf_id

            INNER JOIN
            openclinica_fdw.crf_version AS cv
                ON cv.crf_version_id = ec.crf_version_id
                   AND cv.crf_id = edc.crf_id

            INNER JOIN
            openclinica_fdw.crf
                ON crf.crf_id = cv.crf_id
                   AND crf.crf_id = edc.crf_id

            INNER JOIN
            openclinica_fdw.item_group AS ig
                ON ig.crf_id = crf.crf_id

            INNER JOIN
            openclinica_fdw.item_group_metadata AS igm
                ON igm.item_group_id = ig.item_group_id
                   AND igm.crf_version_id = cv.crf_version_id

            INNER JOIN
            openclinica_fdw.item_form_metadata AS ifm
                ON cv.crf_version_id = ifm.crf_version_id

            INNER JOIN
            openclinica_fdw.item AS i
                ON i.item_id = ifm.item_id
                   AND i.item_id = igm.item_id

            INNER JOIN
            openclinica_fdw.item_data_type AS idt
                ON idt.item_data_type_id = i.item_data_type_id

            INNER JOIN
            openclinica_fdw.response_set AS rs
                ON rs.response_set_id = ifm.response_set_id
                   AND rs.version_id = ifm.crf_version_id

            INNER JOIN
            openclinica_fdw.response_type AS rt
                ON rs.response_type_id = rt.response_type_id

            INNER JOIN
            openclinica_fdw."section" AS sct
                ON sct.crf_version_id = cv.crf_version_id
                   AND sct.section_id = ifm.section_id

            INNER JOIN
            openclinica_fdw.item_data AS id
                ON id.item_id = i.item_id
                   AND id.event_crf_id = ec.event_crf_id

            LEFT JOIN
            multi_split
                ON multi_split.item_data_id = id.item_data_id

            LEFT JOIN
            dm.response_sets
                ON response_sets.response_set_id = rs.response_set_id
                   AND response_sets.version_id = rs.version_id
                   AND (response_sets.option_value = id.value OR
                        response_sets.option_value =
                        multi_split.split_value)
                   AND id.value != ''

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ss_o
                ON ua_ss_o.user_id = ss.owner_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ss_u
                ON ua_ss_u.user_id = se.update_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_se_o
                ON ua_se_o.user_id = se.owner_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_se_u
                ON ua_se_u.user_id = se.update_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ec_o
                ON ua_ec_o.user_id = ec.owner_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ec_u
                ON ua_ec_u.user_id = ec.update_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ec_v
                ON ua_ec_v.user_id = ec.validator_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_ec_s
                ON ua_ec_s.user_id = ec.sdv_update_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_id_o
                ON ua_id_o.user_id = id.owner_id

            LEFT JOIN
            openclinica_fdw.user_account AS ua_id_u
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
                CASE WHEN edc.parent_id IS NOT NULL THEN
                    edc.event_definition_crf_id =
                    (
                        SELECT
                            max(
                                    edc_max.event_definition_crf_id) edc_max
                        FROM
                            openclinica_fdw.event_definition_crf AS edc_max
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
                                  count(
                                          edc_count.event_definition_crf_id) edc_count
                              FROM
                                  openclinica_fdw.event_definition_crf AS edc_count
                              WHERE
                                  edc_count.study_event_definition_id =
                                  se.study_event_definition_id
                                  AND edc_count.crf_id = crf.crf_id
                              GROUP BY
                                  edc_count.study_event_definition_id,
                                  edc_count.crf_id) = 1
                THEN
                    edc.event_definition_crf_id =
                    (
                        SELECT
                            min(
                                    edc_min.event_definition_crf_id) edc_min
                        FROM
                            openclinica_fdw.event_definition_crf AS edc_min
                        WHERE
                            edc_min.study_event_definition_id =
                            se.study_event_definition_id
                            AND edc_min.crf_id = crf.crf_id
                        GROUP BY
                            edc_min.study_event_definition_id,
                            edc_min.crf_id)
                END
            END;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_subjects()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subjects AS
        SELECT
            DISTINCT ON (study_name, subject_id)
            cd.study_name
            ,
            cd.site_oid
            ,
            cd.site_name
            ,
            cd.subject_person_id
            ,
            cd.subject_oid
            ,
            cd.subject_id
            ,
            cd.study_subject_id
            ,
            cd.subject_secondary_label
            ,
            cd.subject_date_of_birth
            ,
            cd.subject_sex
            ,
            cd.subject_enrol_date
            ,
            cd.person_id
            ,
            cd.subject_owned_by_user
            ,
            cd.subject_last_updated_by_user
        FROM
            dm.clinicaldata AS cd;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_subject_event_crf_status()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_status AS
        SELECT
            DISTINCT ON (study_name, subject_id, event_oid, crf_version_oid)
            cd.study_name
            ,
            cd.site_oid
            ,
            cd.site_name
            ,
            cd.subject_person_id
            ,
            cd.subject_oid
            ,
            cd.subject_id
            ,
            cd.study_subject_id
            ,
            cd.subject_secondary_label
            ,
            cd.subject_date_of_birth
            ,
            cd.subject_sex
            ,
            cd.subject_enrol_date
            ,
            cd.person_id
            ,
            cd.subject_owned_by_user
            ,
            cd.subject_last_updated_by_user
            ,
            cd.event_oid
            ,
            cd.event_order
            ,
            cd.event_name
            ,
            cd.event_repeat
            ,
            cd.event_start
            ,
            cd.event_end
            ,
            cd.event_status
            ,
            cd.event_owned_by_user
            ,
            cd.event_last_updated_by_user
            ,
            cd.crf_parent_oid
            ,
            cd.crf_parent_name
            ,
            cd.crf_version
            ,
            cd.crf_version_oid
            ,
            cd.crf_is_required
            ,
            cd.crf_is_double_entry
            ,
            cd.crf_is_hidden
            ,
            cd.crf_null_values
            ,
            cd.crf_date_created
            ,
            cd.crf_last_update
            ,
            cd.crf_date_completed
            ,
            cd.crf_date_validate
            ,
            cd.crf_date_validate_completed
            ,
            cd.crf_owned_by_user
            ,
            cd.crf_last_updated_by_user
            ,
            cd.crf_status
            ,
            cd.crf_validated_by_user
            ,
            cd.crf_sdv_status
            ,
            cd.crf_sdv_status_last_updated
            ,
            cd.crf_sdv_by_user
            ,
            cd.crf_interviewer_name
            ,
            cd.crf_interview_date
        FROM
            dm.clinicaldata AS cd;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_subject_event_crf_expected()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_expected AS
        SELECT
            s.study_name
            ,
            s.site_oid
            ,
            s.subject_id
            ,
            e.event_oid
            ,
            e.crf_parent_name
        FROM
            (
                SELECT
                    DISTINCT
                    clinicaldata.study_name
                    ,
                    clinicaldata.site_oid
                    ,
                    clinicaldata.site_name
                    ,
                    clinicaldata.subject_id
                FROM
                    dm.clinicaldata
            ) AS s,
            (
                SELECT
                    DISTINCT
                    metadata.study_name
                    ,
                    metadata.event_oid
                    ,
                    metadata.crf_parent_name
                FROM
                    dm.metadata
            ) AS e
        WHERE
            s.study_name = e.study_name
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_subject_event_crf_join()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_join AS
        SELECT
            e.study_name
            ,
            e.site_oid
            ,
            s.site_name
            ,
            s.subject_person_id
            ,
            s.subject_oid
            ,
            e.subject_id
            ,
            s.study_subject_id
            ,
            s.subject_secondary_label
            ,
            s.subject_date_of_birth
            ,
            s.subject_sex
            ,
            s.subject_enrol_date
            ,
            s.person_id
            ,
            s.subject_owned_by_user
            ,
            s.subject_last_updated_by_user
            ,
            e.event_oid
            ,
            s.event_order
            ,
            s.event_name
            ,
            s.event_repeat
            ,
            s.event_start
            ,
            s.event_end
            ,
            CASE WHEN s.event_status IS NOT NULL
            THEN s.event_status
            ELSE $$not scheduled$$
            END AS event_status
            ,
            s.event_owned_by_user
            ,
            s.event_last_updated_by_user
            ,
            s.crf_parent_oid
            ,
            e.crf_parent_name
            ,
            s.crf_version
            ,
            s.crf_version_oid
            ,
            s.crf_is_required
            ,
            s.crf_is_double_entry
            ,
            s.crf_is_hidden
            ,
            s.crf_null_values
            ,
            s.crf_date_created
            ,
            s.crf_last_update
            ,
            s.crf_date_completed
            ,
            s.crf_date_validate
            ,
            s.crf_date_validate_completed
            ,
            s.crf_owned_by_user
            ,
            s.crf_last_updated_by_user
            ,
            s.crf_status
            ,
            s.crf_validated_by_user
            ,
            s.crf_sdv_status
            ,
            s.crf_sdv_status_last_updated
            ,
            s.crf_sdv_by_user
            ,
            s.crf_interviewer_name
            ,
            s.crf_interview_date
        FROM
            dm.subject_event_crf_expected AS e
            LEFT JOIN
            dm.subject_event_crf_status AS s
                ON
                    s.subject_id = e.subject_id
                    AND
                    s.event_oid = e.event_oid
                    AND
                    s.crf_parent_name = e.crf_parent_name
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_discrepancy_notes_all()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.discrepancy_notes_all AS
        SELECT
            dn_src.discrepancy_note_id
            ,
            dn_src.study_name
            ,
            dn_src.site_name
            ,
            dn_src.subject_id
            ,
            dn_src.event_name
            ,
            dn_src.crf_parent_name
            ,
            dn_src.crf_section_label
            ,
            dn_src.item_description
            ,
            dn_src.column_name
            ,
            dn_src.parent_dn_id
            ,
            dn_src.entity_type
            ,
            dn_src.description
            ,
            dn_src.detailed_notes
            ,
            dn_src.date_created
            ,
            dn_src.discrepancy_note_type
            ,
            dn_src.resolution_status
            ,
            dn_src.discrepancy_note_owner
        FROM
            (
                SELECT
                    DISTINCT ON (sua.discrepancy_note_id)
                    sua.discrepancy_note_id
                    ,
                    sua.study_name
                    ,
                    sua.site_name
                    ,
                    sua.subject_id
                    ,
                    sua.event_name
                    ,
                    sua.crf_parent_name
                    ,
                    sua.crf_section_label
                    ,
                    sua.item_description
                    ,
                    sua.column_name
                    ,
                    dn.parent_dn_id
                    ,
                    dn.entity_type
                    ,
                    dn.description
                    ,
                    dn.detailed_notes
                    ,
                    dn.date_created
                    ,
                    CASE
                    WHEN dn.discrepancy_note_type_id =
                         1 THEN $$Failed Validation Check$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id =
                         2 THEN $$Annotation$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id = 3 THEN $$Query$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id =
                         4 THEN $$'Reason for Change$$ :: TEXT
                    ELSE 'unhandled' :: TEXT
                    END :: CHARACTER VARYING(23) AS discrepancy_note_type
                    ,
                    rs.name                      AS resolution_status
                    ,
                    ua.user_name                 AS discrepancy_note_owner
                FROM
                    (
                        (
                            (
                                (
                                    SELECT
                                        didm.discrepancy_note_id
                                        ,
                                        didm.column_name
                                        ,
                                        cd.study_name
                                        ,
                                        cd.site_name
                                        ,
                                        cd.subject_id
                                        ,
                                        cd.event_name
                                        ,
                                        cd.crf_parent_name
                                        ,
                                        cd.crf_section_label
                                        ,
                                        cd.item_description
                                    FROM
                                        openclinica_fdw.dn_item_data_map AS didm
                                        JOIN
                                        dm.clinicaldata AS cd
                                            ON cd.item_data_id =
                                               didm.item_data_id
                                    UNION ALL
                                    SELECT
                                        decm.discrepancy_note_id
                                        ,
                                        decm.column_name
                                        ,
                                        cd.study_name
                                        ,
                                        cd.site_name
                                        ,
                                        cd.subject_id
                                        ,
                                        cd.event_name
                                        ,
                                        cd.crf_parent_name
                                        ,
                                        NULL :: CHARACTER VARYING AS crf_section_label
                                        ,
                                        NULL :: CHARACTER VARYING AS item_description
                                    FROM
                                        openclinica_fdw.dn_event_crf_map AS decm
                                        JOIN
                                        dm.clinicaldata AS cd
                                            ON cd.event_crf_id =
                                               decm.event_crf_id
                                )
                                UNION ALL
                                SELECT
                                    dsem.discrepancy_note_id
                                    ,
                                    dsem.column_name
                                    ,
                                    cd.study_name
                                    ,
                                    cd.site_name
                                    ,
                                    cd.subject_id
                                    ,
                                    cd.event_name
                                    ,
                                    NULL :: CHARACTER VARYING AS crf_parent_name
                                    ,
                                    NULL :: CHARACTER VARYING AS crf_section_label
                                    ,
                                    NULL :: CHARACTER VARYING AS item_description
                                FROM
                                    openclinica_fdw.dn_study_event_map AS dsem
                                    JOIN
                                    dm.clinicaldata AS cd
                                        ON cd.study_event_id =
                                           dsem.study_event_id
                            )
                            UNION ALL
                            SELECT
                                dssm.discrepancy_note_id
                                ,
                                dssm.column_name
                                ,
                                cd.study_name
                                ,
                                cd.site_name
                                ,
                                cd.subject_id
                                ,
                                NULL :: CHARACTER VARYING AS event_name
                                ,
                                NULL :: CHARACTER VARYING AS crf_parent_name
                                ,
                                NULL :: CHARACTER VARYING AS crf_section_label
                                ,
                                NULL :: CHARACTER VARYING AS item_description
                            FROM
                                openclinica_fdw.dn_study_subject_map AS dssm
                                JOIN
                                dm.clinicaldata AS cd
                                    ON cd.study_subject_id =
                                       dssm.study_subject_id
                        )
                        UNION ALL
                        SELECT
                            dsm.discrepancy_note_id
                            ,
                            dsm.column_name
                            ,
                            cd.study_name
                            ,
                            cd.site_name
                            ,
                            cd.subject_id
                            ,
                            NULL :: CHARACTER VARYING AS event_name
                            ,
                            NULL :: CHARACTER VARYING AS crf_parent_name
                            ,
                            NULL :: CHARACTER VARYING AS crf_section_label
                            ,
                            NULL :: CHARACTER VARYING AS item_description
                        FROM
                            openclinica_fdw.dn_subject_map AS dsm
                            JOIN
                            dm.clinicaldata AS cd
                                ON cd.subject_id_seq = dsm.subject_id
                    ) AS sua
                    JOIN
                    openclinica_fdw.discrepancy_note AS dn
                        ON dn.discrepancy_note_id = sua.discrepancy_note_id
                    JOIN
                    openclinica_fdw.resolution_status AS rs
                        ON rs.resolution_status_id = dn.resolution_status_id
                    JOIN
                    openclinica_fdw.user_account AS ua
                        ON ua.user_id = dn.owner_id
            ) AS dn_src;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_discrepancy_notes_parent()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.discrepancy_notes_parent AS
        SELECT
            sub.discrepancy_note_id
            ,
            sub.study_name
            ,
            sub.site_name
            ,
            sub.subject_id
            ,
            sub.event_name
            ,
            sub.crf_parent_name
            ,
            sub.crf_section_label
            ,
            sub.item_description
            ,
            sub.column_name
            ,
            sub.parent_dn_id
            ,
            sub.entity_type
            ,
            sub.description
            ,
            sub.detailed_notes
            ,
            sub.date_created
            ,
            sub.discrepancy_note_type
            ,
            sub.resolution_status
            ,
            sub.discrepancy_note_owner
            ,
            CASE WHEN sub.resolution_status IN ($$Closed$$, $$Not Applicable$$)
            THEN NULL
            WHEN sub.resolution_status IN
                 ($$New$$, $$Updated$$, $$Resolution Proposed$$)
            THEN CURRENT_DATE - sub.date_created
            ELSE NULL
            END AS days_open
            ,
            CASE WHEN sub.resolution_status IN ($$Closed$$, $$Not Applicable$$)
            THEN NULL
            WHEN sub.resolution_status IN
                 ($$New$$, $$Updated$$, $$Resolution Proposed$$)
            THEN CURRENT_DATE - (
                SELECT
                    max(
                            all_dates.date_created
                    )
                FROM
                    (SELECT
                         date_created
                     FROM
                         openclinica_fdw.discrepancy_note AS dn
                     WHERE
                         dn.parent_dn_id = sub.discrepancy_note_id
                     UNION ALL
                     SELECT
                         date_created
                     FROM
                         openclinica_fdw.discrepancy_note AS dn
                     WHERE
                         dn.parent_dn_id = sub.parent_dn_id
                     UNION ALL
                     SELECT
                         date_created
                     FROM
                         openclinica_fdw.discrepancy_note AS dn
                     WHERE
                         dn.discrepancy_note_id =
                         sub.discrepancy_note_id
                    ) AS all_dates
            )
            ELSE NULL
            END AS days_since_update
        FROM
            dm.discrepancy_notes_all AS sub
        WHERE
            sub.parent_dn_id IS NULL
        GROUP BY
            sub.discrepancy_note_id,
            sub.study_name,
            sub.site_name,
            sub.subject_id,
            sub.event_name,
            sub.crf_parent_name,
            sub.crf_section_label,
            sub.item_description,
            sub.column_name,
            sub.parent_dn_id,
            sub.entity_type,
            sub.description,
            sub.detailed_notes,
            sub.date_created,
            sub.discrepancy_note_type,
            sub.resolution_status,
            sub.discrepancy_note_owner;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_subject_groups()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_groups AS
        SELECT
            sub.study_name
            ,
            sub.site_name
            ,
            sub.subject_id
            ,
            gct.name       AS group_class_type
            ,
            sgc.name       AS group_class_name
            ,
            sg.name        AS group_name
            ,
            sg.description AS group_description
        FROM
            dm.subjects AS sub
            INNER JOIN
            openclinica_fdw.subject_group_map AS sgm
                ON sgm.study_subject_id = sub.study_subject_id
            LEFT JOIN
            openclinica_fdw.study_group AS sg
                ON sg.study_group_id = sgm.study_group_id
            LEFT JOIN
            openclinica_fdw.study_group_class AS sgc
                ON sgc.study_group_class_id = sgm.study_group_class_id
            LEFT JOIN
            openclinica_fdw.group_class_types AS gct
                ON gct.group_class_type_id = sgc.group_class_type_id;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_response_set_labels()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.response_set_labels AS
        SELECT
            DISTINCT
            md.study_name
            ,
            md.crf_parent_name
            ,
            md.crf_version
            ,
            md.item_group_oid
            ,
            md.item_group_name
            ,
            md.item_form_order
            ,
            md.item_oid
            ,
            md.item_name
            ,
            md.item_description
            ,
            rs.version_id
            ,
            rs.label
            ,
            rs.option_value
            ,
            rs.option_text
            ,
            rs.option_order
        FROM
            dm.metadata AS md
            INNER JOIN
            dm.response_sets AS rs
                ON rs.version_id = md.item_response_set_version
                   AND rs.label = md.item_response_set_label
        ORDER BY
            md.study_name,
            md.crf_parent_name,
            md.crf_version,
            md.item_group_oid,
            md.item_form_order,
            rs.version_id,
            rs.label,
            rs.option_value;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_user_account_roles()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.user_account_roles AS
        SELECT
            ua.user_name
            ,
            ua.first_name
            ,
            ua.last_name
            ,
            ua.email
            ,
            ua.date_created              AS account_created
            ,
            ua.date_updated              AS account_last_updated
            ,
            ua_status.name               AS account_status
            ,
            COALESCE(
                    parents.unique_identifier,
                    study.unique_identifier,
                    $$no parent study$$) AS role_study_code
            ,
            COALESCE(
                    parents.name,
                    study.name,
                    $$no parent study$$) AS study_name
            ,
            CASE
            WHEN parents.unique_identifier IS NOT NULL
            THEN study.unique_identifier
            END                          AS role_site_code
            ,
            CASE
            WHEN parents.name IS NOT NULL
            THEN study.name
            END                          AS role_site_name
            ,
            CASE
            WHEN
                parents.name IS NULL
            THEN
                CASE
                WHEN role_name = $$admin$$
                THEN $$administrator$$
                WHEN role_name = $$coordinator$$
                THEN $$study data manager$$
                WHEN role_name = $$monitor$$
                THEN $$study monitor$$
                WHEN role_name = $$ra$$
                THEN $$study data entry person$$
                ELSE role_name
                END
            WHEN
                parents.name IS NOT NULL
            THEN
                CASE
                WHEN role_name = $$ra$$
                THEN $$clinical research coordinator$$
                WHEN role_name = $$monitor$$
                THEN $$site monitor$$
                WHEN role_name = $$Data Specialist$$
                THEN $$site investigator$$
                ELSE role_name
                END
            END                          AS role_name_ui
            ,
            sur.date_created             AS role_created
            ,
            sur.date_updated             AS role_last_updated
            ,
            sur_status.name              AS role_status
        FROM
            openclinica_fdw.user_account AS ua
            LEFT JOIN
            openclinica_fdw.study_user_role AS sur
                ON ua.user_name = sur.user_name
            LEFT JOIN
            openclinica_fdw.study
                ON study.study_id = sur.study_id
            LEFT JOIN
            openclinica_fdw.study AS parents
                ON parents.study_id = study.parent_study_id
            LEFT JOIN
            openclinica_fdw.status AS ua_status
                ON ua.status_id = ua_status.status_id
            LEFT JOIN
            openclinica_fdw.status AS sur_status
                ON sur.status_id = sur_status.status_id
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_dm_sdv_status()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.sdv_status AS
        SELECT
            secs.study_name
            ,
            secs.subject_id
            ,
            secs.event_name
            ,
            secs.event_repeat
            ,
            secs.event_status
            ,
            secs.crf_parent_name
            ,
            secs.crf_status
            ,
            pale.new_value  AS audit_sdv_status
            ,
            pua.user_name   AS audit_sdv_user
            ,
            pale.audit_date AS audit_sdv_timestamp
            ,
            CASE
            WHEN pale.audit_date IS NULL
            THEN NULL
            ELSE CASE
                 WHEN secs.crf_sdv_status_last_updated = pale.audit_date
                 THEN 'current'
                 WHEN secs.crf_sdv_status_last_updated <> pale.audit_date
                 THEN 'history'
                 END
            END             AS audit_sdv_current_or_history
        FROM
            (
                SELECT
                    DISTINCT ON (study_name, subject_id, event_oid, crf_version_oid)
                    cd.study_name
                    ,
                    cd.site_oid
                    ,
                    cd.site_name
                    ,
                    cd.subject_person_id
                    ,
                    cd.subject_oid
                    ,
                    cd.subject_id
                    ,
                    cd.study_subject_id
                    ,
                    cd.subject_secondary_label
                    ,
                    cd.subject_date_of_birth
                    ,
                    cd.subject_sex
                    ,
                    cd.subject_enrol_date
                    ,
                    cd.person_id
                    ,
                    cd.subject_owned_by_user
                    ,
                    cd.subject_last_updated_by_user
                    ,
                    cd.event_oid
                    ,
                    cd.event_order
                    ,
                    cd.event_name
                    ,
                    cd.event_repeat
                    ,
                    cd.event_start
                    ,
                    cd.event_end
                    ,
                    cd.event_status
                    ,
                    cd.event_owned_by_user
                    ,
                    cd.event_last_updated_by_user
                    ,
                    cd.event_crf_id
                    ,
                    cd.crf_parent_oid
                    ,
                    cd.crf_parent_name
                    ,
                    cd.crf_version
                    ,
                    cd.crf_version_oid
                    ,
                    cd.crf_is_required
                    ,
                    cd.crf_is_double_entry
                    ,
                    cd.crf_is_hidden
                    ,
                    cd.crf_null_values
                    ,
                    cd.crf_date_created
                    ,
                    cd.crf_last_update
                    ,
                    cd.crf_date_completed
                    ,
                    cd.crf_date_validate
                    ,
                    cd.crf_date_validate_completed
                    ,
                    cd.crf_owned_by_user
                    ,
                    cd.crf_last_updated_by_user
                    ,
                    cd.crf_status
                    ,
                    cd.crf_validated_by_user
                    ,
                    cd.crf_sdv_status
                    ,
                    cd.crf_sdv_status_last_updated
                    ,
                    cd.crf_sdv_by_user
                    ,
                    cd.crf_interviewer_name
                    ,
                    cd.crf_interview_date
                FROM
                    dm.clinicaldata AS cd
            ) AS secs

            LEFT JOIN
            (
                SELECT
                    *
                FROM
                    openclinica_fdw.audit_log_event
                WHERE
                    audit_log_event_type_id = 32
            ) AS pale
                ON pale.event_crf_id = secs.event_crf_id

            LEFT JOIN
            openclinica_fdw.user_account AS pua
                ON pale.user_id = pua.user_id

        ORDER BY
            secs.study_name
            ,
            secs.subject_id
            ,
            secs.event_name
            ,
            secs.event_repeat
            ,
            secs.crf_parent_name
            ,
            pale.audit_date DESC
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_study_schemas(
    filter_study_name TEXT DEFAULT $$$$,
    create_or_drop    TEXT DEFAULT $$create$$
)
    RETURNS TEXT AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        SELECT
            format(
                    $$CREATE SCHEMA %1$I;$$,
                    sub.study_name
            ) AS create_statement,
            format(
                    $$DROP SCHEMA %1$I CASCADE;$$,
                    sub.study_name
            ) AS drop_statement,
            sub.study_name
        FROM
            (
                SELECT
                    DISTINCT ON (metadata.study_name)
                    dm_clean_name_string(
                            metadata.study_name
                    ) AS study_name
                FROM
                    dm.metadata
                WHERE
                    metadata.study_name ~ (
                        CASE
                        WHEN length(
                                     filter_study_name
                             ) > 0
                        THEN filter_study_name
                        ELSE $$.+$$ END
                    )
            ) AS sub
        LOOP
            IF create_or_drop = $$create$$ THEN
                EXECUTE r.create_statement;
            ELSIF create_or_drop = $$drop$$ THEN
                EXECUTE r.drop_statement;
            END IF;
        END LOOP;
        RETURN $$done$$;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_study_common_matviews(
    filter_study_name TEXT DEFAULT $$$$)
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        WITH table_list AS (
                SELECT
                    pg_matviews.matviewname AS table_name
                FROM
                    pg_catalog.pg_matviews
                WHERE
                    pg_matviews.schemaname = $$dm$$
                    AND pg_matviews.matviewname != $$response_sets$$
        )
        SELECT
            format(
                    $$ %1$s %2$s $$,
                    format(
                            $$ CREATE MATERIALIZED VIEW %1$I.%2$I AS
                       SELECT * FROM dm.%2$I WHERE %2$I.study_name=%3$L;$$,
                            study_name,
                            table_list.table_name,
                            study_name_raw
                    ),
                    (
                        CASE
                        WHEN table_list.table_name = $$clinicaldata$$
                        THEN
                            format(
                                    $$ CREATE INDEX i_%1$s_clinicaldata_item_group_oid
                           ON %1$I.clinicaldata
                           USING btree(item_group_oid);$$,
                                    study_name
                            )
                        END
                    )
            )
                AS
                create_statement,
            sub.study_name
        FROM
            (
                SELECT
                    DISTINCT ON (study_name)
                    dm_clean_name_string(
                            metadata.study_name
                    )          AS study_name,
                    study_name AS study_name_raw
                FROM
                    dm.metadata
                WHERE
                    metadata.study_name ~ (
                        CASE
                        WHEN length(
                                     filter_study_name
                             ) > 0
                        THEN filter_study_name
                        ELSE $$.+$$ END
                    )
            )
                AS
            sub,
            table_list
        LOOP
            EXECUTE r.create_statement;
        END LOOP;
        RETURN $$done$$;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_study_itemgroup_matviews(
    alias_views          BOOLEAN DEFAULT FALSE,
    filter_study_name    TEXT DEFAULT $$$$,
    filter_itemgroup_oid TEXT DEFAULT $$$$
)
    RETURNS TEXT AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        SELECT
            format(
                    $$CREATE %1$s VIEW %2$I.%3$I AS SELECT study_name,
                     site_oid, site_name, subject_id, event_oid, event_name,
                     event_order, event_repeat, crf_parent_name, crf_version,
                     crf_status, item_group_oid, item_group_repeat, %4$s %5$s $$,
                    (
                        CASE
                        WHEN alias_views
                        THEN $$$$
                        ELSE $$MATERIALIZED$$
                        END
                    ),
                    dm_clean_name_string(
                            ddl.study_name
                    ),
                    (
                        CASE
                        WHEN alias_views
                        THEN concat(
                                $$av_$$,
                                ddl.item_group_oid
                        )
                        ELSE ddl.item_group_oid
                        END
                    ),
                    array_to_string(
                            array_agg(
                                    (
                                        CASE
                                        WHEN alias_views
                                        THEN ddl.item_ddl_av
                                        ELSE ddl.item_ddl
                                        END
                                    )
                            ),
                            $$,$$
                    ),
                    (
                        CASE
                        WHEN alias_views
                        THEN ddl.ig_ddl_av
                        ELSE ddl.ig_ddl
                        END
                    )
            ) AS create_statement
        FROM
            (
                SELECT
                    format(
                            $$ %1$s %2$s $$
                            ,
                            format
                            (
                                    $$ max(case when item_oid=%1$L
                                      then (case when item_value = '' then null
                                      when item_value IN (%2$s)
                                      then null else cast(item_value as %3$s
                                      ) end) else null end) as %4$I $$,
                                    met.item_oid,
                                    CASE
                                    WHEN met.crf_null_values = ''
                                    THEN $$''$$
                                    ELSE met.crf_null_values
                                    END,
                                    CASE
                                    WHEN
                                        item_data_type
                                        IN
                                        ($$ST$$, $$PDATE$$, $$FILE$$)
                                    THEN $$text$$
                                    WHEN
                                        item_data_type
                                        IN
                                        ($$INT$$, $$REAL$$)
                                    THEN $$numeric$$
                                    ELSE item_data_type
                                    END,
                                    met.item_name_hint
                            )
                            ,
                            (
                                CASE
                                WHEN met.item_response_set_label IS NULL
                                THEN NULL
                                ELSE format(
                                        $$ , max(case when item_oid=%1$L
                                          then (case when item_value = ''
                                          then null when item_value IN (%2$s)
                                          then null else option_text end)
                                          else null end) as %3$s_label$$,
                                        met.item_oid,
                                        CASE
                                        WHEN met.crf_null_values = ''
                                        THEN $$''$$
                                        ELSE met.crf_null_values
                                        END,
                                        met.item_name_hint
                                )
                                END
                            )
                    ) AS item_ddl,
                    format(
                            $$ FROM %1$I.clinicaldata WHERE
                                      item_group_oid=%2$L GROUP BY study_name,
                                      site_oid, site_name, subject_id, event_oid,
                                      event_name, event_order, event_repeat,
                                      crf_parent_name, crf_version, crf_status,
                                      item_group_oid, item_group_repeat;$$,
                            dm_clean_name_string(
                                    met.study_name
                            ),
                            upper(
                                    met.item_group_oid
                            )
                    ) AS ig_ddl,
                    item_group_oid,
                    study_name,
                    format(
                            $$ %1$s %2$s $$
                            ,
                            format(
                                    $$ %1$s AS %2$s $$,
                                    met.item_name_hint,
                                    met.item_name
                            )
                            ,
                            (
                                CASE
                                WHEN met.item_response_set_label IS NULL
                                THEN NULL
                                ELSE format(
                                        $$ , %1$s_label AS %2$s_label $$,
                                        met.item_name_hint,
                                        met.item_name
                                )
                                END
                            )
                    ) AS item_ddl_av,
                    format(
                            $$ FROM %1$I.%2$I;$$,
                            dm_clean_name_string(
                                    met.study_name
                            ),
                            met.item_group_oid
                    ) AS ig_ddl_av,
                    item_form_order
                FROM
                    (
                        SELECT
                            study_name,
                            lower(
                                    item_group_oid
                            ) AS item_group_oid,
                            item_oid,
                            lower(
                                    item_name
                            ) AS item_name,
                            lower(
                                    CASE
                                    WHEN length(
                                                 item_name_hint
                                         ) > 57
                                    THEN substr(
                                            item_name_hint,
                                            1,
                                            57
                                    )
                                    ELSE item_name_hint
                                    END
                            ) AS item_name_hint,
                            item_data_type,
                            max(
                                    item_form_order
                            ) AS item_form_order,
                            max(
                                    item_response_set_label
                            ) AS item_response_set_label,
                            crf_null_values
                        FROM
                            (
                                SELECT
                                    study_name,
                                    item_group_oid,
                                    item_oid,
                                    item_name,
                                    (
                                        CASE WHEN (
                                            SELECT
                                                (
                                                    (
                                                        max(
                                                                length(
                                                                        metadata.item_name
                                                                )
                                                        )
                                                    ) > 12
                                                    OR (
                                                           max(
                                                                   CASE WHEN
                                                                       metadata.item_name
                                                                       ~
                                                                       $reg$^[0-9].+$$reg$ THEN length(
                                                                               metadata.item_name) END)
                                                       ) > 0
                                                ) AS use_item_oid
                                            FROM
                                                dm.metadata
                                            WHERE
                                                dm_meta.study_name
                                                =
                                                metadata.study_name
                                        )
                                        THEN item_oid
                                        ELSE
                                            lower(
                                                    FORMAT(
                                                            $$%1$s_%2$s$$,
                                                            substr(
                                                                    dm_clean_name_string(
                                                                            dm_meta.item_name),
                                                                    1,
                                                                    12

                                                            ),
                                                            substr(
                                                                    dm_clean_name_string(
                                                                            dm_meta.item_description),
                                                                    1,
                                                                    45
                                                            )
                                                    )
                                            )
                                        END
                                    ) AS item_name_hint,
                                    item_data_type,
                                    max(
                                            item_form_order
                                    ) AS item_form_order,
                                    item_response_set_label,
                                    dm_itemgroup_crf_null_values_list(
                                            dm_meta.study_name,
                                            dm_meta.item_group_oid
                                    ) AS crf_null_values
                                FROM
                                    dm.metadata AS dm_meta
                                WHERE
                                    dm_meta.study_name ~ (
                                        CASE
                                        WHEN length(
                                                     filter_study_name
                                             ) > 0
                                        THEN filter_study_name
                                        ELSE $$.+$$ END
                                    )
                                    AND
                                    dm_meta.item_group_oid ~ (
                                        CASE
                                        WHEN length(
                                                     filter_itemgroup_oid
                                             ) > 0
                                        THEN filter_itemgroup_oid
                                        ELSE $$.+$$ END
                                    )
                                GROUP BY
                                    study_name,
                                    item_group_oid,
                                    item_oid,
                                    item_name,
                                    item_description,
                                    item_data_type,
                                    item_response_set_label
                            ) AS namecheck
                        GROUP BY
                            study_name,
                            item_group_oid,
                            item_oid,
                            item_name,
                            item_name_hint,
                            item_data_type,
                            crf_null_values
                    ) AS met
                ORDER BY
                    study_name,
                    item_group_oid,
                    item_form_order,
                    item_oid
            ) AS ddl
        GROUP BY
            ddl.study_name,
            ddl.item_group_oid,
            ddl.ig_ddl,
            ddl.ig_ddl_av
        LOOP
            EXECUTE r.create_statement;
        END LOOP;
        RETURN $$done$$;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_create_study_role(
    filter_study_name TEXT DEFAULT $$$$
)
    RETURNS TEXT AS
    $BODY$
    DECLARE
        r              RECORD;
        study_username VARCHAR;
        study_name     VARCHAR;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT ON (metadata.study_name)
            dm_clean_name_string(
                    metadata.study_name
            ) AS study_name
        FROM
            dm.metadata
        WHERE
            metadata.study_name ~ (
                CASE
                WHEN length(
                             filter_study_name
                     ) > 0
                THEN filter_study_name
                ELSE $$.+$$
                END
            )
        LOOP
            study_name = r.study_name;
            study_username = format(
                    $$dm_study_%1$s$$,
                    r.study_name
            );
            IF NOT EXISTS(
                    SELECT
                        *
                    FROM
                        pg_catalog.pg_roles
                    WHERE
                        pg_roles.rolname = study_username
            ) THEN
                EXECUTE format(
                        $$CREATE ROLE %1$I NOLOGIN;$$,
                        study_username
                );
            END IF;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_grant_study_schema_access_to_study_role(
    filter_study_name TEXT DEFAULT $$$$
)
    RETURNS TEXT AS
    $BODY$
    DECLARE
        r              RECORD;
        study_username VARCHAR;
        study_name     VARCHAR;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT ON (metadata.study_name)
            dm_clean_name_string(
                    metadata.study_name
            ) AS study_name
        FROM
            dm.metadata
        WHERE
            metadata.study_name ~ (
                CASE
                WHEN length(
                             filter_study_name
                     ) > 0
                THEN filter_study_name
                ELSE $$.+$$
                END
            )
        LOOP
            study_name = r.study_name;
            study_username = format(
                    $$dm_study_%1$s$$,
                    r.study_name
            );
            EXECUTE format(
                    $$GRANT USAGE ON SCHEMA %1$I TO %2$I;$$,
                    study_name,
                    study_username
            );
            EXECUTE format(
                    $$GRANT SELECT ON ALL TABLES IN SCHEMA %1$I TO %2$I;$$,
                    study_name,
                    study_username
            );
            EXECUTE format(
                    $$ALTER DEFAULT PRIVILEGES IN SCHEMA %1$I GRANT SELECT ON TABLES TO %2$I;$$,
                    study_name,
                    study_username
            );
            EXECUTE format(
                    $$GRANT %1$I TO dm_admin;$$,
                    study_username
            );
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION dm_clean_name_string(
    name_string TEXT
)
    RETURNS TEXT AS
    $BODY$
    SELECT
        lower(
                regexp_replace(
                        regexp_replace(
                                name_string,
                                $$[^\w\s]$$,
                                $$$$,
                                $$g$$
                        ),
                        $$[\s]$$,
                        $$_$$,
                        $$g$$
                )
        ) AS cleaned_name_string;
    $BODY$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION dm_itemgroup_crf_null_values_list(
    IN  filter_study_name    TEXT,
    IN  filter_itemgroup_oid TEXT,
    OUT crf_null_values_list TEXT
)
    RETURNS TEXT AS
    $BODY$
    DECLARE crf_null_sql         TEXT;
            crf_null_result      TEXT;
            crf_null_result_text TEXT;
    BEGIN
        crf_null_sql := format(
                $query$
    SELECT
        trim(
                BOTH
                ','
                FROM
                (array_to_string(
                        array_agg(
                                quote_literal(
                                        trim(
                                                BOTH
                                                ','
                                                FROM
                                                (
                                                    sub.crf_null_values
                                                )
                                        )

                                )
                        ),
                        $$,$$
                ))
        ) AS crf_null_values_list
    FROM
        (
            SELECT
                DISTINCT
                metadata.study_name
                ,
                metadata.item_group_oid
                ,
                metadata.crf_null_values
            FROM
                dm.metadata
            WHERE
                metadata.crf_null_values != $$$$
                AND
                metadata.study_name = %1$L
                AND
                metadata.item_group_oid = %2$L
        ) AS sub;
        $query$,
                filter_study_name,
                filter_itemgroup_oid
        );

        FOR crf_null_result IN EXECUTE crf_null_sql LOOP
            crf_null_result_text := concat_ws(
                    $$,$$,
                    crf_null_result_text,
                    crf_null_result);
        END LOOP;
        crf_null_values_list := crf_null_result_text;
    END;
    $BODY$
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION dm_refresh_matview(
    schemaname  TEXT,
    matviewname TEXT
)
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            format(
                    $$ REFRESH MATERIALIZED VIEW %1$I.%2$I ; $$,
                    schemaname,
                    matviewname
            ) AS refresh_statement
        LOOP
            EXECUTE r.refresh_statement;
        END LOOP;
        RETURN $$done$$;
    END
    $BODY$
LANGUAGE plpgsql VOLATILE;