#!/bin/bash

DB=$1
dir="src/baseline/data"

dump_table() {
	table=$1
	pg_dump --dbname $DB -t $table --data-only --no-comments | 
		sed '1,19d' | sed -e '/^--/d' | sed  -e '/^$/N;/^\n$/D'
}

dump_table template_mapping > ${dir}/1_mapping.sql
# 
dump_table ontology_terms > ${dir}/2_ontology_terms.sql
# 
dump_table host_organisms > ${dir}/3_host_organisms.sql
dump_table countries > ${dir}/3_countries.sql
dump_table microbes > ${dir}/3_microbes.sql
dump_table state_province_regions > ${dir}/3_states.sql

mapfile -t lu < <(psql --dbname $DB --command "select table_name from foreign_keys where foreign_table_name = 'ontology_terms'" -P "footer=off" --tuples-only)

lu_file=${dir}/4_lookup_tables.sql
echo -n > $lu_file
for table in ${lu[@]}
do 
	dump_table $table >> $lu_file
done


