#!/bin/bash

DB=$1
dir="baseline/sql"

# Create the DB
createdb $DB

# Initial ontology table
psql --dbname $DB --file ${dir}/ontology_tables.sql

# Make the ontology lookup tables
bash baseline/ontology_lookups.sh | psql --dbname $DB --file=-

# Assemble the main data tables
psql --dbname $DB --file ${dir}/samples.sql
psql --dbname $DB --file ${dir}/sample_meta_tables.sql
psql --dbname $DB --file ${dir}/isolates.sql
psql --dbname $DB --file ${dir}/seq_bioinf.sql 
psql --dbname $DB --file ${dir}/ast.sql 
# bioinformatics schema
psql --dbname $DB --file ${dir}/bioinformatics.sql
psql --dbname $DB --file ${dir}/misc.sql
# versioning 
psql --dbname $DB --file ${dir}/versioning.sql

# Input data
for f in baseline/data/*.sql
do
	psql --dbname $DB --file "$f"
done

## Functions 
for func in functions/*.sql
do
  psql --dbname $DB --file "$func"
done

# Views 
for f in views/*
do
	psql --dbname $DB --file "$f"
done
