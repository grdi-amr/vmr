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


DROP TRIGGER audit ON projects;
CREATE TRIGGER audit BEFORE UPDATE OR DELETE on projects FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func();


