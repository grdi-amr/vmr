CREATE OR REPLACE FUNCTION bind_ontology(term text, ont_id text)
  RETURNS text
RETURN concat(term, ' [', ont_id, ']');
