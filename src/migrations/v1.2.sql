BEGIN;

INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (3, 1, 2, 'v1.2.sql', 'v12.2.2', CURRENT_DATE);

-- Add irida colums to the isolates table
ALTER TABLE isolates 
ADD COLUMN irida_sample_id integer,
ADD COLUMN irida_project_id integer
;

-- Migrate existing data to the new location.
WITH update_vals AS (
   SELECT wgs.isolate_id,
	  seq.irida_isolate_id::int,
	  seq.irida_project_id::int
     FROM sequencing AS seq
          LEFT JOIN extractions AS ex
	         ON ex.id = seq.extraction_id 
	  LEFT JOIN wgs_extractions AS wgs
	         ON wgs.extraction_id = ex.id
    WHERE seq.irida_isolate_id IS NOT NULL
)
UPDATE isolates
   SET irida_sample_id = upd.irida_isolate_id::int,
       irida_project_id = upd.irida_project_id::int
  FROM update_vals AS upd
 WHERE isolates.id = upd.isolate_id
;

-- remove the old irida columns
ALTER TABLE sequencing 
 DROP COLUMN irida_isolate_id CASCADE,
 DROP COLUMN irida_project_id CASCADE;

COMMIT;

