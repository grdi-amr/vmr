INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,20,'v2.20.sql', 'v14.5.4', CURRENT_DATE, 'Makes bioinf.qc_fastp columns bases_before and bases_after type bigint');

ALTER TABLE bioinf.qc_fastp
    ALTER COLUMN bases_before TYPE bigint,
    ALTER COLUMN bases_after TYPE bigint;
