-- Collection information table, fully widened
CREATE OR REPLACE VIEW collection_information_wide
AS
SELECT col.sample_id,
       col.original_sample_description,
       ontology_full_term(col.sample_collected_by)                  AS sample_collected_by,
       contacts.contact_name                                        AS sample_collector_contact_name,
       contacts.contact_email                                       AS sample_collector_contact_email,
       contacts.laboratory_name                                     AS sample_collector_laboratory_name,
       col.sample_collection_date,
       col.sample_collection_end_date,
       col.sample_collection_start_time,
       col.sample_collection_end_time,
       ontology_full_term(col.sample_collection_time_of_day)        AS sample_collection_time_of_day,
       col.sample_collection_time_duration_value,
       ontology_full_term(col.sample_collection_time_duration_unit) AS sample_collection_time_duration_units,
       ontology_full_term(col.sample_collection_date_precision)     AS sample_collection_date_precision,
       activities.vals                                              AS presamping_activity,
       col.presampling_activity_details,
       purposes.vals                                                AS purpose_of_samping,
       col.sample_received_date,
       ontology_full_term(col.specimen_processing)                  AS specimen_processing,
       col.specimen_processing_details,
       col.sample_storage_method,
       col.sample_storage_medium,
       ontology_full_term(col.collection_device)                    AS collection_device,
       ontology_full_term(col.collection_method)                    AS collection_method,
       col.sample_processing_date
  FROM collection_information AS col
       LEFT JOIN contact_information AS contacts ON contacts.id = col.contact_information
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('sample_activity')) AS activities
	      ON activities.id = col.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('sample_purposes')) AS purposes
	      ON purposes.id   = col.id
;

-- Geographic location wide
CREATE OR REPLACE VIEW geo_loc_wide
AS
SELECT geo.sample_id                                AS sample_id,
       bind_ontology(cnt.en_term, cnt.ontology_id)  AS country,
       bind_ontology(sta.en_term, sta.ontology_id)  AS state_province_region,
       geo.latitude,
       geo.longitude,
       sit.geo_loc_name_site                        AS geo_loc_site
  FROM geo_loc AS geo
       LEFT JOIN countries              AS cnt ON cnt.id = geo.country
       LEFT JOIN state_province_regions AS sta ON sta.id = geo.state_province_region
       LEFT JOIN geo_loc_name_sites     AS sit ON sit.id = geo.site
;

-- Anatomical data wide
CREATE OR REPLACE VIEW anatomical_data_wide
AS
SELECT a.sample_id                              AS sample_id,
       ontology_full_term(a.anatomical_region)  AS anatomical_region,
       body.vals                                AS body_product,
       material.vals                            AS anatomical_material,
       part.vals                                AS anatomical_part
  FROM anatomical_data AS a
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_body')) AS body
              ON body.id = a.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_material')) AS material
              ON material.id = a.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_part')) AS part
              ON part.id = a.id;

-- Food data wide
CREATE OR REPLACE VIEW food_data_wide
AS
SELECT f.sample_id                                          AS sample_id,
       bind_ontology(countries.en_term, countries.en_term)  AS food_product_origin_country,
       ontology_full_term(f.food_product_production_stream) AS food_product_production_stream,
       f.food_packaging_date,
       f.food_quality_date,
       claims.vals                                          AS label_claim,
       packaging.vals                                       AS food_packaging,
       products.vals                                        AS food_product,
       properties.vals                                      AS food_product_properties,
       sources.vals                                         AS animal_source_of_food
  FROM food_data AS f
       LEFT JOIN countries ON countries.id = f.food_product_origin_country
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('food_data_label_claims')) AS claims
	      ON claims.id = f.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('food_data_packaging')) AS packaging
	      ON packaging.id = f.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('food_data_product')) AS products
	      ON products.id = f.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('food_data_product_property')) AS properties
	      ON properties.id = f.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('food_data_source')) AS sources
	      ON sources.id = f.id;

-- Environmental data wide
CREATE OR REPLACE VIEW env_data_wide
AS
WITH mat_const AS (
  SELECT id,
         string_agg(term_id, '; ') AS vals
    FROM environmental_data_material_constituents
GROUP BY id
)
SELECT env.sample_id                                      AS sample_id,
       env.air_temperature,
       ontology_full_term(env.air_temperature_units)      AS air_temperature_units,
       env.water_depth,
       ontology_full_term(env.water_depth_units)          AS water_depth_units,
       env.water_temperature,
       ontology_full_term(env.water_temperature_units)    AS water_temperature_units,
       env.sediment_depth,
       ontology_full_term(env.sediment_depth_units)       AS sediment_depth_units,
       env.available_data_type_details,
       avail_type.vals                                    AS available_data_types,
       animal_or_plant_pops.vals                          AS animal_or_plant_population,
       mat.vals                                           AS environmental_materials,
       mat_const.vals                                     AS environmental_material_constituent,
       site.vals                                          AS environmental_sites,
       weather.vals                                       AS weather_type,
       sampling_weather_conditions,
       presampling_weather_conditions,
       precipitation_measurement_value,
       ontology_full_term(precipitation_measurement_unit) AS precipitation_measurement_unit,
       precipitation_measurement_method
  FROM environmental_data AS env
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('environmental_data_animal_plant')) AS animal_or_plant_pops
              ON animal_or_plant_pops.id = env.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('environmental_data_available_data_type')) AS avail_type
              ON avail_type.id = env.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('environmental_data_material')) AS mat
              ON mat.id = env.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('environmental_data_site')) AS site
              ON site.id = env.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('environmental_data_weather_type')) AS weather
              ON weather.id = env.id
       LEFT JOIN mat_const ON mat_const.id = env.id;

-- Host table widening
CREATE OR REPLACE VIEW host_organism_terms
AS
SELECT id,
       bind_ontology(en_common_name, ontology_id) AS host_common_name,
       CASE WHEN scientific_name IS NOT NULL THEN bind_ontology(scientific_name, ontology_id) ELSE NULL
        END AS host_scientific_name
  FROM host_organisms;

CREATE OR REPLACE VIEW hosts_wide
AS
SELECT hst.id                                            AS host_id,
       hst.sample_id                                     AS sample_id,
       org.host_common_name,
       org.host_scientific_name,
       hst.host_ecotype,
       hst.host_breed,
       ontology_full_term(hst.host_food_production_name) AS host_food_production_name,
       hst.host_disease,
       ontology_full_term(hst.host_age_bin)              AS host_age_bin,
       bind_ontology(cnt.en_term, cnt.ontology_id)       AS host_origin_geo_loc_name_country
  FROM hosts AS hst
       LEFT JOIN host_organism_terms AS org ON org.id = hst.host_organism
       LEFT JOIN countries           AS cnt ON cnt.id = hst.host_origin_geo_loc_name_country;

-- Isolate table in wide form
CREATE OR REPLACE VIEW isolates_wide
AS
SELECT iso.id                                                   AS isolate_id,
       iso.sample_id                                            AS sample_id,
       iso.isolate_id                                           AS user_isolate_id,
       alt.alt_isolate_names                                    AS alternative_isolate_ids,
       bind_ontology(org.scientific_name, org.ontology_id)      AS organism,
       iso.microbiological_method,
       iso.progeny_isolate_id,
       ontology_full_term(iso.isolated_by)                      AS isolated_by,
       con.contact_name                                         AS isolated_by_contact_name,
       con.contact_email                                        AS isolated_by_contact_email,
       con.laboratory_name                                      AS isolated_by_lab_name,
       iso.isolation_date,
       iso.isolate_received_date,
       ontology_full_term(iso.taxonomic_identification_process) AS taxonomic_identification_process,
       iso.taxonomic_identification_process_details,
       iso.serovar,
       iso.serotyping_method,
       iso.phagetype,
       iso.irida_project_id,
       iso.irida_sample_id,
       iso.bioproject_id,
       iso.biosample_id
  FROM isolates AS iso
       LEFT JOIN alt_iso_wide         AS alt ON alt.isolate_id = iso.id
       LEFT JOIN microbes             AS org ON org.id = iso.organism
       LEFT JOIN strains              AS str ON str.id = iso.strain
       LEFT JOIN contact_information  AS con ON con.id = iso.contact_information;

-- WGS, with library and extractions combined and wide-formed
CREATE OR REPLACE VIEW wgs_wide
       AS
SELECT wgs.isolate_id                                             AS isolate_id,
       wgs.library_id                                             AS user_library_id,
       wgs.experimental_protocol_field,
       ontology_full_term(wgs.experimental_specimen_role_type)    AS experimental_specimen_role_type,
       wgs.nucleic_acid_extraction_method,
       wgs.nucleic_acid_extraction_kit,
       wgs.sample_volume_measurement_value,
       ontology_full_term(wgs.sample_storage_duration_unit)       AS sample_storage_duration_unit,
       ontology_full_term(wgs.residual_sample_status)             AS residual_sample_status,
       wgs.sample_storage_duration_value,
       ontology_full_term(wgs.sample_storage_duration_unit)       AS sample_volume_measurement_unit,
       wgs.nucleic_acid_storage_duration_value,
       ontology_full_term(wgs.nucleic_acid_storage_duration_unit) AS nucleic_acid_storage_duration_unit,
       ontology_full_term(wgs.sequenced_by)                       AS sequenced_by,
       con.contact_name                                           AS sequenced_by_contact_name,
       con.contact_email                                          AS sequenced_by_contact_email,
       con.laboratory_name                                        AS sequenced_by_laboratory_name,
       wgs.sequencing_project_name,
       ontology_full_term(wgs.sequencing_platform)                AS sequencing_platform,
       ontology_full_term(wgs.sequencing_instrument)              AS sequencing_instrument,
       ontology_full_term(wgs.sequencing_assay_type)              AS sequencing_assay_type,
       wgs.dna_fragment_length,
       ontology_full_term(wgs.genomic_target_enrichment_method)   AS genomic_target_enrichment_method,
       wgs.genomic_target_enrichment_method_details,
       wgs.amplicon_pcr_primer_scheme,
       wgs.amplicon_size,
       wgs.sequencing_flow_cell_version,
       wgs.library_preparation_kit,
       wgs.sequencing_protocol,
       wgs.r1_fastq_filename,
       wgs.r2_fastq_filename,
       wgs.fast5_filename,
       wgs.assembly_filename,
       wgs.r1_irida_id,
       wgs.r2_irida_id
  FROM wgs
     LEFT JOIN contact_information AS con ON con.id = wgs.contact_information;
