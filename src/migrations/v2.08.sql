INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,8,'v2.08.sql', 'v14.5.4', CURRENT_DATE, 'Adds new food product terms');

WITH new_prods AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
        VALUES ('FOODON:00002687', 'romaine lettuce head',            false),
               ('FOODON:00002989', 'Broccoli sprout',                 false),
               ('FOODON:00003535', 'blue plum',                       false),
               ('FOODON:00003547', 'sweet green bell pepper',         false),
               ('FOODON:02021341', 'piece of veal meat (boneless)',   false),
               ('FOODON:02021351', 'veal meat (ground)',              false),
               ('FOODON:03000018', 'red leaf lettuce',                false),
               ('FOODON:03304534', 'white wheat flour (all purpose)', false),
               ('FOODON:03311508', 'beef trim',                       false),
               ('FOODON:03411566', 'leafy vegetable plant',           false),
               ('FOODON:03601053', 'sambar',                          false)
     RETURNING id
) INSERT INTO food_products (ontology_term_id, curated) (SELECT id, false FROM new_prods);

