CREATE TABLE ontology_terms (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	en_term text,
	fr_term text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

CREATE TABLE microbes (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	scientific_name text,
	curated bool DEFAULT true
);

CREATE TABLE host_organisms (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	scientific_name text,
	en_common_name text,
	fr_common_name text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

CREATE TABLE countries (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	en_term text,
	fr_term text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

CREATE TABLE state_province_regions (
	id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ontology_id text UNIQUE NOT NULL,
	country_id int4 REFERENCES countries(id),
	en_term text,
	fr_term text,
	en_description text,
	fr_description text,
	curated bool DEFAULT true
);

