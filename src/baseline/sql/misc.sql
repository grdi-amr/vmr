CREATE TABLE template_mapping (
	id int4 PRIMARY KEY GENERATED ALWAYS AS IDENTITY, 
	grdi_group text,
	grdi_field text, 
	vmr_table text,
	vmr_field text,
	is_lookup bool, 
	is_multi_choice bool
);
