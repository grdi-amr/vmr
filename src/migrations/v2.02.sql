INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,2,'v2.02.sql', 'v14.5.4', CURRENT_DATE, 'Adds audit columns to sample table');

ALTER TABLE samples
        ADD COLUMN inserted_at timestamptz NOT NULL DEFAULT now(),
        ADD COLUMN inserted_by text        NOT NULL DEFAULT current_user,
        ADD COLUMN was_updated bool                 DEFAULT FALSE;

