CREATE TABLE strains (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	strain text
);

CREATE TABLE isolates (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 NOT NULL REFERENCES samples(id),
	isolate_id text NOT NULL,
	organism int4 REFERENCES microbes(id),
	strain int4 REFERENCES strains(id),
	microbiological_method text,
	progeny_isolate_id text,
	isolated_by int4 REFERENCES agencies(ontology_term_id),
	contact_information int4 REFERENCES contact_information(id),
	isolation_date date,
	isolate_received_date date,
	taxonomic_identification_process int4 REFERENCES taxonomic_identification_processes(ontology_term_id),
	taxonomic_identification_process_details text, 
	serovar text,
	serotyping_method text,
	phagetype text
);

CREATE TABLE alternative_isolate_ids (
	isolate_id int4 NOT NULL REFERENCES isolates(id),
	alternative_isolate_id text NOT NULL,
	note text NULL,
	CONSTRAINT alt_iso_ids_keep_unique UNIQUE (isolate_id, alternative_isolate_id)
);

-- Risk Assesment 

CREATE TABLE risk_assessment (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	isolate_id int4 REFERENCES isolates(id),
	sample_id int4 REFERENCES samples(id),
	prevalence_metrics int4 REFERENCES prevalence_metrics(ontology_term_id),
	prevalence_metrics_details text,
	stage_of_production int4 REFERENCES stage_of_production(ontology_term_id),
	experimental_intervention_details text
);

CREATE TABLE risk_activity (
	id int4 NOT NULL REFERENCES risk_assessment(id),
	term_id int4 NOT NULL REFERENCES activities(ontology_term_id),
	CONSTRAINT risk_activity_pkey PRIMARY KEY (id, term_id)
);


