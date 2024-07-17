CREATE OR REPLACE VIEW animal_source_of_food_agg 
       AS
   SELECT fd.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms
    FROM food_data AS fd  
LEFT JOIN food_data_source AS fd_src
       ON fd.id = fd_src.id
LEFT JOIN ontology_terms AS o
       ON fd_src.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW environmental_site_agg 
       AS
   SELECT env.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms
     FROM environmental_data as env
LEFT JOIN environmental_data_site AS site
       ON site.id = env.id
LEFT JOIN ontology_terms AS o
       ON site.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW environmental_material_agg 
       AS
   SELECT env.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM environmental_data as env
LEFT JOIN environmental_data_material AS mat
       ON mat.id = env.id
LEFT JOIN ontology_terms AS o
       ON mat.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW body_product_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM anatomical_data AS a
LEFT JOIN anatomical_data_body AS body
       ON a.id = body.id
LEFT JOIN ontology_terms AS o
       ON body.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW anatomical_material_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM anatomical_data AS a
LEFT JOIN anatomical_data_material AS mat
       ON a.id = mat.id
LEFT JOIN ontology_terms AS o
       ON mat.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW anatomical_part_agg
       AS
   SELECT a.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms
     FROM anatomical_data AS a
LEFT JOIN anatomical_data_part AS part
       ON a.id = part.id
LEFT JOIN ontology_terms AS o
       ON part.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW food_product_agg
       AS
   SELECT f.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM food_data AS f
LEFT JOIN food_data_product AS pro
       ON f.id = pro.id
LEFT JOIN ontology_terms AS o
       ON pro.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW food_product_properties_agg
       AS
   SELECT f.sample_id AS sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM food_data AS f
LEFT JOIN food_data_product_property AS pro
       ON f.id = pro.id
LEFT JOIN ontology_terms AS o
       ON pro.term_id = o.id
 GROUP BY sample_id;

CREATE OR REPLACE VIEW sample_purposes_agg
AS 
   SELECT ci.sample_id,
	  string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS terms 
     FROM collection_information AS ci
LEFT JOIN sample_purposes AS pu
       ON ci.id = pu.id
LEFT JOIN ontology_terms AS o 
       ON pu.term_id = o.id 
 GROUP BY sample_id;

CREATE OR REPLACE VIEW full_sample_metadata 
       AS
   SELECT s.id,
          s.sample_collector_sample_id,
          p.sample_plan_id,
          p.sample_plan_names, 
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
          g.country AS geo_loc_country
          g.state_province_region AS geo_loc_name_state_province_region,
          site.geo_loc_name_site AS geo_loc_name_site,
          g.latitude AS geo_loc_latitude,
          g.longitude AS geo_loc_longitude,
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

CREATE OR REPLACE VIEW wgs
       AS
   SELECT * 
     FROM sequencing AS seq
LEFT JOIN wholegenomesequencing AS wgs
       ON seq.id = wgs.sequencing_id;
