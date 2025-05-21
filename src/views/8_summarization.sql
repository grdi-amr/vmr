CREATE VIEW n_sam_iso_seq 
AS
SELECT COUNT(DISTINCT(psi.project_id))    AS n_projects,
       COUNT(DISTINCT(psi.sample_id))     AS n_samples,
       COUNT(DISTINCT(psi.isolate_id))    AS n_isolates,
       COUNT(DISTINCT(wgs.sequencing_id)) AS n_sequences
  FROM projects_samples_isolates AS psi
  LEFT JOIN wgs ON wgs.isolate_id = psi.isolate_id;

CREATE VIEW n_isos_and_seqs_by_microbe
AS
WITH n_iso AS (
    SELECT scientific_name,
           COUNT(scientific_name) AS n_isolates
      FROM isolates LEFT JOIN microbes AS m ON m.id = isolates.organism 
  GROUP BY scientific_name
),
n_seq AS (
    SELECT m.scientific_name,
           COUNT(m.scientific_name) AS n_seqs
      FROM wgs
      LEFT JOIN isolates AS i ON i.id = wgs.isolate_id
      LEFT JOIN microbes AS m ON m.id = i.organism
  GROUP BY scientific_name
)
  SELECT n_iso.scientific_name,
         n_isolates,
         COALESCE(n_seqs, 0) AS n_seqs
    FROM n_iso
    FULL JOIN n_seq ON n_iso.scientific_name = n_seq.scientific_name 
ORDER BY n_isolates DESC;

CREATE VIEW all_possible_ids
AS
   SELECT psi.project_id,
          psi.sample_id,
          iso.isolate_id,
          NULL::int                AS sequencing_id,
          'isolate ID'             AS id_type,
          iso.isolate_collector_id AS identifier,
          iso.note
     FROM possible_isolate_names AS iso
LEFT JOIN projects_samples_isolates AS psi ON psi.isolate_id = iso.isolate_id
          UNION
   SELECT psi.project_id,
          sam.sample_id,
          NULL::int          AS isolate_id,
          NULL::int          AS sequencing_id,
          'sample ID'        AS id_type,
          sam.user_sample_id AS identifier,
          sam.note
     FROM possible_sample_names AS sam
LEFT JOIN projects_samples_isolates AS psi ON psi.sample_id = sam.sample_id
          UNION
   SELECT psi.project_id,
          psi.sample_id,
          wgs.isolate_id,
          wgs.sequencing_id,
          'library ID'       AS id_type,
          library_id         AS identifier,
          NULL AS note
     FROM wgs
LEFT JOIN projects_samples_isolates AS psi ON psi.isolate_id = wgs.isolate_id
    WHERE library_id IS NOT NULL;


CREATE VIEW kleb_view
AS
SELECT  iso.irida_sample_id::text,
       prov.region,
              extract(year FROM col.sample_collection_date) AS collection_year,
          iso.organism,
          iso.user_isolate_id,
          wgs.user_library_id,
         host.host_common_name,
         host.host_scientific_name,
          env.environmental_materials,
          env.environmental_sites,
         food.food_product,
          ana.body_product,
          ana.anatomical_part
     FROM wgs_wide AS wgs
LEFT JOIN isolates_wide          AS iso   ON iso.isolate_id = wgs.isolate_id
LEFT JOIN geo_loc                AS geo   ON geo.sample_id  = iso.sample_id
LEFT JOIN env_data_wide          AS env   ON env.sample_id  = iso.sample_id
LEFT JOIN food_data_wide         AS food  ON food.sample_id = iso.sample_id
LEFT JOIN hosts_wide             AS host  ON host.sample_id = iso.sample_id
LEFT JOIN anatomical_data_wide   AS ana   ON ana.sample_id  = iso.sample_id
LEFT JOIN collection_information AS col   ON col.sample_id  = iso.sample_id
LEFT JOIN state_province_regions AS prov  ON prov.id        = geo.state_province_region
;




