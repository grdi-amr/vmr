INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,6,'v2.06.sql', 'v14.5.4', CURRENT_DATE, 'Adds API term to microbial identification');

WITH new_identifications AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
        VALUES ('MICRO:0000655', 'API microbial identification test kit', false)
     RETURNING id
) INSERT INTO taxonomic_identification_processes (ontology_term_id, curated) (SELECT id, false FROM new_identifications)
;

