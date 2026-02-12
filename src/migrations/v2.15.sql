INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,15,'v2.15.sql', 'v14.5.4', CURRENT_DATE, 'Add a plain-text field for main contact for projects');

ALTER TABLE projects ADD COLUMN contact_name TEXT;

