CREATE TABLE ast_lab_test (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	amr_testing_by int4 REFERENCES agencies(ontology_term_id), 
	laboratory_name text, 
	contact_name text,
	contact_email text
);

CREATE TABLE amr_antibiotics_profile (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ast_lab_test_id int4 NOT NULL REFERENCES ast_lab_test(id),
	isolate_id int4 NOT NULL REFERENCES isolates(id),
	antimicrobial_agent int4 REFERENCES antimicrobial_agents(ontology_term_id),
	antimicrobial_phenotype int4 REFERENCES antimicrobial_phenotypes(ontology_term_id),
	testing_date date,
	measurement float4,
	measurement_units int4 REFERENCES measurement_units(ontology_term_id),
	measurement_sign int4 REFERENCES measurement_sign(ontology_term_id),
	laboratory_typing_method int4 REFERENCES laboratory_typing_methods(ontology_term_id),
	laboratory_typing_platform int4 REFERENCES laboratory_typing_platforms(ontology_term_id),
	laboratory_typing_platform_version text,
	testing_susceptible_breakpoint float4,
	testing_intermediate_breakpoint float4,
	testing_resistance_breakpoint float4,
	testing_standard int4 REFERENCES testing_standard(ontology_term_id),
	testing_standard_version text,
	testing_standard_details text,
	vendor_name int4 REFERENCES vendor_names(ontology_term_id)
);

