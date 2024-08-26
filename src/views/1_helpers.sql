CREATE VIEW foreign_keys 
AS 
SELECT    
	tc.table_schema,      
	tc.constraint_name, 
	tc.table_name, 
	kcu.column_name, 
	ccu.table_schema AS foreign_table_schema,
	ccu.table_name AS foreign_table_name,
	ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema='public';

CREATE VIEW possible_isolate_names
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

CREATE VIEW alt_iso_wide 
AS
  SELECT isolate_id, 
	 string_agg(alternative_isolate_id, '; ') AS alt_isolate_names
    FROM alternative_isolate_ids 
GROUP BY isolate_id;

CREATE VIEW project_stats
AS
SELECT p.id AS database_id, 
       p.sample_plan_id, 
       p.sample_plan_name, 
       project_name,
       Count(DISTINCT s.id) AS n_samples,
       Count(DISTINCT i.id) AS n_isolates,
       Count(DISTINCT wgs.sequencing_id) AS n_wgs
  FROM projects AS p
       LEFT JOIN samples AS s
	      ON p.id = s.project_id
       LEFT JOIN isolates AS i
	      ON i.sample_id = s.id
       LEFT JOIN wgs 
	      ON wgs.isolate_id = i.id
GROUP BY p.id
;
   


