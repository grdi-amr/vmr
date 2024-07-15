# The Virtual Microbial Resource

The virtual microbial resource is a database to store metadata of samples, isolates, and sequences collected as part of the Government of Canada's 
[GRDI-AMR2 project](https://grdi.canada.ca/en/projects/antimicrobial-resistance-2-amr2-project). 
It implements the [GRDI-AMR OneHealth data standard](https://github.com/cidgoh/GRDI_AMR_One_Health) as a relational database in PostGres. 

This repo contains the sql code to generate a mostly-empty database. The GRDI-AMR 
OneHealth ontology, which definesontology terms that are allowed to be selected in 
various the metadata fields, is also implemented in this repo. 

## Installation 

Requirements:

- Postgres

On a local machine, ensure a postgres cluster is initialized. Then, create a 
database from the baseline sql code:

```
cd src
bash make_from_baseline.sh database_name

```

This will generate a schema with empty data tables, but with ontology terms and 
associated lookup tables filled according to the GRDI OneHealth data standard.
