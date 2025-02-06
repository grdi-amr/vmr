INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,12,'v1.12.sql', 'v13.3.4', CURRENT_DATE);

DO $$
DECLARE
    tablename text;
BEGIN
    FOR tablename IN
	(SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name != 'db_versions' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE format(
	 'ALTER TABLE public.%I
	        DROP COLUMN updated_at,
	        DROP COLUMN updated_by,
          ADD  COLUMN was_updated bool DEFAULT FALSE;
	  DROP trigger update_usertimestamp ON public.%I;
	  CREATE TRIGGER audit_changes_to_ext_table
	         BEFORE UPDATE OR DELETE ON public.%I
                 FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func()', tablename,tablename,tablename);
    END loop;
END;
$$ language 'plpgsql';
