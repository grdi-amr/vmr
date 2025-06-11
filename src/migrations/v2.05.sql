INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,5,'v2.05.sql', 'v14.5.4', CURRENT_DATE, 'Brings strains table into its own column');

drop view projects_samples_isolates cascade;
drop view isolates_wide cascade;
alter table isolates drop constraint isolates_strain_fkey;

CREATE TEMPORARY TABLE fix_strains
AS
SELECT isolates.id AS isolate_id,
          strains.strain
  FROM isolates
 INNER JOIN strains ON strains.id = isolates.strain;

ALTER TABLE isolates ALTER COLUMN strain TYPE TEXT;

UPDATE isolates SET strain = fix_strains.strain FROM fix_strains WHERE fix_strains.isolate_id = isolates.id;

DROP TABLE strains CASCADE;

