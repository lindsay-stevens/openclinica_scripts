CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_ft_catalog()
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
                            ),
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
                            ),
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_ft_openclinica(
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
                    ft_pg_namespace.nspname,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_ft_openclinica_matviews()
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_ft_openclinica_matview_indexes(
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_response_sets()
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_metadata()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata AS
    WITH study_with_status AS (
                    SELECT
                        study.parent_study_id,
                        study.study_id,
                        study.oc_oid,
                        study.name,
                        study.date_created,
                        study.date_updated,
                        study.status_id,
                        status_study.name AS status
                    FROM
                        openclinica_fdw.study
                    LEFT JOIN
                        status AS status_study
                        ON status_study.status_id = study.status_id
                ),
    metadata_no_multi AS (
            SELECT
                (
                    CASE
                    WHEN parents.name IS NOT NULL
                    THEN parents.name
                    ELSE study.name
                    END
                )                         AS study_name,
                (
                    CASE
                    WHEN parents.name IS NOT NULL
                    THEN parents.status
                    ELSE study.status
                    END
                )                         AS study_status,
                (
                    CASE
                    WHEN parents.name IS NOT NULL
                    THEN parents.date_created
                    ELSE study.date_created
                    END
                )                         AS study_date_created,
                (
                    CASE
                    WHEN parents.name IS NOT NULL
                    THEN parents.date_updated
                    ELSE study.date_updated
                    END
                )                         AS study_date_updated,
                study.oc_oid              AS site_oid,
                study.name                AS site_name,
                sed.oc_oid                AS event_oid,
                sed.ordinal               AS event_order,
                sed.name                  AS event_name,
                sed.date_created          as event_date_created,
                sed.date_updated          AS event_date_updated,
                sed.repeating             AS event_repeating,
                crf.oc_oid                AS crf_parent_oid,
                crf.name                  AS crf_parent_name,
                crf.date_created          AS crf_parent_date_created,
                crf.date_updated          AS crf_parent_date_updated,
                cv.name                   AS crf_version,
                cv.oc_oid                 AS crf_version_oid,
                cv.date_created           AS crf_version_date_created,
                cv.date_updated           AS crf_version_date_updated,
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
                sim.item_oid              AS item_scd_item_oid,
                sim.option_value          AS item_scd_item_option_value,
                sim.option_text           AS item_scd_item_option_text,
                sim.message               AS item_scd_validation_message
            FROM
                study_with_status AS study
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
                study_with_status AS parents
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
    metadata_no_multi.study_status,
    metadata_no_multi.study_date_created,
    metadata_no_multi.study_date_updated,
    metadata_no_multi.site_oid,
    metadata_no_multi.site_name,
    metadata_no_multi.event_oid,
    metadata_no_multi.event_order,
    metadata_no_multi.event_name,
    metadata_no_multi.event_date_created,
    metadata_no_multi.event_date_updated,
    metadata_no_multi.event_repeating,
    metadata_no_multi.crf_parent_oid,
    metadata_no_multi.crf_parent_name,
    metadata_no_multi.crf_parent_date_created,
    metadata_no_multi.crf_parent_date_updated,
    metadata_no_multi.crf_version,
    metadata_no_multi.crf_version_oid,
    metadata_no_multi.crf_version_date_created,
    metadata_no_multi.crf_version_date_updated,
    metadata_no_multi.crf_is_required,
    metadata_no_multi.crf_is_double_entry,
    metadata_no_multi.crf_is_hidden,
    metadata_no_multi.crf_null_values,
    metadata_no_multi.crf_section_label,
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
    metadata_no_multi.item_scd_item_oid,
    metadata_no_multi.item_scd_item_option_value,
    metadata_no_multi.item_scd_item_option_text,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_metadata_event_crf_ig()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata_event_crf_ig AS
        SELECT
            DISTINCT ON (study_name, event_oid, crf_version_oid)
            study_name,
            study_status,
            study_date_created,
            study_date_updated,
            site_oid,
            site_name,
            event_oid,
            event_order,
            event_name,
            event_date_created,
            event_date_updated,
            event_repeating,
            crf_parent_oid,
            crf_parent_name,
            crf_parent_date_created,
            crf_parent_date_updated,
            crf_version,
            crf_version_oid,
            crf_version_date_created,
            crf_version_date_updated,
            crf_is_required,
            crf_is_double_entry,
            crf_is_hidden,
            crf_null_values,
            crf_section_label,
            crf_section_title,
            item_group_oid,
            item_group_name
        FROM
            dm.metadata;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_metadata_crf_ig_item()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata_crf_ig_item AS
        SELECT
            DISTINCT ON (study_name, crf_version_oid, item_oid)
            study_name,
            study_status,
            study_date_created,
            study_date_updated,
            site_oid,
            site_name,
            crf_parent_oid,
            crf_parent_name,
            crf_parent_date_created,
            crf_parent_date_updated,
            crf_version,
            crf_version_oid,
            crf_version_date_created,
            crf_version_date_updated,
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
            item_scd_item_oid,
            item_scd_item_option_value,
            item_scd_item_option_text,
            item_scd_validation_message
        FROM
            dm.metadata;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_metadata_study()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.metadata_study AS
        SELECT
            DISTINCT ON (study_name)
            study_name,
            study_status,
            study_date_created,
            study_date_updated,
            dm_clean_name_string(study_name) AS study_name_clean
        FROM
            dm.metadata;
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_clinicaldata()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.clinicaldata AS
    WITH status_filter AS (
            SELECT
                status.status_id,
                status.name
            FROM
                openclinica_fdw.status
            WHERE
                status.name
                NOT IN ($$removed$$, $$auto-removed$$)
    ), user_id_name AS (
    SELECT user_account.user_id, user_account.user_name
        FROM openclinica_fdw.user_account
    ), study_details AS (
    SELECT
        COALESCE(
                parent_study.oc_oid,
                study.oc_oid,
                $$no parent study$$) AS study_oid,
        COALESCE(
                parent_study.name,
                study.name,
                $$no parent study$$) AS study_name,
        COALESCE(
                parent_study.study_id,
                study.study_id) AS   study_id,
        study.oc_oid                 AS site_oid,
        study.name                   AS site_name,
        study.study_id as site_id
    FROM
        openclinica_fdw.study
        LEFT JOIN
        (
            SELECT
                study.study_id,
                study.oc_oid,
                study.name
            FROM
                openclinica_fdw.study
                INNER JOIN
                status_filter AS status_pstudy
                    ON status_pstudy.status_id = study.status_id
        ) AS parent_study
            ON parent_study.study_id = study.parent_study_id
        INNER JOIN
        status_filter AS status_study
            ON status_study.status_id = study.status_id      
    ), subject_details AS (
            SELECT
                ss.study_subject_id   AS study_subject_id_seq,
                ss.label              AS subject_id,
                ss.secondary_label    AS subject_secondary_label,
                ss.subject_id         AS subject_id_seq,
                ss.study_id           AS subject_study_id,
                ss.enrollment_date    AS subject_enrol_date,
                ss.date_created       AS subject_date_created,
                ss.date_updated       AS subject_date_updated,
                ua_ss_o.user_name     AS subject_created_by,
                ua_ss_u.user_name     AS subject_updated_by,
                ss.oc_oid             AS subject_oid,
                sub.date_of_birth     AS subject_date_of_birth,
                sub.gender            AS subject_sex,
                sub.unique_identifier AS subject_person_id,
                status_ss.name        AS subject_status
            FROM
                openclinica_fdw.study_subject AS ss
                INNER JOIN
                openclinica_fdw.subject AS sub
                    ON ss.subject_id = sub.subject_id
                INNER JOIN
                status_filter AS status_ss
                    ON ss.status_id = status_ss.status_id
                INNER JOIN
                user_id_name AS ua_ss_o
                    ON ss.owner_id = ua_ss_o.user_id
                LEFT JOIN
                user_id_name AS ua_ss_u
                    ON ss.owner_id = ua_ss_u.user_id
    ), event_details AS (
            SELECT
                se.study_event_id             AS study_event_id_seq,
                se.study_subject_id           AS event_study_subject_id_seq,
                se.location                   AS event_location,
                se.sample_ordinal             AS event_repeat,
                se.date_start                 AS event_date_start,
                se.date_end                   AS event_date_end,
                ses.name                      AS event_status,
                status_se.name                AS event_status_internal,
                se.date_created               AS event_date_created,
                se.date_updated               AS event_date_updated,
                ua_se_o.user_name             AS event_created_by,
                ua_se_u.user_name             AS event_updated_by,
                sed.study_event_definition_id AS study_event_definition_id_seq,
                sed.oc_oid                    AS event_oid,
                sed.name                      AS event_name,
                sed.ordinal                   AS event_order
            FROM
                openclinica_fdw.study_event AS se
                INNER JOIN
                openclinica_fdw.study_event_definition AS sed
                    ON sed.study_event_definition_id = se.study_event_definition_id
                INNER JOIN
                openclinica_fdw.subject_event_status AS ses
                    ON ses.subject_event_status_id = se.subject_event_status_id
                INNER JOIN
                status_filter AS status_se
                    ON se.status_id = status_se.status_id
                INNER JOIN
                user_id_name AS ua_se_o
                    ON se.owner_id = ua_se_o.user_id
                LEFT JOIN
                user_id_name AS ua_se_u
                    ON se.update_id = ua_se_u.user_id
    ), crf_details AS (
            WITH ec_ale_sdv AS (
                    SELECT
                        ale.event_crf_id,
                        max(
                                ale.audit_date) AS audit_date
                    FROM
                        openclinica_fdw.audit_log_event AS ale
                        INNER JOIN
                        openclinica_fdw.audit_log_event_type AS alet
                            ON alet.audit_log_event_type_id =
                            ale.audit_log_event_type_id
                    WHERE
                        ale.event_crf_id IS NOT NULL
                        AND alet.name = $$EventCRF SDV Status$$
                    GROUP BY
                        ale.event_crf_id
            )
            SELECT
                crf.crf_id                     AS crf_id_seq,
                crf.oc_oid                     AS crf_parent_oid,
                crf.name                       AS crf_parent_name,
                cv.crf_version_id              AS crf_version_id_seq,
                cv.oc_oid                      AS crf_version_oid,
                cv.name                        AS crf_version_name,
                ec.event_crf_id                AS event_crf_id_seq,
                ec.study_event_id              AS crf_study_event_id_seq,
                ec.date_interviewed            AS crf_date_interviewed,
                ec.interviewer_name            AS crf_interviewer_name,
                ec.date_completed              AS crf_date_completed,
                ec.date_validate               AS crf_date_validate,
                ua_ec_v.user_name              AS crf_validated_by,
                ec.date_validate_completed     AS crf_date_validate_completed,
                ec.electronic_signature_status AS crf_esignature_status,
                ec.sdv_status                  AS crf_sdv_status,
                ec_ale_sdv.audit_date          AS crf_sdv_status_last_updated,
                ua_ec_s.user_name              AS crf_sdv_status_last_updated_by,
                ec.date_created                AS crf_date_created,
                ec.date_updated                AS crf_date_updated,
                ua_ec_o.user_name              AS crf_created_by,
                ua_ec_u.user_name              AS crf_updated_by,
                CASE
                WHEN ses.name IN
                    ($$stopped$$, $$skipped$$, $$locked$$)
                THEN $$locked$$
                WHEN status_cv.name <> $$available$$
                THEN $$locked$$
                WHEN status_ec.name = $$available$$
                THEN $$initial data entry$$
                WHEN status_ec.name = $$unavailable$$
                THEN
                    CASE
                    WHEN edc.double_entry = TRUE
                    THEN $$validation completed$$
                    WHEN edc.double_entry = FALSE
                    THEN $$data entry complete$$
                    ELSE $$unhandled$$
                    END
                WHEN status_ec.name = $$pending$$
                THEN
                    CASE
                    WHEN ec.validator_id <>
                        0 /* default zero, blank if event_crf created by insertaction */
                    THEN $$double data entry$$
                    WHEN ec.validator_id =
                        0 /* default value present means non-dde run done */
                    THEN $$initial data entry complete$$
                    ELSE $$unhandled$$
                    END
                ELSE status_ec.name
                END                            AS crf_status,
                status_ec.name                 AS crf_status_internal,
                edc.study_id                   AS edc_study_id
            FROM
                openclinica_fdw.event_crf AS ec
                INNER JOIN
                openclinica_fdw.crf_version AS cv
                    ON cv.crf_version_id = ec.crf_version_id
                INNER JOIN
                openclinica_fdw.crf
                    ON crf.crf_id = cv.crf_id
                INNER JOIN
                openclinica_fdw.study_event AS se
                    ON ec.study_event_id = se.study_event_id
                INNER JOIN
                openclinica_fdw.subject_event_status AS ses
                    ON ses.subject_event_status_id = se.subject_event_status_id
                INNER JOIN
                openclinica_fdw.event_definition_crf AS edc
                    ON edc.crf_id = cv.crf_id
                    AND edc.study_event_definition_id =
                        se.study_event_definition_id
                INNER JOIN
                status_filter AS status_ec
                    ON ec.status_id = status_ec.status_id
                INNER JOIN
                status_filter AS status_cv
                    ON cv.status_id = status_cv.status_id
                INNER JOIN
                user_id_name AS ua_ec_o
                    ON ec.owner_id = ua_ec_o.user_id
                LEFT JOIN
                user_id_name AS ua_ec_u
                    ON ec.update_id = ua_ec_u.user_id
                LEFT JOIN
                user_id_name AS ua_ec_v
                    ON ec.validator_id = ua_ec_v.user_id
                LEFT JOIN
                ec_ale_sdv
                    ON ec_ale_sdv.event_crf_id = ec.event_crf_id
                LEFT JOIN
                user_id_name AS ua_ec_s
                    ON ec.sdv_update_id = ua_ec_s.user_id
                    AND ec.sdv_status = TRUE
    ), response_sets AS (
            WITH response_type_filter AS (
    
                    SELECT
                        response_type.response_type_id,
                        response_type.name
                    FROM
                        response_type
                    WHERE
                        response_type.name IN
                        ($$checkbox$$, $$radio$$, $$single-select$$, $$multi-select$$)
            )
            SELECT
                rs_opt_value_min.version_id,
                rs_opt_value_min.response_set_id,
                rs_opt_value_min.label,
                rs_opt_text.option_text,
                rs_opt_value_min.option_value,
                rs_opt_value_min.option_order
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
                                                        INNER JOIN
                                                        response_type_filter
                                                            ON
                                                                response_type_filter.response_type_id
                                                                =
                                                                response_set.response_type_id
                                                ) AS rs_text_replace
                                        ) AS rs_opt_array
                                ) AS rs_opt_array_rownum
                        ) AS rs_opt_split
                ) AS rs_opt_text
                INNER JOIN
                (
                    SELECT
                        rs_opt_value.version_id,
                        rs_opt_value.response_set_id,
                        rs_opt_value.label,
                        rs_opt_value.option_value,
                        min(
                                rs_opt_value.option_order) AS option_order
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
                                                INNER JOIN
                                                response_type_filter
                                                    ON
                                                        response_type_filter.response_type_id
                                                        =
                                                        response_set.response_type_id
                                        ) AS rs_opt_array
                                ) AS rs_opt_array_rownum
                        ) AS rs_opt_value
                    GROUP BY
                        rs_opt_value.version_id,
                        rs_opt_value.response_set_id,
                        rs_opt_value.label,
                        rs_opt_value.option_value
                ) AS rs_opt_value_min
                    ON rs_opt_text.version_id = rs_opt_value_min.version_id
                    AND
                    rs_opt_text.response_set_id =
                    rs_opt_value_min.response_set_id
                    AND rs_opt_text.option_order = rs_opt_value_min.option_order
    ), item_details AS (
            WITH item_details_raw AS (
                    SELECT
                        ig.item_group_id         AS item_group_id_seq,
                        ig.name                  AS item_group_name,
                        ig.oc_oid                AS item_group_oid,
                        item_data.ordinal        AS item_group_repeat,
                        item.item_id             AS item_id_seq,
                        item.name                AS item_name_raw,
                        item.oc_oid              AS item_oid_raw,
                        rt.name                  AS item_response_type,
                        rs.response_set_id       AS item_response_set_id,
                        rs.version_id            AS item_response_set_version_id,
                        item_data.item_data_id   AS item_data_id_seq,
                        item_data.event_crf_id   AS item_event_crf_id_seq,
                        item_data.value          AS item_value_raw,
                        item_data.date_created   AS item_data_date_created,
                        item_data.date_updated   AS item_data_date_updated,
                        ua_item_data_o.user_name AS item_data_created_by,
                        ua_item_data_u.user_name AS item_data_updated_by,
                        status_item_data.name    AS item_data_status
                    FROM
                        openclinica_fdw.item_data
                        INNER JOIN
                        openclinica_fdw.item
                            ON item.item_id = item_data.item_id
                        INNER JOIN
                        openclinica_fdw.item_group_metadata AS igm
                            ON item.item_id = igm.item_id
                        INNER JOIN
                        openclinica_fdw.item_group AS ig
                            ON ig.item_group_id =
                            igm.item_group_id
                        INNER JOIN
                        openclinica_fdw.item_form_metadata AS ifm
                            ON ifm.item_id = item.item_id
                        INNER JOIN
                        openclinica_fdw.response_set AS rs
                            ON rs.response_set_id =
                            ifm.response_set_id
                            AND
                            rs.version_id = ifm.crf_version_id
                        INNER JOIN
                        openclinica_fdw.response_type AS rt
                            ON rs.response_type_id =
                            rt.response_type_id
                        INNER JOIN
                        status_filter AS status_item_data
                            ON item_data.status_id =
                            status_item_data.status_id
                        INNER JOIN
                        user_id_name AS ua_item_data_o
                            ON item_data.owner_id =
                            ua_item_data_o.user_id
                        LEFT JOIN
                        user_id_name AS ua_item_data_u
                            ON item_data.update_id =
                            ua_item_data_u.user_id
                    WHERE
                        item_data.value <> $$$$
            ), multi_split AS (
                    SELECT
                        item_data_id_seq,
                        item_value_split,
                        concat_ws(
                                $$_$$,
                                item_oid_raw,
                                item_value_split) AS item_oid_multi,
                        concat_ws(
                                $$_$$,
                                item_name_raw,
                                item_value_split) AS item_name_multi
                    FROM
                        (
                            SELECT
                                item_data_id_seq,
                                item_oid_raw,
                                item_name_raw,
                                regexp_split_to_table(
                                        item_value_raw,
                                        $$,$$) AS item_value_split
                            FROM
                                item_details_raw
                            WHERE
                                item_response_type IN
                                ($$checkbox$$, $$multi-select$$)
                        ) AS idr_split
            )
            SELECT
                idr.*,
                ms.item_value_split,
                CASE WHEN ms.item_oid_multi IS NOT NULL
                THEN ms.item_oid_multi
                ELSE idr.item_oid_raw
                END AS item_oid,
                CASE WHEN ms.item_name_multi IS NOT NULL
                THEN ms.item_name_multi
                ELSE idr.item_name_raw
                END AS item_name,
                CASE WHEN ms.item_value_split IS NOT NULL
                THEN ms.item_value_split
                ELSE idr.item_value_raw
                END AS item_value,
                response_sets.option_text
            FROM
                item_details_raw AS idr
                LEFT JOIN
                multi_split AS ms
                    ON ms.item_data_id_seq = idr.item_data_id_seq
                LEFT JOIN
                response_sets
                    ON response_sets.response_set_id = idr.item_response_set_id
                    AND
                    response_sets.version_id = idr.item_response_set_version_id
                    AND response_sets.option_value =
                        COALESCE(
                                ms.item_value_split,
                                idr.item_value_raw)
    )
    SELECT
        study_details.*,
        subject_details.*,
        event_details.*,
        crf_details.*,
        item_details.*
    FROM
        study_details
        INNER JOIN
        subject_details
            ON subject_details.subject_study_id = study_details.site_id
        INNER JOIN
        event_details
            ON subject_details.study_subject_id_seq =
            event_details.event_study_subject_id_seq
        INNER JOIN
        crf_details
            ON crf_details.crf_study_event_id_seq = event_details.study_event_id_seq
            AND crf_details.edc_study_id = study_details.study_id
        INNER JOIN
        item_details
            ON item_details.item_event_crf_id_seq = crf_details.event_crf_id_seq
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_subjects()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subjects AS
    WITH status_filter AS (
            SELECT
                status.status_id,
                status.name
            FROM
                openclinica_fdw.status
            WHERE
                status.name
                NOT IN ($$removed$$, $$auto-removed$$)
    ), user_id_name AS (
    SELECT user_account.user_id, user_account.user_name
        FROM openclinica_fdw.user_account
    ), study_details AS (
    SELECT
        COALESCE(
                parent_study.oc_oid,
                study.oc_oid,
                $$no parent study$$) AS study_oid,
        COALESCE(
                parent_study.name,
                study.name,
                $$no parent study$$) AS study_name,
        COALESCE(
                parent_study.study_id,
                study.study_id) AS   study_id,
        study.oc_oid                 AS site_oid,
        study.name                   AS site_name,
        study.study_id as site_id
    FROM
        openclinica_fdw.study
        LEFT JOIN
        (
            SELECT
                study.study_id,
                study.oc_oid,
                study.name
            FROM
                openclinica_fdw.study
                INNER JOIN
                status_filter AS status_pstudy
                    ON status_pstudy.status_id = study.status_id
        ) AS parent_study
            ON parent_study.study_id = study.parent_study_id
        INNER JOIN
        status_filter AS status_study
            ON status_study.status_id = study.status_id      
    ), subject_details AS (
            SELECT
                ss.study_subject_id   AS study_subject_id_seq,
                ss.label              AS subject_id,
                ss.secondary_label    AS subject_secondary_label,
                ss.subject_id         AS subject_id_seq,
                ss.study_id           AS subject_study_id,
                ss.enrollment_date    AS subject_enrol_date,
                ss.date_created       AS subject_date_created,
                ss.date_updated       AS subject_date_updated,
                ua_ss_o.user_name     AS subject_created_by,
                ua_ss_u.user_name     AS subject_updated_by,
                ss.oc_oid             AS subject_oid,
                sub.date_of_birth     AS subject_date_of_birth,
                sub.gender            AS subject_sex,
                sub.unique_identifier AS subject_person_id,
                status_ss.name        AS subject_status
            FROM
                openclinica_fdw.study_subject AS ss
                INNER JOIN
                openclinica_fdw.subject AS sub
                    ON ss.subject_id = sub.subject_id
                INNER JOIN
                status_filter AS status_ss
                    ON ss.status_id = status_ss.status_id
                INNER JOIN
                user_id_name AS ua_ss_o
                    ON ss.owner_id = ua_ss_o.user_id
                LEFT JOIN
                user_id_name AS ua_ss_u
                    ON ss.owner_id = ua_ss_u.user_id
    )
    SELECT
        study_details.*,
        subject_details.*
    FROM
        study_details
        INNER JOIN
        subject_details
            ON subject_details.subject_study_id = study_details.site_id
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_subject_event_crf_status()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_status AS
    WITH status_filter AS (
            SELECT
                status.status_id,
                status.name
            FROM
                openclinica_fdw.status
            WHERE
                status.name
                NOT IN ($$removed$$, $$auto-removed$$)
    ), user_id_name AS (
    SELECT user_account.user_id, user_account.user_name
        FROM openclinica_fdw.user_account
    ), study_details AS (
    SELECT
        COALESCE(
                parent_study.oc_oid,
                study.oc_oid,
                $$no parent study$$) AS study_oid,
        COALESCE(
                parent_study.name,
                study.name,
                $$no parent study$$) AS study_name,
        COALESCE(
                parent_study.study_id,
                study.study_id) AS   study_id,
        study.oc_oid                 AS site_oid,
        study.name                   AS site_name,
        study.study_id as site_id
    FROM
        openclinica_fdw.study
        LEFT JOIN
        (
            SELECT
                study.study_id,
                study.oc_oid,
                study.name
            FROM
                openclinica_fdw.study
                INNER JOIN
                status_filter AS status_pstudy
                    ON status_pstudy.status_id = study.status_id
        ) AS parent_study
            ON parent_study.study_id = study.parent_study_id
        INNER JOIN
        status_filter AS status_study
            ON status_study.status_id = study.status_id      
    ), subject_details AS (
            SELECT
                ss.study_subject_id   AS study_subject_id_seq,
                ss.label              AS subject_id,
                ss.secondary_label    AS subject_secondary_label,
                ss.subject_id         AS subject_id_seq,
                ss.study_id           AS subject_study_id,
                ss.enrollment_date    AS subject_enrol_date,
                ss.date_created       AS subject_date_created,
                ss.date_updated       AS subject_date_updated,
                ua_ss_o.user_name     AS subject_created_by,
                ua_ss_u.user_name     AS subject_updated_by,
                ss.oc_oid             AS subject_oid,
                sub.date_of_birth     AS subject_date_of_birth,
                sub.gender            AS subject_sex,
                sub.unique_identifier AS subject_person_id,
                status_ss.name        AS subject_status
            FROM
                openclinica_fdw.study_subject AS ss
                INNER JOIN
                openclinica_fdw.subject AS sub
                    ON ss.subject_id = sub.subject_id
                INNER JOIN
                status_filter AS status_ss
                    ON ss.status_id = status_ss.status_id
                INNER JOIN
                user_id_name AS ua_ss_o
                    ON ss.owner_id = ua_ss_o.user_id
                LEFT JOIN
                user_id_name AS ua_ss_u
                    ON ss.owner_id = ua_ss_u.user_id
    ), event_details AS (
            SELECT
                se.study_event_id             AS study_event_id_seq,
                se.study_subject_id           AS event_study_subject_id_seq,
                se.location                   AS event_location,
                se.sample_ordinal             AS event_repeat,
                se.date_start                 AS event_date_start,
                se.date_end                   AS event_date_end,
                ses.name                      AS event_status,
                status_se.name                AS event_status_internal,
                se.date_created               AS event_date_created,
                se.date_updated               AS event_date_updated,
                ua_se_o.user_name             AS event_created_by,
                ua_se_u.user_name             AS event_updated_by,
                sed.study_event_definition_id AS study_event_definition_id_seq,
                sed.oc_oid                    AS event_oid,
                sed.name                      AS event_name,
                sed.ordinal                   AS event_order
            FROM
                openclinica_fdw.study_event AS se
                INNER JOIN
                openclinica_fdw.study_event_definition AS sed
                    ON sed.study_event_definition_id = se.study_event_definition_id
                INNER JOIN
                openclinica_fdw.subject_event_status AS ses
                    ON ses.subject_event_status_id = se.subject_event_status_id
                INNER JOIN
                status_filter AS status_se
                    ON se.status_id = status_se.status_id
                INNER JOIN
                user_id_name AS ua_se_o
                    ON se.owner_id = ua_se_o.user_id
                LEFT JOIN
                user_id_name AS ua_se_u
                    ON se.update_id = ua_se_u.user_id
    ), crf_details AS (
            WITH ec_ale_sdv AS (
                    SELECT
                        ale.event_crf_id,
                        max(
                                ale.audit_date) AS audit_date
                    FROM
                        openclinica_fdw.audit_log_event AS ale
                        INNER JOIN
                        openclinica_fdw.audit_log_event_type AS alet
                            ON alet.audit_log_event_type_id =
                            ale.audit_log_event_type_id
                    WHERE
                        ale.event_crf_id IS NOT NULL
                        AND alet.name = $$EventCRF SDV Status$$
                    GROUP BY
                        ale.event_crf_id
            )
            SELECT
                crf.crf_id                     AS crf_id_seq,
                crf.oc_oid                     AS crf_parent_oid,
                crf.name                       AS crf_parent_name,
                cv.crf_version_id              AS crf_version_id_seq,
                cv.oc_oid                      AS crf_version_oid,
                cv.name                        AS crf_version_name,
                ec.event_crf_id                AS event_crf_id_seq,
                ec.study_event_id              AS crf_study_event_id_seq,
                ec.date_interviewed            AS crf_date_interviewed,
                ec.interviewer_name            AS crf_interviewer_name,
                ec.date_completed              AS crf_date_completed,
                ec.date_validate               AS crf_date_validate,
                ua_ec_v.user_name              AS crf_validated_by,
                ec.date_validate_completed     AS crf_date_validate_completed,
                ec.electronic_signature_status AS crf_esignature_status,
                ec.sdv_status                  AS crf_sdv_status,
                ec_ale_sdv.audit_date          AS crf_sdv_status_last_updated,
                ua_ec_s.user_name              AS crf_sdv_status_last_updated_by,
                ec.date_created                AS crf_date_created,
                ec.date_updated                AS crf_date_updated,
                ua_ec_o.user_name              AS crf_created_by,
                ua_ec_u.user_name              AS crf_updated_by,
                CASE
                WHEN ses.name IN
                    ($$stopped$$, $$skipped$$, $$locked$$)
                THEN $$locked$$
                WHEN status_cv.name <> $$available$$
                THEN $$locked$$
                WHEN status_ec.name = $$available$$
                THEN $$initial data entry$$
                WHEN status_ec.name = $$unavailable$$
                THEN
                    CASE
                    WHEN edc.double_entry = TRUE
                    THEN $$validation completed$$
                    WHEN edc.double_entry = FALSE
                    THEN $$data entry complete$$
                    ELSE $$unhandled$$
                    END
                WHEN status_ec.name = $$pending$$
                THEN
                    CASE
                    WHEN ec.validator_id <>
                        0 /* default zero, blank if event_crf created by insertaction */
                    THEN $$double data entry$$
                    WHEN ec.validator_id =
                        0 /* default value present means non-dde run done */
                    THEN $$initial data entry complete$$
                    ELSE $$unhandled$$
                    END
                ELSE status_ec.name
                END                            AS crf_status,
                status_ec.name                 AS crf_status_internal,
                edc.study_id                   AS edc_study_id
            FROM
                openclinica_fdw.event_crf AS ec
                INNER JOIN
                openclinica_fdw.crf_version AS cv
                    ON cv.crf_version_id = ec.crf_version_id
                INNER JOIN
                openclinica_fdw.crf
                    ON crf.crf_id = cv.crf_id
                INNER JOIN
                openclinica_fdw.study_event AS se
                    ON ec.study_event_id = se.study_event_id
                INNER JOIN
                openclinica_fdw.subject_event_status AS ses
                    ON ses.subject_event_status_id = se.subject_event_status_id
                INNER JOIN
                openclinica_fdw.event_definition_crf AS edc
                    ON edc.crf_id = cv.crf_id
                    AND edc.study_event_definition_id =
                        se.study_event_definition_id
                INNER JOIN
                status_filter AS status_ec
                    ON ec.status_id = status_ec.status_id
                INNER JOIN
                status_filter AS status_cv
                    ON cv.status_id = status_cv.status_id
                INNER JOIN
                user_id_name AS ua_ec_o
                    ON ec.owner_id = ua_ec_o.user_id
                LEFT JOIN
                user_id_name AS ua_ec_u
                    ON ec.update_id = ua_ec_u.user_id
                LEFT JOIN
                user_id_name AS ua_ec_v
                    ON ec.validator_id = ua_ec_v.user_id
                LEFT JOIN
                ec_ale_sdv
                    ON ec_ale_sdv.event_crf_id = ec.event_crf_id
                LEFT JOIN
                user_id_name AS ua_ec_s
                    ON ec.sdv_update_id = ua_ec_s.user_id
                    AND ec.sdv_status = TRUE
    )
    SELECT
        study_details.*,
        subject_details.*,
        event_details.*,
        crf_details.*
    FROM
        study_details
        INNER JOIN
        subject_details
            ON subject_details.subject_study_id = study_details.site_id
        INNER JOIN
        event_details
            ON subject_details.study_subject_id_seq =
            event_details.event_study_subject_id_seq
        INNER JOIN
        crf_details
            ON crf_details.crf_study_event_id_seq = event_details.study_event_id_seq
            AND crf_details.edc_study_id = study_details.study_id
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_subject_event_crf_expected()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_expected AS
        SELECT
            s.study_name,
            s.site_oid,
            s.subject_id,
            e.event_oid,
            e.crf_parent_name
        FROM
            (
                SELECT
                    DISTINCT
                    clinicaldata.study_name,
                    clinicaldata.site_oid,
                    clinicaldata.site_name,
                    clinicaldata.subject_id
                FROM
                    dm.clinicaldata
            ) AS s,
            (
                SELECT
                    DISTINCT
                    metadata.study_name,
                    metadata.event_oid,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_subject_event_crf_join()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_event_crf_join AS
        SELECT
            e.study_name,
            e.site_oid,
            s.site_name,
            s.subject_person_id,
            s.subject_oid,
            e.subject_id,
            s.study_subject_id,
            s.subject_secondary_label,
            s.subject_date_of_birth,
            s.subject_sex,
            s.subject_enrol_date,
            s.person_id,
            s.subject_owned_by_user,
            s.subject_last_updated_by_user,
            e.event_oid,
            s.event_order,
            s.event_name,
            s.event_repeat,
            s.event_start,
            s.event_end,
            CASE WHEN s.event_status IS NOT NULL
            THEN s.event_status
            ELSE $$not scheduled$$
            END AS event_status,
            s.event_owned_by_user,
            s.event_last_updated_by_user,
            s.crf_parent_oid,
            e.crf_parent_name,
            s.crf_version,
            s.crf_version_oid,
            s.crf_is_required,
            s.crf_is_double_entry,
            s.crf_is_hidden,
            s.crf_null_values,
            s.crf_date_created,
            s.crf_last_update,
            s.crf_date_completed,
            s.crf_date_validate,
            s.crf_date_validate_completed,
            s.crf_owned_by_user,
            s.crf_last_updated_by_user,
            s.crf_status,
            s.crf_validated_by_user,
            s.crf_sdv_status,
            s.crf_sdv_status_last_updated,
            s.crf_sdv_by_user,
            s.crf_interviewer_name,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_discrepancy_notes_all()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.discrepancy_notes_all AS
        SELECT
            dn_src.discrepancy_note_id,
            dn_src.study_name,
            dn_src.site_name,
            dn_src.subject_id,
            dn_src.event_name,
            dn_src.crf_parent_name,
            dn_src.crf_section_label,
            dn_src.item_description,
            dn_src.column_name,
            dn_src.parent_dn_id,
            dn_src.entity_type,
            dn_src.description,
            dn_src.detailed_notes,
            dn_src.date_created,
            dn_src.discrepancy_note_type,
            dn_src.resolution_status,
            dn_src.discrepancy_note_owner
        FROM
            (
                SELECT
                    DISTINCT ON (sua.discrepancy_note_id)
                    sua.discrepancy_note_id,
                    sua.study_name,
                    sua.site_name,
                    sua.subject_id,
                    sua.event_name,
                    sua.crf_parent_name,
                    sua.crf_section_label,
                    sua.item_description,
                    sua.column_name,
                    dn.parent_dn_id,
                    dn.entity_type,
                    dn.description,
                    dn.detailed_notes,
                    dn.date_created,
                    CASE
                    WHEN dn.discrepancy_note_type_id =
                         1 THEN $$Failed Validation Check$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id =
                         2 THEN $$Annotation$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id = 3 THEN $$Query$$ :: TEXT
                    WHEN dn.discrepancy_note_type_id =
                         4 THEN $$Reason for Change$$ :: TEXT
                    ELSE $$unhandled$$ :: TEXT
                    END :: TEXT                  AS discrepancy_note_type,
                    rs.name                      AS resolution_status,
                    ua.user_name                 AS discrepancy_note_owner
                FROM
                    (
                        (
                            (
                                (
                                    SELECT
                                        didm.discrepancy_note_id,
                                        didm.column_name,
                                        cd.study_name,
                                        cd.site_name,
                                        cd.subject_id,
                                        cd.event_name,
                                        cd.crf_parent_name,
                                        cd.crf_section_label,
                                        cd.item_description
                                    FROM
                                        openclinica_fdw.dn_item_data_map AS didm
                                        JOIN
                                        dm.clinicaldata AS cd
                                            ON cd.item_data_id =
                                               didm.item_data_id
                                    UNION ALL
                                    SELECT
                                        decm.discrepancy_note_id,
                                        decm.column_name,
                                        cd.study_name,
                                        cd.site_name,
                                        cd.subject_id,
                                        cd.event_name,
                                        cd.crf_parent_name,
                                        NULL :: TEXT AS crf_section_label,
                                        NULL :: TEXT AS item_description
                                    FROM
                                        openclinica_fdw.dn_event_crf_map AS decm
                                        JOIN
                                        dm.clinicaldata AS cd
                                            ON cd.event_crf_id =
                                               decm.event_crf_id
                                )
                                UNION ALL
                                SELECT
                                    dsem.discrepancy_note_id,
                                    dsem.column_name,
                                    cd.study_name,
                                    cd.site_name,
                                    cd.subject_id,
                                    cd.event_name,
                                    NULL :: TEXT AS crf_parent_name,
                                    NULL :: TEXT AS crf_section_label,
                                    NULL :: TEXT AS item_description
                                FROM
                                    openclinica_fdw.dn_study_event_map AS dsem
                                    JOIN
                                    dm.clinicaldata AS cd
                                        ON cd.study_event_id =
                                           dsem.study_event_id
                            )
                            UNION ALL
                            SELECT
                                dssm.discrepancy_note_id,
                                dssm.column_name,
                                cd.study_name,
                                cd.site_name,
                                cd.subject_id,
                                NULL :: TEXT AS event_name,
                                NULL :: TEXT AS crf_parent_name,
                                NULL :: TEXT AS crf_section_label,
                                NULL :: TEXT AS item_description
                            FROM
                                openclinica_fdw.dn_study_subject_map AS dssm
                                JOIN
                                dm.clinicaldata AS cd
                                    ON cd.study_subject_id =
                                       dssm.study_subject_id
                        )
                        UNION ALL
                        SELECT
                            dsm.discrepancy_note_id,
                            dsm.column_name,
                            cd.study_name,
                            cd.site_name,
                            cd.subject_id,
                            NULL :: TEXT AS event_name,
                            NULL :: TEXT AS crf_parent_name,
                            NULL :: TEXT AS crf_section_label,
                            NULL :: TEXT AS item_description
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_discrepancy_notes_parent()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.discrepancy_notes_parent AS
        SELECT
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
            sub.discrepancy_note_owner,
            CASE WHEN sub.resolution_status IN ($$Closed$$, $$Not Applicable$$)
            THEN NULL
            WHEN sub.resolution_status IN
                 ($$New$$, $$Updated$$, $$Resolution Proposed$$)
            THEN CURRENT_DATE - sub.date_created
            ELSE NULL
            END AS days_open,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_subject_groups()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.subject_groups AS
        SELECT
            sub.study_name,
            sub.site_name,
            sub.subject_id,
            gct.name       AS group_class_type,
            sgc.name       AS group_class_name,
            sg.name        AS group_name,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_response_set_labels()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.response_set_labels AS
        SELECT
            DISTINCT
            md.study_name,
            md.crf_parent_name,
            md.crf_version,
            md.item_group_oid,
            md.item_group_name,
            md.item_form_order,
            md.item_oid,
            md.item_name,
            md.item_description,
            rs.version_id,
            rs.label,
            rs.option_value,
            rs.option_text,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_user_account_roles()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.user_account_roles AS
        SELECT
            ua.user_id,
            ua.user_name,
            ua.first_name,
            ua.last_name,
            ua.email,
            ua.date_created              AS account_created,
            ua.date_updated              AS account_last_updated,
            ua_status.name               AS account_status,
            COALESCE(
                    parents.unique_identifier,
                    study.unique_identifier,
                    $$no parent study$$) AS role_study_code,
            COALESCE(
                    parents.name,
                    study.name,
                    $$no parent study$$) AS study_name,
            CASE
            WHEN parents.unique_identifier IS NOT NULL
            THEN study.unique_identifier
            END                          AS role_site_code,
            CASE
            WHEN parents.name IS NOT NULL
            THEN study.name
            END                          AS role_site_name,
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
            END                          AS role_name_ui,
            sur.date_created             AS role_created,
            sur.date_updated             AS role_last_updated,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_dm_sdv_status_history()
    RETURNS VOID AS
    $BODY$
    BEGIN
        EXECUTE $query$
    CREATE MATERIALIZED VIEW dm.sdv_status_history AS
        SELECT
            secs.study_name,
            secs.subject_id,
            secs.event_name,
            secs.event_repeat,
            secs.event_status,
            secs.crf_parent_name,
            secs.crf_status,
            pale.new_value  AS audit_sdv_status,
            pua.user_name   AS audit_sdv_user,
            pale.audit_date AS audit_sdv_timestamp,
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
                    cd.study_name,
                    cd.site_oid,
                    cd.site_name,
                    cd.subject_person_id,
                    cd.subject_oid,
                    cd.subject_id,
                    cd.study_subject_id,
                    cd.subject_secondary_label,
                    cd.subject_date_of_birth,
                    cd.subject_sex,
                    cd.subject_enrol_date,
                    cd.person_id,
                    cd.subject_owned_by_user,
                    cd.subject_last_updated_by_user,
                    cd.event_oid,
                    cd.event_order,
                    cd.event_name,
                    cd.event_repeat,
                    cd.event_start,
                    cd.event_end,
                    cd.event_status,
                    cd.event_owned_by_user,
                    cd.event_last_updated_by_user,
                    cd.event_crf_id,
                    cd.crf_parent_oid,
                    cd.crf_parent_name,
                    cd.crf_version,
                    cd.crf_version_oid,
                    cd.crf_is_required,
                    cd.crf_is_double_entry,
                    cd.crf_is_hidden,
                    cd.crf_null_values,
                    cd.crf_date_created,
                    cd.crf_last_update,
                    cd.crf_date_completed,
                    cd.crf_date_validate,
                    cd.crf_date_validate_completed,
                    cd.crf_owned_by_user,
                    cd.crf_last_updated_by_user,
                    cd.crf_status,
                    cd.crf_validated_by_user,
                    cd.crf_sdv_status,
                    cd.crf_sdv_status_last_updated,
                    cd.crf_sdv_by_user,
                    cd.crf_interviewer_name,
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
            secs.study_name,
            secs.subject_id,
            secs.event_name,
            secs.event_repeat,
            secs.crf_parent_name,
            pale.audit_date DESC
            $query$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_study_schemas(
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
                    $$CREATE SCHEMA %1$I AUTHORIZATION dm_admin; 
                    CREATE MATERIALIZED VIEW %1$I.timestamp_schema AS 
                    SELECT %1$L::text AS study_name, now() AS timestamp_schema;
                    CREATE MATERIALIZED VIEW %1$I.timestamp_data AS 
                    SELECT %1$L::text AS study_name, now() as timestamp_data;$$,
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_study_common_matviews(
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_study_itemgroup_matviews(
    alias_views          BOOLEAN DEFAULT FALSE,
    filter_study_name    TEXT DEFAULT $$$$ :: TEXT,
    filter_itemgroup_oid TEXT DEFAULT $$$$ :: TEXT)
    RETURNS TEXT AS
    $BODY$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN
        WITH use_item_oid AS (SELECT
                                  study_name,
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
                                  dm.metadata_crf_ig_item AS metadata
                              GROUP BY
                                  study_name
        ),
                crf_nulls AS
            (
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
                        ) AS crf_null_values,
                        study_name,
                        item_group_oid
                    FROM
                        (
                            SELECT
                                metadata.study_name,
                                metadata.item_group_oid,
                                metadata.crf_null_values
                            FROM
                                dm.metadata_event_crf_ig AS metadata
                            WHERE
                                metadata.crf_null_values != $$$$
                        ) AS sub
                    GROUP BY
                        study_name,
                        item_group_oid
            )

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
                        WHEN alias_views THEN concat(
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
                                    WHEN met.crf_null_values IS NULL
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
                                        WHEN met.crf_null_values IS NULL
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
                                        CASE WHEN use_item_oid.use_item_oid
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
                                    item_form_order,
                                    item_response_set_label,
                                    crf_nulls.crf_null_values
                                FROM
                                    dm.metadata_crf_ig_item AS dm_meta
                                    LEFT JOIN
                                    use_item_oid
                                    USING (study_name)
                                    LEFT JOIN
                                    crf_nulls
                                    USING (study_name, item_group_oid)
                                WHERE
                                    (
                                        CASE
                                        WHEN length(
                                                     filter_study_name
                                             ) > 0
                                        THEN dm_meta.study_name =
                                             filter_study_name
                                        ELSE TRUE END
                                    )
                                    AND
                                    (
                                        CASE
                                        WHEN length(
                                                     filter_itemgroup_oid
                                             ) > 0
                                        THEN dm_meta.item_group_oid =
                                             filter_itemgroup_oid
                                        ELSE TRUE END
                                    )
                            ) AS namecheck
                        GROUP BY
                            study_name,
                            item_group_oid,
                            item_oid,
                            item_name,
                            item_name_hint,
                            item_data_type,
                            crf_null_values) AS met
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_create_study_role(
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


CREATE OR REPLACE FUNCTION openclinica_fdw.dm_grant_study_schema_access_to_study_role(
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


CREATE OR REPLACE FUNCTION openclinica_fdw.dm_clean_name_string(
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_refresh_matview(
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

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_users_new_oc_user_new_login_role()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT ON (email_local)
            format(
                    $$ CREATE ROLE %1$I LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION; $$,
                    email_local
            ) AS statements,
            email_local
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            initcap(
                                    substring(
                                            email
                                            FROM
                                            $$^([A-z]+)@$$
                                    )
                            ) AS email_local,
                            role_name_ui,
                            account_status,
                            user_name
                        FROM
                            dm.user_account_roles
                    ) AS all_users
                WHERE
                    role_name_ui LIKE $$study%$$
                    AND account_status = $$available$$
                    AND email_local NOT IN (
                        SELECT
                            pg_roles.rolname
                        FROM
                            pg_catalog.pg_roles
                    )
                    AND length(
                                email_local
                        ) > 0
                    AND user_name != $$root$$
            ) AS users_statements
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_users_removed_oc_user_alter_role_nologin()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT ON (email_local)
            format(
                    $$ ALTER ROLE %1$I NOLOGIN; $$,
                    email_local
            ) AS statements,
            email_local
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            initcap(
                                    substring(
                                            email
                                            FROM
                                            $$^([A-z]+)@$$
                                    )
                            ) AS email_local,
                            role_name_ui,
                            account_status,
                            user_name
                        FROM
                            dm.user_account_roles
                    ) AS all_users
                WHERE
                    role_name_ui LIKE $$study%$$
                    AND account_status = $$removed$$
                    AND email_local IN (
                        SELECT
                            pg_roles.rolname
                        FROM
                            pg_catalog.pg_roles
                    )
                    AND length(
                                email_local
                        ) > 0
                    AND user_name != $$root$$
            ) AS users_statements
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_users_restored_oc_user_alter_role_login()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT ON (email_local)
            format(
                    $$ ALTER ROLE %1$I LOGIN; $$,
                    email_local
            ) AS statements,
            email_local
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            initcap(
                                    substring(
                                            email
                                            FROM
                                            $$^([A-z]+)@$$
                                    )
                            ) AS email_local,
                            role_name_ui,
                            account_status,
                            user_name
                        FROM
                            dm.user_account_roles
                    ) AS all_users
                WHERE
                    role_name_ui LIKE $$study%$$
                    AND account_status = $$available$$
                    AND email_local IN (
                        SELECT
                            pg_roles.rolname
                        FROM
                            pg_catalog.pg_roles
                        WHERE
                            pg_roles.rolcanlogin IS FALSE
                    )
                    AND length(
                                email_local) > 0
                    AND user_name != $$root$$
            ) AS users_statements
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION openclinica_fdw.dm_users_available_role_oc_user_grant_to_role()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        WITH all_users AS (
            SELECT
                initcap(
                        substring(
                                email
                                FROM
                                $$^([A-z]+)@$$
                        )
                ) AS email_local,
                role_name_ui,
                role_status,
                user_name,
                concat(
                        $$dm_study_$$,
                        dm_clean_name_string(
                                study_name)
                )     AS study_name_role,
                study_name
            FROM
                dm.user_account_roles
            WHERE
                study_name IN (SELECT study_name FROM dm.metadata_study)
        )
        SELECT
            format(
                    $$ GRANT %1$s TO %2$I; $$,
                    study_name_role,
                    email_local
            ) AS statements,
            email_local
        FROM
            (
                SELECT
                    *
                FROM
                    all_users
                WHERE
                    role_name_ui LIKE $$study%$$
                    AND role_status = $$available$$
                    AND email_local IN (
                        SELECT
                            pg_roles.rolname
                        FROM
                            pg_catalog.pg_roles
                        WHERE
                            NOT pg_has_role(
                                    rolname,
                                    study_name_role,
                                    $$member$$
                            )
                    )
                    AND length(
                                email_local) > 0
                    AND user_name != $$root$$
            ) AS users_statements
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_users_removed_role_oc_user_revoke_from_role()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        WITH all_users AS (
            SELECT
                initcap(
                        substring(
                                email
                                FROM
                                $$^([A-z]+)@$$
                        )
                ) AS email_local,
                role_name_ui,
                role_status,
                user_name,
                concat(
                        $$dm_study_$$,
                        dm_clean_name_string(
                                study_name)
                )     AS study_name_role
            FROM
                dm.user_account_roles
            WHERE
                study_name IN (SELECT study_name FROM dm.metadata_study)
        )
        SELECT
            format(
                    $$ REVOKE %1$s FROM %2$I; $$,
                    study_name_role,
                    email_local
            ) AS statements,
            email_local
        FROM
            (
                SELECT
                    *
                FROM
                    all_users
                WHERE
                    role_name_ui LIKE $$study%$$
                    AND role_status = $$removed$$
                    AND email_local IN (
                        SELECT
                            pg_roles.rolname
                        FROM
                            pg_catalog.pg_roles
                        WHERE
                            pg_has_role(
                                    rolname,
                                    study_name_role,
                                    $$member$$
                            )
                    )
                    AND length(
                                email_local) > 0
                    AND user_name != $$root$$
            ) AS users_statements
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_drop_study_schema_having_new_definitions()
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            DISTINCT
            format(
                    $query$
                    DROP TABLE IF EXISTS schema_to_drop;
                    CREATE TEMP TABLE schema_to_drop AS 
                    SELECT DISTINCT ON (dmm.study_name) dmm.study_name
                    FROM %1$I.metadata AS dmm, %1$I.timestamp_schema AS ts
                    WHERE crf_version_date_created > date_trunc($$day$$, ts.timestamp_schema)
                    OR event_date_created > date_trunc($$day$$, ts.timestamp_schema)
                    OR event_date_updated > date_trunc($$day$$, ts.timestamp_schema)
                    $query$,
                    dm_clean_name_string(
                            study_name)
            ) AS statements, 
            $query$
            SELECT dm_create_study_schemas(study_name, $$drop$$)
            FROM schema_to_drop;
            $query$ AS drop_statement
        FROM
            dm.metadata
        WHERE dm_clean_name_string(study_name) IN 
            (SELECT nspname FROM pg_catalog.pg_namespace)
        LOOP
            EXECUTE r.statements;
            EXECUTE r.drop_statement;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION openclinica_fdw.dm_reassign_owner_study_matviews(
    to_role TEXT DEFAULT $$dm_admin$$
)
    RETURNS TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        FOR r IN
        SELECT
            format(
                    $$ ALTER MATERIALIZED VIEW %1$I.%2$I OWNER TO %3$I;$$,
                    pgm.schemaname,
                    pgm.matviewname,
                    to_role
            ) AS statements
        FROM
            pg_catalog.pg_matviews AS pgm
        WHERE
            pgm.schemaname IN (
                SELECT
                    study_name_clean
                FROM
                    dm.metadata_study)
            AND pgm.matviewowner != to_role
        LOOP
            EXECUTE r.statements;
        END LOOP;
        RETURN $$done$$;
    END;
    $BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION public.dm_snapshot_code_sas(
    filter_study_name_schema     TEXT,
    outputdir                    TEXT,
    odbc_string_or_file_dsn_path TEXT,
    data_filter_string           TEXT DEFAULT $$$$
)
    RETURNS SETOF TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        RETURN QUERY
        WITH views AS (
                SELECT
                    *
                FROM
                    pg_catalog.pg_class AS pgc
                    INNER JOIN
                    pg_catalog.pg_namespace AS pgn
                        ON pgc.relnamespace = pgn.oid
                WHERE
                    pgn.nspname = filter_study_name_schema
        )
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$%%LET snapshotdir=%1$s; LIBNAME snapshot "&snapshotdir"; RUN;$head$,
                    outputdir
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$%%LET data_filter_string=%1$s;$head$,
                    data_filter_string
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$PROC SQL; CONNECT TO odbc AS pgodbc (NOPROMPT="%1$s");$head$,
                    odbc_string_or_file_dsn_path
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            format(
                    $line$create table snapshot.%2$s as select * from connection to pgodbc
                    (select * from %1$s.%3$s &data_filter_string );$line$,
                    filter_study_name_schema,
                    substring(relname from 4 for 32),
                    relname
            )
        FROM
            views
        WHERE
            views.relkind = $$v$$
        UNION ALL
        SELECT
            format(
                    $line$create table snapshot.%2$s as select * from connection to pgodbc
                    (select * from %1$s.%2$s);$line$,
                    filter_study_name_schema,
                    relname
            )
        FROM
            views
        WHERE
            views.relkind = $$m$$
            AND views.relname NOT LIKE $$ig_%$$
            AND views.relname != $$clinicaldata$$;
        RETURN;
    END;
    $BODY$
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION public.dm_snapshot_code_stata(
    filter_study_name_schema     TEXT,
    outputdir                    TEXT,
    odbc_string_or_file_dsn_path TEXT,
    data_filter_string           TEXT DEFAULT $$$$
)
    RETURNS SETOF TEXT AS
    $BODY$
    DECLARE r RECORD;
    BEGIN
        RETURN QUERY
        WITH views AS (
                SELECT
                    *
                FROM
                    pg_catalog.pg_class AS pgc
                    INNER JOIN
                    pg_catalog.pg_namespace AS pgn
                        ON pgc.relnamespace = pgn.oid
                WHERE
                    pgn.nspname = filter_study_name_schema
        )
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$local snapshotdir="%1$s"$head$,
                    outputdir
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$local data_filter_string="%1$s"$head$,
                    data_filter_string
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            DISTINCT ON (nspname)
            format(
                    $head$local odbc_string_or_file_dsn_path="%1$s"$head$,
                    odbc_string_or_file_dsn_path
            ) AS statements
        FROM
            views
        UNION ALL
        SELECT
            format(
                    $line$odbc load, exec("SELECT * FROM %1$s.%2$s `data_filter_string'") connectionstring("`odbc_string_or_file_dsn_path'")
                    save "`snapshotdir'/%3$s.dta"
                    clear$line$,
                    filter_study_name_schema,
                    relname,
                    substring(
                            relname
                            FROM
                            4)
            )
        FROM
            views
        WHERE
            views.relkind = $$v$$
        UNION ALL
        SELECT
            format(
                    $line$odbc load, exec("SELECT * FROM %1$s.%2$s") connectionstring("`odbc_string_or_file_dsn_path'")
                    save "`snapshotdir'/%2$s.dta"
                    clear$line$,
                    filter_study_name_schema,
                    relname
            )
        FROM
            views
        WHERE
            views.relkind = $$m$$
            AND views.relname NOT LIKE $$ig_%$$
            AND views.relname != $$clinicaldata$$;
        RETURN;
    END;
    $BODY$
LANGUAGE plpgsql STABLE;