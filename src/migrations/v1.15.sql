INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (1,15,'From R: vmR::append_ncbi_taxon_ontology_to_microbes()', 'v14.5.4', CURRENT_DATE, 'Adds all bacteria to the microbes table from the NCBITaxon ontology');

   -- Note: This script only increments the database version table. In order to actually update the database, it 
   -- is neccessary to use R, and the package ejurga/vmR (on github) - use the function 
   -- vmR::append_ncbi_taxon_ontology_to_microbes


