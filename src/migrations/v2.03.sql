INSERT INTO db_versions (major_release, minor_release, script_name, grdi_template_version, date_applied, note)
   VALUES (2,3,'v2.03.sql', 'v14.5.4', CURRENT_DATE, 'Changes timestamp columns to timestamptz');

DO $$
DECLARE
   x record;
BEGIN
   FOR x IN
      (select table_name, column_name from information_schema.columns where data_type = 'timestamp without time zone')
   LOOP
      EXECUTE format('ALTER TABLE public.%I ALTER %I TYPE timestamptz USING %I AT TIME ZONE ''UTC''',
		     x.table_name, x.column_name, x.column_name);
   END LOOP;
END;
$$ language 'plpgsql';
