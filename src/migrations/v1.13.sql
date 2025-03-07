INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,13,'v1.13.sql', 'v13.3.4', CURRENT_DATE);

-- Add a note to the update table 
ALTER TABLE db_versions ADD COLUMN note text;
-- Add a note to current update
UPDATE db_versions
   SET note = 'Adds note column to db_version; adds chicken feed term, pre curation; removes not-null constrains on sample plans fields in projects table'
 WHERE major_release = 1 AND minor_release = 13;
-- Add chicken feed term to tables.
WITH terms_inserted AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('FOODON:03310338',   'Chicken feed',     false)
   RETURNING id)
INSERT INTO food_products (ontology_term_id, curated) VALUES ((SELECT id FROM terms_inserted),false);
-- Remove not nulls on sample_plan columns;
ALTER TABLE projects
      ALTER COLUMN sample_plan_name DROP NOT NULL,
      ALTER COLUMN sample_plan_id   DROP NOT NULL;


