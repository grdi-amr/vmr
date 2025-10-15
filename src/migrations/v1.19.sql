INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,19,'v1.19.sql', 'v14.5.4', CURRENT_DATE, 'Adds new pathotype columns to bioinf table to accomodate the update to ectyper');

ALTER TABLE bioinf.ecoli_serotyping
 ADD COLUMN pathotype                    TEXT,
 ADD COLUMN pathotype_counts             INTEGER,
 ADD COLUMN pathotype_genes              TEXT,
 ADD COLUMN pathotype_gene_names         TEXT,
 ADD COLUMN pathotype_accessions         TEXT,
 ADD COLUMN pathotype_allele_ids         TEXT,
 ADD COLUMN pathotype_identities         FLOAT,
 ADD COLUMN pathotype_coverages          FLOAT,
 ADD COLUMN pathotype_gene_length_ratios NUMERIC,
 ADD COLUMN pathotype_rule_ids           TEXT,
 ADD COLUMN pathotype_gene_counts        TEXT,
 ADD COLUMN pathodb_ver                  TEXT,
 ADD COLUMN stx_subtypes                 TEXT,
 ADD COLUMN stx_accessions               TEXT,
 ADD COLUMN stx_allele_ids               TEXT,
 ADD COLUMN stx_allele_names             TEXT,
 ADD COLUMN stx_identities               FLOAT,
 ADD COLUMN stx_coverages                FLOAT,
 ADD COLUMN stx_lengths                  INTEGER,
 ADD COLUMN stx_contig_names             TEXT,
 ADD COLUMN stx_coordinates              TEXT;
