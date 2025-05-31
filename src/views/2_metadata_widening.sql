-- Full widened sample metadata
CREATE OR REPLACE VIEW full_sample_metadata
AS
WITH mat_const AS (
  SELECT sample_id,
         string_agg(term_id, '; ') AS vals
    FROM environmental_data_material_constituents
GROUP BY sample_id
)
SELECT sam.id                          AS sample_id,
       sam.sample_collector_sample_id,
       pro.project_name                AS sample_collection_project_name,
       pro.description                 AS project_description,
       pro.sample_plan_id,
       pro.sample_plan_name,
       -- Collection Information
       sam.original_sample_description,
       ontology_full_term(sam.sample_collected_by)                  AS sample_collected_by,
       contacts.contact_name                                        AS sample_collector_contact_name,
       contacts.contact_email                                       AS sample_collector_contact_email,
       contacts.laboratory_name                                     AS sample_collected_by_laboratory_name,
       sam.sample_collection_date,
       sam.sample_collection_end_date,
       sam.sample_collection_start_time,
       sam.sample_collection_end_time,
       ontology_full_term(sam.sample_collection_time_of_day)        AS sample_collection_time_of_day,
       sam.sample_collection_time_duration_value,
       ontology_full_term(sam.sample_collection_time_duration_unit) AS sample_collection_time_duration_unit,
       ontology_full_term(sam.sample_collection_date_precision)     AS sample_collection_date_precision,
       activities.vals                                              AS presampling_activity,
       sam.presampling_activity_details,
       purposes.vals                                                AS purpose_of_sampling,
       sam.sample_received_date,
       ontology_full_term(sam.specimen_processing)                  AS specimen_processing,
       sam.specimen_processing_details,
       sam.sample_storage_method,
       sam.sample_storage_medium,
       ontology_full_term(sam.collection_device)                    AS collection_device,
       ontology_full_term(sam.collection_method)                    AS collection_method,
       sam.sample_processing_date,
       -- Geographical information
       bind_ontology(cnt.en_term, cnt.ontology_id) AS geo_loc_name_country,
       bind_ontology(sta.en_term, sta.ontology_id) AS geo_loc_name_state_province_region,
       sam.geo_loc_latitude,
       sam.geo_loc_longitude,
       sam.geo_loc_name_site                       AS geo_loc_name_site,
       -- Anatomical information
       ontology_full_term(sam.anatomical_region) AS anatomical_region,
       body.vals                                 AS body_product,
       material.vals                             AS anatomical_material,
       part.vals                                 AS anatomical_part,
       --  Food information
       bind_ontology(food_origin.en_term, food_origin.ontology_id) AS food_product_origin_geo_loc_name_country,
       ontology_full_term(sam.food_product_production_stream)      AS food_product_production_stream,
       sam.food_packaging_date,
       sam.food_quality_date,
       claims.vals                                                 AS label_claim,
       packaging.vals                                              AS food_packaging,
       products.vals                                               AS food_product,
       properties.vals                                             AS food_product_properties,
       sources.vals                                                AS animal_source_of_food,
       -- Environemntal data
       sam.air_temperature,
       ontology_full_term(sam.air_temperature_units)      AS air_temperature_units,
       sam.water_depth,
       ontology_full_term(sam.water_depth_units)          AS water_depth_units,
       sam.water_temperature,
       ontology_full_term(sam.water_temperature_units)    AS water_temperature_units,
       sam.sediment_depth,
       ontology_full_term(sam.sediment_depth_units)       AS sediment_depth_units,
       sam.available_data_type_details,
       avail_type.vals                                    AS available_data_types,
       aniplant.vals                                      AS animal_or_plant_population,
       mat.vals                                           AS environmental_material,
       mat_const.vals                                     AS environmental_material_constituent,
       site.vals                                          AS environmental_site,
       sample_weather.vals                                AS sampling_weather_conditions,
       presample_weather.vals                             AS presampling_weather_conditions,
       precipitation_measurement_value,
       ontology_full_term(precipitation_measurement_unit) AS precipitation_measurement_unit,
       precipitation_measurement_method,
       -- Host information
       bind_ontology(org.en_common_name,  org.ontology_id) AS host_common_name,
       bind_ontology(org.scientific_name, org.ontology_id) AS host_scientific_name,
       sam.host_ecotype,
       sam.host_breed,
       ontology_full_term(sam.host_food_production_name)   AS host_food_production_name,
       sam.host_disease,
       ontology_full_term(sam.host_age_bin)                AS host_age_bin,
       bind_ontology(cnt.en_term, cnt.ontology_id)         AS host_origin_geo_loc_name_country
  FROM samples       AS sam
  LEFT JOIN projects AS pro ON pro.id = sam.project_id
       -- collection tables
  LEFT JOIN contact_information                             AS contacts   ON   contacts.id        = sam.contact_information
  LEFT JOIN aggregate_multi_choice_table('sample_activity') AS activities ON activities.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('sample_purposes') AS purposes   ON   purposes.sample_id = sam.id
       -- geo tables
  LEFT JOIN countries              AS cnt ON cnt.id = sam.geo_loc_country
  LEFT JOIN state_province_regions AS sta ON sta.id = sam.geo_loc_state_province_region
       -- Anatomical tables
  LEFT JOIN aggregate_multi_choice_table('anatomical_data_body')     AS body     ON     body.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('anatomical_data_material') AS material ON material.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('anatomical_data_part')     AS part     ON     part.sample_id = sam.id
      -- Food tables
  LEFT JOIN countries                                                  AS food_origin ON food_origin.id        = sam.food_product_origin_country
  LEFT JOIN aggregate_multi_choice_table('food_data_label_claims')     AS claims      ON      claims.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('food_data_packaging')        AS packaging   ON   packaging.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('food_data_product')          AS products    ON    products.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('food_data_product_property') AS properties  ON  properties.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('food_data_source')           AS sources     ON     sources.sample_id = sam.id
     -- Environmental data
  LEFT JOIN aggregate_multi_choice_table('environmental_data_animal_plant')                   AS aniplant          ON          aniplant.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_available_data_type')            AS avail_type        ON        avail_type.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_material')                       AS mat               ON               mat.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_site')                           AS site              ON              site.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_sampling_weather_conditions')    AS sample_weather    ON    sample_weather.sample_id = sam.id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_presampling_weather_conditions') AS presample_weather ON presample_weather.sample_id = sam.id
  LEFT JOIN mat_const                                                                                              ON         mat_const.sample_id = sam.id
       -- host info
  LEFT JOIN host_organisms AS org      ON      org.id = sam.host_organism
  LEFT JOIN countries      AS host_cnt ON host_cnt.id = sam.host_origin_geo_loc_name_country;

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
  FROM isolates                       AS iso
       LEFT JOIN alt_iso_wide         AS alt ON alt.isolate_id = iso.id
       LEFT JOIN microbes             AS org ON org.id         = iso.organism
       LEFT JOIN strains              AS str ON str.id         = iso.strain
       LEFT JOIN contact_information  AS con ON con.id         = iso.contact_information;

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
       wgs.sequencing_date,
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
       wgs.genome_sequence_filename,
       wgs.r1_irida_id,
       wgs.r2_irida_id
  FROM wgs
  LEFT JOIN contact_information AS con ON con.id = wgs.contact_information;

