CREATE TABLE ontology_terms (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	en_term text,
	fr_term text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

CREATE TABLE organism_terms (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	scientific_name text,
	common_name_en text,
	common_name_fr text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

CREATE TABLE isolate_organisms (
	organism_term_id int4 PRIMARY KEY REFERENCES organism_terms(id),
	curated bool DEFAULT true
);

CREATE TABLE host_organisms (
	organism_term_id int4 PRIMARY KEY REFERENCES organism_terms(id),
	curated bool DEFAULT true
);

CREATE TABLE gaz_terms (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	en_term text,
	fr_term text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);
CREATE TABLE countries (
	gaz_term_id int4 PRIMARY KEY REFERENCES gaz_terms(id),
	curated bool DEFAULT true
);

CREATE TABLE state_province_regions (
	gaz_term_id int4 PRIMARY KEY REFERENCES gaz_terms(id),
	curated bool DEFAULT true
);

