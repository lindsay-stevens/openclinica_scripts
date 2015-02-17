/* revoke execution privilege from public on the dm functions */
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA openclinica_fdw FROM public;
/* required to connect to foreign server, can only be run by superuser */
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
/* administrator role that will be used for managing the database */  
CREATE ROLE dm_admin INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOLOGIN;
/* grant execution privilege to dm_admin on the dm functions */
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA openclinica_fdw to dm_admin;
/* add postgres to dm_admin, but for now don't impersonate */
GRANT dm_admin TO postgres;
/* give control of the report database to dm_admin */
GRANT ALL ON DATABASE openclinica_fdw_db TO dm_admin;
/* give control of the foreign objects schema to dm_admin */
GRANT ALL ON SCHEMA openclinica_fdw TO dm_admin;
/* add a schema for the centralised datamart views */
CREATE SCHEMA dm;
/* give control of to the dm schema to dm_admin */
GRANT ALL ON SCHEMA dm TO dm_admin;
/* add a foreign server definition for connecting with later, variables are substituted by the batch script */
CREATE SERVER openclinica_fdw_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host :foreign_server_host_name,
    hostaddr :foreign_server_host_address,
    port :foreign_server_port,
    dbname :foreign_server_database,
    sslmode 'verify-full',
    sslrootcert 'root.crt'
);
/* turn off logging temporarily so ocdm_fdw password isn't logged */
SET log_statement TO 'none';
/* map the foreign server user to dm_admin so any dm_admin can access and refresh foreign objects */
CREATE USER MAPPING FOR dm_admin SERVER openclinica_fdw_server
OPTIONS (
USER 'ocdm_fdw',
PASSWORD :foreign_server_user_password
);
/* turn logging back on */
SET log_statement TO 'all';
/* give usage so any dm_admin can access and refresh foreign objects */
GRANT USAGE ON FOREIGN SERVER openclinica_fdw_server TO dm_admin;
/* impersonate dm_admin so that the following commands create objects owned by dm_admin */
SET ROLE dm_admin;
/* add foreign tables for catalog tables for looking up objects and their definitions  */
SELECT dm_create_ft_catalog();
/* add foreign tables for each table or view in the specified openclinica schema */
SELECT dm_create_ft_openclinica(
            :foreign_server_openclinica_schema_name);
/* add matviews for openclinica tables to cache them locally for reporting */
SELECT dm_create_ft_openclinica_matviews();
/* add indexes to the openclinica matviews that existed in the foreign schema */
SELECT dm_create_ft_openclinica_matview_indexes(
            :foreign_server_openclinica_schema_name);
/* add dm matview with choice lists split to rows, re-used many times so not a cte */
SELECT dm_create_dm_response_sets();
/* change query planner parameter, improves execution time of dm.metadata query */
SET seq_page_cost = 0.25; 
/* add dm matview with study metadata for all items in all events and studies */
SELECT dm_create_dm_metadata();
/* change query planner parameter back to default */
SET seq_page_cost = 1.0; 
/* add dm matview with study metadata for all itemgroups in all events and studies */
SELECT dm_create_dm_metadata_event_crf_ig();
/* add dm matview with study metadata for all items in all studies */
SELECT dm_create_dm_metadata_crf_ig_item();
/* add dm matview with study list and their schema names */
SELECT dm_create_dm_metadata_study();
/* add index on non-blank item_data values which helps the dm_clinicaldata query */
CREATE INDEX i_item_id_value_notblank ON item_data USING btree (item_id) WHERE ("value" <> $$$$)
/* add dm matview with item data and related site or study metadata */
SELECT dm_create_dm_clinicaldata();
/* change query planner parameter back to default */
SET join_collapse_limit = 8;
/* add index on study_name and item_group_oid as these are common filters */
CREATE INDEX i_dm_clinicaldata_study_name_item_group_oid
ON dm.clinicaldata USING BTREE (study_name, item_group_oid);
/* add dm matview with subjects in all studies */
SELECT dm_create_dm_subjects();
/* add dm matview with event and crf statuses for each subject in each study */
SELECT dm_create_dm_subject_event_crf_status();
/* add dm matview with possible events and crfs for each subject in each study */
SELECT dm_create_dm_subject_event_crf_expected();
/* add dm matview with expected and current event and crf statuses for each subject in each study */
SELECT dm_create_dm_subject_event_crf_join();
/* add dm matview with discrepancy notes in each study */
SELECT dm_create_dm_discrepancy_notes_all();
/* add dm matview with parent discrepancy notes in each study */
SELECT dm_create_dm_discrepancy_notes_parent();
/* add dm matview with subject groups for each subject in each study */
SELECT dm_create_dm_subject_groups();
/* add dm matview with reponse sets for each item in each crf in each study */
SELECT dm_create_dm_response_set_labels();
/* add dm matview with study roles for each user account in the instance */
SELECT dm_create_dm_user_account_roles();
/* add dm matview with sdv status history for each subject event crf */
SELECT dm_create_dm_sdv_status_history();
/* add a view for running the set of study schema object creation functions */
CREATE VIEW dm.build_study_functions AS
    SELECT
        dm_create_study_schemas(
                study_name),
        dm_create_study_common_matviews(
                study_name),
        dm_create_study_itemgroup_matviews(
                FALSE,
                study_name),
        dm_create_study_itemgroup_matviews(
                TRUE,
                study_name) AS dm_create_study_itemgroup_matviews_av,
        dm_create_study_role(
                study_name),
        dm_grant_study_schema_access_to_study_role(
                study_name)
    FROM
        (
            SELECT
                DISTINCT
                study_name
            FROM
                dm.metadata AS dmd
            WHERE
                dmd.study_status != $$removed$$
                AND NOT EXISTS
                (
                        SELECT
                            n.nspname AS schemaname
                        FROM
                            pg_class AS c
                            LEFT JOIN
                            pg_namespace AS n
                                ON n.oid = c.relnamespace
                        WHERE
                            c.relkind = $$m$$
                            AND dm_clean_name_string(
                                        dmd.study_name) = n.nspname
                        ORDER BY
                            c.oid
                )
        ) AS study_names;
/* add a view for running user management functions */
CREATE VIEW dm.user_management_functions AS
SELECT 
    dm_users_new_oc_user_new_login_role(),
    dm_users_removed_oc_user_alter_role_nologin(),
    dm_users_restored_oc_user_alter_role_login(),
    dm_users_available_role_oc_user_grant_to_role(),
    dm_users_removed_role_oc_user_revoke_from_role();

/* add a view for refreshing all openclinica foreign table matviews*/
CREATE VIEW dm.refresh_matviews_openclinica_fdw AS
    SELECT
        dm_refresh_matview(
                mv.schemaname,
                mv.matviewname)
    FROM
        (
            SELECT
                n.nspname AS schemaname,
                c.relname AS matviewname
            FROM
                pg_class c
                LEFT JOIN
                pg_namespace n
                    ON n.oid = c.relnamespace
            WHERE
                c.relkind = $$m$$ AND n.nspname = $$openclinica_fdw$$
            ORDER BY
                c.oid
        ) AS mv;
/* add a view for refreshing all datamart schema matviews */
CREATE VIEW dm.refresh_matviews_dm AS
    SELECT
        dm_refresh_matview(
                mv.schemaname,
                mv.matviewname)
    FROM
        (
            SELECT
                n.nspname AS schemaname,
                c.relname AS matviewname
            FROM
                pg_class c
                LEFT JOIN
                pg_namespace n
                    ON n.oid = c.relnamespace
            WHERE
                c.relkind = $$m$$ AND n.nspname = $$dm$$
            ORDER BY
                c.oid
        ) AS mv;
/* add a view for refreshing all study schema matviews. refresh if study is available,
   or if the study is locked or frozen then refresh until end of day after last update */
CREATE VIEW dm.refresh_matviews_study AS
    SELECT
        dm_refresh_matview(
                mv.schemaname,
                mv.matviewname)
    FROM
        (
            SELECT
                n.nspname AS schemaname,
                c.relname AS matviewname
            FROM
                pg_class c
                LEFT JOIN
                pg_namespace n
                    ON n.oid = c.relnamespace
                INNER JOIN
                (
                    SELECT
                        ddmd.study_name
                    FROM
                        (
                            SELECT
                                DISTINCT ON (dmd.study_name)
                                dmd.study_name,
                                dmd.study_status,
                                dmd.study_date_updated
                            FROM
                                dm.metadata AS dmd
                        ) AS ddmd
                    WHERE
                        ddmd.study_status = $$available$$
                        OR (
                            ddmd.study_status IN ($$locked$$, $$frozen$$)
                            AND ddmd.study_date_updated >= (date_trunc(
                                                                   $$day$$,
                                                                   now()
                                                           ) -
                                                           INTERVAL '1 day')
                        )
                ) AS study_names
                    ON dm_clean_name_string(
                               study_names.study_name) = n.nspname
            WHERE
                c.relkind = $$m$$
                AND c.relname !=$$timestamp_schema$$
            ORDER BY
                c.oid
        ) AS mv;
/* change back to postgres user for createrole permission to run views */
SET ROLE postgres;
TABLE dm.build_study_functions;
TABLE dm.user_management_functions;
/* reassign ownership of the study matviews created above to dm_admin so it can do refresh */
SELECT dm_reassign_owner_study_matviews();