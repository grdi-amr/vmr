INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,9,'v1.9.sql', 'v13.3.4', CURRENT_DATE);

-- Add primary key fo alt sample IDs
ALTER TABLE alternative_sample_ids  DROP CONSTRAINT  alternative_sample_ids_pkey;
ALTER TABLE alternative_sample_ids  DROP CONSTRAINT  alt_sample_ids_keep_unique;
ALTER TABLE alternative_sample_ids  ADD  PRIMARY KEY (sample_id, alternative_sample_id);

-- Add primary key fo alt isolate IDs
ALTER TABLE alternative_isolate_ids DROP CONSTRAINT alternative_isolate_ids_alternative_isolate_id_key;
ALTER TABLE alternative_isolate_ids ADD  PRIMARY KEY (isolate_id, alternative_isolate_id);


