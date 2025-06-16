CREATE VIEW bioinf.rgi_by_drug_class
AS
SELECT id,
       sequencing_id,
       orf_id,
       unnest(string_to_array(drug_class, ', ')) AS drug_class
  FROM bioinf.mob_rgi;

CREATE VIEW bioinf.rgi_by_antibiotic
AS
SELECT id,
       sequencing_id,
       orf_id,
       unnest(string_to_array(antibiotic, '; ')) AS antibiotic
  FROM bioinf.mob_rgi;

CREATE VIEW bioinf.rgi_by_gene_family
AS
SELECT id,
       sequencing_id,
       orf_id,
       unnest(string_to_array(amr_gene_families, '; ')) AS amr_gene_families
  FROM bioinf.mob_rgi;

CREATE VIEW bioinf.rgi_by_resistance_mechanism
AS
SELECT id,
       sequencing_id,
       orf_id,
       unnest(string_to_array(resistance_mechanism, '; ')) AS resistance_mechanism
  FROM bioinf.mob_rgi;

CREATE SCHEMA IF NOT EXISTS pbi;

CREATE view pbi.simple_contacts
AS
SELECT id AS contact_id,
       contact_name || ' (' || contact_email || ')' AS contact
  FROM contact_information;

create view pbi.all_ana
AS
  select sample_id, term_id FROM anatomical_data_body
  UNION
  select sample_id, term_id FROM anatomical_data_material
  UNION
  select sample_id, term_id FROM anatomical_data_part;

create view pbi.all_food
AS
  select sample_id, term_id FROM food_data_product_property
  UNION
  select sample_id, term_id FROM food_data_product;

create view pbi.all_env
AS
  select sample_id, term_id FROM environmental_data_material
  UNION
  select sample_id, term_id FROM environmental_data_site;

create view pbi.typed_fields
AS
WITH all_terms AS (
  select sample_id, 'anatomical'    as field_type, term_id FROM pbi.all_ana
  UNION
  select sample_id, 'environmental' as field_type, term_id FROM pbi.all_env
  UNION
  select sample_id, 'food'          as field_type, term_id FROM pbi.all_food
) SELECT sample_id, field_type, term_id FROM all_terms WHERE term_id NOT IN (select id from ontology_terms where en_term LIKE 'Not%');


CREATE view pbi.source_type
AS
WITH src AS (
SELECT sam.id as sample_id,
       sam.host_organism,
      CASE WHEN sam.id IN (SELECT sample_id FROM pbi.typed_fields WHERE field_type = 'anatomical'    ) THEN TRUE ELSE FALSE END AS anatomical,
      CASE WHEN sam.id IN (SELECT sample_id FROM pbi.typed_fields WHERE field_type = 'environmental' ) THEN TRUE ELSE FALSE END AS environmental,
      CASE WHEN sam.id IN (SELECT sample_id FROM pbi.typed_fields WHERE field_type = 'food'          ) THEN TRUE ELSE FALSE END AS food
from samples AS sam
)
select sample_id, food, anatomical, environmental, host_organism, org.en_common_name, org.scientific_name,
CASE WHEN host_organism =  (SELECT id from host_organisms where en_common_name = 'Human') AND NOT food THEN 'Human'
     WHEN host_organism <> (SELECT id from host_organisms where en_common_name = 'Human') AND NOT food AND anatomical THEN 'anatomical'
     WHEN (host_organism IS NULL OR host_organism IN (SELECT id from host_organisms where en_common_name LIKE 'Not%'))
           AND environmental AND NOT anatomical AND NOT food THEN 'environmental'
     WHEN food THEN 'food'
    ELSE 'Other' END AS source_type
from src
LEFT JOIN host_organisms AS org ON org.id = src.host_organism;

CREATE VIEW pbi.isolates_with_irida
AS
SELECT iso.id          AS isolate_id,
       org.scientific_name,
       src.source_type,
       sam.sample_collection_date,
       reg.en_term     AS province,
       contact.contact AS contact_information
  FROM isolates AS iso
  LEFT JOIN samples                AS sam     ON sam.id             = iso.sample_id
  LEFT JOIN pbi.simple_contacts    AS contact ON contact.contact_id = sam.contact_information
  LEFT JOIN microbes               AS org     ON org.id             = iso.organism
  LEFT JOIN pbi.source_type        AS src     ON src.sample_id      = iso.sample_id
  LEFT JOIN state_province_regions AS reg     ON reg.id             = sam.geo_loc_name_state_province_region
 WHERE irida_sample_id IS NOT NULL;

CREATE VIEW pbi.mob_rgi
AS
SELECT pbi.isolate_id,
       pbi.scientific_name,
       pbi.source_type,
       pbi.sample_collection_date,
       pbi.province,
       pbi.contact_information,
       wgs.sequencing_id,
       mob.orf_id,
       mob.cut_off,
       mob.best_hit_aro,
       mob.best_hit_bitscore,
       mob.drug_class,
       mob.resistance_mechanism,
       mob.amr_gene_families,
       mob.antibiotic,
       mob.molecule_type,
       mob.primary_cluster_id,
       mob.secondary_cluster_id
  FROM pbi.isolates_with_irida as pbi
  LEFT JOIN wgs                   ON wgs.isolate_id    = pbi.isolate_id
  LEFT JOIN bioinf.mob_rgi AS mob ON mob.sequencing_id = wgs.sequencing_id;

CREATE VIEW pbi.n_amr_genes_per_isolates
AS
SELECT isolate_id,
       scientific_name,
       cut_off,
       source_type,
       count(best_hit_aro) AS n_amr_genes
FROM pbi.mob_rgi as pbi
group by isolate_id, cut_off, scientific_name, source_type
order by isolate_id;

CREATE VIEW pbi.n_amr_genes_per_org
AS
select n_amr_genes,
       cut_off,
       scientific_name,
       count(*)
from pbi.n_amr_genes_per_isolates
group by n_amr_genes, cut_off, scientific_name
order by n_amr_genes;

CREATE VIEW pbi.all_rgi_tags
AS
SELECT rgi.isolate_id,
       rgi.scientific_name,
       rgi.source_type,
       rgi.sample_collection_date,
       rgi.province,
       rgi.contact_information,
       rgi.sequencing_id,
       rgi.orf_id,
       rgi.best_hit_aro,
      drug.drug_class,
        ab.antibiotic,
       fam.amr_gene_families,
      mech.resistance_mechanism
  FROM pbi.mob_rgi AS rgi
LEFT JOIN bioinf.rgi_by_drug_class           AS drug ON drug.orf_id = rgi.orf_id AND drug.sequencing_id = rgi.sequencing_id
LEFT JOIN bioinf.rgi_by_antibiotic           AS ab   ON   ab.orf_id = rgi.orf_id AND   ab.sequencing_id = rgi.sequencing_id
LEFT JOIN bioinf.rgi_by_gene_family          AS fam  ON  fam.orf_id = rgi.orf_id AND  fam.sequencing_id = rgi.sequencing_id
LEFT JOIN bioinf.rgi_by_resistance_mechanism AS mech ON mech.orf_id = rgi.orf_id AND mech.sequencing_id = rgi.sequencing_id;

