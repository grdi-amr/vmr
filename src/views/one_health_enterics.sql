DROP SCHEMA IF EXISTS ohe CASCADE;
CREATE SCHEMA IF NOT EXISTS ohe;

CREATE VIEW ohe.sample_identifiers
AS 
   SELECT i.isolate_id AS sample_name,
          p.bioproject_accession,
          COALESCE(strains.strain, i.isolate_id) AS strain,
          alt_iso_wide.alt_isolate_names AS isolate_name_alias
     FROM isolates AS i
LEFT JOIN samples AS s 
       ON i.sample_id = s.id
LEFT JOIN wgs 
       ON wgs.isolate_id = i.id 
LEFT JOIN public_repository_information AS p
       ON wgs.id = p.sequencing_id
LEFT JOIN strains 
       ON i.id = strains.id
LEFT JOIN alt_iso_wide 
       ON alt_iso_wide.isolate_id = i.id
;

CREATE VIEW ohe.collection_information
AS
   SELECT s.id AS sample_id,
          microbes.scientific_name AS organism, 
          bind_ontology(agencies.en_term, agencies.ontology_id) AS collected_by, 
          c.sample_collection_date AS collection_date,
          i.isolation_date AS cult_isol_date,
          country.geo_loc_name, 
          source.isolation_source,
          src_type.source_type,
          bind_ontology(col_device.en_term, col_device.ontology_id) AS samp_collect_device,
          sp.terms AS purpose_of_sampling,
          projects.project_name,
          concat_ws(' | ', latitude, longitude) AS lat_lon, 
          i.serovar, 
          bind_ontology(seqed_by.en_term, seqed_by.ontology_id) AS sequenced_by
     FROM isolates AS i
LEFT JOIN samples AS s 
       ON i.sample_id = s.id
LEFT JOIN microbes 
       ON i.organism = microbes.id
LEFT JOIN collection_information as c 
       ON s.id = c.sample_id
LEFT JOIN ontology_terms AS agencies
       ON c.sample_collected_by = agencies.id
LEFT JOIN ohe.country_state as country
       ON s.id = country.sample_id
LEFT JOIN projects 
       ON s.project_id = projects.id
LEFT JOIN geo_loc 
       ON s.id = geo_loc.sample_id
LEFT JOIN sample_purposes_agg AS sp 
       ON s.id = sp.sample_id
LEFT JOIN wgs
       ON wgs.isolate_id = i.id 
LEFT JOIN ontology_terms AS seqed_by 
       ON wgs.sequenced_by = seqed_by.id
LEFT JOIN ohe.source_type AS src_type 
       ON s.id = src_type.sample_id
LEFT JOIN ontology_terms AS col_device 
       ON c.collection_device = col_device.id
LEFT JOIN ohe.isolation_source as source 
       ON s.id = source.sample_id 
;

CREATE VIEW ohe.host_data
AS 
   SELECT s.id AS sample_id,
          host_col.host AS host, 
          bind_ontology(age_ont.en_term, age_ont.ontology_id) AS host_age,
          host_diseases.host_disease, 
          env_site.terms AS environmental_site, 
          ana_mat.terms AS host_tissue_sampled, 
          body_prod.terms AS host_body_product, 
          h.host_ecotype AS host_variety, 
          breeds.host_breed AS host_animal_breed, 
          risk.terms AS upstream_intervention, 
          host_am.host_am,
          housing.host_housing
     FROM isolates AS i
LEFT JOIN samples AS s 
       ON i.sample_id = s.id
LEFT JOIN hosts as h 
       ON s.id = h.sample_id
LEFT JOIN ohe.host as host_col
       ON s.id = host_col.sample_id
LEFT JOIN ontology_terms AS age_ont 
       ON h.host_age_bin = age_ont.id
LEFT JOIN host_diseases 
       ON h.host_disease = host_diseases.id
LEFT JOIN environmental_site_agg as env_site 
       ON s.id = env_site.sample_id
LEFT JOIN anatomical_material_agg AS ana_mat 
       ON s.id = ana_mat.sample_id
LEFT JOIN body_product_agg AS body_prod
       ON s.id = body_prod.sample_id
LEFT JOIN host_breeds AS breeds 
       ON h.host_breed = breeds.id
LEFT JOIN risk_activity_agg AS risk
       ON s.id = risk.sample_id
LEFT JOIN ohe.host_am as host_am
       ON s.id = host_am.sample_id
LEFT JOIN ohe.host_housing as housing 
       ON s.id = housing.sample_id
;

CREATE VIEW ohe.food 
AS
   SELECT s.id AS sample_id,
          countries.en_term AS food_origin,
          source.terms AS food_source, 
          proc.food_processing_method, 
          proc.food_preserv_proc, 
          bind_ontology(prod_str.en_term, prod_str.ontology_id) AS food_prod, 
          product.terms AS food_product_type, 
          packaging.terms AS food_contain_wrap, 
          f.food_quality_date
     FROM isolates AS i
LEFT JOIN samples AS s
       ON s.id = i.sample_id
LEFT JOIN food_data AS f
       ON s.id = f.sample_id
LEFT JOIN countries 
       ON f.food_product_origin_country = countries.id 
LEFT JOIN animal_source_of_food_agg as source
       ON s.id = source.sample_id
LEFT JOIN ohe.food_process_and_preserve as proc
       ON s.id = proc.sample_id
LEFT JOIN ontology_terms AS prod_str 
       ON f.food_product_production_stream = prod_str.id
LEFT JOIN food_product_agg AS product 
       ON s.id = product.sample_id
LEFT JOIN food_packaging_agg AS packaging 
       ON s.id = packaging.sample_id;


CREATE VIEW ohe.country_state 
AS 
SELECT g.sample_id,
       concat_ws(':', c.en_term, states.en_term) AS geo_loc
FROM geo_loc AS g
LEFT JOIN countries as c
ON g.country = c.id
LEFT JOIN state_province_regions as states
ON g.state_province_region = states.id;

CREATE VIEW ohe.isolation_source
AS
  SELECT sample_id, 
         string_agg(terms, '; ') AS isolation_source
    FROM 
         (SELECT   sample_id, 
                   bind_ontology(org.scientific_name, org.ontology_id) AS terms
              FROM samples 
         LEFT JOIN ohe.host_organism as org
                ON samples.id = org.sample_id
             UNION
            SELECT sample_id, 
                   terms 
              FROM environmental_site_agg
             UNION
            SELECT sample_id, 
                   terms 
              FROM anatomical_material_agg
             UNION
            SELECT sample_id, 
                   terms 
              FROM body_product_agg
             UNION
            SELECT sample_id, 
                   terms 
              FROM anatomical_part_agg
             UNION 
            SELECT sample_id, 
                   terms 

              FROM food_product_agg
             UNION 
            SELECT sample_id, 
                   terms 
              FROM food_product_properties_agg)
   WHERE terms NOT LIKE 'Not %'
GROUP BY sample_id;

CREATE VIEW ohe.host
AS 
   SELECT h.sample_id, 
          org.ontology_id,
          org.scientific_name, 
          org.en_common_name
     FROM hosts as h 
LEFT JOIN host_organisms as org
       ON h.host_organism = org.id;



CREATE VIEW ohe.source_type 
AS
SELECT h.sample_id,
       CASE WHEN h.scientific_name = 'Homo sapiens' THEN 'Human'
            WHEN f.terms IS NOT NULL THEN 'Food'
            WHEN scientific_name != 'Homo sapiens' THEN 'Animal'
            ELSE 'Environmental' 
       END AS source_type
FROM ohe.host_organism AS h
LEFT JOIN food_product_agg AS f
       ON h.sample_id = f.sample_id
      AND f.terms NOT LIKE 'Not %'
;

CREATE VIEW ohe.host  
AS 
SELECT org.sample_id,

       CASE WHEN org.ontology_id IS NOT NULL THEN bind_ontology(org.en_common_name, org.ontology_id)
       ELSE bind_ontology(fd_prod.en_term, fd_prod.ontology_id)
       END AS host
FROM ohe.host_organism AS org
LEFT JOIN hosts AS h
ON org.sample_id = h.sample_id
LEFT JOIN ontology_terms AS fd_prod
ON h.host_food_production_name = fd_prod.id
;


CREATE VIEW ohe.host_am 
AS 
SELECT c.sample_id, 
       c.presampling_activity_details AS host_am
FROM sample_activity AS sa
LEFT JOIN collection_information AS c
      ON sa.id = c.id

WHERE sa.term_id = (SELECT id FROM ontology_terms WHERE ontology_id = 'GENEPIO:0100537')
;


CREATE VIEW ohe.host_housing
SELECT 
   ed.sample_id,
   string_agg(bind_ontology(o.en_term, o.ontology_id), '; ') AS host_housing
FROM environmental_data_site AS e
LEFT JOIN environmental_data as ed
       ON e.id = ed.id
LEFT JOIN ontology_terms AS o
ON e.term_id = o.id
WHERE o.ontology_id IN (
   'ENVO:01000922', --Animal Cage
   'ENVO:00002196', --Aquarium
   'ENVO:00000073', --Building 
   'ENVO:03501257', --Barn
   'ENVO:03501383', --Breeder Barn
   'ENVO:03501385', --Sheep Barn
   'ENVO:03501413', --Pigsty
   'ENVO:03501387', --Animal pen
   'EOL:0001903', -- Stall 
   'ENVO:01001874', -- Poultry hatchery 
   'ENVO:03501439', --Roost (Bird)
   'ENVO:03501372', -- Crate
   'ENVO:03501386' -- Broiler Barn
)
GROUP BY ed.sample_id
;


CREATE VIEW ohe.food_process_and_preserve
AS
  SELECT food_data.sample_id AS sample_id, 
         string_agg(
              (CASE WHEN o.ontology_id NOT IN ('FOODON:03510128', -- Organic food claim or use
                                               'FOODON:00002418', -- Food (canned)
                                               'FOODON:03307539', -- Food (dried)
                                               'FOODON:03302148')  -- Food (frozen)
                         THEN bind_ontology(o.en_term, o.ontology_id)
                    ELSE NULL 
               END), '; ') AS food_processing_method, 
         string_agg(
              (CASE WHEN o.ontology_id IN ('FOODON:00002418', --Food (canned)
                                           'FOODON:03307539', --Food (dried)
                                           'FOODON:03302148') -- Food (frozen)
                         THEN bind_ontology(o.en_term, o.ontology_id)
                    ELSE NULL 
               END), '; ') AS food_preserv_proc
    FROM food_data_product_property as prop
         LEFT JOIN food_data
                ON prop.id = food_data.id
         LEFT JOIN ontology_terms AS o 
                ON prop.term_id = o.id
GROUP BY sample_id;
                                        
CREATE view ohe.fac_type_and_local_scale
AS
SELECT env.sample_id,
       string_agg(
            (CASE WHEN o.ontology_id IN ('ENVO:01000925', -- Abattoir
                                         'ENVO:00003862', -- Dairy
                                         'ENVO:01001448', -- Retail Environment 
                                         'ENVO:00002221', -- Shop
                                         'ENVO:03501396', -- Butcher Shop
                                         'ENVO:01000984', -- Supermarket
                                         'ENVO:0350142')  -- Manure digester facility
                       THEN bind_ontology(o.en_term, o.ontology_id)
            ELSE NULL 
            END), '; ') AS facility_type, 
       string_agg(
            (CASE WHEN o.ontology_id IN ('ENVO:00000114', --Agricultural Field
                                         'ENVO:00000314', --Alluvial fan
                                         'ENVO:03501406', --Artificial wetland
                                         'ENVO:03501441', --Breeding ground
                                         'ENVO:03501405', --Creek
                                         'ENVO:00000078', --Farm
                                         'ENVO:03501443', --Beef farm
                                         'ENVO:03501384', --Breeder farm
                                         'ENVO:03501416', --Dairy farm
                                         'ENVO:01000627', --Feedlot
                                         'ENVO:03501444', --Beef cattle feedlot
                                         'ENVO:00000294', --Fish farm
                                         'ENVO:03501417', --Research farm
                                         'ENVO:01000306', --Freshwater environment
                                         'ENVO:01001873', --Hatchery
                                         'ENVO:01001874', --Poultry hatchery
                                         'ENVO:00000020', --Lake
                                         'ENVO:03501423', --Manure lagoon (Anaerobic lagoon)
                                         'ENVO:01001872', --Manure pit
                                         'ENVO:01000320', --Marine environment
                                         'ENVO:03501440', --Benthic zone
                                         'ENVO:00000208', --Pelagic zone
                                         'ENVO:00000562', --Park
                                         'ENVO:00000033', --Pond
                                         'ENVO:00000025', --Reservoir
                                         'ENVO:00000450', --Irrigation reservoir
                                         'ENVO:00000022', --River
                                         'ENVO:03501439', --Roost (bird)
                                         'ENVO:01000772', --Rural area
                                         'ENVO:03501438', --Slough
                                         'ENVO:00000023', --Stream
                                         'ENVO:00000495', --Tributary
                                         'ENVO:01001191', --Water surface
                                         'ENVO:00000109') --Woodland area
                       THEN bind_ontology(o.en_term, o.ontology_id)
            ELSE NULL 
            END), '; ') AS env_local_scale
  FROM environmental_data as env
       LEFT JOIN environmental_data_site AS e
              ON env.id = e.id 
       LEFT JOIN ontology_terms as o 
              ON e.term_id = o.id 
GROUP BY env.sample_id;

CREATE VIEW ohe.geo_feat_and_medium 
AS
WITH vals (ont) AS (
   VALUES
      ('AGRO:00000671'), --Animal transportation equipment 
      ('GENEPIO:0100896'), --Dead haul trailer 
      ('AGRO:00000673'), --Dead haul truck 
      ('GENEPIO:0100897'), --Live haul trailer 
      ('AGRO:00000674'), --Live haul truck 
      ('ENVO:03501379'), --Bulk tank 
      ('AGRO:00000675'), --Animal feeding equipment 
      ('AGRO:00000679'), --Animal feeder 
      ('AGRO:00000680'), --Animal drinker 
      ('AGRO:00000676'), --Feed pan 
      ('AGRO:00000677'), --Watering bowl 
      ('NCIT:C49844'), --Belt 
      ('GSSO:012935'), --Boot 
      ('OBI:0002806'), --Boot cover 
      ('ENVO:03501431'), --Broom 
      ('ENVO:03501379'), --Bulk tank 
      ('AGRO:00000678'), --Chick box 
      ('AGRO:00000672'), --Chick pad 
      ('ENVO:03501430'), --Cleaning equipment 
      ('ENVO:03501400'), --Dumpster 
      ('AGRO:00000670'), --Egg belt 
      ('NCIT:C49947'), --Fan 
      ('ENVO:03501415'), --Freezer 
      ('ENVO:03501414'), --Freezer handle 
      ('AGRO:00000669')--Plucking belt 
)
SELECT env.sample_id,
      string_agg( 
         (CASE WHEN o.ontology_id IN (SELECT ont FROM vals)
                    THEN bind_ontology(o.en_term, o.ontology_id)
               ELSE NULL 
            END), '; ') AS coll_site_geo_feat,
      string_agg( 
         (CASE WHEN o.ontology_id NOT IN (SELECT ont FROM vals)
                    THEN bind_ontology(o.en_term, o.ontology_id)
               ELSE NULL 
            END), '; ') AS env_medium
  FROM environmental_data as env
       LEFT JOIN environmental_data_material AS e
              ON env.id = e.id 
       LEFT JOIN ontology_terms as o 
              ON e.term_id = o.id 
GROUP BY env.sample_id;

CREATE VIEW ohe.fertilizer_admin 
AS
SELECT c.sample_id,
       c.presampling_activity_details AS fertilizer_admin
   FROM sample_activity as sa
   LEFT JOIN collection_information AS c
          ON c.id = sa.id
WHERE sa.term_id = (SELECT id FROM ontology_terms WHERE ontology_id = 'GENEPIO:0100543');

CREATE VIEW ohe.environmental_fields
AS 
SELECT s.id AS sample_id,
       fac.facility_type, 
       feat.coll_site_geo_feat,
       fac.env_local_scale,
       feat.env_medium
FROM samples AS s
LEFT JOIN ohe.fac_type_and_local_scale AS fac 
       ON s.id = fac.sample_id 
LEFT JOIN ohe.geo_feat_and_medium AS feat
       ON s.id = feat.sample_id
LEFT JOIN ohe.fertilizer_admin AS fert
       ON s.id = fert.sample_id;
