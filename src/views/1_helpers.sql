CREATE MATERIALIZED VIEW IF NOT EXISTS foreign_keys
AS
SELECT tc.table_schema,
       tc.constraint_name,
       tc.table_name,
       kcu.column_name,
       ccu.table_schema AS foreign_table_schema,
       ccu.table_name   AS foreign_table_name,
       ccu.column_name  AS foreign_column_name
  FROM information_schema.table_constraints       AS tc
  JOIN information_schema.key_column_usage        AS kcu ON tc.constraint_name  = kcu.constraint_name
                                                        AND tc.table_schema     = kcu.table_schema
  JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
 WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema='public';

REFRESH MATERIALIZED VIEW foreign_keys;

CREATE VIEW ontology_columns
AS
select table_name, column_name from foreign_keys where foreign_table_name IN (SELECT table_name FROM foreign_keys WHERE foreign_table_name = 'ontology_terms');

CREATE VIEW country_cols
AS
select table_name, column_name from foreign_keys where foreign_table_name = 'countries' AND table_name <> 'state_province_regions';

CREATE OR REPLACE VIEW possible_isolate_names
AS
  SELECT i.id AS isolate_id,
         i.isolate_id AS isolate_collector_id,
         'Assigned as main isolate ID'::text AS note
    FROM isolates AS i
UNION ALL
  SELECT a.isolate_id,
         a.alternative_isolate_id AS isolate_collector_id,
         a.note
    FROM alternative_isolate_ids as a
ORDER BY isolate_id;

CREATE OR REPLACE VIEW possible_sample_names
AS
  SELECT sam.id                             AS sample_id,
         sam.sample_collector_sample_id     AS user_sample_id,
         'Assigned as main sample ID'::text AS note
    FROM samples AS sam
UNION ALL
  SELECT alt.sample_id,
         alt.alternative_sample_id AS user_sample_id,
         alt.note
    FROM alternative_sample_ids AS alt
ORDER BY sample_id;

CREATE OR REPLACE VIEW alt_iso_wide
AS
  SELECT isolate_id,
	 string_agg(alternative_isolate_id, '; ') AS alt_isolate_names
    FROM alternative_isolate_ids
GROUP BY isolate_id;

CREATE OR REPLACE VIEW alt_sample_wide
AS
  SELECT sample_id,
	 string_agg(alternative_sample_id, '; ') AS alternative_sample_ids
    FROM alternative_sample_ids
GROUP BY sample_id;

CREATE OR REPLACE VIEW projects_samples_isolates
AS
SELECT pro.id                         AS project_id,
       pro.sample_plan_id,
       pro.sample_plan_name,
       pro.project_name,
       pro.description,
       sam.id                         AS sample_id,
       sam.sample_collector_sample_id AS sample_collector_sample_id,
       iso.id                         AS isolate_id,
       iso.isolate_id                 AS user_isolate_id,
       iso.biosample_id               AS BioSample_accession,
       iso.bioproject_id              AS BioProject_accession,
       iso.irida_project_id,
       iso.irida_sample_id,
       iso.organism,
       iso.strain,
       iso.microbiological_method,
       iso.progeny_isolate_id,
       iso.isolated_by,
       iso.contact_information,
       iso.isolation_date,
       iso.isolate_received_date,
       iso.taxonomic_identification_process,
       iso.taxonomic_identification_process_details,
       iso.serovar,
       iso.serotyping_method,
       iso.phagetype
  FROM projects      AS pro
  LEFT JOIN samples  AS sam ON sam.project_id = pro.id
  LEFT JOIN isolates AS iso ON iso.sample_id  = sam.id;

CREATE OR REPLACE VIEW wgs
       AS
   SELECT wgs.isolate_id,
	  iso.irida_sample_id,
          ext.id AS extraction_id,
          seq.id AS sequencing_id,
          seq.library_id,
          ext.nucleic_acid_extraction_method,
          ext.nucleic_acid_extraction_kit,
          ext.nucleic_acid_storage_duration_value,
          ext.nucleic_acid_storage_duration_unit,
          seq.contact_information,
          seq.sequenced_by,
          seq.sequencing_date,
          seq.sequencing_project_name,
          seq.sequencing_platform,
          seq.sequencing_instrument,
          seq.sequencing_assay_type,
          seq.dna_fragment_length,
          seq.genomic_target_enrichment_method,
          seq.genomic_target_enrichment_method_details,
          seq.amplicon_pcr_primer_scheme,
          seq.amplicon_size,
          seq.sequencing_flow_cell_version,
          seq.library_preparation_kit,
          seq.sequencing_protocol,
          seq.r1_fastq_filename,
          seq.r2_fastq_filename,
          seq.fast5_filename,
          seq.genome_sequence_filename,
          seq.r1_irida_id,
          seq.r2_irida_id
     FROM wgs_extractions AS wgs
LEFT JOIN extractions     AS ext ON wgs.extraction_id = ext.id
LEFT JOIN sequencing      AS seq ON ext.id            = seq.extraction_id
LEFT JOIN isolates 	  AS iso ON iso.id 	      = wgs.isolate_id;

CREATE OR REPLACE VIEW latest_version
AS
SELECT major_release || '.' || LPAD(minor_release::text, 2, '0') AS db_ver,
       grdi_template_version                                     AS template_ver,
       date_applied,
       note
  FROM db_versions
  ORDER BY major_release DESC,
           minor_release DESC LIMIT 1;

