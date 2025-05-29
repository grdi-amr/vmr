CREATE OR REPLACE VIEW project_stats
AS
  SELECT pro.id                            AS "Project Database ID",
         pro.sample_plan_id                AS "Sample plan ID",
         pro.sample_plan_name              AS "Sample plan name",
         project_name                      AS "Project name",
         Count(DISTINCT sam.id)            AS "Number of Samples",
         Count(DISTINCT iso.id)            AS "Number of Isolates",
         Count(DISTINCT wgs.sequencing_id) AS "Number of WGS",
         Count(DISTINCT ab.id)             AS "Number of AST"
    FROM projects                     AS pro
    LEFT JOIN samples                 AS sam ON pro.id         = sam.project_id
    LEFT JOIN isolates                AS iso ON iso.sample_id  = sam.id
    LEFT JOIN wgs                            ON wgs.isolate_id = iso.id
    LEFT JOIN am_susceptibility_tests AS ab  ON ab.isolate_id  = iso.id
GROUP BY pro.id;
