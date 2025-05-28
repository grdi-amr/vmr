CREATE OR REPLACE FUNCTION bind_ontology(term text, ont_id text) RETURNS text
AS $$
  BEGIN
    IF   (term IS NULL OR ont_id IS NULL)
      THEN RETURN NULL;
    ELSE
      RETURN concat(term, ' [', ont_id, ']');
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ontology_full_term(i integer, lang text default 'en') RETURNS text
AS $$
  BEGIN
    RETURN(
      SELECT CASE WHEN lang = 'en' THEN bind_ontology(o.en_term, o.ontology_id)
                  WHEN lang = 'fr' THEN bind_ontology(o.fr_term, o.ontology_id)
              END
        FROM ontology_terms AS o
       WHERE o.id = i);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ontology_id(i integer) RETURNS text
AS $$
  BEGIN
    RETURN(
      SELECT o.ontology_id
        FROM ontology_terms AS o
       WHERE o.id = i);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ontology_term(i integer, lang text default 'en') RETURNS text
AS $$
  BEGIN
    RETURN(
      SELECT CASE WHEN lang = 'en' THEN o.en_term
                  WHEN lang = 'fr' THEN o.fr_term
              END
        FROM ontology_terms AS o
       WHERE o.id = i);
  END;
$$ LANGUAGE plpgsql;
