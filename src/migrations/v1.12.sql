INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,12,'v1.12.sql', 'v13.3.4', CURRENT_DATE);

DO $$
DECLARE
    table_row record;
BEGIN
    FOR table_row IN
	(WITH public_cols AS (
		SELECT table_name, column_name, data_type 
		  FROM information_schema.columns
		 WHERE table_schema = 'public'
		   AND table_name   NOT IN (SELECT table_name FROM information_schema.views)
	),
	tables_with_id AS (
		SELECT table_name
		  FROM public_cols
		 WHERE column_name = 'id'
	),
	tables_with_dif_id AS (
		SELECT table_name, column_name
		  FROM public_cols
	   WHERE table_name  NOT IN (SELECT table_name FROM tables_with_id)
	   	 AND column_name LIKE '%id'
		 AND data_type   = 'integer'
	),
	table_and_id_col AS (
		SELECT table_name, NULL AS column_name 
		  FROM tables_with_id
		 UNION
		SELECT table_name, column_name
	    FROM tables_with_dif_id 
		 WHERE table_name  != 'wgs_extractions'
		   AND column_name != 'extraction_id'
	)
	SELECT table_name, column_name from table_and_id_col)
    LOOP
        EXECUTE format(
	 'ALTER TABLE public.%I
	        DROP COLUMN IF EXISTS updated_at,
	        DROP COLUMN updated_by,
		ADD  COLUMN was_updated bool DEFAULT FALSE;
	  DROP TRIGGER update_usertimestamp ON public.%I;
	  CREATE TRIGGER audit_changes_to_ext_table
	         BEFORE UPDATE OR DELETE ON public.%I
                 FOR EACH ROW EXECUTE PROCEDURE audit.log_changes(%s)', table_row.table_name,table_row.table_name,table_row.table_name,table_row.column_name);
    END LOOP;
END;
$$ language 'plpgsql';
