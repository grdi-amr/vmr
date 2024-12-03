-- Collection information table, fully widened 
CREATE OR REPLACE VIEW collection_information_wide 
AS 
SELECT c.sample_id,
       c.original_sample_description,
       ontology_full_term(c.sample_collected_by) 	      AS sample_collected_by, 
       contacts.contact_name		         	      AS sample_collector_contact_name,
       contacts.contact_email			 	      AS sample_collector_contact_email,
       contacts.laboratory_name			   	      AS sample_collector_laboratory_name, 
       c.sample_collection_date, 
       ontology_full_term(c.sample_collection_date_precision) AS sample_collection_date_precision, 
       activities.vals					      AS presamping_activity,
       c.presampling_activity_details,
       purposes.vals					      AS purpose_of_samping,
       c.sample_received_date,
       ontology_full_term(c.specimen_processing)	      AS specimen_processing,
       c.sample_storage_method,
       c.sample_storage_medium, 
       ontology_full_term(c.collection_device)		      AS collection_device,
       ontology_full_term(c.collection_method)		      AS collection_method
  FROM collection_information AS c
       LEFT JOIN contact_information AS contacts ON contacts.id = c.contact_information
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('sample_activity')) AS activities
	      ON activities.id = c.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('sample_purposes')) AS purposes 
	      ON purposes.id = c.id
;

-- Geographic location wide
CREATE OR REPLACE VIEW geo_loc_wide 
AS
SELECT g.sample_id					       AS sample_id, 
       bind_ontology(countries.en_term, countries.ontology_id) AS country,
       bind_ontology(states.en_term, states.ontology_id)       AS state_province_region, 
       g.latitude, 
       g.longitude, 
       sites.geo_loc_name_site				       AS geo_loc_site
  FROM geo_loc AS g
       LEFT JOIN countries ON countries.id = g.country
       LEFT JOIN state_province_regions AS states ON states.id = g.state_province_region
       LEFT JOIN geo_loc_name_sites AS sites ON sites.id = g.site
;  

-- Anatomical data wide
CREATE OR REPLACE VIEW anatomical_data_wide 
AS
SELECT a.sample_id				  AS sample_id, 
       ontology_full_term(a.anatomical_region) AS anatomical_region,
       body.vals				  AS body_product,
       material.vals				  AS anatomical_material, 
       part.vals				  AS anatomical_part
  FROM anatomical_data AS a 
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_body')) AS body 
              ON body.id = a.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_material')) AS material
              ON material.id = a.id
       LEFT JOIN (SELECT id,vals FROM aggregate_multi_choice_table('anatomical_data_part')) AS part
              ON part.id = a.id;

-- Host table widening
CREATE OR REPLACE VIEW host_organism_terms 
AS 
SELECT id, 
       bind_ontology(en_common_name,  ontology_id) AS host_common_name, 
       CASE WHEN scientific_name IS NOT NULL THEN bind_ontology(scientific_name, ontology_id) ELSE NULL
        END AS host_scientific_name
  FROM host_organisms;

CREATE OR REPLACE VIEW hosts_wide 
AS
SELECT h.id AS host_id,
       h.sample_id AS sample_id,
       host_org.host_common_name,
       host_org.host_scientific_name,
       h.host_ecotype,
       h.host_breed,
       ontology_full_term(host_food_production_name) AS host_food_production_name,
       h.host_disease,
       ontology_full_term(host_age_bin) AS host_age_bin,
       bind_ontology(c.en_term, c.ontology_id) AS host_origin_geo_loc_name_country
  FROM hosts AS h 
       LEFT JOIN host_organism_terms AS host_org
	      ON h.host_organism = host_org.id
       LEFT JOIN countries AS c
	      ON h.host_origin_geo_loc_name_country = c.id;


CREATE OR REPLACE VIEW wgs
       AS
   SELECT wgs.isolate_id,
          ext.id AS extraction_id,
          seq.id AS sequencing_id,
          seq.library_id,
          ext.experimental_protocol_field,
          ext.experimental_specimen_role_type,
          ext.nucleic_acid_extraction_method,
          ext.nucleic_acid_extraction_kit,
          ext.sample_volume_measurement_value,
          ext.sample_volume_measurement_unit,
          ext.residual_sample_status,
          ext.sample_storage_duration_value,
          ext.sample_storage_duration_unit,
          ext.nucleic_acid_storage_duration_value,
          ext.nucleic_acid_storage_duration_unit,
          seq.contact_information,
          seq.sequenced_by,
          seq.sequencing_project_name,
          seq.sequencing_platform,
          seq.sequencing_instrument,
          seq.sequencing_assay_type,
          seq.dna_fragment_length,
          seq.genomic_target_enrichment_method,
          seq.genomic_target_enrichment_method_details,
          seq.amplicon_pcr_primer_scheme,
          seq.amplicon_size,
          seq.sequencing_flow_cell_version,
          seq.library_preparation_kit,
          seq.sequencing_protocol,
          seq.r1_fastq_filename,
          seq.r2_fastq_filename,
          seq.fast5_filename,
          seq.assembly_filename, 
          seq.r1_irida_id,
          seq.r2_irida_id
     FROM wgs_extractions AS wgs
LEFT JOIN extractions AS ext
       ON wgs.extraction_id = ext.id 
LEFT JOIN sequencing AS seq
       ON ext.id = seq.extraction_id;

CREATE OR REPLACE VIEW full_sample_metadata 
       AS
   SELECT s.id,
          s.sample_collector_sample_id,
          p.sample_plan_id,
          p.sample_plan_name, 
          p.project_name,
          c.id AS collection_information_id,
          c.sample_collected_by,
          c.collection_method,
          c.collection_device,
          c.sample_storage_medium,
          c.sample_storage_method,
          c.specimen_processing,
          c.original_sample_description,
          c.sample_received_date,
          c.presampling_activity_details,
          c.sample_collection_date_precision,
          c.sample_collection_date,
          c.contact_information,
          ci.laboratory_name AS sample_collected_by_laboratory_name, 
          ci.contact_name AS sample_collector_contact_name, 
          ci.contact_email AS sample_collector_contact_email,
          g.country AS geo_loc_country,
          g.state_province_region AS geo_loc_name_state_province_region,
          site.geo_loc_name_site AS geo_loc_name_site,
          g.latitude AS geo_loc_latitude,
          g.longitude AS geo_loc_longitude,
          e.id AS environmental_data_id,
          e.air_temperature,
          e.sediment_depth,
          e.water_depth,
          e.water_temperature,
          h.host_organism,
          h.host_origin_geo_loc_name_country,
          h.host_age_bin,
          h.host_disease,
          h.host_food_production_name,
          h.host_breed,
          h.host_ecotype,
          a.anatomical_region,
          f.id AS food_data_id,
          f.food_product_production_stream,
          f.food_product_origin_country,
          f.food_packaging_date,
          f.food_quality_date
     FROM samples AS s
LEFT JOIN projects as p
       ON s.id = p.id
LEFT JOIN collection_information AS c
       ON s.id = c.sample_id
LEFT JOIN contact_information AS ci
       ON c.contact_information = ci.id
LEFT JOIN geo_loc AS g 
       ON s.id = g.sample_id
LEFT JOIN geo_loc_name_sites AS site 
       ON g.site = site.id
LEFT JOIN environmental_data AS e
       ON s.id = e.sample_id
LEFT JOIN hosts AS h
       ON s.id = h.sample_id
LEFT JOIN anatomical_data AS a
       ON s.id = a.sample_id
LEFT JOIN food_data AS f
       ON s.id = f.sample_id;

