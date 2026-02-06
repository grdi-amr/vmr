INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,14,'v2.14.sql', 'v14.5.4', CURRENT_DATE, 'Adds bacment table to bioinf schema');

CREATE TABLE bioinf.bacmet (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    file              TEXT,
    sequence          TEXT,
    start_pos         INTEGER NOT NULL,
    end_pos           INTEGER NOT NULL,
    strand            CHAR(1) CHECK (strand IN ('+', '-')),
    gene              TEXT
    -- Alignment metrics
    coverage          TEXT,
    coverage_map      TEXT,
    gaps              TEXT,
    pct_coverage      FLOAT,
    pct_identity      FLOAT,
    -- BacMet-specific
    database          TEXT,
    prediction_status TEXT NOT NULL CHECK (prediction_status IN ('confirmed', 'predicted')),
    resistance        TEXT,
);
