CREATE OR REPLACE VIEW missing_term_ids 
AS
SELECT id,
       bind_ontology(en_term, ontology_id) AS full_term
  FROM ontology_terms
 WHERE en_term LIKE 'Not%'
    OR en_term = 'Missing'
    OR en_term = 'Restricted Access';

CREATE OR REPLACE FUNCTION get_multi_table(table_name text, slot_name text)
   RETURNS TABLE (sample_id integer, slot text, term text)
AS $$
BEGIN
   RETURN QUERY EXECUTE format('
     SELECT sample_id,
            %L AS slot,
            bind_ontology(ont.en_term, ont.ontology_id) AS term
       FROM %I AS tab
       LEFT JOIN ontology_terms AS ont ON ont.id = tab.term_id
       WHERE term_id NOT IN (SELECT id FROM missing_term_ids)', slot_name, table_name);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW basic_sample_characteristics
AS
WITH
orgs AS (
   SELECT sam.id                                             AS sample_id,
          bind_ontology(org.en_common_name, org.ontology_id) AS host_org,
          src.term                                           AS animal_src
     FROM samples AS sam
     LEFT JOIN host_organisms                                               AS org ON org.id        = sam.host_organism
     LEFT JOIN get_multi_table('food_data_source', 'animal_source_of_food') AS src ON src.sample_id = sam.id
),
from_org AS (
   SELECT sample_id,
          CASE WHEN orgs.host_org = orgs.animal_src                           THEN host_org
               WHEN orgs.host_org IS NULL     AND orgs.animal_src IS NOT NULL THEN orgs.animal_src
               WHEN orgs.host_org IS NOT NULL AND orgs.animal_src IS NULL     THEN orgs.host_org
               WHEN orgs.host_org IS NULL     AND orgs.animal_src IS NULL     THEN NULL
               WHEN orgs.host_org IN (select full_term FROM missing_term_ids) THEN NULL
               ELSE CONCAT(orgs.host_org, '/', orgs.animal_src) END
                 AS organism
     FROM orgs
),

all_anatomical_tags AS (
   (SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_body',        'body_product')
   UNION
    SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_material',    'anatomical_material')
   UNION
    SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_part',        'anatomical_part'))
   ORDER BY sample_id, term
),
anatomical AS (
   SELECT sample_id,
          TRUE AS anatomical
          string_agg(term, '; ') AS vals
     FROM all_anatomical
 GROUP BY sample_id
),
from_site AS (
   SELECT sample_id, vals FROM aggregate_multi_choice_table('environmental_data_site')
),
food AS (
   SELECT sample_id, vals FROM aggregate_multi_choice_table('food_data_product')
),
env_mat AS (
   SELECT sample_id, vals FROM aggregate_multi_choice_table('environmental_data_material')
),
and_also AS (
   SELECT sample_id, vals FROM aggregate_multi_choice_table('sample_activity')
)
    SELECT sam.id             AS sample_id,
           sam.project_id     AS project_id,
           sam.original_sample_description,
           CASE WHEN anatomical.vals IS NOT NULL AND food.vals IS NULL     AND env_mat.vals IS NULL     THEN 'anatomical'
                WHEN anatomical.vals IS NULL     AND food.vals IS NOT NULL AND env_mat.vals IS NULL     THEN 'food'
                WHEN anatomical.vals IS NULL     AND food.vals IS NULL     AND env_mat.vals IS NOT NULL THEN 'environmental'
                WHEN anatomical.vals IS NULL     AND food.vals IS NULL     AND env_mat.vals IS NULL     THEN 'env - site only?'
                                                                                                        ELSE 'other'
                          END AS is_a,
           concat(anatomical.vals, food.vals, env_mat.vals) AS all_terms,
           from_site.vals     AS from_site_terms,
           from_org.organism  AS from_org,
           and_also.vals      AS presampling_activity,
           bind_ontology(cnt.en_term, cnt.ontology_id) AS from_country,
           bind_ontology(pro.en_term, pro.ontology_id) AS from_province
      FROM samples AS sam
 LEFT JOIN from_site                     ON  from_site.sample_id = sam.id
 LEFT JOIN from_org                      ON   from_org.sample_id = sam.id
 LEFT JOIN food                          ON       food.sample_id = sam.id
 LEFT JOIN env_mat                       ON    env_mat.sample_id = sam.id
 LEFT JOIN anatomical                    ON anatomical.sample_id = sam.id
 LEFT JOIN and_also                      ON   and_also.sample_id = sam.id
 LEFT JOIN countries              AS cnt ON        cnt.id        = sam.geo_loc_name_country
 LEFT JOIN state_province_regions AS pro ON        pro.id        = sam.geo_loc_name_state_province_region
;
