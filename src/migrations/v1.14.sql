INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,14,'v1.14.sql', 'v14.5.4', CURRENT_DATE, 'Updates schema to conform to GRDI template version');

-- First, "Surgival Removal" has been officially added - reflect this in the schema.
UPDATE ontology_terms      SET curated = TRUE WHERE en_term          = 'Surgical Removal';
UPDATE collection_methods  SET curated = TRUE WHERE ontology_term_id = (SELECT id FROM ontology_terms WHERE en_term = 'Surgical Removal');

-- Add new sequencing date field.
ALTER TABLE sequencing ADD COLUMN sequencing_date DATE;

-- Add some new terms to the agencies list. 
-- This is going to break the database update sequence - there is no update that initially added these, but
-- I feel a bit too lazy to add it in post.
UPDATE ontology_terms SET ontology_id = 'GENEPIO:0102053', en_description = NULL, curated = TRUE WHERE en_term = 'BCCDC Public Health Laboratory';
UPDATE ontology_terms SET ontology_id = 'GENEPIO:0102054', en_description = NULL, curated = TRUE WHERE en_term = 'Manitoba Cadham Provincial Laboratory';
UPDATE ontology_terms SET ontology_id = 'GENEPIO:0102055', en_description = NULL, curated = TRUE WHERE en_term = 'New Brunswick - Vitalité Health Network';
-- Something a little different for Quebec.
UPDATE ontology_terms
   SET ontology_id    = 'GENEPIO:0102056',
       en_description = NULL,
       en_term        = 'Public Health Laboratory of Quebec',
       fr_term        = 'Laboratoire de santé publique du Québec (LSPQ)',
       curated        = TRUE
 WHERE en_term = 'Laboratoire de santé publique du Québec (LSPQ)';

-- New antibiotics!
WITH terms_inserted AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated) 
   VALUES ('CHEBI:17334',   'Penicillin',  true),
          ('CHEBI:7507',    'Neomycin',    true)
   RETURNING id)
INSERT INTO antimicrobial_agents (ontology_term_id, curated) (SELECT id, true FROM terms_inserted);

