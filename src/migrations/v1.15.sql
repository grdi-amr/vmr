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
    id TEXT,
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
