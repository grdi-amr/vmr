INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,4,'v2.04.sql', 'v14.5.4', CURRENT_DATE, 'Fixes some tables in the bioinf schema');

-- A rename
ALTER TABLE bioinf.kleborate RENAME COLUMN spurious_virulence_hits TO spurious_resistance_hits;
-- Adds columns
ALTER TABLE bioinf.kleborate ADD COLUMN truncated_resistance_hits TEXT;
ALTER TABLE bioinf.kleborate ADD COLUMN flq_mutations             TEXT;
