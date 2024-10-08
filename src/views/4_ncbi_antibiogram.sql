CREATE VIEW ncbi_antibiogram_format
AS
-- Collect relevant columns in term or ontology_id form for later 
-- conversion into NCBI antibiogram.
WITH amr AS (
    SELECT i.id AS isolate_id, 
           i.isolate_id AS user_isolate_id,
	   ontology_term(amr.antimicrobial_agent) AS ab,
	   ontology_id(amr.antimicrobial_phenotype) AS pheno,
	   ontology_id(amr.measurement_sign) AS sign,
	   amr.measurement, 
	   ontology_id(amr.measurement_units) AS units,
	   ontology_id(amr.laboratory_typing_method) AS typing,
	   ontology_id(amr.laboratory_typing_platform) AS platform,
	   ontology_id(amr.vendor_name) AS vendor,
	   ontology_id(amr.testing_standard) AS standard,
           laboratory_typing_platform_version AS laboratory_typing_method_version_or_reagent
      FROM isolates AS i
	   INNER JOIN am_susceptibility_tests as tests
                   ON i.id = tests.isolate_id 
	   INNER JOIN amr_antibiotics_profile as amr
	 	   ON amr.test_id = tests.id)
-- Prepare view according to substitution rules	      
SELECT user_isolate_id AS sample_name, 
       -- Antibiotic
       CASE WHEN ab = 'Polymyxin B' THEN 'polymyxin B' 
	    ELSE LOWER(ab) 
	END AS antibiotic,
       -- Resistance phenotype
       CASE WHEN pheno = 'ARO:3004301'     THEN 'resistant'
            WHEN pheno = 'ARO:3004302'     THEN 'susceptible'
            WHEN pheno = 'ARO:3004300'     THEN 'intermediate'
            WHEN pheno = 'ARO:3004303'     THEN 'nonsusceptible'
            WHEN pheno = 'GENEPIO:0002040' THEN 'not defined'
            WHEN pheno = 'GENEPIO:0100585' THEN 'not defined'
            WHEN pheno = 'ARO:3004304'     THEN 'susceptible-dose dependent'
	    ELSE NULL 
	END AS resistance_phenotype, 
       -- Measurement sign
       CASE WHEN sign = 'GENEPIO:0001002' THEN '<'
      	    WHEN sign = 'GENEPIO:0001003' THEN '<='
      	    WHEN sign = 'GENEPIO:0001004' THEN '=='
      	    WHEN sign = 'GENEPIO:0001006' THEN '>'
      	    WHEN sign = 'GENEPIO:0001005' THEN '>='
	    ELSE NULL 
        END AS measurement_sign,
       -- Numerical measurement
       CASE WHEN ab = 'Amoxicillin-clavulanic acid'
                 AND standard = 'ARO:3004366' -- CLSI
                 THEN CONCAT(measurement, '/', measurement/2)::text -- Fixed 2:1 ratio
            WHEN ab = 'Amoxicillin-clavulanic acid'
                 AND standard = 'ARO:3004368' -- EUCAST -- 
                 THEN CONCAT(measurement, '/', 2)::text
            WHEN ab = 'Trimethoprim-sulfamethoxazole'
                 AND standard = 'ARO:3004366' -- CLSI
                 THEN CONCAT(measurement, '/', ROUND((measurement*19)::numeric, 2))::text -- Fixed 1:19 ratio
            ELSE measurement::text
        END AS measurement,
       -- Measurment units
       CASE WHEN units = 'UO:0000273' THEN 'mg/L'
      	    WHEN units = 'UO:0000016' THEN 'mm'
      	    WHEN units = 'UO:0000274' THEN 'mg/L'
 	    ELSE NULL 
        END AS measurement_units,
       -- Laboratory typing method
       CASE WHEN typing = 'NCIT:85595'  THEN 'disk diffusion'
      	    WHEN typing = 'NCIT:85596'  THEN 'e-test'
      	    WHEN typing = 'ARO:3004411' THEN 'agar dilution'
	    WHEN typing = 'ARO:3004397' THEN 'MIC'
            ELSE NULL
        END AS laboratory_typing_method,
       -- Typing platform
       CASE WHEN platform = 'ARO:3007569' THEN 'BIOMIC'
      	    WHEN platform = 'ARO:3004400' THEN 'Microscan'
      	    WHEN platform = 'ARO:3004401' THEN 'Phoenix'
	    WHEN platform = 'ARO:3004402' THEN 'Sensititre'
	    WHEN platform = 'ARO:3004403' THEN 'Vitek'
            ELSE NULL
        END AS laboratory_typing_platform,
       -- Antimicrobial vendor
       CASE WHEN vendor = 'ARO:3004405' THEN 'Becton Dickinson'
            WHEN vendor = 'ARO:3004406' THEN 'Biomérieux'
            WHEN vendor = 'ARO:3004408' THEN 'Omron'
            WHEN vendor = 'ARO:3004407' THEN 'Siemens'
            WHEN vendor = 'ARO:3004409' THEN 'Trek'
            ELSE NULL
        END AS vendor,
       -- Method verion/reagent
       laboratory_typing_method_version_or_reagent,
       -- Testing standard
       CASE WHEN standard = 'ARO:3004365' THEN 'BSAC' 
            WHEN standard = 'ARO:3004366' THEN 'CLSI' 
            WHEN standard = 'ARO:3004367' THEN 'DIN' 
            WHEN standard = 'ARO:3004368' THEN 'EUCAST'
            WHEN standard = 'ARO:3007195' THEN 'NARMS' 
            WHEN standard = 'ARO:3007193' THEN 'NCCLS' 
            WHEN standard = 'ARO:3004369' THEN 'SFM' 
            WHEN standard = 'ARO:3007397' THEN 'SIR' 
            WHEN standard = 'ARO:3007398' THEN 'WRG' 
            ELSE 'missing'
       END AS testing_standard
  FROM amr;
