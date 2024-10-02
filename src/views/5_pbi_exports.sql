CREATE SCHEMA pbi;

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

CREATE OR REPLACE VIEW pbi.arg
AS
WITH iso_orgs AS (
  SELECT isolates.id AS isolate_id, 
	 microbes.scientific_name AS organism
  FROM isolates
  LEFT JOIN microbes ON microbes.id = isolates.organism
), 
loc AS (
  SELECT sample_id AS sample_id,
         c.en_term AS country,
	 reg.en_term AS region
  FROM geo_loc as geo
  LEFT JOIN countries AS c ON c.id = geo.country
  LEFT JOIN state_province_regions AS reg ON reg.id = geo.state_province_region
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
       loc.country, 
       loc.region,
       amr.id AS amr_genes_id,
       amr.best_hit_aro, 
       amr.cut_off, 
       amr.model_type
FROM pro_sam_iso_wgs_ids AS pro
 LEFT JOIN bioinf.amr_genes_profiles AS amr
        ON pro.sequencing_id = amr.sequencing_id
 LEFT JOIN iso_orgs AS org 
        ON org.isolate_id = pro.isolate_id
 LEFT JOIN loc ON loc.sample_id = pro.sample_id
;

CREATE VIEW pbi.seq_counts
AS
SELECT project_name, 
       organism, 
       COUNT(DISTINCT sequencing_id) AS n_sequences, 
       COUNT(DISTINCT isolate_id) AS n_isolates
FROM pbi.arg
GROUP BY project_name, organism
;

CREATE OR REPLACE VIEW pbi.n_arg_per_isolate_seq 
AS 
SELECT project_name,
       user_isolate_id,
       library_id,
       organism, 
       cut_off,
       COUNT(amr_genes_id) AS n_arg,
       CASE WHEN COUNT(amr_genes_id) > 0 THEN TRUE
	    WHEN COUNT(amr_genes_id) = 0 THEN FALSE
	    ELSE NULL 
        END AS has_arg
FROM pbi.arg AS arg
GROUP BY project_name, user_isolate_id, library_id, organism, cut_off
;

CREATE OR REPLACE VIEW pbi.arg_drugs
AS
SELECT arg.project_name,
       arg.organism,
       arg.library_id, 
       arg.amr_genes_id,
       arg.region AS province,
       arg.best_hit_aro,
       arg.cut_off,
       drugs.drug_id
FROM pbi.arg AS arg
     INNER JOIN bioinf.amr_genes_drugs AS drugs 
     ON arg.amr_genes_id = drugs.amr_genes_id
;

CREATE OR REPLACE VIEW pbi.arg_families
AS
SELECT arg.project_name,
       arg.organism,
       arg.library_id, 
       arg.cut_off,
       fam.amr_gene_family_id AS gene_family
FROM pbi.arg AS arg
     INNER JOIN bioinf.amr_genes_families AS fam
     ON arg.amr_genes_id = fam.amr_genes_id
;

CREATE OR REPLACE VIEW pbi.n_with_drug
AS
WITH drugs AS (
  SELECT 
  DISTINCT arg.project_name, 
           arg.user_isolate_id, 
           arg.library_id, 
           arg.organism, 
           arg.cut_off,
           drugs.drug_id
      FROM pbi.arg AS arg
           JOIN bioinf.amr_genes_drugs AS drugs 
             ON arg.amr_genes_id = drugs.amr_genes_id
), n_isos AS (
  SELECT project_name, 
         organism, 
         COUNT(DISTINCT library_id) AS n_isolates
  FROM pbi.arg 
  GROUP BY project_name, organism
)
SELECT drugs.project_name, 
       drugs.organism, 
       drugs.cut_off,
       drugs.drug_id, 
       COUNT(*) AS n_with_drug, 
       n_isos.n_isolates
FROM drugs
     JOIN n_isos ON n_isos.project_name = drugs.project_name 
                AND n_isos.organism = drugs.organism
GROUP BY drugs.project_name, 
         drugs.organism, 
         drugs.cut_off, 
         n_isos.n_isolates, 
         drugs.drug_id;

CREATE OR REPLACE VIEW pbi.arg_all_info
AS
SELECT arg.amr_genes_id,
       arg.project_name,
       arg.organism,
       arg.library_id, 
       arg.best_hit_aro,
       arg.cut_off,
       drugs.drug_id, 
       fam.amr_gene_family_id AS gene_family, 
       mek.resistance_mechanism_id AS resistance_mechanism
FROM pbi.arg AS arg
     LEFT JOIN bioinf.amr_genes_drugs AS drugs 
     ON arg.amr_genes_id = drugs.amr_genes_id
     LEFT JOIN bioinf.amr_genes_families AS fam 
     ON arg.amr_genes_id = fam.amr_genes_id
     LEFT JOIN bioinf.amr_genes_resistance_mechanism AS mek 
     ON arg.amr_genes_id = mek.amr_genes_id
WHERE arg.amr_genes_id IS NOT NULL
;

CREATE OR REPLACE VIEW pbi.arg_food
AS
SELECT arg.project_name AS "Project Name",
       arg.organism AS "Organism",
       arg.library_id,
       arg.amr_genes_id, 
       arg.best_hit_aro AS "Gene",
       arg.cut_off AS "RGI Cut Off",
       arg.model_type AS "RGI Model",
       drugs.drug_id AS "Drug",
       food.id AS food_id,
       ontology_full_term(food.food_product_production_stream) AS "Production Stream", 
       food.food_packaging_date AS "Food Packaging Date", 
       food.food_quality_date AS "Food Quality Date"
  FROM pbi.arg AS arg
       LEFT JOIN food_data as food
              ON food.sample_id = arg.sample_id
       LEFT JOIN bioinf.amr_genes_drugs AS drugs 
              ON arg.amr_genes_id = drugs.amr_genes_id
;

CREATE OR REPLACE VIEW pbi.arg_by_food_product
AS 
SELECT arg."Project Name", 
       arg."Organism", 
       arg.library_id, 
       arg.amr_genes_id,
       arg."RGI Cut Off",
       arg."RGI Model",
       arg."Gene",
       arg."Drug",
       ontology_full_term(prod.term_id) AS "Food Product"
FROM pbi.arg_food AS arg
     LEFT JOIN food_data_product as prod
            ON prod.id = arg.food_id
;          

