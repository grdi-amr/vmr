INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,21,'v2.21.sql', 'v14.5.4', CURRENT_DATE, 'Adds new food terms to accomodate Richard Reid-Smith isoaltes');

WITH new_prods AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
        VALUES ('FOODON:02021339', 'piece of veal meat', false),
               ('FOODON:02021303', 'veal tongue',        false),
               ('FOODON:02021300', 'veal liver',         false),
               ('FOODON:02021386', 'veal chop',          false)
     RETURNING id
) INSERT INTO food_products (ontology_term_id, curated) (SELECT id, false FROM new_prods);
