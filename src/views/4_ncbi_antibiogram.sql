CREATE VIEW ncbi_antibiotics
AS
SELECT amr.id AS amr_id, 
       CASE WHEN o.en_term = 'Amoxicillin-clavulanic' THEN 'amoxicillin-clavulanic acid' 
	    WHEN o.en_term = 'Polymyxin B' THEN 'polymyxin B' 
	    ELSE LOWER(o.en_term) 
	END AS antibiotic
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.antimicrobial_agent = o.id;

CREATE VIEW ncbi_amr_phenotype
AS
SELECT amr.id AS amr_id,
       CASE WHEN o.ontology_id = 'ARO:3004301'     THEN 'resistant'
            WHEN o.ontology_id = 'ARO:3004302'     THEN 'susceptible'
            WHEN o.ontology_id = 'ARO:3004300'     THEN 'intermediate'
            WHEN o.ontology_id = 'ARO:3004303'     THEN 'nonsusceptible'
            WHEN o.ontology_id = 'GENEPIO:0002040' THEN 'not defined'
            WHEN o.ontology_id = 'GENEPIO:0100585' THEN 'not defined'
            WHEN o.ontology_id = 'ARO:3004304'	   THEN 'susceptible-dose dependent'
	    ELSE NULL 
       END AS resistance_phenotype
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.antimicrobial_phenotype = o.id;

CREATE VIEW ncbi_amr_sign
AS
SELECT amr.id AS amr_id,
       CASE WHEN o.ontology_id = 'GENEPIO:0001002' THEN '<'
      	    WHEN o.ontology_id = 'GENEPIO:0001003' THEN '<='
      	    WHEN o.ontology_id = 'GENEPIO:0001004' THEN '=='
      	    WHEN o.ontology_id = 'GENEPIO:0001006' THEN '>'
      	    WHEN o.ontology_id = 'GENEPIO:0001005' THEN '>='
	    ELSE NULL 
       END AS measurement_sign
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.measurement_sign= o.id;

CREATE VIEW ncbi_amr_measurement
AS
SELECT amr.id AS amr_id,
       amr.measurement,
       CASE WHEN o.ontology_id = 'UO:0000273' THEN 'mg/L'
      	    WHEN o.ontology_id = 'UO:0000016' THEN 'mm'
      	    WHEN o.ontology_id = 'UO:0000274' THEN 'mg/L'
	    ELSE NULL 
       END AS measurement_units
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.measurement_units = o.id;

CREATE VIEW ncbi_amr_method
AS
SELECT amr.id AS amr_id, 
       CASE WHEN o.ontology_id = 'NCIT:85595'  THEN 'disk diffusion'
      	    WHEN o.ontology_id = 'NCIT:85596'  THEN 'e-test'
      	    WHEN o.ontology_id = 'ARO:3004411' THEN 'agar dilution'
	    WHEN o.ontology_id = 'ARO:3004397' THEN 'MIC'
            ELSE NULL
       END AS laboratory_typing_method 
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.laboratory_typing_method = o.id;

CREATE VIEW ncbi_amr_platform
AS
SELECT amr.id AS amr_id, 
       CASE WHEN o.ontology_id = 'ARO:3007569' THEN 'BIOMIC'
      	    WHEN o.ontology_id = 'ARO:3004400' THEN 'Microscan'
      	    WHEN o.ontology_id = 'ARO:3004401' THEN 'Phoenix'
	    WHEN o.ontology_id = 'ARO:3004402' THEN 'Sensititre'
	    WHEN o.ontology_id = 'ARO:3004403' THEN 'Vitek'
            ELSE NULL
       END AS laboratory_typing_platform
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.laboratory_typing_platform = o.id;

CREATE VIEW ncbi_amr_vendor
AS
SELECT amr.id AS amr_id, 
       CASE WHEN o.ontology_id = 'ARO:3004405' THEN 'Becton Dickinson'
            WHEN o.ontology_id = 'ARO:3004406' THEN 'Biomérieux'
            WHEN o.ontology_id = 'ARO:3004408' THEN 'Omron'
            WHEN o.ontology_id = 'ARO:3004407' THEN 'Siemens'
            WHEN o.ontology_id = 'ARO:3004409' THEN 'Trek'
            ELSE NULL
       END AS vendor
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.vendor_name = o.id;

CREATE VIEW ncbi_amr_standard
AS
SELECT amr.id AS amr_id, 
       CASE WHEN o.ontology_id = 'ARO:3004365' THEN 'BSAC' 
            WHEN o.ontology_id = 'ARO:3004366' THEN 'CLSI' 
            WHEN o.ontology_id = 'ARO:3004367' THEN 'DIN' 
            WHEN o.ontology_id = 'ARO:3004368' THEN 'EUCAST'
            WHEN o.ontology_id = 'ARO:3007195' THEN 'NARMS' 
            WHEN o.ontology_id = 'ARO:3007193' THEN 'NCCLS' 
            WHEN o.ontology_id = 'ARO:3004369' THEN 'SFM' 
            WHEN o.ontology_id = 'ARO:3007397' THEN 'SIR' 
            WHEN o.ontology_id = 'ARO:3007398' THEN 'WRG' 
            ELSE NULL
       END AS testing_standard
  FROM amr_antibiotics_profile AS amr
       LEFT JOIN ontology_terms AS o 
	      ON amr.testing_standard = o.id;

CREATE VIEW ncbi_antibiogram
AS
SELECT i.isolate_id AS sample_name,
       ab.antibiotic,
       pheno.resistance_phenotype,
       sign.measurement_sign, 
       meas.measurement, 
       meas.measurement_units, 
       meth.laboratory_typing_method,
       plat.laboratory_typing_platform,
       vendor.vendor,
       laboratory_typing_platform_version AS laboratory_typing_method_version_or_reagent, 
       stand.testing_standard
  FROM isolates AS i
       LEFT JOIN am_susceptibility_tests as tests
              ON i.id = tests.isolate_id 
       LEFT JOIN amr_antibiotics_profile as amr
	      ON amr.test_id = tests.id
       LEFT JOIN ncbi_antibiotics AS ab 
	      ON amr.id = ab.amr_id
       LEFT JOIN ncbi_amr_phenotype AS pheno 
	      ON amr.id = pheno.amr_id
       LEFT JOIN ncbi_amr_sign AS sign
	      ON amr.id = pheno.amr_id
       LEFT JOIN ncbi_amr_measurement AS meas
	      ON amr.id = meas.amr_id
       LEFT JOIN ncbi_amr_method AS meth
	      ON amr.id = meth.amr_id
       LEFT JOIN ncbi_amr_platform AS plat
	      ON amr.id = plat.amr_id
       LEFT JOIN ncbi_amr_vendor AS vendor
	      ON amr.id = vendor.amr_id
       LEFT JOIN ncbi_amr_standard AS stand
	      ON amr.id = stand.amr_id;

