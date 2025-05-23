CREATE OR REPLACE FUNCTION aggregate_multi_choice_table(table_name text) 
   RETURNS TABLE (sample_id integer, vals text) 
AS $$
BEGIN
   RETURN QUERY EXECUTE format('
     SELECT sample_id,
  	    string_agg(ontology_full_term(term_id), ''; '') AS terms
       FROM %I 
   GROUP BY sample_id', table_name);
END; 
$$ LANGUAGE plpgsql;
