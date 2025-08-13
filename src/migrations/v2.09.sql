INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,9,'v2.09.sql', 'v14.5.4', CURRENT_DATE, 'Removes sample collection columns from extraction table and migrates them to the sample table');

-- Add these columns in the extraction table to the sample table, where they belong.
alter table samples add column experimental_protocol_field     text,
		    add column experimental_specimen_role_type int              REFERENCES experimental_specimen_role_types(ontology_term_id),
            	    add column sample_volume_measurement_value double precision,
	    	    add column sample_volume_measurement_unit  int              REFERENCES volume_measurement_units(ontology_term_id),
            	    add column sample_storage_duration_value   double precision,
            	    add column sample_storage_duration_unit    int              REFERENCES duration_units(ontology_term_id),
		    add column residual_sample_status          int              REFERENCES residual_sample_status(ontology_term_id);

-- migrate the existing data over
UPDATE samples
   SET experimental_protocol_field     = ins.experimental_protocol_field,
       experimental_specimen_role_type = ins.experimental_specimen_role_type,
       sample_volume_measurement_value = ins.sample_volume_measurement_value,
       sample_volume_measurement_unit  = ins.sample_volume_measurement_unit,
       sample_storage_duration_value   = ins.sample_storage_duration_value,
       sample_storage_duration_unit    = ins.sample_storage_duration_unit,
       residual_sample_status          = ins.residual_sample_status
FROM (
    SELECT iso.sample_id,
           ext.experimental_protocol_field,
           ext.experimental_specimen_role_type,
           ext.sample_volume_measurement_value,
           ext.sample_volume_measurement_unit,
           ext.sample_storage_duration_value,
           ext.sample_storage_duration_unit,
           ext.residual_sample_status
      FROM extractions AS ext
      LEFT JOIN wgs_extractions AS wgs ON wgs.extraction_id = ext.id
      LEFT JOIN isolates        AS iso ON            iso.id = wgs.isolate_id
     WHERE iso.sample_id                       IS NOT NULL AND
           ext.experimental_protocol_field     IS NOT NULL OR
           ext.experimental_specimen_role_type IS NOT NULL OR
           ext.sample_volume_measurement_value IS NOT NULL OR
           ext.sample_volume_measurement_unit  IS NOT NULL OR
           ext.sample_storage_duration_value   IS NOT NULL OR
           ext.sample_storage_duration_unit    IS NOT NULL OR
           ext.residual_sample_status          IS NOT NULL
) AS ins
WHERE samples.id = ins.sample_id;

ALTER TABLE extractions
 DROP COLUMN experimental_protocol_field     CASCADE,
 DROP COLUMN experimental_specimen_role_type CASCADE,
 DROP COLUMN sample_volume_measurement_value CASCADE,
 DROP COLUMN sample_volume_measurement_unit  CASCADE,
 DROP COLUMN sample_storage_duration_value   CASCADE,
 DROP COLUMN sample_storage_duration_unit    CASCADE,
 DROP COLUMN residual_sample_status          CASCADE;

