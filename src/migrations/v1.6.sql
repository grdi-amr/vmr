-- Update versioning table 
INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (7, 1, 6, 'v1.6.sql', 'v13.3.4', CURRENT_DATE);

CREATE TABLE time_of_day (
   ontology_term_id int4 PRIMARY KEY REFERENCES ontology_terms(id),
   curated boolean DEFAULT true
);

WITH terms_inserted AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('NCIT:C64934',   'Morning',     true),
	    ('NCIT:C64935',   'Afternoon',   true),
	    ('NCIT:C64936',   'Evening',     true),
	    ('NCIT:C65001',   'Night',       true)
   RETURNING id)
INSERT INTO time_of_day (ontology_term_id) (SELECT id FROM terms_inserted);


WITH terms_inserted AS (
   INSERT INTO ontology_term (ontology_id, en_term, curated)
   VALUES   ('ENVO:06105300',    'Wastewater treatment process',          true),
            ('GENEPIO:0100881',  'Wastewater filtration',                 true),
            ('GENEPIO:0100882',  'Wastewater grit removal',               true),
            ('GENEPIO:0100883',  'Wastewater microbial treatment',        true),
            ('GENEPIO:0100884',  'Wastewater primary sedimentation',      true),
            ('GENEPIO:0100885',  'Wastewater secondary sedimentation',    true)
   RETURNING id)
INSERT INTO activities (ontology_term_id) (SELECT id FROM terms_inserted);

WITH terms_inserted AS (
   INSERT INTO ontology_term (ontology_id, en_term, curated)
   VALUES   ('ENVO:00000037',  'Ditch',                          true),
            ('ENVO:00000140',  'Drainage ditch',                 true),
            ('ENVO:00000139',  'Irrigation ditch',               true),
            ('ENVO:01000924',  'Plumbing drain',                 true),
            ('ENVO:00002272',  'Wastewater treatment plant',     true)
   RETURNING id)
INSERT INTO environmental_sites (ontology_term_id) (SELECT id FROM terms_inserted);

-- Update Pig Manure term to have the correct Ontology ID
UPDATE ontology_terms SET ontology_id = 'ENVO:00003860' WHERE en_term = 'Pig manure';

-- Add new terms to environemtal_materials, and also add the poultry litter term, which had not been added due to an ontology_term_id conflict.
WITH terms_inserted AS (
   INSERT INTO ontology_term (ontology_id, en_term, curated)
   VALUES   ('ENVO:00002044', 'Sludge',            true),
            ('ENVO:00002057', 'Primary sludge',    true),
            ('ENVO:00002058', 'Secondary sludge',  true),
            ('AGRO:00000080', 'Poultry litter',    true)
   RETURNING id)
INSERT INTO environmental_materials (ontology_term_id) (SELECT id FROM terms_inserted);

ALTER TABLE collection_information
   ADD COLUMN specimen_processing_details           text,
   ADD COLUMN sample_collection_end_date            date,
   ADD COLUMN sample_processing_date                date,
   ADD COLUMN sample_collection_start_time          time,
   ADD COLUMN sample_collection_end_time            time,
   ADD COLUMN sample_collection_time_of_day         int      REFERENCES time_of_day(ontology_term_id),
   ADD COLUMN sample_collection_time_duration_value int,
   ADD COLUMN sample_collection_time_duration_unit  int      REFERENCES duration_units(ontology_term_id);

ALTER TABLE environmental_data
   ADD COLUMN sampling_weather_conditions       text,
   ADD COLUMN presampling_weather_conditions    text,
   ADD COLUMN precipitation_measurement_value   text,
   ADD COLUMN precipitation_measurement_unit    text,
   ADD COLUMN precipitation_measurement_method  text

ALTER TABLE sequencing RENAME COLUMN assembly_filename TO genome_sequence_filename;

