
INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,7,'v2.07.sql', 'v14.5.4', CURRENT_DATE, 'Adds MASH table to bioinf');

CREATE TABLE bioinf.refseq_masher (
    id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sequencing_id int4 REFERENCES sequencing(id),
    sample TEXT,
    top_taxonomy_name TEXT,
    distance FLOAT,
    pvalue FLOAT,
    matching TEXT,
    full_taxonomy TEXT,
    taxonomic_subspecies TEXT,
    taxonomic_species TEXT,
    taxonomic_genus TEXT,
    taxonomic_family TEXT,
    taxonomic_order TEXT,
    taxonomic_class TEXT,
    taxonomic_phylum TEXT,
    taxonomic_superkingdom TEXT,
    subspecies TEXT,
    serovar TEXT,
    plasmid TEXT,
    bioproject TEXT,
    biosample TEXT,
    taxid INTEGER,
    assembly_accession TEXT,
    match_id TEXT
);
