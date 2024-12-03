SELECT *
from wgs

;

CREATE OR REPLACE FUNCTION aggregate_multi_choice_table(table_name text) 
RETURNS TABLE (id integer, vals text) AS $$
BEGIN
   RETURN QUERY EXECUTE format('
   SELECT id,
	  string_agg(ontology_full_term(term_id), ''; '') AS terms
     FROM %I 
    GROUP BY id', table_name);
END; 
$$ language plpgsql;

select * FROM aggregate_multi_choice_table('food_data_product_property');



