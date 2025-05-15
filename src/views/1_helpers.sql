CREATE VIEW foreign_keys 
AS 
SELECT    
	tc.table_schema,      
	tc.constraint_name, 
	tc.table_name, 
	kcu.column_name, 
	ccu.table_schema AS foreign_table_schema,
	ccu.table_name AS foreign_table_name,
	ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema='public';

CREATE VIEW possible_isolate_names
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

CREATE VIEW possible_sample_names
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

CREATE VIEW alt_iso_wide 
AS
  SELECT isolate_id, 
	 string_agg(alternative_isolate_id, '; ') AS alt_isolate_names
    FROM alternative_isolate_ids 
GROUP BY isolate_id;

CREATE OR REPLACE VIEW projects_samples_isolates 
AS
SELECT p.id AS project_id, 
       p.sample_plan_id, 
       p.sample_plan_name,
       p.project_name,
       p.description,
       s.id AS sample_id, 
       s.sample_collector_sample_id AS sample_collector_sample_id,
       i.id AS isolate_id,
       i.isolate_id AS user_isolate_id, 
       i.biosample_id AS BioSample_accession,
       i.bioproject_id AS BioProject_accession,
       i.irida_project_id,
       i.irida_sample_id,
       i.organism,
       i.strain,
       i.microbiological_method,
       i.progeny_isolate_id,
       i.isolated_by,
       i.contact_information,
       i.isolation_date,
       i.isolate_received_date,
       i.taxonomic_identification_process,
       i.taxonomic_identification_process_details,
       i.serovar,
       i.serotyping_method,
       i.phagetype
FROM projects AS p
     LEFT JOIN samples AS s 
            ON s.project_id = p.id
     LEFT JOIN isolates AS i
            ON i.sample_id = s.id;

CREATE OR REPLACE VIEW wgs
       AS
   SELECT wgs.isolate_id,
          ext.id AS extraction_id,
          seq.id AS sequencing_id,
          seq.library_id,
          ext.experimental_protocol_field,
          ext.experimental_specimen_role_type,
          ext.nucleic_acid_extraction_method,
          ext.nucleic_acid_extraction_kit,
          ext.sample_volume_measurement_value,
          ext.sample_volume_measurement_unit,
          ext.residual_sample_status,
          ext.sample_storage_duration_value,
          ext.sample_storage_duration_unit,
          ext.nucleic_acid_storage_duration_value,
          ext.nucleic_acid_storage_duration_unit,
          seq.contact_information,
          seq.sequenced_by,
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
LEFT JOIN extractions AS ext
       ON wgs.extraction_id = ext.id 
LEFT JOIN sequencing AS seq
       ON ext.id = seq.extraction_id;
