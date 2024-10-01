CREATE OR REPLACE VIEW project_stats
AS
SELECT p.id AS database_id, 
       p.sample_plan_id AS "Sample plan ID",
       p.sample_plan_name AS "Sample plan name",
       project_name AS "Project name",
       Count(DISTINCT s.id) AS "Number of Samples",
       Count(DISTINCT i.id) AS "Number of Isolates",
       Count(DISTINCT wgs.sequencing_id) AS "Number of WGS",
       Count(DISTINCT ab.id) AS "Number of AST"
  FROM projects AS p
       LEFT JOIN samples AS s
	      ON p.id = s.project_id
       LEFT JOIN isolates AS i
	      ON i.sample_id = s.id
       LEFT JOIN wgs 
	      ON wgs.isolate_id = i.id
       LEFT JOIN am_susceptibility_tests as ab
	      ON ab.isolate_id =  i.id
GROUP BY p.id;

DROP VIEW IF EXISTS pro_sam_iso_wgs_ids CASCADE;
CREATE OR REPLACE VIEW pro_sam_iso_wgs_ids
AS 
select pro.project_id, 
       pro.sample_id, 
       pro.sample_collector_sample_id, 
       pro.isolate_id,
       pro.user_isolate_id, 
       wgs.sequencing_id, 
       wgs.library_id
from wgs 
INNER JOIN projects_samples_isolates AS pro ON pro.isolate_id = wgs.isolate_id
;

CREATE OR REPLACE VIEW bioinf.arg
AS
SELECT pro.project_id, 
       pro.isolate_id,
       pro.sequencing_id, 
       isolates.organism AS organism_id,
       geo_loc.country AS country_id, 
       geo_loc.state_province_region AS province_id,
       amr.id AS amr_genes_id,
       amr.best_hit_aro, 
       amr.cut_off, 
       amr.model_type
FROM pro_sam_iso_wgs_ids AS pro
 LEFT JOIN bioinf.amr_genes_profiles AS amr
        ON pro.sequencing_id = amr.sequencing_id
 LEFT JOIN isolates ON pro.isolate_id = isolates.id
 LEFT JOIN geo_loc ON geo_loc.sample_id = pro.sample_id
;

CREATE OR REPLACE VIEW bioinf.n_arg_per_isolate_seq 
AS 
SELECT project_id,
       isolate_id,
       sequencing_id,
       organism_id, 
       cut_off,
       COUNT(amr_genes_id) AS n_arg,
       CASE WHEN COUNT(amr_genes_id) > 0 THEN TRUE
      WHEN COUNT(amr_genes_id) = 0 THEN FALSE
      ELSE NULL 
        END AS has_arg
FROM bioinf.arg AS arg
GROUP BY project_id, isolate_id, sequencing_id, organism_id, cut_off
;

CREATE OR REPLACE VIEW bioinf.n_with_drug
AS
WITH drugs AS (
  SELECT 
  DISTINCT arg.project_id, 
           arg.sequencing_id, 
           arg.organism_id, 
           arg.cut_off,
           drugs.drug_id
      FROM bioinf.arg AS arg
           JOIN bioinf.amr_genes_drugs AS drugs 
             ON arg.amr_genes_id = drugs.amr_genes_id
)
SELECT drugs.project_id,
       drugs.organism_id, 
       drugs.cut_off,
       drugs.drug_id, 
       COUNT(*) AS n_with_drug
FROM drugs
GROUP BY drugs.project_id,
         drugs.organism_id, 
         drugs.cut_off, 
         drugs.drug_id;
