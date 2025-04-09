INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,16,'v1.16.sql', 'v14.5.4', CURRENT_DATE, 'Adds some new terms awaiting curation');

INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES ('UBERON:0002030', 'Nipple',		false),
	  ('UBERON:0000344', 'Mucosa',		false),
	  ('ENVO:00002191',  'Animal litter',	false);

INSERT INTO anatomical_parts	    (ontology_term_id, curated) (SELECT id, false FROM ontology_terms where ontology_id = 'UBERON:0002030');
INSERT INTO anatomical_materials    (ontology_term_id, curated) (SELECT id, false FROM ontology_terms where ontology_id = 'UBERON:0000344');
INSERT INTO environmental_materials (ontology_term_id, curated) (SELECT id, false FROM ontology_terms where ontology_id = 'ENVO:00002191' );

WITH new_activities AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
        VALUES ('TEMP:0000010', 'Raised without antibiotics farming practices',			      false),
	       ('TEMP:0000011', 'Raised without medically important antibiotics farming practices',   false)
     RETURNING id
) INSERT into activities (ontology_term_id, curated) (SELECT id, false FROM new_activities)
;
