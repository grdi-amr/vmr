ALTER TABLE db_versions DROP CONSTRAINT db_versions_pkey;
ALTER TABLE db_versions DROP COLUMN id;
ALTER TABLE db_versions ADD  PRIMARY KEY (major_release, minor_release);

INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,7,'v1.7.sql', 'v13.3.4', CURRENT_DATE);
