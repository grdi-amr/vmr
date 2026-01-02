INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,13,'v2.13.sql', 'v14.5.4', CURRENT_DATE, 'Adds new values to agencies; Updates AST tables for more robust data integrity');

-- Insert new term into agencies
WITH new_terms AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('ror:01r7awg59',   'University of Guelph',     false)
   RETURNING id)
INSERT INTO agencies (ontology_term_id, curated) (SELECT id, FALSE FROM new_terms);

-- Insert new term into lab testing import
WITH new_terms AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('ARO:3004410', 'Micro Broth Dilution Method', false)
   RETURNING id)
INSERT INTO laboratory_typing_methods (ontology_term_id, curated) (SELECT id, FALSE FROM new_terms);

-- Insert new term into antimicrobial agents
WITH new_terms AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('ARO:0000067', 'Colistin', false)
   RETURNING id)
INSERT INTO antimicrobial_agents (ontology_term_id, curated) (SELECT id, FALSE FROM new_terms);

ALTER TABLE amr_antibiotics_profile
      ALTER COLUMN testing_intermediate_breakpoint TYPE TEXT,
      ALTER COLUMN measurement SET NOT NULL,
      ADD CONSTRAINT amr_antibiotics_profile_test_id_agent_unique UNIQUE (test_id, antimicrobial_agent);

-- There is a strange error in the database, remove it.
DELETE FROM am_susceptibility_tests WHERE id = 4095;
ALTER TABLE am_susceptibility_tests
      ADD CONSTRAINT am_tests_all_unique UNIQUE NULLS NOT DISTINCT
      (isolate_id, amr_testing_by, testing_date, contact_information);


