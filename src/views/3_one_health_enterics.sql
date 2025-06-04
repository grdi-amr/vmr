CREATE SCHEMA IF NOT EXISTS ohe;

CREATE VIEW ohe.wgs_by_isolate
AS
WITH wgs_w_project AS (
  SELECT iso.id                                   AS isolate_id,
         wgs.sequencing_id,
             ontology_full_term(wgs.sequenced_by) AS sequenced_by,
         pri.bioproject_accession
    FROM isolates                           AS iso
    LEFT JOIN wgs                           AS wgs    ON wgs.isolate_id      = iso.id
    LEFT JOIN public_repository_information AS pri    ON wgs.sequencing_id   = pri.sequencing_id
)
SELECT isolate_id, 
       string_agg(case when seqnum_acc = 1 then bioproject_accession end, '; ') AS bioproject_accession,
       string_agg(case when seqnum_sby = 1 then sequenced_by end, '; ')         AS sequenced_by
    FROM (SELECT wgs_w_project.*,
                 row_number() OVER (PARTITION BY isolate_id, bioproject_accession) AS seqnum_acc,
                 row_number() OVER (PARTITION BY isolate_id, sequenced_by)         AS seqnum_sby
          FROM wgs_w_project) 
GROUP BY isolate_id;

CREATE VIEW ohe.sample_identification_fields
AS
SELECT iso.id                                   AS isolate_id,
       iso.isolate_id                           AS sample_name,
       sam.id                                   AS sample_id,
       seq.bioproject_accession,
       COALESCE(strains.strain, iso.isolate_id) AS strain,
       alt_iso_wide.alt_isolate_names           AS isolate_name_alias
  FROM isolates                     AS iso
       LEFT JOIN samples            AS sam ON iso.sample_id             = sam.id
       LEFT JOIN ohe.wgs_by_isolate AS seq ON iso.id                    = seq.isolate_id
       LEFT JOIN strains                   ON iso.id                    = strains.id
       LEFT JOIN alt_iso_wide              ON alt_iso_wide.isolate_id   = iso.id;

CREATE VIEW ohe.country_state
AS
SELECT sam.id                                      AS sample_id,
       concat_ws(':', cnt.en_term, states.en_term) AS geo_loc_name
  FROM samples                     AS sam
  LEFT JOIN countries              AS cnt    ON sam.geo_loc_name_country               = cnt.id
  LEFT JOIN state_province_regions AS states ON sam.geo_loc_name_state_province_region = states.id;

CREATE VIEW ohe.host_organism
AS
SELECT sam.id AS sample_id,
       org.ontology_id,
       org.scientific_name,
       org.en_common_name
  FROM samples AS sam
  LEFT JOIN host_organisms AS org ON sam.host_organism = org.id;

CREATE VIEW ohe.source_type
AS
SELECT h.sample_id,
       CASE WHEN h.scientific_name =  'Homo sapiens' THEN 'Human'
            WHEN f.vals            IS NOT NULL       THEN 'Food'
            WHEN scientific_name   != 'Homo sapiens' THEN 'Animal'
                                                     ELSE 'Environmental' END AS source_type
  FROM ohe.host_organism AS h
  LEFT JOIN aggregate_multi_choice_table('food_data_product') AS f ON h.sample_id = f.sample_id
        AND f.vals NOT LIKE 'Not %';

CREATE VIEW ohe.isolation_source
AS
with all_sources AS (
  SELECT sample_id,
         bind_ontology(org.scientific_name, org.ontology_id) AS terms
    FROM samples
    LEFT JOIN ohe.host_organism as org ON samples.id = org.sample_id
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('environmental_data_site')
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('anatomical_data_material')
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('anatomical_data_body')
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('anatomical_data_part')
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('food_data_product')
   UNION
  SELECT sample_id, vals FROM aggregate_multi_choice_table('food_data_product_property')
)
SELECT sample_id,
       string_agg(terms, '; ') AS isolation_source
    FROM all_sources
   WHERE terms NOT LIKE 'Not %'
GROUP BY sample_id;

CREATE VIEW ohe.collection_information_fields
AS
SELECT iso.id                                    AS isolate_id,
       sam.id                                    AS sample_id,
  microbes.scientific_name                       AS organism,
       ontology_full_term(sample_collected_by)   AS collected_by,
       sam.sample_collection_date                AS collection_date,
       iso.isolation_date                        AS cult_isol_date,
   country.geo_loc_name,
    source.isolation_source,
       src_type.source_type,
       ontology_full_term(sam.collection_device) AS samp_collect_device,
        sp.vals                                  AS purpose_of_sampling,
       pro.project_name,
       concat_ws(' | ', sam.geo_loc_latitude,
                        sam.geo_loc_longitude)   AS lat_lon,
       iso.serovar,
       seq.sequenced_by
  FROM isolates                  AS iso
  LEFT JOIN samples              AS sam      ON iso.sample_id  = sam.id
  LEFT JOIN microbes                         ON iso.organism   = microbes.id
  LEFT JOIN ohe.country_state    AS country  ON sam.id         = country.sample_id
  LEFT JOIN projects             AS pro      ON sam.project_id = pro.id
  LEFT JOIN aggregate_multi_choice_table('sample_purposes')
                                 AS sp       ON sam.id         = sp.sample_id
  LEFT JOIN ohe.wgs_by_isolate   AS seq      ON iso.id         = seq.isolate_id
  LEFT JOIN ohe.source_type      AS src_type ON sam.id         = src_type.sample_id
  LEFT JOIN ohe.isolation_source AS source   ON sam.id         = source.sample_id;

CREATE VIEW ohe.host
AS
SELECT org.sample_id,
       CASE WHEN org.ontology_id IS NOT NULL THEN bind_ontology(    org.en_common_name,     org.ontology_id)
                                             ELSE bind_ontology(fd_prod.en_term,        fd_prod.ontology_id)
             END AS host
  FROM ohe.host_organism   AS org
  LEFT JOIN samples        AS sam     ON org.sample_id                 = sam.id
  LEFT JOIN ontology_terms AS fd_prod ON sam.host_food_production_name = fd_prod.id;

CREATE VIEW ohe.host_am
AS
SELECT sam.id                           AS sample_id,
       sam.presampling_activity_details AS host_am
  FROM sample_activity AS sa
  LEFT JOIN samples AS sam ON sa.sample_id = sam.id
 WHERE sa.term_id = (SELECT id FROM ontology_terms WHERE ontology_id = 'GENEPIO:0100537');

CREATE VIEW ohe.host_housing
AS
  SELECT site.sample_id,
         string_agg(bind_ontology(ont.en_term, ont.ontology_id), '; ') AS host_housing
    FROM environmental_data_site AS site
    LEFT JOIN samples            AS sam ON  sam.id      = site.sample_id
    LEFT JOIN ontology_terms     AS ont ON site.term_id = ont.id
   WHERE ont.ontology_id IN ('ENVO:01000922', --Animal Cage
                             'ENVO:00002196', --Aquarium
                             'ENVO:00000073', --Building
                             'ENVO:03501257', --Barn
                             'ENVO:03501383', --Breeder Barn
                             'ENVO:03501385', --Sheep Barn
                             'ENVO:03501413', --Pigsty
                             'ENVO:03501387', --Animal pen
                             'EOL:0001903',   -- Stall
                             'ENVO:01001874', -- Poultry hatchery
                             'ENVO:03501439', --Roost (Bird)
                             'ENVO:03501372', -- Crate
                             'ENVO:03501386')-- Broiler Barn)
GROUP BY site.sample_id;

CREATE VIEW ohe.host_fields
AS
SELECT iso.id                               AS isolate_id,
       sam.id                               AS sample_id,
       host_col.host                        AS host,
       ontology_full_term(sam.host_age_bin) AS host_age,
       sam.host_disease,
       env_site.vals                        AS environmental_site,
       ana_mat.vals                         AS host_tissue_sampled,
       body_prod.vals                       AS host_body_product,
       sam.host_ecotype                     AS host_variety,
       sam.host_breed                       AS host_animal_breed,
       risk.vals                            AS upstream_intervention,
       host_am.host_am,
       housing.host_housing
  FROM isolates                                                      AS iso
  LEFT JOIN samples                                                  AS sam       ON iso.sample_id =       sam.id
  LEFT JOIN ohe.host                                                 AS host_col  ON sam.id        =  host_col.sample_id
  LEFT JOIN aggregate_multi_choice_table('environmental_data_site')  AS env_site  ON sam.id        =  env_site.sample_id
  LEFT JOIN aggregate_multi_choice_table('anatomical_data_material') AS ana_mat   ON sam.id        =   ana_mat.sample_id
  LEFT JOIN aggregate_multi_choice_table('anatomical_data_part')     AS body_prod ON sam.id        = body_prod.sample_id
  LEFT JOIN aggregate_multi_choice_table('risk_activity')            AS risk      ON sam.id        =      risk.sample_id
  LEFT JOIN ohe.host_am                                              AS host_am   ON sam.id        =   host_am.sample_id
  LEFT JOIN ohe.host_housing                                         AS housing   ON sam.id        =   housing.sample_id;

CREATE VIEW ohe.food_process_and_preserve
AS
  SELECT sam.id         AS sample_id,
         string_agg(
              (CASE WHEN ont.ontology_id NOT IN ('FOODON:03510128',  -- Organic food claim or use
                                                 'FOODON:00002418',  -- Food (canned)
                                                 'FOODON:03307539',  -- Food (dried)
                                                 'FOODON:03302148')  -- Food (frozen)
                         THEN bind_ontology(ont.en_term, ont.ontology_id)
                         ELSE NULL
               END
               ), '; ') AS food_processing_method,
         string_agg(
              (CASE WHEN ont.ontology_id IN ('FOODON:00002418', --Food (canned)
                                             'FOODON:03307539', --Food (dried)
                                             'FOODON:03302148') -- Food (frozen)
                         THEN bind_ontology(ont.en_term, ont.ontology_id)
                         ELSE NULL
               END), '; ') AS food_preserv_proc
    FROM food_data_product_property AS prop
    LEFT JOIN samples               AS sam  ON sam.id       = prop.sample_id
    LEFT JOIN ontology_terms        AS ont  ON prop.term_id = ont.id
GROUP BY sam.id;


CREATE VIEW ohe.food_fields
AS
SELECT iso.id                                                 AS isolate_id,
       sam.id                                                 AS sample_id,
       countries.en_term                                      AS food_origin,
       source.vals                                            AS food_source,
       proc.food_processing_method,
       proc.food_preserv_proc,
       ontology_full_term(sam.food_product_production_stream) AS food_prod,
       product.vals                                           AS food_product_type,
       pack.vals                                              AS food_contain_wrap,
       sam.food_quality_date
  FROM isolates AS iso
  LEFT JOIN samples                                             AS sam     ON                                       sam.id =       iso.sample_id
  LEFT JOIN countries                                                      ON sam.food_product_origin_geo_loc_name_country = countries.id
  LEFT JOIN aggregate_multi_choice_table('food_data_source')    AS source  ON                                       sam.id =    source.sample_id
  LEFT JOIN ohe.food_process_and_preserve                       AS proc    ON                                       sam.id =      proc.sample_id
  LEFT JOIN aggregate_multi_choice_table('food_data_product')   AS product ON                                       sam.id =   product.sample_id
  LEFT JOIN aggregate_multi_choice_table('food_data_packaging') AS pack    ON                                       sam.id =      pack.sample_id;

CREATE VIEW ohe.fac_type_and_local_scale
AS
SELECT sam.id AS sample_id,
       string_agg(
            (CASE WHEN ont.ontology_id IN ('ENVO:01000925', -- Abattoir
                                           'ENVO:00003862', -- Dairy
                                           'ENVO:01001448', -- Retail Environment
                                           'ENVO:00002221', -- Shop
                                           'ENVO:03501396', -- Butcher Shop
                                           'ENVO:01000984', -- Supermarket
                                           'ENVO:0350142')  -- Manure digester facility
                                    THEN bind_ontology(ont.en_term, ont.ontology_id)
                                    ELSE NULL
            END), '; ') AS facility_type,
       string_agg(
            (CASE WHEN ont.ontology_id IN ('ENVO:00000114', --Agricultural Field
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
                                    THEN bind_ontology(ont.en_term, ont.ontology_id)
                                    ELSE NULL
            END), '; ') AS env_local_scale
  FROM samples                      AS sam
 INNER JOIN environmental_data_site AS site ON  sam.id      = site.sample_id
  LEFT JOIN ontology_terms          AS ont  ON site.term_id =  ont.id
GROUP BY sam.id;

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
  SELECT sam.id AS sample_id,
         string_agg(
             (CASE WHEN ont.ontology_id     IN (SELECT ont FROM vals) THEN bind_ontology(ont.en_term, ont.ontology_id)
                                                                      ELSE NULL END), '; ') AS coll_site_geo_feat,
         string_agg(
             (CASE WHEN ont.ontology_id NOT IN (SELECT ont FROM vals) THEN bind_ontology(ont.en_term, ont.ontology_id)
                                                                      ELSE NULL END), '; ') AS env_medium
    FROM samples AS sam
   INNER JOIN environmental_data_material AS mat ON mat.sample_id = sam.id
    LEFT JOIN ontology_terms              AS ont ON mat.term_id   = ont.id
GROUP BY sam.id;

CREATE VIEW ohe.fertilizer_admin
AS
SELECT sam.id                           AS sample_id,
       sam.presampling_activity_details AS fertilizer_admin
  FROM sample_activity AS sa
  LEFT JOIN samples    AS sam ON sam.id = sa.sample_id
 WHERE sa.term_id = (SELECT id FROM ontology_terms WHERE ontology_id = 'GENEPIO:0100543');

CREATE VIEW ohe.environmental_fields
AS
SELECT iso.id   AS isolate_id,
       sam.id   AS sample_id,
       fac.facility_type,
       feat.coll_site_geo_feat,
       fac.env_local_scale,
       feat.env_medium,
       fert.fertilizer_admin
  FROM isolates                          AS iso
  LEFT JOIN samples                      AS sam  ON iso.sample_id =  sam.id
  LEFT JOIN ohe.fac_type_and_local_scale AS fac  ON sam.id        =  fac.sample_id
  LEFT JOIN ohe.geo_feat_and_medium      AS feat ON sam.id        = feat.sample_id
  LEFT JOIN ohe.fertilizer_admin         AS fert ON sam.id        = fert.sample_id;

CREATE VIEW ohe.one_health_enterics_export
AS

SELECT s.sample_name,
       s.bioproject_accession,
       s.isolate_name_alias,
       s.strain,
       NULL AS culture_collection,
       NULL AS reference_material,
       c.organism,
       c.collected_by,
       c.collection_date,
       c.cult_isol_date,
       c.geo_loc_name,
       c.isolation_source,
       c.source_type,
       c.samp_collect_device,
       c.purpose_of_sampling,
       c.project_name,
       NULL AS "IFSAC_category",
       c.lat_lon,
       NULL AS serotype,
       c.serovar,
       c.sequenced_by,
       NULL AS description,
       h.host,
       NULL AS host_sex,
       h.host_age,
       h.host_disease,
       NULL AS host_subject_id,
       h.environmental_site AS animal_env,
       h.host_tissue_sampled,
       h.host_body_product,
       h.host_variety,
       h.host_animal_breed,
       h.upstream_intervention,
       h.host_am,
       NULL AS host_group_size,
       h.host_housing,
       f.food_origin,
       NULL AS intended_consumer,
       NULL AS spec_intended_cons,
       e.coll_site_geo_feat,
       f.food_prod,
       NULL AS label_claims,
       f.food_product_type,
       NULL AS food_industry_code,
       NULL AS food_industry_class,
       f.food_source,
       f.food_processing_method,
       f.food_preserv_proc,
       NULL AS food_additive,
       NULL AS food_contact_surf,
       f.food_contain_wrap,
       NULL AS food_pack_medium,
       NULL AS food_pack_integrity,
       f.food_quality_date,
       NULL AS food_prod_synonym,
       e.facility_type,
       NULL AS building_setting,
       NULL AS food_type_processed,
       NULL AS location_in_facility,
       NULL AS env_monitoring_zone,
       NULL AS indoor_surf,
       NULL AS indoor_surf_subpart,
       NULL AS surface_material,
       NULL AS material_condition,
       NULL AS surface_orientation,
       NULL AS surf_temp,
       NULL AS biocide_used,
       NULL AS animal_intrusion,
       NULL AS env_broad_scale,
       e.env_local_scale,
       e.env_medium,
       NULL AS plant_growth_med,
       NULL AS plant_water_method,
       NULL AS rel_location,
       NULL AS soil_type,
       NULL AS farm_water_source,
       e.fertilizer_admin,
       NULL AS food_clean_proc,
       NULL AS sanitizer_used_postharvest,
       NULL AS farm_equip,
       NULL AS extr_weather_event,
       NULL AS mechanical_damage
  FROM ohe.sample_identification_fields            AS s
       LEFT JOIN ohe.collection_information_fields AS c ON s.isolate_id = c.isolate_id
       LEFT JOIN ohe.host_fields                   AS h ON s.isolate_id = h.isolate_id
       LEFT JOIN ohe.food_fields                   AS f ON s.isolate_id = f.isolate_id
       LEFT JOIN ohe.environmental_fields          AS e ON s.isolate_id = e.isolate_id;

