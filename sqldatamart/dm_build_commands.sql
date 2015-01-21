/* required to connect to foreign server, can only be run by superuser */
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
/* administrator role that will be used for managing the database */  
CREATE ROLE dm_admin INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOLOGIN;
/* add postgres to dm_admin, but for now don't impersonate */
GRANT dm_admin TO postgres;
/* give control of the report database to dm_admin */
GRANT ALL ON DATABASE openclinica_fdw_db TO dm_admin;
/* give control of the foreign objects schema to dm_admin */
GRANT ALL ON SCHEMA openclinica_fdw TO dm_admin;
/* add a schema for the centralised datamart views */
CREATE SCHEMA dm;
/* give control of the dm schema to dm_admin */
GRANT ALL ON SCHEMA dm TO dm_admin;
/* set default privileges on foreign objects schema so the objects created are under control of dm_admin automatically */
ALTER DEFAULT PRIVILEGES IN SCHEMA openclinica_fdw GRANT SELECT ON TABLES TO dm_admin;
/* set default privileges on datamart schema so the objects created are under control of dm_admin automatically */
ALTER DEFAULT PRIVILEGES IN SCHEMA dm GRANT SELECT ON TABLES TO dm_admin;
/* add a foreign server definition for connecting with later, :variables are substituted by the batch script */
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
/* map the foreign server user to dm_admin so any dm_admin can access and refresh foreign objects */
CREATE USER MAPPING FOR dm_admin SERVER openclinica_fdw_server
OPTIONS (
USER 'ocdm_fdw',
PASSWORD :foreign_server_user_password
);
/* give usage so any dm_admin can access and refresh foreign objects */
GRANT USAGE ON FOREIGN SERVER openclinica_fdw_server TO dm_admin;
/* impersonate dm_admin so that the following commands create objects owned by dm_admin */
SET ROLE dm_admin;
/* add foreign tables for catalog tables for looking up objects and their definitions  */
SELECT
    dm_create_ft_catalog();
/* add foreign tables for each table or view in the specified openclinica schema */
SELECT
    dm_create_ft_openclinica(
            :foreign_openclinica_schema_name);
/* add matviews for openclinica tables to cache them locally for reporting */
SELECT
    dm_create_ft_openclinica_matviews();
/* add indexes to the openclinica matviews that existed in the foreign schema */
SELECT
    dm_create_ft_openclinica_matview_indexes(
            :foreign_openclinica_schema_name);
/* add dm matview with choice lists split to rows, re-used many times so not a cte */
SELECT
    dm_create_dm_response_sets();
/* change query planner parameter, improves execution time of dm.metadata query */
SET seq_page_cost = 0.25; 
/* add dm matview with study metadata for all items in all events and studies */

SELECT
    dm_create_dm_metadata();
/* change query planner parameter back to default */
SET seq_page_cost = 1.0; 
/* add dm matview with study metadata for all itemgroups in all events and studies */
SELECT
    dm_create_dm_metadata_event_crf_ig();
/* add dm matview with study metadata for all items in all studies */
SELECT
    dm_create_dm_metadata_crf_ig_item();
/* change query planner parameter, improves execution time of dm.clinicaldata query */
SET join_collapse_limit = 1;
/* add dm matview with item data and related site or study metadata */
SELECT
    dm_create_dm_clinicaldata();
/* change query planner parameter back to default */
SET join_collapse_limit = 8;
/* add index on study_name and item_group_oid as these are common filters */
CREATE INDEX i_dm_clinicaldata_study_name_item_group_oid
ON dm.clinicaldata USING BTREE (study_name, item_group_oid);
/* add dm matview with subjects in all studies */
SELECT
    dm_create_dm_subjects();
/* add dm matview with event and crf statuses for each subject in each study */
SELECT
    dm_create_dm_subject_event_crf_status();
/* add dm matview with possible events and crfs for each subject in each study */
SELECT
    dm_create_dm_subject_event_crf_expected();
/* add dm matview with expected and current event and crf statuses for each subject in each study */
SELECT
    dm_create_dm_subject_event_crf_join();
/* add dm matview with discrepancy notes in each study */
SELECT
    dm_create_dm_discrepancy_notes_all();
/* add dm matview with parent discrepancy notes in each study */
SELECT
    dm_create_dm_discrepancy_notes_parent();
/* add dm matview with subject groups for each subject in each study */
SELECT
    dm_create_dm_subject_groups();
/* add dm matview with reponse sets for each item in each crf in each study */
SELECT
    dm_create_dm_response_set_labels();
/* add dm matview with study roles for each user account in the instance */
SELECT
    dm_create_dm_user_account_roles();
/* add dm matview with sdv status history for each subject event crf */
SELECT
    dm_create_dm_sdv_status();
/* add schema for each study in the instance */
SELECT
    dm_create_study_schemas();
/* add a copy of the dm matviews to each study schema, filtered for the study */
SELECT
    dm_create_study_common_matviews();
/* add matviews to each study for each itemgroup with item data pivoted */
SELECT
    dm_create_study_itemgroup_matviews(
            FALSE);
/* add views for each study itemgroup matview which alias each column with the shorter item_name */
SELECT
    dm_create_study_itemgroup_matviews(
            TRUE);
/* add a role for each study to facilitate user access management */
SELECT
    dm_create_study_role();
/* give usage and select privileges to each study role and grant each role to dm_admin */
SELECT
    dm_grant_study_schema_access_to_study_role();
/* add a view for running the study schema object functions for new studies */
CREATE VIEW dm.build_new_study AS
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
                NOT EXISTS
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
/* add a view for refreshing all study schema matviews */
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
                        DISTINCT
                        study_name
                    FROM
                        dm.metadata
                ) AS study_names
                    ON dm_clean_name_string(
                               study_names.study_name) = n.nspname
            WHERE
                c.relkind = $$m$$
            ORDER BY
                c.oid
        ) AS mv
