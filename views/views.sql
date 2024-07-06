CREATE OR REPLACE VIEW possible_isolate_names
      AS
  SELECT i.id AS isolate_id,
         i.isolate_id AS isolate_collector_id,
         'Assigned as main isolate ID'::text AS note
    FROM isolates AS i
UNION ALL
  SELECT a.isolate_id,
         a.alternative_isolate_id AS isolate_collector_id,
         a.note
    FROM alternative_isolate_ids as a
ORDER BY isolate_id;

CREATE OR REPLACE VIEW alt_iso_wide 
      AS
  SELECT isolate_id, 
	 string_agg(alternative_isolate_id, '; ') AS alt_isolate_names
    FROM alternative_isolate_ids 
GROUP BY isolate_id;

CREATE OR REPLACE VIEW animal_source_of_food_agg 
       AS
   SELECT food_data AS food_data_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), ';') AS animal_source_of_food
     FROM food_data_source 
LEFT JOIN ontology_terms AS o
       ON animal_source_of_food = o.id
 GROUP BY food_data_id;

CREATE OR REPLACE VIEW environmental_site_agg 
       AS
   SELECT environmental_data AS env_data_id, 
	  string_agg(bind_ontology(o.en_term, o.ontology_id), ';') AS environmental_site
     FROM environment_data_site
LEFT JOIN ontology_terms AS o
       ON environmental_site = o.id
 GROUP BY env_data_id;

CREATE OR REPLACE VIEW full_sample_metadata 
       AS
   SELECT s.id,
          s.sample_collector_sample_id,
          c.sample_collected_by,
          c.sample_plan,
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
          c.sample_collection_project_name,
          c.contact_information,
          g.geo_loc_name_country,
          g.geo_loc_name_state_province_region,
          g.geo_loc_name_site,
          g.geo_loc_latitude,
          g.geo_loc_longitude,
          e.id AS environmental_data_id,
          e.air_temperature,
          e.sediment_depth,
          e.water_depth,
          e.water_temperature,
          h.host_common_name,
          h.host_origin_geo_loc_name_country,
          h.host_age_bin,
          h.host_disease,
          h.host_food_production_name,
          h.host_breed,
          h.host_ecotype,
          h.host_scientific_name,
          a.anatomical_region,
          a.body_product,
          a.anatomical_part,
          a.anatomical_material,
          f.id AS food_data_id,
          f.food_product_production_stream,
          f.food_product_origin_country,
          f.food_packaging_date,
          f.food_quality_date
     FROM samples AS s
LEFT JOIN collection_information AS c
       ON s.id = c.sample_id
LEFT JOIN geo_loc AS g 
       ON s.id = g.sample_id
LEFT JOIN environmental_data AS e
       ON s.id = e.sample_id
LEFT JOIN hosts AS h
       ON s.id = h.sample_id
LEFT JOIN anatomical_data AS a
       ON s.id = a.sample_id
LEFT JOIN food_data AS f
       ON s.id = f.sample_id;

CREATE OR REPLACE VIEW hosts_readable 
       AS
   SELECT h.id AS host_id,
          h.sample_id AS sample_id,
          bind_ontology(com_name.en_term, com_name.ontology_id) AS host_common_name,
          bind_ontology(sci_name.en_term, sci_name.ontology_id) AS host_scientific_name,
          h.host_ecotype,
          h.host_breed,
          bind_ontology(prod_name.en_term, prod_name.ontology_id) AS host_food_production_name,
          h.host_disease,
          bind_ontology(age.en_term, age.ontology_id) AS host_age_bin,
          bind_ontology(geo.en_term, geo.ontology_id) AS host_origin_geo_loc_name_country
     FROM hosts AS h 
LEFT JOIN ontology_terms AS age
       ON h.host_age_bin = age.id 
LEFT JOIN ontology_terms AS com_name
       ON h.host_common_name = com_name.id 
LEFT JOIN ontology_terms AS sci_name
       ON h.host_scientific_name = sci_name.id 
LEFT JOIN ontology_terms AS prod_name
       ON h.host_food_production_name = prod_name.id 
LEFT JOIN ontology_terms AS geo
       ON h.host_origin_geo_loc_name_country = geo.id;

CREATE OR REPLACE VIEW anatomical_data_readable 
       AS
   SELECT a.id AS anatomical_data_id,
          a.sample_id AS sample_id, 
          bind_ontology(region.en_term, region.ontology_id) AS anatomical_region,
          bind_ontology(body_prod.en_term, body_prod.ontology_id) AS body_product,
          bind_ontology(part.en_term, part.ontology_id) AS anatomical_part, 
          bind_ontology(material.en_term, material.ontology_id) AS anatomical_material
     FROM anatomical_data AS a
LEFT JOIN ontology_terms as region
       ON a.anatomical_region = region.id
LEFT JOIN ontology_terms as body_prod
       ON a.body_product = body_prod.id
LEFT JOIN ontology_terms as part
       ON a.anatomical_part = part.id
LEFT JOIN ontology_terms as material
       ON a.anatomical_material = material.id;
