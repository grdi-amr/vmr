CREATE OR REPLACE VIEW wgs_full_wide_metadata
    AS
SELECT
iso.user_isolate_id,                    iso.alternative_isolate_ids,                    sam.sample_collector_sample_id,
wgs.user_library_id,                    wgs.experimental_protocol_field,                wgs.experimental_specimen_role_type,
wgs.nucleic_acid_extraction_method,     wgs.nucleic_acid_extraction_kit,                wgs.sample_volume_measurement_value,
wgs.sample_storage_duration_unit,       wgs.residual_sample_status,                     wgs.sample_storage_duration_value,
wgs.sample_volume_measurement_unit,     wgs.nucleic_acid_storage_duration_value,        wgs.nucleic_acid_storage_duration_unit,
wgs.sequenced_by,                       wgs.sequenced_by_contact_name,                  wgs.sequenced_by_contact_email,
wgs.sequenced_by_laboratory_name,       wgs.sequencing_project_name,                    wgs.sequencing_platform,
wgs.sequencing_instrument,              wgs.sequencing_assay_type,                      wgs.dna_fragment_length,
wgs.genomic_target_enrichment_method,   wgs.genomic_target_enrichment_method_details,   wgs.amplicon_pcr_primer_scheme,
wgs.amplicon_size,                      wgs.sequencing_flow_cell_version,               wgs.library_preparation_kit,
wgs.sequencing_protocol,                wgs.r1_fastq_filename,                          wgs.r2_fastq_filename,
wgs.fast5_filename,                     wgs.assembly_filename,                          wgs.r1_irida_id,
wgs.r2_irida_id,                        iso.organism,                                   iso.microbiological_method,
iso.progeny_isolate_id,                 iso.isolated_by,                                iso.isolated_by_contact_name,
iso.isolated_by_contact_email,          iso.isolated_by_lab_name,                       iso.isolation_date,
iso.isolate_received_date,              iso.taxonomic_identification_process,           iso.taxonomic_identification_process_details,
iso.serovar,                            iso.serotyping_method,                          iso.phagetype,
iso.irida_project_id,                   iso.irida_sample_id,                            iso.bioproject_id,
iso.biosample_id,                       pro.project_name,                               pro.description,
pro.sample_plan_id,                     pro.sample_plan_name,                           col.original_sample_description,
col.sample_collected_by,                col.sample_collector_contact_name,              col.sample_collector_contact_email,
col.sample_collector_laboratory_name,   col.sample_collection_date,                     col.sample_collection_date_precision,
col.presamping_activity,                col.presampling_activity_details,               col.purpose_of_samping,
col.sample_received_date,               col.specimen_processing,                        col.sample_storage_method,
col.sample_storage_medium,              col.collection_device,                          col.collection_method,
geo.country,                            geo.state_province_region,                      geo.latitude,
geo.longitude,                          geo.geo_loc_site,                               env.air_temperature,
env.air_temperature_units,              env.water_depth,                                env.water_depth_units,
env.water_temperature,                  env.water_temperature_units,                    env.sediment_depth,
env.sediment_depth_units,               env.available_data_type_details,                env.available_data_types,
env.animal_or_plant_population,         env.environmental_materials,                    env.environmental_material_constituent,
env.environmental_sites,                env.weather_type,                               ana.anatomical_region,
ana.body_product,                       ana.anatomical_material,                        ana.anatomical_part,
hst.host_common_name,                   hst.host_scientific_name,                       hst.host_ecotype,
hst.host_breed,                         hst.host_food_production_name,                  hst.host_disease,
hst.host_age_bin,                       hst.host_origin_geo_loc_name_country,           fud.food_product_origin_country,
fud.food_product_production_stream,     fud.food_packaging_date,                        fud.food_quality_date,
fud.label_claim,                        fud.food_packaging,                             fud.food_product,
fud.food_product_properties,            fud.animal_source_of_food
FROM
wgs_wide AS wgs
  LEFT JOIN isolates_wide               AS iso ON iso.isolate_id  = wgs.isolate_id
  LEFT JOIN samples                     AS sam ON sam.id          = wgs.isolate_id
  LEFT JOIN projects                    AS pro ON pro.id          = sam.project_id
  LEFT JOIN collection_information_wide AS col ON col.sample_id   = sam.id
  LEFT JOIN geo_loc_wide                AS geo ON geo.sample_id   = sam.id
  LEFT JOIN env_data_wide               AS env ON env.sample_id   = sam.id
  LEFT JOIN anatomical_data_wide        AS ana ON ana.sample_id   = sam.id
  LEFT JOIN hosts_wide                  AS hst ON hst.sample_id   = sam.id
  LEFT JOIN food_data_wide              AS fud ON fud.sample_id   = sam.id;

