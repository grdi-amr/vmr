--Resfinder results - One sequencing can get multiple genes results which can have many predicted phenotypes each gene
CREATE TABLE bioinf.resfinder (
    sequencing_id int4 REFERENCES sequencing(id),
    resfinder_gene text,
    CONSTRAINT resfinderpkey PRIMARY KEY (sequencing_id, resfinder_gene)
);

CREATE TABLE bioinf.resfinder_predicted_phenotypes (
    sequencing_id int4 REFERENCES bioinf.resfinder(sequencing_id),
    resfinder_gene text REFERENCES bioinf.resfinder(resfinder_gene),
    predicted_phenotype text,
    CONSTRAINT resfinder_predicted_phenotypes_pkey PRIMARY KEY (sequencing_id, resfinder_gene, predicted_phenotype)
);

-- MLST results, one sequencing has one MLST sequence
CREATE TABLE bioinf.mlst (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    mlst_sequence text,
    mlst_scheme text
);

-- Plasmid finder results , each sequencing can have multiple plasmids
CREATE TABLE bioinf.plasmid_finder (
    sequencing_id int4 REFERENCES sequencing(id),
    plasmid text,
    CONSTRAINT plasmid_finder PRIMARY KEY (sequencing_id, plasmid)
);

--Serotyping for e.coli -> one serotype for each sequencing
CREATE TABLE bioinf.ecoli_serotyping (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    ecoli_serotype text,
    htype text,
    otype text
);

-- Salmonella serotyping, one serotype for each sequencing
CREATE TABLE bioinf.salmonella_serotyping  (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    serovar text,
    serovar_antigen text,
    serogroup text,
    o_antigen text,
    h2 text,
    h1 text,
    genome text
);

--VFDB using Abricate --> Multiple genes for each sequencing.
CREATE TABLE bioinf.virulence_VFDB (
    sequencing_id int4 REFERENCES sequencing(id),
    vfdb_gene_accession text,
    vfdb_product_resisence text
    CONSTRAINT virulence_VFDB_pkey PRIMARY KEY (sequencing_id, vfdb_gene_accession)
);

-- Virulence finder results
CREATE TABLE bioinf.virulence_VF (
    sequencing_id int4 REFERENCES sequencing(id),
    vf_gene text,
    vf_protein_function text
    CONSTRAINT virulence_VF_pkey PRIMARY KEY (sequencing_id, vf_gene)
);
