#!/bin/sh

DB=$1

SQL=$(cat <<- 'EOF'
SELECT 'DROP VIEW ' || table_schema || '.' || table_name || ';' 
   FROM information_schema.views 
  WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    AND table_name !~ '^pg_';
EOF
)

psql --dbname $DB --tuples-only --command "$SQL" | psql --dbname $DB 

for f in src/views/
do
	psql --dbname $DB --file "$f"
done
