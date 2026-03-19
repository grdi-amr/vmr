INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,16,'v2.16.sql', 'v14.5.4', CURRENT_DATE, 'Adds new ontology terms to accomodate Rahat Zaheer data');

-- Insert new term into agencies
WITH new_terms AS (
   INSERT INTO ontology_terms
          (ontology_id,      en_term,                        curated)
   VALUES ('ror:02nt5es71', 'Alberta Health Services (AHS)', false)
   RETURNING id)
INSERT INTO agencies (ontology_term_id, curated) (SELECT id, FALSE FROM new_terms);

-- Insert new term into collection methods
INSERT INTO collection_methods (ontology_term_id, curated) (
   SELECT id, FALSE FROM ontology_terms WHERE en_term = 'Swab'
);

-- Insert new term into env sites
WITH new_terms AS (
   INSERT INTO ontology_terms
          (ontology_id,      en_term,       curated)
   VALUES ('ENVO:00000043', 'Wetland area', false),
          ('TEMP:0000022' , 'Storage Pond', false)
   RETURNING id)
INSERT INTO environmental_sites (ontology_term_id, curated) (SELECT id, FALSE FROM new_terms);

-- Update the antibiotic-free terms that were added temporarily. Set curated to TRUE
UPDATE ontology_terms
   SET ontology_id = 'GENEPIO:0102081',
           en_term = 'Animals raised without antibiotics',
           curated = TRUE
 WHERE id = 955;

UPDATE ontology_terms
   SET ontology_id = 'GENEPIO:0102082',
           en_term = 'Animals raised without medically important antibiotics',
           curated = TRUE
 WHERE id = 956;

UPDATE activities SET curated = TRUE WHERE ontology_term_id IN (955, 956);
