CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions%ROWTYPE; --  Define a rowtype variable, which will be used to insert relevant information
    excluded_cols text[] := ARRAY[]::text[];
    old_row       hstore := hstore(OLD.*) - excluded_cols;
    new_row       hstore := hstore(NEW.*) - excluded_cols;
    row_id        int;
BEGIN
    -- Just raise error if trigger is accidently set to anything other then BEFORE
    IF TG_WHEN <> 'BEFORE' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as a BEFORE trigger';
    END IF;
    IF TG_NARGS = 0 THEN
        audit_row.row_id = OLD.id;
    ELSE
        EXECUTE format('SELECT %I FROM $1', TG_ARGV[0]) USING OLD INTO row_id;
        audit_row.row_id = row_id;
    END IF;
    -- Set the values of the audit row!
    audit_row.event_id          = nextval('audit.logged_actions_event_id_seq');
    audit_row.schema_name       = TG_TABLE_SCHEMA::text;
    audit_row.table_name        = TG_TABLE_NAME::text;
    audit_row.relid             = TG_RELID;
    audit_row.session_user_name = session_user::text;
    audit_row.action_timestamp  = current_timestamp;
    audit_row.application_name  = current_setting('application_name');
    audit_row.action_type       = substring(TG_OP,1,1);
    audit_row.previous_values   = NULL;
    IF (TG_OP = 'UPDATE') THEN
        audit_row.previous_values = old_row - new_row;
        IF audit_row.previous_values = hstore('') THEN
            RAISE EXCEPTION 'Update on table % and row id % results in no change', TG_TABLE_NAME, OLD.id;
            RETURN NULL;
            -- If the update results in no changes, then say so
        END IF;
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
        NEW.was_updated := TRUE;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        audit_row.previous_values = old_row;
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
        RETURN OLD;
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public;
