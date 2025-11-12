INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,11,'v2.11.sql', 'v14.5.4', CURRENT_DATE, 'Adds Calamari term to food_products');
 
WITH new_terms AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('FOODON:00002897',   'Calamari',     false)
   RETURNING id)
INSERT INTO food_products (ontology_term_id) (SELECT id FROM new_terms);

