INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,19,'v2.19.sql', 'v14.5.4', CURRENT_DATE, 'Makes bioinf.qc_raw_read_quality.qual_sum to be BIGINT');

ALTER TABLE bioinf.qc_raw_read_quality ALTER COLUMN qual_sum TYPE BIGINT;
