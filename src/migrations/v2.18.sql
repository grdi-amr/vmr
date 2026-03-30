-- raw qc
CREATE TABLE bioinf.qc_raw_read_quality (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

    sequencing_id INTEGER REFERENCES sequencing(id),

    read_pair TEXT,

    total_bp BIGINT,
    total_reads BIGINT,

    qual_min INTEGER,
    qual_max INTEGER,
    qual_sum INTEGER,
    qual_mean FLOAT,
    qual_std FLOAT,

    read_qual_mean FLOAT,
    read_qual_std FLOAT,

    mean_sequence_length FLOAT,
    min_sequence_length INTEGER,
    max_sequence_length INTEGER,
    std_sequence_length FLOAT
);


-- quast qc
CREATE TABLE bioinf.qc_quast (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id INTEGER REFERENCES sequencing(id),

    assembly_name TEXT,

    -- Contiguity
    num_contigs INTEGER,
    largest_contig INTEGER,
    n50 INTEGER,
    n90 INTEGER,
    l50 INTEGER,
    l90 INTEGER,
    aun FLOAT,

    -- Assembly size
    total_length INTEGER,

    -- Composition
    gc_percent FLOAT,

    -- Read mapping QC (VERY valuable)
    total_reads INTEGER,
    mapped_percent FLOAT,
    properly_paired_percent FLOAT,

    -- Coverage
    coverage_depth FLOAT,
    coverage_1x_percent FLOAT,

    -- Cleanliness
    n_per_100kb FLOAT
);

-- fastp qc
CREATE TABLE bioinf.qc_fastp (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id INTEGER REFERENCES sequencing(id),

    -- General
    fastp_version TEXT,
    sequencing_type TEXT,

    -- BEFORE filtering
    reads_before INTEGER,
    bases_before INTEGER,
    q20_rate_before FLOAT,
    q30_rate_before FLOAT,
    gc_content_before FLOAT,

    -- AFTER filtering
    reads_after INTEGER,
    bases_after INTEGER,
    q20_rate_after FLOAT,
    q30_rate_after FLOAT,
    gc_content_after FLOAT,

    -- Filtering breakdown
    passed_reads INTEGER,
    low_quality_reads INTEGER,
    too_many_N_reads INTEGER,
    low_complexity_reads INTEGER,
    too_short_reads INTEGER,
    too_long_reads INTEGER,

    -- Duplication
    duplication_rate FLOAT
);

-- seqkit qc
CREATE TABLE bioinf.qc_seqkit_stats (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id INTEGER REFERENCES sequencing(id),

    file_name TEXT,
    format TEXT,
    seq_type TEXT,

    num_seqs INTEGER,
    total_bases BIGINT,
    min_len INTEGER,
    avg_len FLOAT,
    max_len INTEGER
);
