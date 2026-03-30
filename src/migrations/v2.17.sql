INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,17,'v2.17.sql', 'v14.5.4', CURRENT_DATE, 'Adds columns to vfdb table, and adds a table for phaster_blastp results');

-- phaster table
CREATE TABLE bioinf.phaster_blastp_hits (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    sequence TEXT,

    start_pos INTEGER,
    end_pos INTEGER,
    strand CHAR(1),

    phaster_id TEXT,

    coverage_raw TEXT,
    gaps_raw TEXT,

    coverage_percent FLOAT,
    identity_percent FLOAT,

    database TEXT,
    accession TEXT,
    product_id TEXT,
    product_description TEXT
);

-- Adding columns to vfdb table
ALTER TABLE bioinf.virulence_vfdb
ADD COLUMN file_name TEXT,              -- #FILE (e.g. AMC1007.fna)
ADD COLUMN sequence_id TEXT,            -- contig (NODE_...)
ADD COLUMN start_pos INTEGER,
ADD COLUMN end_pos INTEGER,
ADD COLUMN strand CHAR(1),

ADD COLUMN gene TEXT,                   -- e.g. astA, fimB

ADD COLUMN coverage_raw TEXT,           -- 1-117/117
ADD COLUMN coverage_map TEXT,           -- ======= (visual)

ADD COLUMN gaps_raw TEXT,               -- 0/0

ADD COLUMN coverage_percent NUMERIC(5,2),
ADD COLUMN identity_percent NUMERIC(5,2),

ADD COLUMN database TEXT,               -- vfdb
ADD COLUMN vfdb_accession TEXT;         -- BAA94855


