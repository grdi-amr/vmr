CREATE TABLE db_versions (
	id int4 PRIMARY KEY,
	major_release int NOT NULL,
	minor_release int NOT NULL, 
	script_name text NOT NULL,
	grdi_template_version text, 
	date_applied date NOT NULL
);

INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (1, 1, 0, 'initial installation', 'v11.1.1', CURRENT_DATE);
