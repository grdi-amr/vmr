-- Sequencing 

CREATE TABLE sequencing (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	library_id text,
	contact_information int4 REFERENCES contact_information(id),
	sequenced_by int4 REFERENCES agencies(ontology_term_id),
	sequencing_project_name text,
	sequencing_platform int4 REFERENCES sequencing_platforms(ontology_term_id),
	sequencing_instrument int4 REFERENCES sequencing_instruments(ontology_term_id),
	sequencing_assay_type int4 REFERENCES sequencing_assay_types(ontology_term_id),
	dna_fragment_length int4,
	genomic_target_enrichment_method int4 REFERENCES genomic_target_enrichment_methods(ontology_term_id),
	genomic_target_enrichment_method_details text,
	amplicon_pcr_primer_scheme text,
	amplicon_size text,
	sequencing_flow_cell_version text,
	library_preparation_kit text,
	sequencing_protocol text,
	irida_isolate_id text,
	irida_project_id text,
	r1_fastq_filename text,
	r2_fastq_filename text,
	fast5_filename text,
	assembly_filename text
);

CREATE TABLE sequencing_purposes (
	id int4 NOT NULL REFERENCES sequencing(id),
	term_id int4 NOT NULL REFERENCES purposes(ontology_term_id),
	CONSTRAINT sequencing_purposes_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE metagenomics (
	sample_id int4 NOT NULL REFERENCES samples(id),
	sequencing_id int4 NOT NULL REFERENCES sequencing(id),
	CONSTRAINT metagenomics_pkey PRIMARY KEY (sample_id, sequencing_id)
);

CREATE TABLE wholegenomesequencing (
	isolate_id int4 NOT NULL REFERENCES isolates(id),
	sequencing_id int4 NOT NULL REFERENCES sequencing(id),
	CONSTRAINT wholegenomesequencing_pkey PRIMARY KEY (isolate_id, sequencing_id)
);

CREATE TABLE public_repository_information (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sequencing_id int4 REFERENCES sequencing(id),
	contact_information int4 REFERENCES contact_information(id),
	sequence_submitted_by int4 REFERENCES agencies(ontology_term_id),
	publication_id text,
	bioproject_accession text,
	biosample_accession text,
	sra_accession text,
	genbank_accession text,
	attribute_package int4 REFERENCES attribute_packages(ontology_term_id)
);

CREATE TABLE extraction_information (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sequencing_id int4 REFERENCES sequencing(id),
	experimental_protocol_field text,
	experimental_specimen_role_type int4 REFERENCES experimental_specimen_role_types(ontology_term_id),
	nucleic_acid_extraction_method text,
	nucleic_acid_extraction_kit text,
	sample_volume_measurement_value float8,
	sample_volume_measurement_unit int4 REFERENCES volume_measurement_units(ontology_term_id),
	residual_sample_status int4 REFERENCES residual_sample_status(ontology_term_id),
	sample_storage_duration_value float8,
	sample_storage_duration_unit int4 REFERENCES duration_units(ontology_term_id),
	nucleic_acid_storage_duration_value float8,
	nucleic_acid_storage_duration_unit int4 REFERENCES duration_units(ontology_term_id)
);

CREATE TABLE read_mapping_software_names (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name text NOT NULL
);


CREATE TABLE reference_genome_accessions (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	accession text NOT NULL
);

CREATE TABLE sequence_assembly_software (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name text NOT NULL
);

CREATE TABLE consensus_sequence_software (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name text NOT NULL
);

CREATE TABLE user_bioinformatic_analyses (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sequencing_id int4 REFERENCES sequencing(id),
	quality_control_method_name text,
	quality_control_method_version text,
	quality_control_determination int4 REFERENCES quality_control_determinations(ontology_term_id),
	quality_control_issues int4 REFERENCES quality_control_issues(ontology_term_id),
	quality_control_details text,
	raw_sequence_data_processing_method text,
	dehosting_method text,
	sequence_assembly_software int4 REFERENCES sequence_assembly_software(id),
	sequence_assembly_software_version text,
	consensus_sequence_software int4 REFERENCES consensus_sequence_software(id),
	consensus_sequence_software_version text,
	breadth_of_coverage_value float8,
	depth_of_coverage_value float8,
	depth_of_coverage_threshold float8,
	genome_completeness float8,
	number_of_base_pairs_sequenced int4,
	number_of_total_reads int4,
	number_of_unique_reads int4,
	minimum_post_trimming_read_length int4,
	number_of_contigs int4,
	percent_n float8,
	ns_per_100_kbp float8,
	n50 float8,
	percent_read_contamination float8,
	sequence_assembly_length int4,
	consensus_genome_length int4,
	reference_genome_accession int4 REFERENCES reference_genome_accessions(id),
	deduplication_method text,
	bioinformatics_protocol text,
	read_mapping_software_name int4 REFERENCES read_mapping_software_names(id),
	read_mapping_software_version text, 
	taxonomic_reference_database_name text,
	taxonomic_reference_database_version text,
	taxonomic_analysis_report_filename text,
	taxonomic_analysis_date date,
	read_mapping_criteria text
);
