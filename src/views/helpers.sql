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

