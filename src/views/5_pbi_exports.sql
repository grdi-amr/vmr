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

CREATE OR REPLACE VIEW pro_sam_iso_wgs_ids
AS 
select pro.project_id, 
       pro.project_name,
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
WITH iso_orgs AS (
  SELECT isolates.id AS isolate_id, 
	 microbes.scientific_name AS organism
  FROM isolates
  LEFT JOIN microbes ON microbes.id = isolates.organism
)
SELECT pro.project_id, 
       pro.project_name,
       pro.sample_id, 
       pro.sample_collector_sample_id, 
       pro.isolate_id,
       pro.user_isolate_id, 
       pro.sequencing_id, 
       pro.library_id, 
       org.organism,
       amr.id AS amr_genes_id,
       amr.best_hit_aro, 
       amr.cut_off, 
       amr.model_type
FROM pro_sam_iso_wgs_ids AS pro
LEFT JOIN bioinf.amr_genes_profiles AS amr
       ON pro.sequencing_id = amr.sequencing_id
LEFT JOIN iso_orgs AS org 
       ON org.isolate_id = pro.isolate_id
;

CREATE OR REPLACE VIEW bioinf.n_arg_per_isolate_seq 
AS 
SELECT project_name,
       user_isolate_id,
       library_id,
       organism, 
       cut_off,
       COUNT(amr_genes_id) AS n_arg
FROM bioinf.arg AS arg
GROUP BY project_name, user_isolate_id, library_id, organism, cut_off
;
