library(tidyverse)
library(DBI)
load_all("~/Projects/grdiamR/")

inserts_for_main_ontology <- function(db, ontology_id, en_term){

  message("Adding ", length(ontology_id), " terms")
  ins <- glue::glue_sql(.con = db, "INSERT INTO ontology_terms (ontology_id, en_term) VALUES ")
  val <- glue::glue_sql("({ontology_id}, {en_term})", .con = db)
  sql <- paste0(ins, "\n",paste0(val, collapse = ', \n'), ";")

  return(sql)
}

inserts_for_host_orgs <- function(df, terms){

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

  missing <-
    host_org_names %>%
    filter(!ontology_id %in% dbOrgs$ontology_id)

  ontology_id <- missing$ontology_id
  scientific_name <- missing$scientific_name
  en_common_name <- missing$en_common_name

  if (nrow(missing)>0){
    message("Adding ", nrow(missing), " terms")
    ins <- glue::glue_sql(
      .con = db,
      "INSERT INTO host_organisms (ontology_id, scientific_name, en_common_name) VALUES")
    val <- glue::glue_sql("({ontology_id}, {scientific_name}, {en_common_name})", .con = db)
    sql <- paste0(ins, "\n",paste0(val, collapse = ', \n'), ";")
    return(sql)
  }
}

inserts_for_microbes <- function(db, terms){

  isolate_orgs <-
    terms %>%
    filter(Field=="organism") %>%
    rename(ontology_id = Id,
           scientific_name = Term) %>%
    select(-Field, -version) %>%
    filter(scientific_name != "Streptococcus equinus")

  dbIsoOrgs <- dbReadTable(db, name = "microbes") %>% as_tibble()

  missing <-
    isolate_orgs %>%
    filter(!ontology_id %in% dbIsoOrgs$ontology_id)

  ontology_id <- missing$ontology_id
  scientific_name <- missing$scientific_name

  if (nrow(missing)>0){
    message("Adding ", nrow(missing), " terms")
    ins <- glue::glue_sql(.con = db, "INSERT INTO microbes (ontology_id, scientific_name) VALUES ")
    val <- glue::glue_sql("({ontology_id}, {scientific_name})", .con = db)
    sql <- paste0(ins, "\n",paste0(val, collapse = ', \n'), ";")
    return(sql)
  }
}

insert_into_lookup_table <- function(db, vmr_table, lookup_terms){

  q <- glue::glue_sql(.con = db,
  "SELECT ontology_id FROM {`vmr_table`} as t LEFT JOIN ontology_terms AS o ON t.ontology_term_id = o.id")
  db_lookups <- dbGetQuery(vmr, q)

  missing <- lookup_terms[!lookup_terms %in% db_lookups$ontology_id]

  if (length(missing > 0)){
    message("New values for lookup table ", vmr_table)
    ins_lu_sql <-
      glue::glue_sql(.con = db,
      "-- Update lookup table {`vmr_table`}
      WITH lookup AS
      (SELECT id
         FROM ontology_terms
        WHERE ontology_id IN
      ({missing*}))
      INSERT INTO {`vmr_table`} (ontology_term_id)
      SELECT id FROM lookup;")
    return(ins_lu_sql)
  }

}

template_file <- "~/Software/GRDI_AMR_One_Health/Template/GRDI_Harmonization-Template_v12.2.2.xlsm"

excel_vals <- excel_lookup_values(template_file = template_file)

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
message("These fields appear to be missing in the vmr. Do they need to be added?\n",
        paste0(missing_fields_in_vmr, collapse = ', '))

all_vmr_cols <- dbGetQuery(vmr, "SELECT * FROM information_schema.columns")
map %>% filter(!vmr_table %in% all_vmr_cols$table_name)
map %>% filter(!vmr_field %in% all_vmr_cols$column_name)

terms <-
  excel_vals %>%
  filter(!is.na(Id)) %>%
  arrange(Field)

microbes_sql <- inserts_for_microbes(vmr, terms)
host_orgs_sql <- inserts_for_host_orgs(vmr, terms)

map_to_tables <-
  map %>%
  left_join(fk, c("vmr_table"="table_name", "vmr_field"="column_name")) %>%
  select(grdi_field, vmr_table, vmr_field, is_lookup, is_multi_choice, foreign_table_name,
         foreign_column_name)

terms_insert <-
  terms %>%
  mutate(Field = sub(x=Field, " menu$", ""))
terms_insert <-
  terms_insert %>%
  mutate(Field = case_when(
    Field=="antimicrobial_phenotype" ~ "antimicrobial_resistance_phenotype",
    Field=="quality_control_determination" ~ "quality control determination",
    Field=="quality_control_issues" ~ "quality control issues",
    TRUE ~ Field))

tab_fk_to_ont_term <- fk %>% filter(foreign_table_name=='ontology_terms')
terms_to_ins <-
  map_to_tables %>%
  select(grdi_field, foreign_table_name) %>%
  filter(!is.na(foreign_table_name)) %>%
  filter(foreign_table_name %in% tab_fk_to_ont_term$table_name) %>%
  left_join(terms_insert, by = c("grdi_field"="Field")) %>%
  select(grdi_field, foreign_table_name, Term, Id) %>%
  filter(!foreign_table_name %in% c("prevalence_metrics", "stage_of_production")) %>%
  distinct()

unique_terms <-
  terms_to_ins %>%
  select(Term, Id) %>%
  distinct() %>%
  filter(!duplicated(Id)) %>%
  rename(ontology_id = Id, en_term = Term)

dbOntTerms <- dbReadTable(vmr, "ontology_terms") %>% as_tibble()

ontology_terms_to_add <-
  unique_terms %>%
  filter(!ontology_id %in% dbOntTerms$ontology_id)

main_ontology_ins <-
  inserts_for_main_ontology(vmr, ontology_terms_to_add$ontology_id, ontology_terms_to_add$en_term)

lookups <-
  terms_to_ins %>%
  group_by(foreign_table_name) %>%
  summarise(terms = list(unique(Id)))

lus <- mapply(insert_into_lookup_table,
              vmr_table = lookups$foreign_table_name,
              lookups$terms,
              MoreArgs = list(db=vmr))

sql_full <-
  paste(
    main_ontology_ins,
    microbes_sql,
    host_orgs_sql,
    sep = "\n\n",
    paste0(unlist(lus), collapse = "\n\n"))

write_file(sql_full, file = "test.sql")
