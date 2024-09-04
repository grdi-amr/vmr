CREATE OR REPLACE VIEW project_stats
AS
SELECT p.id AS database_id, 
       p.sample_plan_id AS "Sample plan ID",
       p.sample_plan_name AS "Sample plan name",
       project_name AS "Project name",
       Count(DISTINCT s.id) AS "Number of Samples",
       Count(DISTINCT i.id) AS "Number of Isolates",
       Count(DISTINCT wgs.sequencing_id) AS "Number of WGS",
       Count(DISTINCT ab.id) AS "Number of AST"
  FROM projects AS p
       LEFT JOIN samples AS s
	      ON p.id = s.project_id
       LEFT JOIN isolates AS i
	      ON i.sample_id = s.id
       LEFT JOIN wgs 
	      ON wgs.isolate_id = i.id
       LEFT JOIN am_susceptibility_tests as ab
	      ON ab.isolate_id =  i.id
GROUP BY p.id;
