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

# Countries and States.
countries <-
  terms %>%
  filter(grepl(x=Field, "country")) %>%
  select(Term, Id) %>%
  rename(ontology_id = Id, en_term = Term) %>%
  distinct() %>%
  arrange(ontology_id) %>%
  filter(!en_term == "Swaziland")
dbAppendTable(vmr, name = "countries", value = countries)

canada_id <-
  dbSendQuery(vmr, "SELECT id FROM countries WHERE en_term = 'Canada'") %>%
  dbFetch() %>% pull(id)
states <-
  terms %>%
  filter(grepl(x=Field, "state")) %>%
  select(Term, Id) %>%
  rename(ontology_id = Id, en_term = Term) %>%
  arrange(ontology_id) %>%
  filter(!grepl(x=ontology_id, "GENEPIO")) %>%
  mutate(country_id = canada_id)
dbAppendTable(vmr, name = "state_province_regions", value = states)

# Organisms.
host_org_names <-
  df %>%
  filter(grepl(x=Field, "common") | grepl(x=Field, "scientific")) %>%
  select(Field, Term, Id) %>%
  pivot_wider(names_from = Field, values_from = Term, values_fill = NA) %>%
  janitor::clean_names() %>%
  rename(ontology_id = id,
         scientific_name = host_scientific_name,
         en_common_name = host_common_name)
dbAppendTable(vmr, name = "host_organisms", value = host_org_names)

isolate_orgs <-
  df %>%
  filter(Field=="organism") %>%
  rename(ontology_id = Id,
         scientific_name = Term) %>%
  select(-Field, -version) %>%
  filter(scientific_name != "Streptococcus equinus")
dbAppendTable(vmr, name = "microbes", value = isolate_orgs)



