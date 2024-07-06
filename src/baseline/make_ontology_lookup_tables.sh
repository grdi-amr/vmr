#!/bin/bash

make_lookup_table() {
table_name=$1
cat <<- EOF
	CREATE TABLE ${table_name} (
		ontology_term_id int4 PRIMARY KEY REFERENCES ontology_terms(id),
		curated bool DEFAULT true
	);
EOF
}

lu=(
	# Multiple tables 
	"agencies" 
	"purposes"
	"activities"
	# Collection Information
	"collection_methods"
	"sample_collection_date_precision"
	"collection_devices" 
	"specimen_processing"
	# Environmental Data 
	"weather_types"
	"available_data_types"
	"environmental_materials"
	"animal_or_plant_populations"
	"environmental_sites"
	# Sequencing 
	"sequencing_assay_types"
	"sequencing_instruments"
	"genomic_target_enrichment_methods"
	"sequencing_platforms"
	# Public Repo 
	"attribute_packages"
	# Isolates 
	"taxonomic_identification_processes"
	# Anatomical Data
	"anatomical_parts"
	"body_products"
	"anatomical_regions"
	"anatomical_materials"	
	# Food Data 
	"food_product_production_streams"
	"food_product_properties"
	"animal_source_of_food"
	"food_products"
	"food_packaging"
	# Risk Assesment 
	"prevalence_metrics"
	"stage_of_production"
	# Bioinfomratics 
	"quality_control_issues"
	"quality_control_determinations"
	# Hosts 
	"host_age_bin"
	"host_common_names"
	"host_food_production_names"
	"host_scientific_names"
	# AMR antibiotics profiles 
	"antimicrobial_agents"
	"antimicrobial_phenotypes"
	"laboratory_typing_methods"
	"laboratory_typing_platforms"
	"measurement_sign"
	"measurement_units"
	"testing_standard"
	"vendor_names"
	# Extraction 
	"volume_measurement_units"
	"residual_sample_status"
	"experimental_specimen_role_types"
	"duration_units"
)

for table in "${lu[@]}"; do 
	make_lookup_table $table
done


	
	
