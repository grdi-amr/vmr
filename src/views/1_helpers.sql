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
