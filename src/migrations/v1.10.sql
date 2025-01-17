INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,10,'v1.10.sql', 'v13.3.4', CURRENT_DATE);

-- For tables in main schema
ALTER TABLE anatomical_data             ALTER COLUMN sample_id     SET NOT NULL;
ALTER TABLE food_data                   ALTER COLUMN sample_id     SET NOT NULL;
ALTER TABLE collection_information      ALTER COLUMN sample_id     SET NOT NULL;
ALTER TABLE samples                     ALTER COLUMN project_id    SET NOT NULL;
ALTER TABLE sequencing                  ALTER COLUMN extraction_id SET NOT NULL;
ALTER TABLE user_bioinformatic_analyses ALTER COLUMN sequencing_id SET NOT NULL;

-- For all the tables in the bioinf schema
ALTER TABLE bioinf.amr_genes_profiles    ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.ecoli_serotyping      ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.mlst                  ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.plasmid_finder        ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.resfinder             ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.salmonella_serotyping ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.virulence_vf          ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.virulence_vfdb        ALTER COLUMN sequencing_id SET NOT NULL;
ALTER TABLE bioinf.amr_mob_suite         ALTER COLUMN amr_genes_id  SET NOT NULL;
