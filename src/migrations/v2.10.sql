INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,10,'v2.10.sql', 'v14.5.4', CURRENT_DATE, 'Adds rapeseed, barley, and oats terms to host organisms');

INSERT INTO host_organisms (ontology_id, scientific_name, en_common_name, curated)
        VALUES ('NCBITaxon:112509', 'Hordeum vulgare subsp. vulgare', 'Domesticated barley', false),
               ('NCBITaxon:3708',   'Brassica napus',                 'Rapeseed',            false),
               ('NCBITaxon:4498',   'Avena sativa',                   'Cultivated oats',     false);
