CREATE OR REPLACE FUNCTION execute(text) returns void as 
$BODY$BEGIN EXECUTE $1;END;$BODY$ LANGUAGE plpgsql;

with matview_order_public as (
select public_schema, public_order 
from (values('public',1)) as public_orders (public_schema, public_order)
) 
,matview_order_dm as (
select dm_schema, dm_order, dm_mv_name 
from (values
 ('dm',1,'edc_study_def')
,('dm',2,'cd_no_labels')
,('dm',3,'response_sets')
,('dm',4,'cd_no_labels_multi_values')
,('dm',5,'cd_no_labels_multi_join')
,('dm',6,'clinicaldata')
,('dm',7,'metadata_no_multi')
,('dm',8,'metadata')
,('dm',9,'subjects')
,('dm',10,'subject_event_crf_status')
,('dm',11,'subject_event_crf_expected')
,('dm',12,'subject_event_crf_join')
,('dm',13,'discrepancy_notes_all')
,('dm',14,'discrepancy_notes_parent')
,('dm',15,'subject_groups')
,('dm',16,'response_set_labels')
) as dm_orders (dm_schema, dm_order, dm_mv_name)
)

SELECT execute(refresh_statements)
FROM (
SELECT $$REFRESH MATERIALIZED VIEW $$ || schemaname || $$.$$ || matviewname || $$;$$ as refresh_statements
FROM pg_matviews

LEFT JOIN matview_order_public
ON public_schema=schemaname

LEFT JOIN matview_order_dm
ON dm_schema=schemaname AND matviewname=dm_mv_name

ORDER BY public_order, dm_order, schemaname, matviewname) as statements;

DROP FUNCTION IF EXISTS execute(text);