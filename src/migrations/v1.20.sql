-- altering values in columns from float/numeric to text since they can have multiple values separated to ";"

ALTER TABLE bioinf.ecoli_serotyping
    ALTER COLUMN pathotype_counts TYPE TEXT,
    ALTER COLUMN pathotype_identities TYPE TEXT,
    ALTER COLUMN pathotype_coverages TYPE TEXT,
    ALTER COLUMN pathotype_gene_length_ratios TYPE TEXT,
    ALTER COLUMN stx_identities TYPE TEXT,
    ALTER COLUMN stx_coverages TYPE TEXT,
    ALTER COLUMN stx_lengths TYPE TEXT;
