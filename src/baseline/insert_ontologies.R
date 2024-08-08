library(tidyverse)
library(DBI)
library(grdiamR)
load_all("~/Projects/grdiamR/")

template_file <- "~/Software/GRDI_AMR_One_Health/Template/GRDI_Harmonization-Template_v12.2.2.xlsm"

excel_vals <- excel_lookup_values(template_file = template_file)

populate_lookup_table <- function(con, lookup_table, terms){
  message("Table: ", lookup_table)
  query_string <-
    glue::glue_sql(
      .con = con,
      "INSERT into ", lookup_table,
      " (ontology_term_id) VALUES ( (SELECT id FROM ontology_terms WHERE ontology_id = $1) )
      ON CONFLICT (ontology_term_id) DO NOTHING")
  dbExecute(con, query_string, params = list(terms))
}

vmr <-
  dbConnect(drv = RPostgres::Postgres(),
            dbname = "vmr_testing",
            user = "emil")

map <- dbReadTable(vmr, "template_mapping") %>% as_tibble()
fk <- dbReadTable(vmr, "foreign_keys") %>% as_tibble()

# Check that all grdi columns are in the method
sheet <-
  openxlsx::read.xlsx(template_file,
                      sheet = 2,
                      startRow = 2,
                      sep.names = " ")
excel_fields <- colnames(sheet)
xcel_no_amr <- excel_fields[!grepl(x=excel_fields, paste(grdiamR::amr_regexes(), collapse = "|"))]

missing_fields_in_vmr <- xcel_no_amr[!xcel_no_amr %in% map$grdi_field]


all_vmr_cols <- dbGetQuery(vmr, "SELECT * FROM information_schema.columns")
map %>% filter(!vmr_table %in% all_vmr_cols$table_name)
map %>% filter(!vmr_field %in% all_vmr_cols$column_name)

terms <-
  excel_vals %>%
  filter(!is.na(Id)) %>%
  arrange(Field)

# Countries and Statess
countries <-
  terms %>%
  filter(grepl(x=Field, "country")) %>%
  select(Term, Id) %>%
  rename(ontology_id = Id, en_term = Term) %>%
  distinct() %>%
  arrange(ontology_id) %>%
  filter(!en_term == "Swaziland")

dbCountries <- dbReadTable(vmr, "countries") %>% as_tibble()

countries_to_add <-
  countries %>%
  filter(!ontology_id %in% dbCountries$ontology_id)

if (nrow(countries_to_add)>0){
  dbAppendTable(vmr, name = "countries", value = countries_to_add)
}

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

dbStates <- dbReadTable(vmr, "state_province_regions") %>% as_tibble()

states_to_add <-
  states %>%
  filter(!ontology_id %in% dbStates$ontology_id)

if (nrow(states_to_add)>0){
  dbAppendTable(vmr, name = "state_province_regions", value = states_to_add)
}

# Organisms.
host_org_names <-
  terms %>%
  filter(grepl(x=Field, "common") | grepl(x=Field, "scientific")) %>%
  select(Field, Term, Id) %>%
  pivot_wider(names_from = Field, values_from = Term, values_fill = NA) %>%
  janitor::clean_names() %>%
  rename(ontology_id = id,
         scientific_name = host_scientific_name,
         en_common_name = host_common_name)

dbOrgs <- dbReadTable(vmr, "host_organisms") %>% as_tibble()

host_orgs_to_add <-
  host_org_names %>%
  filter(!ontology_id %in% dbOrgs$ontology_id)

if (nrow(host_orgs_to_add)>0){
  dbAppendTable(vmr, name = "host_organisms", value = host_orgs_to_add)
}


isolate_orgs <-
  terms %>%
  filter(Field=="organism") %>%
  rename(ontology_id = Id,
         scientific_name = Term) %>%
  select(-Field, -version) %>%
  filter(scientific_name != "Streptococcus equinus")

dbIsoOrgs <- dbReadTable(vmr, name = "microbes") %>% as_tibble()

isos_to_add <-
  isolate_orgs %>%
  filter(!ontology_id %in% dbIsoOrgs$ontology_id)

if (nrow(isos_to_add)>0){
  message("Adding ", nrow(isos_to_add), " terms")
  message(paste(isos_to_add$scientific_name, collapse = "; "))
  dbAppendTable(vmr, name = "microbes", value = isos_to_add)
}

map_to_tables <-
  map %>%
  left_join(fk, c("vmr_table"="table_name", "vmr_field"="column_name")) %>%
  select(grdi_field, vmr_table, vmr_field, is_lookup, is_multi_choice, foreign_table_name,
         foreign_column_name)

terms_insert <-
  terms %>%
  mutate(Field = sub(x=Field, " menu$", ""))
x <- terms_insert$Field=="antimicrobial_phenotype"
terms_insert$Field[x] <- "antimicrobial_resistance_phenotype"

tab_fk_to_ont_term <- fk %>% filter(foreign_table_name=='ontology_terms')
terms_to_ins <-
  map_to_tables %>%
  select(grdi_field, foreign_table_name) %>%
  filter(!is.na(foreign_table_name)) %>%
  filter(foreign_table_name %in% tab_fk_to_ont_term$table_name) %>%
  left_join(terms_insert, by = c("grdi_field"="Field")) %>%
  group_by(foreign_table_name) %>%
  summarise(ontology_terms = list(Id)) %>%
  rowwise() %>%
  mutate(ontology_terms = list(unique(ontology_terms))) %>%
  filter(!foreign_table_name %in% c("prevalence_metrics", "stage_of_production"))

unique_terms <-
  terms_insert %>%
  filter(Id %in% unlist(terms_to_ins$ontology_terms)) %>%
  select(Term, Id) %>%
  distinct() %>%
  filter(!duplicated(Id)) %>%
  rename(ontology_id = Id, en_term = Term)
dbAppendTable(vmr, name = "ontology_terms", value = unique_terms)

mapply(populate_lookup_table,
       lookup_table = terms_to_ins$foreign_table_name,
       terms = terms_to_ins$ontology_terms,
       MoreArgs = list(con = vmr))







