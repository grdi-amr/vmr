library(tidyverse)
library(DBI)
devtools::load_all()

vmr <-
  dbConnect(drv = RPostgres::Postgres(),
            dbname = "remake",
            user = "emil")

data("excel_lookup_values")

terms <-
  excel_lookup_values %>%
  filter(!is.na(Id)) %>%
  arrange(Field)

# Get the gazette ontology terms.
gaz_ontology <-
  terms %>%
  filter(grepl(x=Field, "state") | grepl(x=Field, "country")) %>%
  select(Term, Id) %>%
  rename(ontology_id = Id, en_term = Term) %>%
  distinct() %>%
  filter(!duplicated(ontology_id)) %>%
  arrange(en_term)
dbAppendTable(vmr, name = "gaz_terms", value = gaz_ontology)
print("Swaziland removed from gazette ontology")

# Insert into states lookup table
states <-
  terms %>%
  filter(grepl(x=Field, "state"))  %>%
  pull(Id)

insert_states.sql <-
  glue::glue_sql("INSERT INTO state_province_regions (gaz_term_id) VALUES
                 ((SELECT id FROM gaz_terms WHERE ontology_id = $1))")
dbExecute(vmr, insert_states.sql, params = list(states))

# Insert into the countries lookup table
countries <-
  terms %>%
  filter(grepl(x=Field, "country"))  %>%
  pull(Id) %>% unique()

insert_country.sql <-
  glue::glue_sql("INSERT INTO countries (gaz_term_id) VALUES
                 ((SELECT id FROM gaz_terms WHERE ontology_id = $1))")
dbExecute(vmr, insert_country.sql, params = list(countries))

host_org_names <-
  df %>%
  filter(grepl(x=Field, "common") | grepl(x=Field, "scientific")) %>%
  select(Field, Term, Id) %>%
  pivot_wider(names_from = Field, values_from = Term, values_fill = NA) %>%
  janitor::clean_names() %>%
  rename(ontology_id = id,
         scientific_name = host_scientific_name,
         common_name_en = host_common_name) %>%
  mutate(field = "host_organism")

isolate_org_names <-
  df %>%
  filter(Field=="organism") %>%
  rename(ontology_id = Id,
         scientific_name = Term) %>%
  select(-Field, -version) %>%
  mutate(field = "isolate_organism")

all_org <-
  bind_rows(host_org_names, isolate_org_names) %>%
  arrange(ontology_id) %>%
  filter(!grepl(x=ontology_id, "GENEPIO")) %>%
  filter(scientific_name != "Streptococcus bovis")

dbAppendTable(vmr, name = "organism_terms", value = all_org)

# Insert isolate orgs
isolate_orgs <-
  all_org %>%
  filter(field == "isolate_organism") %>%
  pull(ontology_id)

dbExecute(vmr,
          "INSERT INTO isolate_organisms (organism_term_id) VALUES
           ((SELECT id FROM organism_terms WHERE ontology_id = $1))"),
          params = list(isolate_orgs))

# Insert host orgs
host_orgs <-
  all_org %>%
  filter(field == "host_organism") %>%
  pull(ontology_id)

dbExecute(vmr,
          "INSERT INTO host_organisms (organism_term_id) VALUES
          ((SELECT id FROM organism_terms WHERE ontology_id = $1))",
          params = list(host_orgs))


