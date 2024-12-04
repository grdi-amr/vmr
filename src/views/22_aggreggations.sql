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

