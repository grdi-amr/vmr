INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,22,'v2.21.sql', 'v14.5.4', CURRENT_DATE, 'Set project_id to Not Nullable in samples table');

ALTER TABLE samples ALTER COLUMN project_id SET NOT NULL;
