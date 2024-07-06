CREATE SCHEMA bioinf; 

CREATE TABLE bioinf.amr_genes_profiles (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sequencing_id int4 REFERENCES sequencing(id),
	cut_off text,
	best_hit_aro text,
	model_type text
);

CREATE TABLE bioinf.amr_mob_suite (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	amr_genes_id int4 NULL REFERENCES bioinf.amr_genes_profiles(id),
	molecule_type text NULL,
	primary_cluster_id text NULL,
	secondary_cluster_id text NULL
);

CREATE TABLE bioinf.amr_genes_drugs (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	drug_id text NOT NULL,
	CONSTRAINT amr_genes_drugs_pkey PRIMARY KEY (amr_genes_id, drug_id)
);

CREATE TABLE bioinf.amr_genes_families (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	amr_gene_family_id text NOT NULL,
	CONSTRAINT amr_genes_families_pkey PRIMARY KEY (amr_genes_id, amr_gene_family_id)
);

CREATE TABLE bioinf.amr_genes_resistance_mechanism (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	resistance_mechanism_id text NOT NULL,
	CONSTRAINT amr_genes_resistance_mechanism_pkey PRIMARY KEY (amr_genes_id, resistance_mechanism_id)
);

CREATE TABLE bioinf.amr_mpf_type (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	mpf_type text NOT NULL,
	CONSTRAINT amr_mpf_type_pkey PRIMARY KEY (amr_genes_id, mpf_type)
);

CREATE TABLE bioinf.amr_orit_types (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	orit_type text NOT NULL,
	CONSTRAINT amr_orit_types_pkey PRIMARY KEY (amr_genes_id, orit_type)
);

CREATE TABLE bioinf.amr_predicted_mobility (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	predicted_mobility text NOT NULL,
	CONSTRAINT amr_predicted_mobility_pkey PRIMARY KEY (amr_genes_id, predicted_mobility)
);

CREATE TABLE bioinf.amr_ref_type (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	rep_type text NOT NULL,
	CONSTRAINT amr_ref_type_pkey PRIMARY KEY (amr_genes_id, rep_type)
);

CREATE TABLE bioinf.amr_relaxase_type (
	amr_genes_id int4 NOT NULL REFERENCES bioinf.amr_genes_profiles(id),
	relaxase_type text NOT NULL,
	CONSTRAINT amr_relaxase_type_pkey PRIMARY KEY (amr_genes_id, relaxase_type)
);
