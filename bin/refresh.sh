#!/bin/sh

DB=$1

# A command to get all functions defined in public
FUNCS=$(cat <<- 'EOF'
SELECT 'DROP FUNCTION IF EXISTS public.' || routine_name || ';' 
  FROM information_schema.routines 
 WHERE routine_type = 'FUNCTION' AND routine_schema = 'public';
EOF
)

# A command to get all views
VIEWS=$(cat <<- 'EOF'
SELECT 'DROP VIEW IF EXISTS ' || table_schema || '.' || table_name || ' CASCADE;' 
   FROM information_schema.views 
  WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
    AND table_name !~ '^pg_';
EOF
)

# Drop Views
psql --quiet --dbname $DB --tuples-only --command "$VIEWS" | psql --quiet --dbname $DB
# Drop Functions
psql --quiet --dbname $DB --tuples-only --command "$FUNCS" | psql --quiet --dbname $DB 

# Refresh functions
for func in src/functions/*.sql
do
  psql --dbname $DB --file "$func"
done

# Refresh views
for view in src/views/*.sql
do
  psql --dbname $DB --file "$view"
done

