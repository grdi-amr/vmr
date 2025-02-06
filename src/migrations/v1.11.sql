INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied)
   VALUES (1,11,'v1.11.sql', 'v14.4.4', CURRENT_DATE);

CREATE EXTENSION IF NOT EXISTS hstore;

CREATE SCHEMA audit;
REVOKE ALL ON SCHEMA audit FROM public;
COMMENT ON SCHEMA audit IS 'Out-of-table audit/history logging tables and trigger functions';

DROP TABLE if exists audit.logged_actions;
CREATE TABLE audit.logged_actions (
  event_id bigserial primary key,
  schema_name       text NOT NULL,
  table_name text NOT NULL,
  relid oid   NOT NULL,
  row_id int NOT NULL,
  session_user_name text  NOT NULL,
  application_name  text,
  action_type       TEXT NOT NULL CHECK (action_type IN ('D','U')),
  action_timestamp  TIMESTAMP WITH TIME ZONE NOT NULL,
  previous_values   hstore
);

DO $$
DECLARE
    table_name text;
BEGIN
    FOR table_name IN
	(SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name != 'db_versions' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE format(
	 'ALTER TABLE public.%I
	        DROP COLUMN updated_at,
	        DROP COLUMN updated_by,
          ADD  COLUMN was_updated bool DEFAULT FALSE;
	  CREATE TRIGGER audit_changes_to_ext_table
	         BEFORE UPDATE OR DELETE ON public.%I
                 FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func()', table_name,table_name);
    END loop;
END;
$$ language 'plpgsql';


