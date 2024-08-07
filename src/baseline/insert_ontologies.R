library(tidyverse)
library(DBI)
library(grdiamR)

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
            dbname = "remake",
            user = "emil")

map <- dbReadTable(vmr, "template_mapping") %>% as_tibble()
fk <- dbReadTable(vmr, "foreign_keys") %>% as_tibble()

# Check that all grdi columns are in the method
sheet <-
  openxlsx::read.xlsx("~/Software/GRDI_AMR_One_Health/Template/GRDI_Harmonization-Template_v11.1.1.xlsm",
                    sheet = 2,
                    startRow = 2,
                    sep.names = " ",
                    )
fields <- colnames(sheet)[1:176]
fields[!fields %in% map$grdi_field]



q <- dbSendQuery(vmr, "SELECT * FROM information_schema.columns")
all_vmr_cols <- dbFetch(q) %>% as_tibble()
map %>% filter(!vmr_table %in% all_vmr_cols$table_name)
map %>% filter(!vmr_field %in% all_vmr_cols$column_name)

data("excel_lookup_values")

terms <-
  excel_lookup_values %>%
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
  terms %>%
  filter(grepl(x=Field, "common") | grepl(x=Field, "scientific")) %>%
  select(Field, Term, Id) %>%
  pivot_wider(names_from = Field, values_from = Term, values_fill = NA) %>%
  janitor::clean_names() %>%
  rename(ontology_id = id,
         scientific_name = host_scientific_name,
         en_common_name = host_common_name)
dbAppendTable(vmr, name = "host_organisms", value = host_org_names)

isolate_orgs <-
  terms %>%
  filter(Field=="organism") %>%
  rename(ontology_id = Id,
         scientific_name = Term) %>%
  select(-Field, -version) %>%
  filter(scientific_name != "Streptococcus equinus")
dbAppendTable(vmr, name = "microbes", value = isolate_orgs)


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







