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

CREATE OR REPLACE VIEW from_organism
AS
WITH
orgs AS (
   SELECT sam.id                                             AS sample_id,
          bind_ontology(org.en_common_name, org.ontology_id) AS host_org,
          src.term                                           AS animal_src
     FROM samples AS sam
     LEFT JOIN host_organisms                                               AS org ON org.id        = sam.host_organism
     LEFT JOIN get_multi_table('food_data_source', 'animal_source_of_food') AS src ON src.sample_id = sam.id
) SELECT sample_id,
         CASE WHEN orgs.host_org = orgs.animal_src                           THEN host_org
              WHEN orgs.host_org IS NULL     AND orgs.animal_src IS NOT NULL THEN orgs.animal_src
              WHEN orgs.host_org IS NOT NULL AND orgs.animal_src IS NULL     THEN orgs.host_org
              WHEN orgs.host_org IS NULL     AND orgs.animal_src IS NULL     THEN NULL
              WHEN orgs.host_org IN (select full_term FROM missing_term_ids) THEN NULL
              ELSE CONCAT(orgs.host_org, '/', orgs.animal_src)
          END AS organism
     FROM orgs;

CREATE OR REPLACE VIEW from_site
AS
  SELECT sample_id,
         'environmental_site' AS source_type,
         string_agg(term , '; ') AS vals
    FROM get_multi_table('environmental_data_site', 'env')
GROUP BY sample_id;

CREATE OR REPLACE VIEW sample_is_a
AS
WITH
all_anatomical_tags AS (
   (SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_body',     'anatomical')
   UNION
    SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_material', 'anatomical')
   UNION
    SELECT sample_id, slot, term FROM get_multi_table('anatomical_data_part',     'anatomical'))
   ORDER BY sample_id, term
),
anatomical AS (
   SELECT sample_id,
          'anatomical'           AS source_type,
          string_agg(term, '; ') AS vals
     FROM all_anatomical_tags
 GROUP BY sample_id
),
food AS (
    SELECT sample_id,
           'food'                  AS source_type,
           string_agg(term , '; ') AS vals
      FROM get_multi_table('food_data_product', 'food')
  GROUP BY sample_id
),
env_mat AS (
    SELECT sample_id,
           'environmental_material' AS source_type,
           string_agg(term , '; ')  AS vals
      FROM get_multi_table('environmental_data_material', 'env_mat')
  GROUP BY sample_id
)
SELECT sample_id,
       string_agg(source_type, '; ') AS is_a,
       string_agg(vals, '; ')        AS applicable_terms
  FROM
   ( (SELECT * from env_mat
      UNION
      SELECT * from food
      UNION
      SELECT * from anatomical)
      ORDER BY sample_id, source_type  )
 GROUP BY sample_id;

CREATE OR REPLACE VIEW basic_characteristics
AS
WITH presam AS (
  SELECT sample_id, vals FROM aggregate_multi_choice_table('sample_activity')
)
   SELECT sam.id                                      AS sample_id,
          sam.project_id                              AS project_id,
          sam.original_sample_description,
          is_a.is_a,
          is_a.applicable_terms,
          from_site.vals                              AS from_site_terms,
          org.organism                                AS from_org,
          act.vals                                    AS presampling_activity,
          bind_ontology(cnt.en_term, cnt.ontology_id) AS from_country,
          bind_ontology(pro.en_term, pro.ontology_id) AS from_province
     FROM samples                AS sam
LEFT JOIN from_site                      ON from_site.sample_id = sam.id
LEFT JOIN from_organism          AS org  ON       org.sample_id = sam.id
LEFT JOIN sample_is_a            AS is_a ON      is_a.sample_id = sam.id
LEFT JOIN countries              AS cnt  ON       cnt.id        = sam.geo_loc_name_country
LEFT JOIN state_province_regions AS pro  ON       pro.id        = sam.geo_loc_name_state_province_region
LEFT JOIN presam                 AS act  ON       act.sample_id = sam.id;
