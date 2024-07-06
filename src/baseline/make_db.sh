#!/bin/bash

DB="remake"

# Create the DB
createdb $DB

# 
psql --dbname $DB --file ontology_tables.sql

# Make the ontology lookup tables
bash make_ontology_lookup_tables.sh | psql --dbname $DB --file=-

# Assemble the main data tables
psql --dbname $DB --file samples.sql
psql --dbname $DB --file sample_meta_tables.sql
psql --dbname $DB --file isolates.sql
psql --dbname $DB --file seq_bioinf.sql 
psql --dbname $DB --file ast.sql 
# 
psql --dbname $DB --file bioinformatics.sql
