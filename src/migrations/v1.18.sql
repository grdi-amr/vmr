INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,18,'v1.18.sql', 'v14.5.4', CURRENT_DATE, 'Adds Halva food term for Sandeeps data, and adds regions field to states_provinces_regions');
 
WITH terms_inserted AS (
   INSERT INTO ontology_terms (ontology_id, en_term, curated)
   VALUES   ('FOODON:00002931',   'Halva',     false)
   RETURNING id)
INSERT INTO food_products (ontology_term_id) (SELECT id FROM terms_inserted);


-- Add regions column that should make it easier to show results in terms of Canadian regions
-- Add the column
ALTER TABLE state_province_regions ADD COLUMN region text;
-- Add the regions, there is only canadian provinces in this table.
UPDATE state_province_regions SET region = 'Atlantic region'   WHERE en_term IN ('Nova Scotia', 'Newfoundland & Labrador', 'New Brunswick', 'Prince Edward Island', 'Atlantic region (Canada)');
UPDATE state_province_regions SET region = 'West Coast'        WHERE en_term IN ('British Columbia', 'Pacific region (Canada)');
UPDATE state_province_regions SET region = 'Central Canada'    WHERE en_term IN ('Ontario', 'Quebec', 'Central region (Canada)');
UPDATE state_province_regions SET region = 'Prairie Provinces' WHERE en_term IN ('Saskatchewan', 'Alberta', 'Manitoba', 'Prairie region (Canada)');
UPDATE state_province_regions SET region = 'North'             WHERE en_term IN ('Nunuvut', 'Northwest Territories', 'Yukon', 'Northern region (Canada)');

