INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,0,'v2.00.sql', 'v14.5.4', CURRENT_DATE, 'Simplifies the sample metadata tables into a single table');

-- New Big table for the metadata!
CREATE TABLE sample_metadata (
   id                                    integer      PRIMARY    KEY,
   project_id                            int          REFERENCES projects(id),
   sample_collector_sample_id            text         NOT        NULL,
   original_sample_description           text,
   sample_collected_by                   integer      REFERENCES agencies(ontology_term_id),
   contact_information                   integer      REFERENCES contact_information(id),
   sample_collection_date                date,
   sample_collection_date_precision      integer      REFERENCES sample_collection_date_precision(ontology_term_id),
   collection_device                     integer      REFERENCES collection_devices(ontology_term_id),
   collection_method                     integer      REFERENCES collection_methods(ontology_term_id),
   specimen_processing                   integer      REFERENCES specimen_processing(ontology_term_id),
   presampling_activity_details          text,
   geo_loc_country                       integer      REFERENCES countries(id),
   geo_loc_state_province_region         integer      REFERENCES state_province_regions(id),
   geo_loc_name_site                     text,
   geo_loc_latitude                      numeric(8,6),
   geo_loc_longitude                     numeric(9,6),
   sample_storage_method                 text,
   sample_storage_medium                 text,
   specimen_processing_details           text,
   sample_received_date                  date,
   sample_collection_end_date            date,
   sample_processing_date                date,
   sample_collection_start_time          time,
   sample_collection_end_time            time,
   sample_collection_time_of_day         integer      REFERENCES time_of_day(ontology_term_id),
   sample_collection_time_duration_value integer,
   sample_collection_time_duration_unit  integer      REFERENCES duration_units(ontology_term_id),
   food_product_production_stream        integer      REFERENCES food_product_production_streams(ontology_term_id),
   food_product_origin_country           integer      REFERENCES countries(id),
   food_packaging_date                   date,
   food_quality_date                     date,
   anatomical_region                     integer      REFERENCES anatomical_regions(ontology_term_id),
   host_organism                         integer      REFERENCES host_organisms(id),
   host_ecotype                          text,
   host_breed                            text,
   host_food_production_name             integer      REFERENCES host_food_production_names(ontology_term_id),
   host_disease                          text,
   host_age_bin                          integer      REFERENCES host_age_bin(ontology_term_id),
   host_origin_geo_loc_name_country      integer      REFERENCES countries(id),
   air_temperature                       float8,
   air_temperature_units                 integer      REFERENCES temperature_units(ontology_term_id),
   water_temperature                     float8,
   water_temperature_units               integer      REFERENCES temperature_units(ontology_term_id),
   sediment_depth                        float8,
   sediment_depth_units                  integer      REFERENCES depth_units(ontology_term_id),
   water_depth                           integer,
   water_depth_units                     integer      REFERENCES depth_units(ontology_term_id),
   available_data_type_details           text,
   precipitation_measurement_value       text,
   precipitation_measurement_unit        integer      REFERENCES depth_units(ontology_term_id),
   precipitation_measurement_method      text,
   prevalence_metrics                    text,
   prevalence_metrics_details            text,
   stage_of_production                   integer      REFERENCES stage_of_production(ontology_term_id),
   experimental_intervention_details     text
);

-- Before we change the other tables, we must insert the existing data:
INSERT INTO sample_metadata
   SELECT sam.id,
          sam.project_id,
	  sam.sample_collector_sample_id,
          col.original_sample_description,
          col.sample_collected_by,
          col.contact_information,
          col.sample_collection_date,
          col.sample_collection_date_precision,
          col.collection_device,
          col.collection_method,
          col.specimen_processing,
          col.presampling_activity_details,
          geo.country                                      AS geo_loc_country,
          geo.state_province_region                        AS geo_loc_state_province_region,
        sites.geo_loc_name_site                            AS geo_loc_name_site,
          geo.latitude                                     AS geo_loc_latitude,
          geo.longitude                                    AS geo_loc_longitude,
          col.sample_storage_method,
          col.sample_storage_medium,
          col.specimen_processing_details,
          col.sample_received_date,
          col.sample_collection_end_date,
          col.sample_processing_date,
          col.sample_collection_start_time,
          col.sample_collection_end_time,
          col.sample_collection_time_of_day,
          col.sample_collection_time_duration_value,
          col.sample_collection_time_duration_unit,
         food.food_product_production_stream,
         food.food_product_origin_country,
         food.food_packaging_date,
         food.food_quality_date,
	  ana.anatomical_region,
 	  hst.host_organism,
 	  hst.host_ecotype,
       breeds.host_breed,
 	  hst.host_food_production_name,
 	  dis.host_disease,
 	  hst.host_age_bin,
 	  hst.host_origin_geo_loc_name_country,
	  env.air_temperature,
	  env.air_temperature_units,
	  env.water_temperature,
	  env.water_temperature_units,
	  env.sediment_depth,
	  env.sediment_depth_units,
	  env.water_depth,
	  env.water_depth_units,
	  env.available_data_type_details,
	  env.precipitation_measurement_value,
	  env.precipitation_measurement_unit,
	  env.precipitation_measurement_method,
         risk.prevalence_metrics,
         risk.prevalence_metrics_details,
         risk.stage_of_production,
         risk.experimental_intervention_details
     FROM samples AS sam
LEFT JOIN collection_information AS col    ON col.sample_id  = sam.id
LEFT JOIN environmental_data     AS env    ON env.sample_id  = sam.id
LEFT JOIN hosts                  AS hst    ON hst.sample_id  = sam.id
LEFT JOIN host_breeds            AS breeds ON breeds.id      = hst.host_breed
LEFT JOIN host_diseases          AS dis    ON dis.id         = hst.host_disease
LEFT JOIN geo_loc                AS geo    ON geo.sample_id  = sam.id
LEFT JOIN geo_loc_name_sites     AS sites  ON sites.id       = geo.site
LEFT JOIN anatomical_data        AS ana    ON ana.sample_id  = sam.id
LEFT JOIN food_data              AS food   ON food.sample_id = sam.id
LEFT JOIN risk_assessment        AS risk   ON risk.sample_id = sam.id
;

-- Make an identity column
alter table sample_metadata alter column id add generated always as identity;
-- Set it to the correct value
select setval(pg_get_serial_sequence('sample_metadata', 'id'), max(id)) from sample_metadata;
-- Add the audit TRIGGER
CREATE TRIGGER audit_changes_to_ext_table BEFORE UPDATE OR DELETE ON sample_metadata FOR EACH ROW EXECUTE PROCEDURE audit.log_changes();

DO $$
DECLARE x record;
BEGIN
   FOR x IN (
      SELECT tc.constraint_name,
             tc.table_name,
             kcu.column_name,
             ccu.table_name AS meta_table,
             ccu.column_name AS foreign_column_name 
        FROM information_schema.table_constraints       AS tc
        JOIN information_schema.key_column_usage        AS kcu  ON tc.constraint_name  = kcu.constraint_name
                                                               AND tc.table_schema     = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu  ON ccu.constraint_name = tc.constraint_name
       WHERE tc.constraint_type = 'FOREIGN KEY'
         AND ccu.table_name   IN ('food_data', 'environmental_data', 'anatomical_data', 'risk_assessment', 'collection_information')
      )
   LOOP
      -- Add the sample_id column
      EXECUTE format('ALTER TABLE public.%I ADD COLUMN sample_id integer REFERENCES sample_metadata(id);', x.table_name);
      -- I don't want to log these changes, so drop the trigger
      EXECUTE format('DROP TRIGGER audit_changes_to_ext_table ON public.%I', x.table_name);
      -- Here, add the sample_ids
      EXECUTE format('UPDATE %I SET sample_id = %I.sample_id FROM %I where %I.id = %I.id', x.table_name, x.meta_table, x.meta_table, x.meta_table, x.table_name);
      -- Remove the old id column
      EXECUTE format('ALTER TABLE public.%I DROP COLUMN id CASCADE', x.table_name);
      -- Re-add the primary key
      EXECUTE format('ALTER TABLE public.%I ADD PRIMARY KEY (sample_id, term_id)', x.table_name);
      -- Re-add the trigger
      EXECUTE format('CREATE TRIGGER audit_changes_to_ext_table BEFORE UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE PROCEDURE audit.log_changes(sample_id)', x.table_name);
   END LOOP;
END;
$$ language 'plpgsql';

-- Drop those old nasty tables
drop table collection_information CASCADE;
drop table environmental_data CASCADE;
drop table hosts CASCADE;
drop table host_breeds CASCADE;
drop table host_diseases;
drop table geo_loc CASCADE;
drop table geo_loc_name_sites;
drop table anatomical_data CASCADE;
drop table food_data CASCADE;
drop table risk_assessment CASCADE;


