CREATE TABLE bioinf.res_resfinder (
	
	sequencing_id int4 REFERENCES sequencing(id),
	resfinder_gene int4 REFERENCES resfinder_genes(id),
    CONSTRAINT res_resfinderpkey PRIMARY KEY (sequencing_id, resfinder_gene)
);

CREATE TABLE bioinf.resfinder_genes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Resfinder_gene text
);
CREATE TABLE bioinf.genes_predicted_phenotypes (
    resfinder_gene int4 REFERENCES resfinder_genes(id),
    predicted_phenotype REFERENCES predicted_phenotypes(id),
    CONSTRAINT resfinder_predicted_phenotypes_pkey PRIMARY KEY (sequencing_id, predicted_phenotype)
);
CREATE TABLE bioinf.predicted_phenotypes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    predicted_phenotype text
);

CREATE TABLE bioinf.res_mlst (
	
	sequencing_id int4 REFERENCES sequencing(id),
	mlst_sequence int4 REFERENCES mlst_sequences(id),
    CONSTRAINT res_mlst_pkey PRIMARY KEY (sequencing_id, mlst_sequence)
);
CREATE TABLE bioinf.mlst_sequence (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    mlst_sequence text,
    mlst_scheme text
);
CREATE TABLE bioinf.res_plasmid_finder (
	
	sequencing_id int4 REFERENCES sequencing(id),
	plasmid int4 REFERENCES plasmid_finder_table(id),
    CONSTRAINT res_plasmid_finder PRIMARY KEY (sequencing_id, plasmid)
);
CREATE TABLE bioinf.plasmid_finder_table (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    plasmid text
);
--Serotyping
CREATE TABLE bioinf.res_ecoli_serotyping (
	
	sequencing_id int4 REFERENCES sequencing(id),
	ecoli_serotype int4 REFERENCES ecoli_serotypes(id),
    CONSTRAINT res_ecoli_serotyping_pkey PRIMARY KEY (sequencing_id, ecoli_serotype)
);
CREATE TABLE bioinf.ecoli_serotypes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    serotype text,
    htype text,
    otype
);
CREATE TABLE bioinf.res_salmonella_serotyping (
	
	sequencing_id int4 REFERENCES sequencing(id),
	salmonela_serotype int4 REFERENCES salomnella_serotypes(id),
    CONSTRAINT res_salmonella_serotyping_pkey PRIMARY KEY (sequencing_id, salmonella_serotype)
);
CREATE TABLE bioinf.salmonella_serotypes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    serovar text,
    serovar_antigen text,
    serogroup text,
    o_antigen text,
    h2 text,
    h1 text,
    genome text
);
--VFDB using Abricate
CREATE TABLE bioinf.res_virulence_VFDB (
	
	sequencing_id int4 REFERENCES sequencing(id),
	vfdb_gene_accession int4 REFERENCES vfdb_genes(id),
    CONSTRAINT res_virulence_VFDB_pkey PRIMARY KEY (sequencing_id, vfdb_gene_accession)
);
CREATE TABLE bioinf.vfdb_genes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    vfdb_gene_accession text,
    vfdb_product_resisence text
);
-- Virulence finder results
CREATE TABLE bioinf.res_virulence_VF (
	
	sequencing_id int4 REFERENCES sequencing(id),
	vf_gene int4 REFERENCES vf_genes(id),
    CONSTRAINT res_virulence_VF_pkey PRIMARY KEY (sequencing_id, vf_genevf_gene)
);
CREATE TABLE bioinf.vf_genes (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    vf_gene text
    
);