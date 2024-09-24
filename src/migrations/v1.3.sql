INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (4, 1, 3, 'v1.3.sql', 'v12.2.2', CURRENT_DATE);

ALTER TABLE sequencing 
   ADD COLUMN r1_irida_id integer, 
   ADD COLUMN r2_irida_id integer;

ALTER TABLE isolates 
   ADD COLUMN BioSample_id text,
   ADD COLUMN BioProject_id text;


