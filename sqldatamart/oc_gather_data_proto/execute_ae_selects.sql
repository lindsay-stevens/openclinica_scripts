/* 
 The following returns the atahc_ii adverse events item group data in 
 a single table with an index column (ae_group) to identify the source.
 The type tells postgres what cols and data types expect from the function.
 Errors occur if the data types are wrong, but it is a way to rename the cols. 
 The function executes the final union query from the iter_selects_set query.
 The iter_selects_set query aggregates the iter_selects statements into one.
 The iter_selects statements build using a template and the generate_series cte.
 The generate_series cte provides a set of numbers from 1 to 50.
*/

DROP TYPE aerec CASCADE;
CREATE TYPE aerec as (
  ae_group int
 ,study_name varchar(255)
 ,site_oid varchar(40)
 ,site_name varchar(255)
 ,subject_id varchar(30)
 ,event_oid varchar(40)
 ,event_name text
 ,event_order int
 ,event_repeat int
 ,crf_parent_name varchar(255)
 ,crf_version varchar(255)
 ,crf_status varchar(50)
 ,item_group_oid varchar(40)
 ,item_group_repeat int
 ,aeevnt_adverse_event_term text
 ,aestdt_start_date_of_adverse_event date
 ,aespdt_stop_date_of_adverse_event date
 ,aesvry_severity_of_the_adverse_event int
 ,aesvry_severity_of_the_adverse_event_label text
 ,aedrug_relationship_of_the_adverse_event_to_the_stud int
 ,aedrug_relationship_of_the_adverse_event_to_the_stud_label text
 ,aeotc_ae_outcome int
 ,aeotc_ae_outcome_label text
 ,aesae_serious_adverse_event int
 ,aesae_serious_adverse_event_label text
 ,saeons_sae_onset date
 ,saestp_sae_stop_date date
 ,saetyp_sae_type int
 ,saetyp_sae_type_label text
 ,saetys_sae_type_specify text
 ,saecau_sae_cause int
 ,saecau_sae_cause_label text
 ,saecas_sae_cause_specify text
 ,saeotc_sae_outcome int
 ,saeotc_sae_outcome_label text);

CREATE OR REPLACE FUNCTION execute_ae_selects(ae_selects text) 
RETURNS SETOF aerec as $$
BEGIN 
 RETURN QUERY EXECUTE ae_selects;
END;
$$ LANGUAGE plpgsql;

SELECT * 
FROM execute_ae_selects(
(SELECT array_to_string(array_agg(iter_selects_set.iter_selects),'') as full_select
 FROM (
 WITH gen_ser as (SELECT generate_series(1,50) as iter)
 SELECT 
  CASE WHEN iter > 1 THEN $$ UNION ALL $$ ELSE '' END ||
  $$SELECT $$ || iter || $$ AS ae_group
   ,study_name
   ,site_oid
   ,site_name
   ,subject_id
   ,event_oid
   ,event_name
   ,event_order
   ,event_repeat
   ,crf_parent_name
   ,crf_version
   ,crf_status
   ,item_group_oid
   ,item_group_repeat
   ,ae$$ || iter || $$evnt_adverse_event_term
   ,ae$$ || iter || $$stdt_start_date_of_adverse_event
   ,ae$$ || iter || $$spdt_stop_date_of_adverse_event
   ,ae$$ || iter || $$svry_severity_of_the_adverse_event
   ,ae$$ || iter || $$svry_severity_of_the_adverse_event_label
   ,ae$$ || iter || $$drug_relationship_of_the_adverse_event_to_the_stud
   ,ae$$ || iter || $$drug_relationship_of_the_adverse_event_to_the_stud_label
   ,ae$$ || iter || $$otc_ae_outcome
   ,ae$$ || iter || $$otc_ae_outcome_label
   ,ae$$ || iter || $$sae_serious_adverse_event
   ,ae$$ || iter || $$sae_serious_adverse_event_label
   ,sae$$ || iter || $$ons_sae_onset
   ,sae$$ || iter || $$stp_sae_stop_date
   ,sae$$ || iter || $$typ_sae_type
   ,sae$$ || iter || $$typ_sae_type_label
   ,sae$$ || iter || $$tys_sae_type_specify
   ,sae$$ || iter || $$cau_sae_cause
   ,sae$$ || iter || $$cau_sae_cause_label
   ,sae$$ || iter || $$cas_sae_cause_specify
   ,sae$$ || iter || $$otc_sae_outcome
   ,sae$$ || iter || $$otc_sae_outcome_label
    FROM atahc_ii.ig_k1002_ae$$ || iter || $$_$$ 
  as iter_selects
  FROM gen_ser
  ) as iter_selects_set
  )) as full_ae_set