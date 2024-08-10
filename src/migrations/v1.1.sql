BEGIN;

INSERT INTO db_versions
	(id, major_release, minor_release, script_name, grdi_template_version, date_applied)
	VALUES (2, 1, 0, 'v1.1.sql', 'v12.2.2', CURRENT_DATE);

-- Add a new column to the ontology terms table 
ALTER TABLE ontology_terms 
        ADD COLUMN deprecated boolean DEFAULT FALSE, 
        ADD COLUMN replaced_by int REFERENCES ontology_terms(id);

-- Add new lookup table for new label_claims
CREATE TABLE label_claims (
		ontology_term_id int4 PRIMARY KEY REFERENCES ontology_terms(id),
		curated bool DEFAULT true
);

-- Add new multi choice table for new label_claims field 
CREATE TABLE food_data_label_claims (
	id int4 NOT NULL REFERENCES food_data(id),
	term_id int4 NOT NULL REFERENCES label_claims(ontology_term_id),
	CONSTRAINT food_data_label_claims_pk PRIMARY KEY (id, term_id)
);

-- Add new multi choice table for environmental_material_consituents field. 
CREATE TABLE environmental_data_material_constituents (
	id int4 NOT NULL REFERENCES environmental_data(id),
  term_id text,
	CONSTRAINT environmental_data_material_constituents_pk PRIMARY KEY (id, term_id)
);

-- New terms:
INSERT INTO ontology_terms (ontology_id, en_term) VALUES 
('FOODON:03411223', 'Mussel'), 
('FOODON:03411205', 'Squid'), 
('GENEPIO:0101196', 'Tube'), 
('FOODON:0001282', 'beef (ground)'), 
('FOODON:02000426', 'Beef (ground, extra lean)'), 
('FOODON:02000425', 'Beef (ground, lean)'), 
('FOODON:02000427', 'Beef (ground, medium)'), 
('FOODON:02000428', 'Beef (ground, regular)'), 
('FOODON:02000429', 'Beef (ground, sirloin)'), 
('FOODON:02000069', 'Beef shoulder'), 
('FOODON:02000412', 'Beef (pieces of)'), 
('FOODON:02020231', 'Chicken breast (skinless)'), 
('FOODON:02020233', 'Chicken breast (with skin)'), 
('FOODON:02020235', 'Chicken breast (skinless, boneless)'), 
('FOODON:02020237', 'Chicken drumstick (skinless)'), 
('FOODON:02020239', 'Chicken drumstick (with skin)'), 
('FOODON:02020311', 'Chicken meat (ground)'), 
('FOODON:02020228', 'Chicken thigh (skinless, boneless)'), 
('FOODON:02021718', 'Pork meat (ground)'), 
('FOODON:02000322', 'Pork shoulder'), 
('FOODON:02000300', 'Pork sirloin chop'), 
('FOODON:02021757', 'Pork steak'), 
('FOODON:02000306', 'Pork tenderloin'), 
('FOODON:03411224', 'Oyster'), 
('FOODON:02020805', 'Scallop'), 
('FOODON:02020495', 'Turkey breast (skinless)'), 
('FOODON:02020499', 'Turkey breast (skinless, boneless)'), 
('FOODON:02020497', 'Turkey breast (with skin)'), 
('FOODON:02020477', 'Turkey drumstick'), 
('FOODON:02020501', 'Turkey drumstick (skinless)'), 
('FOODON:02020503', 'Turkey drumstick (with skin)'), 
('FOODON:02020577', 'Turkey meat (ground)'), 
('FOODON:02020491', 'Turkey thigh (skinless, boneless)'), 
('FOODON:02020478', 'Turkey wing'), 
('FOODON:00003643', 'Arugula greens bunch'), 
('FOODON:00003744', 'Chili pepper'), 
('FOODON:00004367', 'Karela (bitter melon)'), 
('FOODON:03000180', 'Chia sprout'), 
('FOODON:00002318', 'Tomato (whole or parts)'), 
('FOODON:03301223', 'Paprika (ground)'), 
('GENEPIO:0101022', 'Biological replicate process'), 
('GENEPIO:0101021', 'Technical replicate process'), 
('OBI:0003099', 'Matrix Assisted Laser Desorption Ionization imaging mass spectrometry assay (MALDI)'), 
('FOODON:03601063', 'Antibiotic free'), 
('FOODON:03601064', 'Cage free'), 
('FOODON:03601062', 'Hormone free'), 
('FOODON:03601065', 'Pasture raised');

INSERT INTO microbes (ontology_id, scientific_name) VALUES 
('NCBITaxon:670', 'Vibrio parahaemolyticus');

-- Update lookup table "animal_source_of_food"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('FOODON:03411223', 'FOODON:03411205'))
INSERT INTO "animal_source_of_food" (ontology_term_id)
SELECT id FROM lookup;

-- Update lookup table "collection_devices"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('GENEPIO:0101196'))
INSERT INTO "collection_devices" (ontology_term_id)
SELECT id FROM lookup;

-- Update lookup table "food_products"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('FOODON:0001282', 'FOODON:02000426', 'FOODON:02000425', 'FOODON:02000427', 'FOODON:02000428', 'FOODON:02000429', 'FOODON:02000069', 'FOODON:02000412', 'FOODON:02020231', 'FOODON:02020233', 'FOODON:02020235', 'FOODON:02020237', 'FOODON:02020239', 'FOODON:02020311', 'FOODON:02020228', 'FOODON:02021718', 'FOODON:02000322', 'FOODON:02000300', 'FOODON:02021757', 'FOODON:02000306', 'FOODON:03411223', 'FOODON:03411224', 'FOODON:02020805', 'FOODON:03411205', 'FOODON:02020495', 'FOODON:02020499', 'FOODON:02020497', 'FOODON:02020477', 'FOODON:02020501', 'FOODON:02020503', 'FOODON:02020577', 'FOODON:02020491', 'FOODON:02020478', 'FOODON:00003643', 'FOODON:00003744', 'FOODON:00004367', 'FOODON:03000180', 'FOODON:00002318', 'FOODON:03301223'))
INSERT INTO "food_products" (ontology_term_id)
SELECT id FROM lookup;

-- Update lookup table "label_claims"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('FOODON:03601063', 'FOODON:03601064', 'FOODON:03601062', 'FOODON:03510128', 'FOODON:03601065', 'GENEPIO:0001619', 'GENEPIO:0001620', 'GENEPIO:0001668', 'GENEPIO:0001618', 'GENEPIO:0001810'))
INSERT INTO "label_claims" (ontology_term_id)
SELECT id FROM lookup;

-- Update lookup table "specimen_processing"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('GENEPIO:0101022', 'GENEPIO:0101021'))
INSERT INTO "specimen_processing" (ontology_term_id)
SELECT id FROM lookup;

-- Update lookup table "taxonomic_identification_processes"
WITH lookup AS
(SELECT id
   FROM ontology_terms
  WHERE ontology_id IN
('OBI:0003099'))
INSERT INTO "taxonomic_identification_processes" (ontology_term_id)
SELECT id FROM lookup;

-- Deprecate some terms and set their replacements.
WITH x (old_term, new_term) as (VALUES 
('FOODON:03000412','FOODON:0001282' ),
('FOODON:03000398','FOODON:02000426'),
('FOODON:03000394','FOODON:02000425'),
('FOODON:03000402','FOODON:02000427'),
('FOODON:03000406','FOODON:02000428'),
('FOODON:03000408','FOODON:02000429'),
('FOODON:03000377','FOODON:02000069'),
('FOODON:03000333','FOODON:02000412'),
('FOODON:00003332','FOODON:02020231'),
('FOODON:03000374','FOODON:02020233'),
('FOODON:00003364','FOODON:02020235'),
('FOODON:03000366','FOODON:02020237'),
('FOODON:03000368','FOODON:02020239'),
('FOODON:03000410','FOODON:02020311'),
('FOODON:03000417','FOODON:02020228'),
('FOODON:03000413','FOODON:02021718'),
('FOODON:03000376','FOODON:02000322'),
('FOODON:03000390','FOODON:02000300'),
('FOODON:00003148','FOODON:02021757'),
('FOODON:03000416','FOODON:02000306'),
('FOODON:03411489','FOODON:02020805'),
('FOODON:03000372','FOODON:02020495'),
('FOODON:03000373','FOODON:02020499'),
('FOODON:03000375','FOODON:02020497'),
('FOODON:03000365','FOODON:02020477'),
('FOODON:03000367','FOODON:02020501'),
('FOODON:03000369','FOODON:02020503'),
('FOODON:03000411','FOODON:02020577'),
('FOODON:03000370','FOODON:02020491'),
('FOODON:03000371','FOODON:02020478'),
('FOODON:00002426','FOODON:00003643'),
('FOODON:03315873','FOODON:00003744'),
('FOODON:00004284','FOODON:03000180'),
('FOODON:03000227','FOODON:00002318'),
('FOODON:03301105','FOODON:03301223'),
('OBI:0000198'    ,'GENEPIO:0101022'),
('OBI:0000249'    ,'GENEPIO:0101021'),
('UBERON:0000025' ,'GENEPIO:0101196'))
UPDATE ontology_terms AS o 
   SET deprecated = TRUE, 
       replaced_by = (SELECT id FROM ontology_terms WHERE ontology_id = x.new_term)
  FROM x
 WHERE o.id = (SELECT id FROM ontology_terms WHERE ontology_id = x.old_term)
;

-- Do an update of deprecated terms
-- Food products
WITH new_vals AS 
  (SELECT id, replaced_by from ontology_terms where deprecated = TRUE)
UPDATE food_data_product AS f 
   SET term_id = new_vals.replaced_by 
  FROM new_vals
 WHERE f.term_id = new_vals.id;

-- specimen processing
WITH new_vals AS 
  (SELECT id, replaced_by from ontology_terms where deprecated = TRUE)
UPDATE collection_information AS c
   SET specimen_processing = new_vals.replaced_by 
  FROM new_vals
 WHERE c.specimen_processing = new_vals.id;

-- collection device
WITH new_vals AS 
  (SELECT id, replaced_by from ontology_terms where deprecated = TRUE)
UPDATE collection_information AS c
   SET collection_device = new_vals.replaced_by 
  FROM new_vals
 WHERE c.collection_device = new_vals.id;

COMMIT;
