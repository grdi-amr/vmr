
COPY public.template_mapping (id, grdi_group, grdi_field, vmr_table, vmr_field, is_lookup, is_multi_choice) FROM stdin;
1	Antimicrobial resistance	AMR_testing_by	am_susceptibility_tests	amr_testing_by	t	f
2	Antimicrobial resistance	AMR_testing_by_contact_email	am_susceptibility_tests	contact_information	f	f
3	Antimicrobial resistance	AMR_testing_by_contact_name	am_susceptibility_tests	contact_information	f	f
4	Antimicrobial resistance	AMR_testing_by_laboratory_name	am_susceptibility_tests	contact_information	f	f
5	Antimicrobial resistance	AMR_testing_date	amr_antibiotics_profile	testing_date	f	f
6	Antimicrobial resistance	antimicrobial_agent_name	amr_antibiotics_profile	antimicrobial_agent	t	f
7	Antimicrobial resistance	antimicrobial_intermediate_breakpoint	amr_antibiotics_profile	testing_intermediate_breakpoint	f	f
8	Antimicrobial resistance	antimicrobial_laboratory_typing_method	amr_antibiotics_profile	laboratory_typing_method	t	f
9	Antimicrobial resistance	antimicrobial_laboratory_typing_platform	amr_antibiotics_profile	laboratory_typing_platform	t	f
10	Antimicrobial resistance	antimicrobial_laboratory_typing_platform_version	amr_antibiotics_profile	laboratory_typing_platform_version	f	f
11	Antimicrobial resistance	antimicrobial_measurement	amr_antibiotics_profile	measurement	f	f
12	Antimicrobial resistance	antimicrobial_measurement_sign	amr_antibiotics_profile	measurement_sign	t	f
13	Antimicrobial resistance	antimicrobial_measurement_units	amr_antibiotics_profile	measurement_units	t	f
14	Antimicrobial resistance	antimicrobial_resistance_phenotype	amr_antibiotics_profile	antimicrobial_phenotype	t	f
15	Antimicrobial resistance	antimicrobial_resistant_breakpoint	amr_antibiotics_profile	testing_resistance_breakpoint	f	f
16	Antimicrobial resistance	antimicrobial_susceptible_breakpoint	amr_antibiotics_profile	testing_susceptible_breakpoint	f	f
17	Antimicrobial resistance	antimicrobial_testing_standard	amr_antibiotics_profile	testing_standard	t	f
18	Antimicrobial resistance	antimicrobial_testing_standard_details	amr_antibiotics_profile	testing_standard_details	f	f
19	Antimicrobial resistance	antimicrobial_testing_standard_version	amr_antibiotics_profile	testing_standard_version	f	f
20	Antimicrobial resistance	antimicrobial_vendor_name	amr_antibiotics_profile	vendor_name	t	f
21	Bioinformatics and QC metrics	bioinformatics protocol	user_bioinformatic_analyses	bioinformatics_protocol	f	f
22	Bioinformatics and QC metrics	breadth of coverage value	user_bioinformatic_analyses	breadth_of_coverage_value	f	f
23	Bioinformatics and QC metrics	consensus genome length	user_bioinformatic_analyses	consensus_genome_length	f	f
24	Bioinformatics and QC metrics	consensus sequence software name	user_bioinformatic_analyses	consensus_sequence_software	f	f
25	Bioinformatics and QC metrics	consensus sequence software version	user_bioinformatic_analyses	consensus_sequence_software_version	f	f
26	Bioinformatics and QC metrics	deduplication method	user_bioinformatic_analyses	deduplication_method	f	f
27	Bioinformatics and QC metrics	dehosting method	user_bioinformatic_analyses	dehosting_method	f	f
28	Bioinformatics and QC metrics	depth of coverage threshold	user_bioinformatic_analyses	depth_of_coverage_threshold	f	f
29	Bioinformatics and QC metrics	depth of coverage value	user_bioinformatic_analyses	depth_of_coverage_value	f	f
30	Bioinformatics and QC metrics	genome completeness	user_bioinformatic_analyses	genome_completeness	f	f
31	Bioinformatics and QC metrics	minimum post-trimming read length	user_bioinformatic_analyses	minimum_post_trimming_read_length	f	f
32	Bioinformatics and QC metrics	N50	user_bioinformatic_analyses	n50	f	f
33	Bioinformatics and QC metrics	Ns per 100 kbp	user_bioinformatic_analyses	ns_per_100_kbp	f	f
34	Bioinformatics and QC metrics	number of base pairs sequenced	user_bioinformatic_analyses	number_of_base_pairs_sequenced	f	f
35	Bioinformatics and QC metrics	number of contigs	user_bioinformatic_analyses	number_of_contigs	f	f
36	Bioinformatics and QC metrics	number of total reads	user_bioinformatic_analyses	number_of_total_reads	f	f
37	Bioinformatics and QC metrics	number of unique reads	user_bioinformatic_analyses	number_of_unique_reads	f	f
38	Bioinformatics and QC metrics	percent Ns across total genome length	user_bioinformatic_analyses	percent_n	f	f
39	Bioinformatics and QC metrics	percent read contamination	user_bioinformatic_analyses	percent_read_contamination	f	f
40	Bioinformatics and QC metrics	quality control details	user_bioinformatic_analyses	quality_control_details	f	f
41	Bioinformatics and QC metrics	quality_control_determination	user_bioinformatic_analyses	quality_control_determination	f	f
42	Bioinformatics and QC metrics	quality control method name	user_bioinformatic_analyses	quality_control_method_name	f	f
43	Bioinformatics and QC metrics	quality control method version	user_bioinformatic_analyses	quality_control_method_version	f	f
44	Bioinformatics and QC metrics	quality_control_issues	user_bioinformatic_analyses	quality_control_issues	t	f
45	Bioinformatics and QC metrics	raw sequence data processing method	user_bioinformatic_analyses	raw_sequence_data_processing_method	f	f
46	Bioinformatics and QC metrics	reference genome accession	user_bioinformatic_analyses	reference_genome_accession	f	f
47	Bioinformatics and QC metrics	sequence assembly length	user_bioinformatic_analyses	sequence_assembly_length	f	f
48	Bioinformatics and QC metrics	sequence assembly software name	user_bioinformatic_analyses	sequence_assembly_software	f	f
49	Bioinformatics and QC metrics	sequence assembly software version	user_bioinformatic_analyses	sequence_assembly_software_version	f	f
50	Contributor acknowledgement	authors	NA	NA	f	f
51	Contributor acknowledgement	DataHarmonizer provenance	NA	NA	f	f
52	Environmental conditions and measurements	air_temperature	environmental_data	air_temperature	f	f
53	Environmental conditions and measurements	air_temperature_units	environmental_data	air_temperature_units	t	f
54	Environmental conditions and measurements	sediment_depth	environmental_data	sediment_depth	f	f
55	Environmental conditions and measurements	sediment_depth_units	environmental_data	sediment_depth_units	t	f
56	Environmental conditions and measurements	water_depth	environmental_data	water_depth	f	f
57	Environmental conditions and measurements	water_depth_units	environmental_data	water_depth_units	t	f
58	Environmental conditions and measurements	water_temperature	environmental_data	water_temperature	f	f
59	Environmental conditions and measurements	water_temperature_units	environmental_data	water_temperature_units	t	f
60	Environmental conditions and measurements	weather_type	environmental_data_weather_type	term_id	t	t
61	Host information	host (breed)	hosts	host_breed	f	f
62	Host information	host (common name)	host_organisms	en_common_name	t	f
63	Host information	host (ecotype)	hosts	host_ecotype	f	f
64	Host information	host (food production name)	hosts	host_food_production_name	t	f
65	Host information	host (scientific name)	host_organisms	scientific_name	t	f
66	Host information	host_age_bin	hosts	host_age_bin	t	f
67	Host information	host_disease	hosts	host_disease	f	f
68	Public repository information	attribute_package	public_repository_information	attribute_package	t	f
69	Public repository information	bioproject_accession	public_repository_information	bioproject_accession	f	f
70	Public repository information	biosample_accession	public_repository_information	biosample_accession	f	f
71	Public repository information	GenBank_accession	public_repository_information	genbank_accession	f	f
72	Public repository information	publication_ID	public_repository_information	publication_id	f	f
73	Public repository information	sequence_submitted_by	public_repository_information	sequence_submitted_by	t	f
74	Public repository information	sequence_submitted_by_contact_email	public_repository_information	contact_information	f	f
75	Public repository information	sequence_submitted_by_contact_name	public_repository_information	contact_information	f	f
76	Public repository information	SRA_accession	public_repository_information	sra_accession	f	f
77	Risk assessment information	experiment_intervention_details	risk_assessment	experimental_intervention_details	f	f
78	Risk assessment information	experimental_intervention	risk_activity	term_id	t	t
79	Risk assessment information	prevalence_metrics	risk_assessment	prevalence_metrics	f	f
80	Risk assessment information	prevalence_metrics_details	risk_assessment	prevalence_metrics_details	f	f
81	Risk assessment information	stage_of_production	risk_assessment	stage_of_production	f	f
82	Sample collection and processing	alternative_sample_ID	alternative_sample_ids	alternative_sample_id	f	f
83	Sample collection and processing	anatomical_material	anatomical_data_material	term_id	t	t
84	Sample collection and processing	anatomical_part	anatomical_data_part	term_id	t	t
85	Sample collection and processing	anatomical_region	anatomical_data	anatomical_region	t	f
86	Sample collection and processing	animal_or_plant_population	environmental_data_animal_plant	term_id	t	t
87	Sample collection and processing	animal_source_of_food	food_data_source	term_id	t	t
88	Sample collection and processing	available_data_types_details	environmental_data	available_data_type_details	f	f
89	Sample collection and processing	available_data_types	environmental_data_available_data_type	term_id	t	t
90	Sample collection and processing	body_product	anatomical_data_body	term_id	t	t
91	Sample collection and processing	collection_device	collection_information	collection_device	t	f
92	Sample collection and processing	collection_method	collection_information	collection_method	t	f
93	Sample collection and processing	environmental_material	environmental_data_material	term_id	t	t
94	Sample collection and processing	environmental_site	environmental_data_site	term_id	t	t
95	Sample collection and processing	experimental _protocol_field	extraction_information	experimental_protocol_field	f	f
96	Sample collection and processing	experimental_specimen_role _type	extraction_information	experimental_specimen_role_type	f	f
97	Sample collection and processing	food_packaging	food_data_packaging	term_id	t	t
98	Sample collection and processing	food_packaging_date	food_data	food_packaging_date	f	f
99	Sample collection and processing	food_product	food_data_product	term_id	t	t
100	Sample collection and processing	food_product_origin geo_loc (country)	food_data	food_product_origin_country	t	f
101	Sample collection and processing	food_product_production_stream	food_data	food_product_production_stream	t	f
102	Sample collection and processing	food_product_properties	food_data_product_property	term_id	t	t
103	Sample collection and processing	food_quality_date	food_data	food_quality_date	f	f
104	Sample collection and processing	geo_loc latitude	geo_loc	latitude	f	f
105	Sample collection and processing	geo_loc longitude	geo_loc	longitude	f	f
106	Sample collection and processing	geo_loc_name (country)	geo_loc	country	t	f
107	Sample collection and processing	geo_loc_name (site)	geo_loc	site	f	f
108	Sample collection and processing	geo_loc_name (state/province/region)	geo_loc	state_province_region	t	f
109	Sample collection and processing	host_origin geo_loc (country)	hosts	host_origin_geo_loc_name_country	t	f
110	Sample collection and processing	nucleic acid extraction kit	extraction_information	nucleic_acid_extraction_kit	f	f
111	Sample collection and processing	nucleic acid extraction method	extraction_information	nucleic_acid_extraction_method	f	f
112	Sample collection and processing	nucleic_acid_storage_duration_unit	extraction_information	nucleic_acid_storage_duration_unit	t	f
113	Sample collection and processing	nucleic_acid_storage_duration_value	extraction_information	nucleic_acid_storage_duration_value	f	f
114	Sample collection and processing	sample_volume_measurement_value	extraction_information	sample_volume_measurement_value	f	f
115	Sample collection and processing	sample_volume_measurement_unit	extraction_information	sample_volume_measurement_unit	t	t
116	Sample collection and processing	original_sample_description	collection_information	original_sample_description	f	f
117	Sample collection and processing	presampling_activity	sample_activity	term_id	t	t
118	Sample collection and processing	presampling_activity_details	collection_information	presampling_activity_details	f	f
119	Sample collection and processing	purpose_of_sampling	sample_purposes	term_id	t	t
120	Sample collection and processing	residual_sample_status	extraction_information	residual_sample_status	t	f
121	Sample collection and processing	sample_collected_by	collection_information	sample_collected_by	t	f
122	Sample collection and processing	sample_collected_by_laboratory_name	collection_information	contact_information	f	f
123	Sample collection and processing	sample_collection_date	collection_information	sample_collection_date	f	f
124	Sample collection and processing	sample_collection_date_precision	collection_information	sample_collection_date_precision	t	f
125	Sample collection and processing	sample_collection_project_name	collection_information	project_id	f	f
126	Sample collection and processing	sample_collector_contact_email	collection_information	contact_information	f	f
127	Sample collection and processing	sample_collector_contact_name	collection_information	contact_information	f	f
128	Sample collection and processing	sample_collector_sample_ID	samples	sample_collector_sample_id	f	f
129	Sample collection and processing	sample_plan_ID	collection_information	project_id	f	f
130	Sample collection and processing	sample_plan_name	collection_information	project_id	f	f
131	Sample collection and processing	sample_received_date	collection_information	sample_received_date	f	f
132	Sample collection and processing	sample_storage_duration_unit	extraction_information	sample_storage_duration_unit	t	f
133	Sample collection and processing	sample_storage_duration_value	extraction_information	sample_storage_duration_value	f	f
134	Sample collection and processing	sample_storage_medium	collection_information	sample_storage_medium	f	f
135	Sample collection and processing	sample_storage_method	collection_information	sample_storage_method	f	f
136	Sample collection and processing	specimen_processing	collection_information	specimen_processing	t	f
137	Sequence information	amplicon_pcr_primer_scheme	sequencing	amplicon_pcr_primer_scheme	f	f
138	Sequence information	amplicon_size	sequencing	amplicon_size	f	f
139	Sequence information	assembly_filename	sequencing	assembly_filename	f	f
140	Sequence information	DNA_fragment_length	sequencing	dna_fragment_length	f	f
141	Sequence information	fast5_filename	sequencing	fast5_filename	f	f
142	Sequence information	genomic_target_enrichment_method	sequencing	genomic_target_enrichment_method	t	f
143	Sequence information	genomic_target_enrichment_method_details	sequencing	genomic_target_enrichment_method_details	f	f
144	Sequence information	library_ID	sequencing	library_id	f	f
145	Sequence information	library_preparation_kit	sequencing	library_preparation_kit	f	f
146	Sequence information	purpose_of_sequencing	sequencing_purposes	term_id	t	f
147	Sequence information	r1_fastq_filename	sequencing	r1_fastq_filename	f	f
148	Sequence information	r2_fastq_filename	sequencing	r2_fastq_filename	f	f
149	Sequence information	sequenced_by	sequencing	sequenced_by	t	f
150	Sequence information	sequenced_by_contact_email	sequencing	contact_information	f	f
151	Sequence information	sequenced_by_contact_name	sequencing	contact_information	f	f
152	Sequence information	sequenced_by_laboratory_name	sequencing	contact_information	f	f
153	Sequence information	sequencing_flow_cell_version	sequencing	sequencing_flow_cell_version	f	f
154	Sequence information	sequencing_assay_type	sequencing	sequencing_assay_type	t	f
155	Sequence information	sequencing_instrument	sequencing	sequencing_instrument	t	f
156	Sequence information	sequencing_platform	sequencing	sequencing_platform	t	f
157	Sequence information	sequencing_project_name	sequencing	sequencing_project_name	f	f
158	Sequence information	sequencing_protocol	sequencing	sequencing_protocol	f	f
159	Strain and isolation information	alternative_isolate_ID	alternative_isolate_ids	alternative_isolate_id	f	f
160	Strain and isolation information	IRIDA_isolate_ID	sequencing	irida_isolate_id	f	f
161	Strain and isolation information	IRIDA_project_ID	sequencing	irida_project_id	f	f
162	Strain and isolation information	isolate_ID	isolates	isolate_id	f	f
163	Strain and isolation information	isolate_received_date	isolates	isolate_received_date	f	f
164	Strain and isolation information	isolated_by	isolates	isolated_by	t	f
165	Strain and isolation information	isolated_by_contact_email	isolates	contact_information	f	f
166	Strain and isolation information	isolated_by_contact_name	isolates	contact_information	f	f
167	Strain and isolation information	isolated_by_laboratory_name	isolates	contact_information	f	f
168	Strain and isolation information	isolation_date	isolates	isolation_date	f	f
169	Strain and isolation information	microbiological_method	isolates	microbiological_method	f	f
170	Strain and isolation information	organism	isolates	organism	t	f
171	Strain and isolation information	phagetype	isolates	phagetype	f	f
172	Strain and isolation information	progeny_isolate_ID	isolates	progeny_isolate_id	f	f
173	Strain and isolation information	serotyping_method	isolates	serotyping_method	f	f
174	Strain and isolation information	serovar	isolates	serovar	f	f
175	Strain and isolation information	strain	isolates	strain	f	f
176	Strain and isolation information	taxonomic_identification_process	isolates	taxonomic_identification_process	t	f
177	Strain and isolation information	taxonomic_identification_process_details	isolates	taxonomic_identification_process_details	f	f
178	Taxonomic identification information	read mapping criteria	user_bioinformatic_analyses	read_mapping_criteria	f	f
179	Taxonomic identification information	read mapping software name	user_bioinformatic_analyses	read_mapping_software_name	f	f
180	Taxonomic identification information	read mapping software version	user_bioinformatic_analyses	read_mapping_software_version	f	f
181	Taxonomic identification information	taxonomic analysis date	user_bioinformatic_analyses	taxonomic_analysis_date	f	f
182	Taxonomic identification information	taxonomic analysis report filename	user_bioinformatic_analyses	taxonomic_analysis_report_filename	f	f
183	Taxonomic identification information	taxonomic reference database name	user_bioinformatic_analyses	taxonomic_reference_database_name	f	f
184	Taxonomic identification information	taxonomic reference database version	user_bioinformatic_analyses	taxonomic_reference_database_version	f	f
\.

SELECT pg_catalog.setval('public.template_mapping_id_seq', 184, true);

