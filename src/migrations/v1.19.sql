-- adding columns related to patothype to ectyper

ALTER TABLE bioinf.ecoli_serotyping
ADD COLUMN pathotype TEXT,
ADD COLUMN pathotype_counts INTEGER,
ADD COLUMN pathotype_genes TEXT[],
ADD COLUMN pathotype_gene_names TEXT[],
ADD COLUMN pathotype_accessions TEXT[],
ADD COLUMN pathotype_allele_ids TEXT[],
ADD COLUMN pathotype_identities NUMERIC[],
ADD COLUMN pathotype_coverages NUMERIC[],
ADD COLUMN pathotype_gene_length_ratios NUMERIC[],
ADD COLUMN pathotype_rule_ids TEXT[],
ADD COLUMN pathotype_gene_counts TEXT,
ADD COLUMN pathodb_ver TEXT,
ADD COLUMN stx_subtypes TEXT[],
ADD COLUMN stx_accessions TEXT[],
ADD COLUMN stx_allele_ids TEXT[],
ADD COLUMN stx_allele_names TEXT[],
ADD COLUMN stx_identities NUMERIC[],
ADD COLUMN stx_coverages NUMERIC[],
ADD COLUMN stx_lengths INTEGER[],
ADD COLUMN stx_contig_names TEXT[],
ADD COLUMN stx_coordinates TEXT[];
