CREATE EXTENSION IF NOT EXISTS hstore;

CREATE SCHEMA audit;
REVOKE ALL ON SCHEMA audit FROM public;

COMMENT ON SCHEMA audit IS 'Out-of-table audit/history logging tables and trigger functions';

--
-- Audited data. Lots of information is available, it's just a matter of how much
-- you really want to record. See:
--
--   http://www.postgresql.org/docs/9.1/static/functions-info.html
--
-- Remember, every column you add takes up more audit table space and slows audit
-- inserts.
--
-- Every index you add has a big impact too, so avoid adding indexes to the
-- audit table unless you REALLY need them. The hstore GIST indexes are
-- particularly expensive.
--
-- It is sometimes worth copying the audit table, or a coarse subset of it that
-- you're interested in, into a temporary table where you CREATE any useful
-- indexes and do your analysis.
-

DROP TABLE if exists audit.logged_actions;
CREATE TABLE audit.logged_actions (
  event_id bigserial primary key,
	schema_name       text NOT NULL,
	table_name text NOT NULL,
  relid oid   NOT NULL,
  row_id int NOT NULL,
  session_user_name text  NOT NULL,
  action_tstamp_clk TIMESTAMP WITH TIME ZONE NOT NULL,
  application_name text,
  client_addr    inet,
  client_port    integer,
  action      TEXT NOT NULL CHECK (action IN ('I','D','U', 'T')),
  previous_values  hstore
);

DROP function if exists audit_if_modified_func;
CREATE OR REPLACE FUNCTION audit.if_modified_func() RETURNS TRIGGER AS $body$
DECLARE
    audit_row audit.logged_actions%ROWTYPE; --  Define a rowtype variable, which will be used to insert relevant information
    excluded_cols text[] = ARRAY[]::text[];
    old_row hstore := hstore(OLD.*) - excluded_cols;
    new_row hstore := hstore(NEW.*) - excluded_cols;
BEGIN
    -- Just raise error if trigger is accidently set to anything other then AFTER
    IF TG_WHEN <> 'BEFORE' THEN
        RAISE EXCEPTION 'audit.if_modified_func() may only run as a BEFORE trigger';
    END IF;
    -- Set the values of the audit row!
    audit_row.event_id          = nextval('audit.logged_actions_event_id_seq');
	  audit_row.schema_name       = TG_TABLE_SCHEMA::text;                        -- schema_nam
	  audit_row.table_name        = TG_TABLE_NAME::text;                          -- table_name
    audit_row.relid             = TG_RELID;                                    -- relation OID for much quicker searches
    audit_row.row_id            = OLD.id;
    audit_row.session_user_name = session_user::text;                           -- session_user_name                                                  
    audit_row.action_tstamp_clk = current_timestamp;                            -- action_tstamp_tx                                                   
    audit_row.application_name  = current_setting('application_name');          -- client application                                                
    audit_row.client_addr       = inet_client_addr();                           -- client_addr                                                  
    audit_row.client_port       = inet_client_port();                           -- client_port                                                  
    audit_row.action            = substring(TG_OP,1,1);                         -- action
    audit_row.previous_values   = NULL;                                   -- row_data, changed_fields
    IF TG_ARGV[0] IS NOT NULL THEN
        excluded_cols = TG_ARGV[1]::text[];
    END IF;
    IF (TG_OP = 'UPDATE') THEN
        audit_row.previous_values = old_row - new_row;
        IF audit_row.previous_values = hstore('') THEN
            RAISE EXCEPTION 'Update on table % and row id % results in no change', TG_TABLE_NAME, OLD.id;
            RETURN NULL;
            -- If the update results in no changes, then say so
        END IF;
        NEW.was_updated := TRUE;
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        audit_row.previous_values = old_row;
        INSERT INTO audit.logged_actions VALUES (audit_row.*);
        RETURN NULL;
    ELSE
        RAISE EXCEPTION '[audit.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
END;
$body$
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public;
DROP TRIGGER audit ON projects;
CREATE TRIGGER audit BEFORE UPDATE OR DELETE on projects FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();

update projects set project_name = 'A brand new project name' where id = 4;

select * from projects;

select * from audit.logged_actions;

delete from projects where id =4;

alter tab

