CREATE OR REPLACE VIEW animal_source_of_food_agg 
       AS
   SELECT fd.sample_id AS sample_id,
	  string_agg(ontology_full_term(fd_src.term_id), '; ') AS terms
    FROM food_data AS fd  
         LEFT JOIN food_data_source AS fd_src
                ON fd.id = fd_src.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW environmental_site_agg 
       AS
   SELECT env.sample_id AS sample_id,
	  string_agg(ontology_full_term(site.term_id), '; ') AS terms
     FROM environmental_data as env
          LEFT JOIN environmental_data_site AS site
                 ON site.id = env.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW environmental_material_agg 
       AS
   SELECT env.sample_id AS sample_id,
	  string_agg(ontology_full_term(mat.term_id), '; ') AS terms
     FROM environmental_data as env
          LEFT JOIN environmental_data_material AS mat
                 ON mat.id = env.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW body_product_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(ontology_full_term(body.term_id), '; ') AS terms
     FROM anatomical_data AS a
          LEFT JOIN anatomical_data_body AS body
                 ON a.id = body.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW anatomical_material_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(ontology_full_term(mat.term_id), '; ') AS terms
     FROM anatomical_data AS a
          LEFT JOIN anatomical_data_material AS mat
                 ON a.id = mat.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW anatomical_part_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(ontology_full_term(part.term_id), '; ') AS terms
     FROM anatomical_data AS a
          LEFT JOIN anatomical_data_part AS part
                 ON a.id = part.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW food_product_agg
       AS
   SELECT f.sample_id AS sample_id,
          string_agg(ontology_full_term(pro.term_id), '; ') AS terms
     FROM food_data AS f
          LEFT JOIN food_data_product AS pro
                 ON f.id = pro.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW food_product_properties_agg
       AS
   SELECT f.sample_id AS sample_id,
	  string_agg(ontology_full_term(pro.term_id), '; ') AS terms
     FROM food_data AS f
           LEFT JOIN food_data_product_property AS pro
                  ON f.id = pro.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW food_packaging_agg
       AS
   SELECT f.sample_id AS sample_id,
	  string_agg(ontology_full_term(pack.term_id), '; ') AS terms
     FROM food_data AS f
          LEFT JOIN food_data_packaging AS pack
                 ON f.id = pack.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW sample_purposes_agg
AS 
   SELECT ci.sample_id,
	  string_agg(ontology_full_term(sp.term_id), '; ') AS terms
     FROM collection_information AS ci
          LEFT JOIN sample_purposes AS sp
                 ON ci.id = sp.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW risk_activity_agg
AS 
   SELECT ra.sample_id,
	  string_agg(ontology_full_term(risk_activity.term_id), '; ') AS terms
     FROM risk_assessment AS ra
          LEFT JOIN risk_activity 
                 ON ra.id = risk_activity.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW hosts_wide
       AS
   SELECT h.id AS host_id,
          h.sample_id AS sample_id,
          h.host_ecotype,
          bind_ontology(ho.en_common_name, ho.ontology_id) AS host_common_name,
          bind_ontology(ho.scientific_name, ho.ontology_id) AS host_scientific_name,
          h.host_breed,
          bind_ontology(prod_name.en_term, prod_name.ontology_id) AS host_food_production_name,
          h.host_disease,
          bind_ontology(age.en_term, age.ontology_id) AS host_age_bin,
          bind_ontology(c.en_term, c.ontology_id) AS host_origin_geo_loc_name_country
     FROM hosts AS h 
LEFT JOIN host_organisms AS ho
       ON h.host_organism = ho.id
LEFT JOIN ontology_terms AS age
       ON h.host_age_bin = age.id 
LEFT JOIN ontology_terms AS prod_name
       ON h.host_food_production_name = prod_name.id 
LEFT JOIN countries AS c
       ON h.host_origin_geo_loc_name_country = c.id;

CREATE OR REPLACE VIEW anatomical_data_wide
       AS
   SELECT a.id AS anatomical_data_id,
          a.sample_id AS sample_id, 
          bind_ontology(region.en_term, region.ontology_id) AS anatomical_region
     FROM anatomical_data AS a
LEFT JOIN ontology_terms as region
       ON a.anatomical_region = region.id;

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


