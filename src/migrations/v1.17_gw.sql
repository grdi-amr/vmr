INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,17,'v1.17_gw.sql', 'v14.5.4', CURRENT_DATE, 'Changes schema bioinf to be more generic; adds new tables for new tools');

DROP TABLE IF EXISTS
  bioinf.amr_relaxase_type,
  bioinf.amr_ref_type,
  bioinf.amr_predicted_mobility,
  bioinf.amr_orit_types,
  bioinf.amr_mpf_type,
  bioinf.amr_genes_resistance_mechanism,
  bioinf.amr_genes_families,
  bioinf.amr_genes_drugs,
  bioinf.amr_mob_suite,
  bioinf.amr_genes_profiles
CASCADE;

CREATE TABLE bioinf.mob_rgi (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    orf_id TEXT,
    contig TEXT,
    start INTEGER,
    stop INTEGER,
    orientation TEXT,
    cut_off TEXT,
    pass_bitscore FLOAT,
    best_hit_bitscore FLOAT,
    best_hit_aro TEXT,
    best_identities FLOAT,
    aro TEXT,
    model_type TEXT,
    snps_in_best_hit_aro TEXT,
    other_snps TEXT,
    drug_class TEXT,  -- Stored as semicolon-separated string
    resistance_mechanism TEXT,  -- Semicolon-separated
    amr_gene_families TEXT,  -- Semicolon-separated
    predicted_dna TEXT,
    predicted_protein TEXT,
    card_protein_sequence TEXT,
    percentage_length_of_reference_sequence FLOAT,
    hsp_id TEXT,
    model_id TEXT,
    nudged TEXT,
    note TEXT,
    hit_start INTEGER,
    hit_end INTEGER,
    antibiotic TEXT,
    molecule_type TEXT,
    primary_cluster_id TEXT,
    secondary_cluster_id TEXT,
    size INTEGER,
    gc FLOAT,
    md5 TEXT,
    circularity_status TEXT,
    rep_type TEXT,  -- Stored as comma-separated string
    rep_type_accessions TEXT,  -- Comma-separated
    relaxase_type TEXT,  -- Comma-separated
    relaxase_type_accessions TEXT,  -- Comma-separated
    mpf_type TEXT,  -- Comma-separated
    mpf_type_accessions TEXT,  -- Comma-separated
    orit_type TEXT,  -- Comma-separated
    orit_accessions TEXT,  -- Comma-separated
    amr_predicted_mobility TEXT,  -- Comma-separated
    mash_nearest_neighbor TEXT,
    mash_neighbor_distance FLOAT,
    mash_neighbor_identification TEXT,
    repetitive_dna_id TEXT,
    repetitive_dna_type TEXT,
    filtering_reason TEXT
);

CREATE TABLE bioinf.kleborate (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    species TEXT,
    species_match TEXT,
    --- QC
    contig_count INT,
    N50 INT,
    largest_contig INT,
    total_size BIGINT,
    ambiguous_bases TEXT,
    QC_warnings TEXT,
    -- MLST: oxytoca & pneumo
    mlst_ST TEXT,
    clonal_complex TEXT,
    gapA TEXT,
    infB TEXT,
    mdh TEXT,
    pgi TEXT,
    phoE TEXT,
    rpoB TEXT,
    tonB TEXT,
    -- Yersiniabactin
    YbST TEXT,
    Yersiniabactin TEXT,
    ybtS TEXT,
    ybtX TEXT,
    ybtQ TEXT,
    ybtP TEXT,
    ybtA TEXT,
    irp2 TEXT,
    irp1 TEXT,
    ybtU TEXT,
    ybtT TEXT,
    ybtE TEXT,
    fyuA TEXT,
    spurious_ybt_hits TEXT,
    -- Colibactin
    CbST TEXT,
    Colibactin TEXT,
    clbA TEXT,
    clbB TEXT,
    clbC TEXT,
    clbD TEXT,
    clbE TEXT,
    clbF TEXT,
    clbG TEXT,
    clbH TEXT,
    clbI TEXT,
    clbL TEXT,
    clbM TEXT,
    clbN TEXT,
    clbO TEXT,
    clbP TEXT,
    clbQ TEXT,
    spurious_clb_hits TEXT,
    -- Aerobactin
    AbST TEXT,
    Aerobactin TEXT,
    iucA TEXT,
    iucB TEXT,
    iucC TEXT,
    iucD TEXT,
    iutA TEXT,
    spurious_abst_hits TEXT,
    -- Salmochelin
    SmST TEXT,
    Salmochelin TEXT,
    iroB TEXT,
    iroC TEXT,
    iroD TEXT,
    iroN TEXT,
    spurious_smst_hits TEXT,
    -- RmpADC
    RmST TEXT,
    RmpADC TEXT,
    rmpA TEXT,
    rmpD TEXT,
    rmpC TEXT,
    spurious_rmst_hits TEXT,
    rmpA2 TEXT,
    -- Virulence score (only for pneumoniae)
    virulence_score TEXT,
    spurious_virulence_hits TEXT,
    -- AMR (only for pneumoniae)
    AGly_acquired TEXT,
    Col_acquired TEXT,
    Fcyn_acquired TEXT,
    Flq_acquired TEXT,
    Gly_acquired TEXT,
    MLS_acquired TEXT,
    Phe_acquired TEXT,
    Rif_acquired TEXT,
    Sul_acquired TEXT,
    Tet_acquired TEXT,
    Tgc_acquired TEXT,
    Tmt_acquired TEXT,
    Bla_acquired TEXT,
    Bla_inhR_acquired TEXT,
    Bla_ESBL_acquired TEXT,
    Bla_ESBL_inhR_acquired TEXT,
    Bla_Carb_acquired TEXT,
    Bla_chr TEXT,
    SHV_mutations TEXT,
    Omp_mutations TEXT,
    Col_mutations TEXT
    --klebsiella complex
    wzi TEXT,
    K_locus TEXT,
    K_type TEXT,
    K_locus_confidence TEXT,
    K_locus_problems TEXT,
    K_locus_identity TEXT,
    K_missing_expected_genes TEXT,
    O_locus TEXT,
    O_type TEXT,
    O_locus_confidence TEXT,
    O_locus_problems TEXT,
    O_locus_identity TEXT,
    O_missing_expected_genes TEXT,
    --other results
    score__resistance_score TEXT,
    class_count__num_resistance_classes INT,
    gene_count__num_resistance_genes INT
    
);

CREATE TABLE bioinf.island_path (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    start_position INT,
    end_position INT
);

CREATE TABLE bioinf.integron_finder (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    id_replicon TEXT NOT NULL,         -- e.g., contig00001
    calin INTEGER NOT NULL,            -- number of CALINs
    complete INTEGER NOT NULL,         -- number of complete integrons
    in0 INTEGER NOT NULL,              -- number of In0 elements
    topology TEXT NOT NULL,
    size INTEGER NOT NULL              -- contig size
);

CREATE TABLE bioinf.digis_elements (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    seqid TEXT,                   -- e.g., contig00001
    source TEXT,                  -- e.g., digIS
    "type" TEXT,                    -- e.g., transposable_element
    "start" INTEGER,                -- start position
    "end" INTEGER,                  -- end position
    score FLOAT,                  -- similarity score (e.g., 0.99)
    strand TEXT CHECK (strand IN ('+', '-')),
    phase TEXT,                   -- usually '.', can be NULL
    element_id TEXT,              -- parsed from attributes: ID
    "level" TEXT,                   -- parsed from attributes: level (e.g., is, orf)
    qid TEXT,                     -- parsed from attributes: qID
    qstart INTEGER,              -- parsed from attributes
    qend INTEGER,                -- parsed from attributes
    blast_score FLOAT,           -- parsed from attributes: score
    evalue TEXT,                 -- parsed from attributes: evalue
    orf_similarity FLOAT,        -- parsed from attributes: ORF_sim
    is_similarity FLOAT,         -- parsed from attributes: IS_sim
    genbank_class TEXT           -- parsed from attributes: GenBank_class
);

CREATE TABLE bioinf.iceberg_blastn_genome (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    "sequence" TEXT,               -- contig name
    "start" INTEGER,
    "end" INTEGER,
    strand TEXT CHECK (strand IN ('+', '-')),
    iceberg_id TEXT,
    coverage_range TEXT,         -- e.g., '108695-109468/133500'
    gaps TEXT,                   -- e.g., '1/1'
    percent_coverage FLOAT,
    percent_identity FLOAT,
    "database" TEXT,               -- e.g., 'ICEberg'
    accession TEXT,              -- e.g., 'AL513382'
    product TEXT,                -- e.g., 'SPI-7'
    description TEXT             -- full description of the hit
);

CREATE TABLE bioinf.iceberg_blastp_genes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    "sequence" TEXT,               -- gene name
    "start" INTEGER,
    "end" INTEGER,
    strand TEXT CHECK (strand IN ('+', '-')),
    iceberg_id TEXT,
    coverage_range TEXT,         -- e.g., '1-259/259'
    gaps TEXT,                   -- e.g., '0/0'
    percent_coverage FLOAT,
    percent_identity FLOAT,
    "database" TEXT,               -- e.g., 'ICEberg'
    accession TEXT,              -- e.g., 'CAF28558.1'
    product TEXT,                -- short product name
    description TEXT             -- full description of the hit
);

