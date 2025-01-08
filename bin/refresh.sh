#!/bin/bash
echo -n "Enter psql password: "
read -s PGPASSWORD
echo \n
export PGPASSWORD

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
psql "$@" --quiet --tuples-only --command "$VIEWS" | psql "$@" --quiet
# Drop Functions
psql "$@" --quiet --tuples-only --command "$FUNCS" | psql "$@" --quiet

# Refresh functions
for func in src/functions/*.sql
do
  psql "$@" --file "$func"
done

# Refresh views
for view in src/views/*.sql
do
  psql "$@" --file "$view"
done

unset PGPASSWORD
