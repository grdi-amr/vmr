-- Update versioning table 
INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (5, 1, 4, 'v1.4.sql', 'v12.2.2', CURRENT_DATE);

--Resfinder results - One sequencing can get multiple genes results which can have many predicted phenotypes each gene
CREATE TABLE bioinf.resfinder (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    resfinder_gene text
);

CREATE TABLE bioinf.resfinder_predicted_phenotypes (
    resfinder_id int4 REFERENCES bioinf.resfinder(id),
    predicted_phenotype text,
    CONSTRAINT resfinder_predicted_phenotypes_pkey PRIMARY KEY (resfinder_id, predicted_phenotype)
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
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    plasmid text
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
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    gene_accession text,
    product_resistance text
);

-- Virulence finder results
CREATE TABLE bioinf.virulence_VF (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    vf_gene text,
    vf_protein_function text
);
