INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,8,'v1.8.sql', 'v13.3.4', CURRENT_DATE);

DO $$
DECLARE
    t text;
BEGIN
    FOR t IN
	(SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name != 'db_versions' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE format(
	 'ALTER TABLE public.%I
	        ADD COLUMN inserted_at timestamp NOT NULL DEFAULT now(),
	        ADD COLUMN inserted_by text      NOT NULL DEFAULT current_user,
	        ADD COLUMN updated_at  timestamp DEFAULT NULL,
	        ADD COLUMN updated_by  text      DEFAULT NULL;
	  CREATE TRIGGER update_usertimestamp
	         BEFORE UPDATE ON public.%I
                 FOR EACH ROW EXECUTE PROCEDURE trigger_set_usertimestamp()', t,t);
    END loop;
END;
$$ language 'plpgsql';
