INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,1,'v2.01.sql', 'v14.5.4', CURRENT_DATE, 'Alters the contacts table to remove nulls, and a migration to fix some errors. Also rename some column names in the sample table!');

-- Fix nulls in contact_information
update contact_information set laboratory_name = 'Not Provided [GENEPIO:0001668]' WHERE laboratory_name IS NULL;
alter table contact_information 
      alter column contact_name    set not null,
      alter column laboratory_name set not null,
      alter column laboratory_name set default 'Not Provided [GENEPIO:0001668]',
      alter column contact_email   set not null,
      alter column contact_email   set default 'Not Provided [GENEPIO:0001668]';

-- fix duplicated entry
update isolates set contact_information = 12 WHERE contact_information = 14;
delete from contact_information where id = 14;

-- fix some names in the new sample table
alter TABLE samples RENAME COLUMN geo_loc_country               TO geo_loc_name_country;
alter TABLE samples RENAME COLUMN geo_loc_state_province_region TO geo_loc_name_state_province_region;
alter TABLE samples RENAME COLUMN food_product_origin_country   TO food_product_origin_geo_loc_name_country;

