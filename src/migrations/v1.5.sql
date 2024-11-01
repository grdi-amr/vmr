-- Update versioning table 
INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (6, 1, 5, 'v1.5.sql', 'v12.2.2', CURRENT_DATE);

-- New term:
WITH ins AS (
   INSERT INTO ontology_terms 
      (ontology_id, en_term, curated) 
   VALUES 
      ('XCO:0000026', 'Surgical Removal', FALSE) 
   RETURNING id
)
INSERT INTO collection_methods 
   (ontology_term_id, curated)
VALUES
   ( (SELECT id FROM ins), FALSE )
;

