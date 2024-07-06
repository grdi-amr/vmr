CREATE TABLE projects (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	name text, 
	description text
);

CREATE TYPE public."status" AS ENUM (
	'curated',
	'ok',
	'flagged',
	'not curated');

CREATE TYPE public."curation_flag" AS ENUM (
	'approved',
	'pending',
	'proposed',
	'not approved');

CREATE TABLE samples (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY, 
	project_id int4 REFERENCES projects(id),
	sample_collector_sample_id text NOT NULL,
	validation_status public."status"
);

CREATE TABLE sample_plan (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 REFERENCES samples(id),
	sample_plan_id text,
	sample_plan_name text
);

CREATE TABLE alternative_sample_ids (
	sample_id int4 PRIMARY KEY REFERENCES samples(id),
	alternative_sample_id text,
	note text,
	CONSTRAINT alt_sample_ids_keep_unique UNIQUE (sample_id, alternative_sample_id)
);




