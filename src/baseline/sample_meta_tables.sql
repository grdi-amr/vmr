-- Contact Information

CREATE TABLE contact_information (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	laboratory_name text,
	contact_name text,
	contact_email text
);

-- Collection information

CREATE TABLE collection_information (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY NOT NULL,
	sample_id int4 UNIQUE REFERENCES samples(id),
	sample_collected_by int4 REFERENCES agencies(ontology_term_id),
	contact_information int4 REFERENCES contact_information(id),
	sample_collection_project_name text,
	sample_collection_date date,
	sample_collection_date_precision int4 REFERENCES sample_collection_date_precision(ontology_term_id),
	presampling_activity_details text,
	sample_received_date date,
	original_sample_description text,
	specimen_processing int4 REFERENCES specimen_processing(ontology_term_id),
	sample_storage_method text,
	sample_storage_medium text,
	collection_device int4 REFERENCES collection_devices(ontology_term_id),
	collection_method int4 REFERENCES collection_methods(ontology_term_id)
);

CREATE TABLE sample_purposes (
	id int4 NOT NULL REFERENCES collection_information(id),
	term_id int4 NOT NULL REFERENCES purposes(ontology_term_id),
	CONSTRAINT sample_purpose_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE sample_activity (
	id int4 NOT NULL REFERENCES collection_information(id),
	term_id int4 NOT NULL REFERENCES activities(ontology_term_id),
	CONSTRAINT sample_activity_pkey PRIMARY KEY (id, term_id)
);

-- Geo Loc

CREATE TABLE geo_loc_name_sites (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY, 
	geo_loc_name_site text NOT NULL
);

CREATE TABLE geo_loc (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 UNIQUE NOT NULL REFERENCES samples(id),
	country int4 REFERENCES countries(gaz_term_id),
	province_region int4 REFERENCES state_province_regions(gaz_term_id),
	site int4 REFERENCES geo_loc_name_sites(id),
	latitude point,
	longitude point
);

-- Food Data 

CREATE TABLE food_data (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 UNIQUE REFERENCES samples(id),
	food_product_production_stream int4 REFERENCES food_product_production_streams(ontology_term_id),
	food_product_origin_country int4 REFERENCES countries(gaz_term_id),
	food_packaging_date date,
	food_quality_date date 
);

CREATE TABLE food_data_product_property (
	id int4 NOT NULL REFERENCES food_data(id),
	term_id int4 NOT NULL REFERENCES food_product_properties(ontology_term_id),
	CONSTRAINT food_data_product_property_pk PRIMARY KEY (id, term_id)
);

CREATE TABLE food_data_source (
	id int4 NOT NULL REFERENCES food_data(id),
	term_id int4 NOT NULL REFERENCES animal_source_of_food(ontology_term_id),
	CONSTRAINT food_data_source_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE food_data_product (
	id int4 NOT NULL REFERENCES food_data(id),
	term_id int4 NOT NULL REFERENCES food_products(ontology_term_id),
	CONSTRAINT food_data_product_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE food_data_packaging (
	id int4 NOT NULL REFERENCES food_data(id),
	term_id int4 NOT NULL REFERENCES food_packaging(ontology_term_id),
	CONSTRAINT food_data_packaging_pkey PRIMARY KEY (id, term_id)
);

-- Environmental Data

CREATE TABLE environmental_data (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 UNIQUE NOT NULL REFERENCES samples(id),
	air_temperature float8,
	sediment_depth float8,
	water_depth float8,
	water_temperature float8
);

CREATE TABLE environmental_data_site (
	id int4 NOT NULL REFERENCES environmental_data(id),
	term_id int4 NOT NULL REFERENCES environmental_sites(ontology_term_id),
	CONSTRAINT environmental_data_site_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE environmental_data_animal_plant (
	id int4 NOT NULL REFERENCES environmental_data(id),
	term_id int4 NOT NULL REFERENCES animal_or_plant_populations(ontology_term_id),
	CONSTRAINT environmental_data_animal_plant_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE environmental_data_material (
	id int4 NOT NULL REFERENCES environmental_data(id),
	term_id int4 NOT NULL REFERENCES environmental_materials(ontology_term_id),
	CONSTRAINT environmental_data_materials_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE environmental_data_available_data_type (
	id int4 NOT NULL REFERENCES environmental_data(id),
	term_id int4 NOT NULL REFERENCES available_data_types(ontology_term_id),
	CONSTRAINT environmental_data_available_data_type_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE environmental_data_weather_type (
	id int4 NOT NULL REFERENCES environmental_data(id),
	term_id int4 NOT NULL REFERENCES weather_types(ontology_term_id), 
	CONSTRAINT environmental_data_weather_type_pkey PRIMARY KEY (id, term_id)
);

-- Anatomical Data

CREATE TABLE anatomical_data (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 UNIQUE REFERENCES samples(id),
	anatomical_region int4 REFERENCES anatomical_regions(ontology_term_id)
);

CREATE TABLE anatomical_data_part (
	id int4 NOT NULL REFERENCES anatomical_data(id),
	term_id int4 NOT NULL REFERENCES anatomical_parts(ontology_term_id), 
	CONSTRAINT anatomical_data_part_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE anatomical_data_body (
	id int4 NOT NULL REFERENCES anatomical_data(id),
	term_id int4 NOT NULL REFERENCES body_products(ontology_term_id), 
	CONSTRAINT anatomical_data_body_pkey PRIMARY KEY (id, term_id)
);

CREATE TABLE anatomical_data_material (
	id int4 NOT NULL REFERENCES anatomical_data(id),
	term_id int4 NOT NULL REFERENCES anatomical_materials(ontology_term_id),
	CONSTRAINT anatomical_data_material_pkey PRIMARY KEY (id, term_id)
);


-- Hosts 

CREATE TABLE host_breeds (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	host_breed text
);

CREATE TABLE host_diseases (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	host_disease text
);

CREATE TABLE hosts (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sample_id int4 UNIQUE NOT NULL REFERENCES samples(id),
	host_organism int4 REFERENCES host_organisms(organism_term_id),
	host_ecotype text,
	host_breed int4 REFERENCES host_breeds(id),
	host_food_production_name int4 REFERENCES host_food_production_names(ontology_term_id),
	host_disease int4 REFERENCES host_diseases(id),
	host_age_bin int4 REFERENCES host_age_bin(ontology_term_id),
	host_origin_geo_loc_name_country int4 REFERENCES countries(gaz_term_id)
);

