#!/bin/bash
echo -n "Enter psql password: "
read -s PGPASSWORD
export PGPASSWORD

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

# Refresh views
for view in src/views/*.sql
do
  psql "$@" --file "$view"
done

unset PGPASSWORD
