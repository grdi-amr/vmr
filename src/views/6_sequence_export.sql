DROP VIEW IF EXISTS ncbi_wgs_export;
CREATE OR REPLACE VIEW ncbi_wgs_export
AS
WITH sel AS (
  SELECT  isolates.biosample_id,
	  wgs.isolate_id, 
	  wgs.library_id,
	  microbes.scientific_name AS organism,
	  ontology_id(sequencing_platform) AS platform,
	  ontology_term(sequencing_instrument) AS instrument,
	  sequencing_assay_type,
	  ontology_id(sequencing_assay_type) AS assay_type_id,
	  r1_fastq_filename, 
	  r2_fastq_filename, 
          fast5_filename, 
          r1_irida_id, 
          r2_irida_id
  FROM wgs 
  LEFT JOIN isolates ON isolates.id = wgs.isolate_id 
  LEFT JOIN microbes ON isolates.organism = microbes.id
)
SELECT biosample_id AS biosample_accession, 
       library_id AS "library_ID",
       CONCAT(ontology_term(sequencing_assay_type), ' of ', organism) AS title,
       -- Library Strategy
       CASE WHEN assay_type_id     = 'OBI:0002117' THEN 'WGS'       --WGS
            WHEN assay_type_id     = 'OBI:0002763'                  --16S
                 OR assay_type_id  = 'OBI:0002767' THEN 'AMPLICON'  --Amplicon
            WHEN assay_type_id     = 'OBI:0002623'                  --Metagenome
                 OR assay_type_id  = 'OBI:0002768' THEN 'OTHER'     --Whole virome
            ELSE NULL
        END AS library_strategy,
       -- Library Source
       CASE WHEN    assay_type_id = 'OBI:0002117'                 --WGS
                 OR assay_type_id = 'OBI:0002763'                 --16S
                 OR assay_type_id = 'OBI:0002767' THEN 'GENOMIC'  --Amplicon
            WHEN assay_type_id = 'OBI:0002623' THEN 'MEAGENOMIC'  --Metagenome
            WHEN assay_type_id = 'OBI:0002768' THEN 'VIRAL RNA'   --Whole virome
            ELSE NULL 
        END AS  library_source,
       -- Library Selection 
       CASE WHEN    assay_type_id = 'OBI:0002117'                --WGS
                 OR assay_type_id = 'OBI:0002623'                --Metagenome
                 OR assay_type_id = 'OBI:0002768' THEN 'RANDOM'  --Whole virome
            WHEN    assay_type_id = 'OBI:0002763'                --16S
                 OR assay_type_id = 'OBI:0002767' THEN 'PCR'     --Amplicon
            ELSE NULL 
        END AS  library_selection,
       -- Library Layout
       CASE WHEN r1_fastq_filename IS NOT NULL 
                 AND 
                 r2_fastq_filename IS NOT NULL THEN 'paired'
            ELSE 'single'
        END AS library_layout,
       -- Plaform
       CASE WHEN platform = 'GENEPIO:0001923' THEN 'ILLUMINA'        --Illumina                    
            WHEN platform = 'GENEPIO:0001927' THEN 'PACBIO_SMRT'     --Pacific Biosciences         
            WHEN platform = 'GENEPIO:0002683' THEN 'ION_TORRENT'     --Ion Torrent                 
            WHEN platform = 'OBI:0002755'     THEN 'OXFORD_NANOPORE' --Oxford Nanopore Technologies
            WHEN platform = 'GENEPIO:0004324' THEN 'BGISEQ'          --BGI Genomics                
            WHEN platform = 'GENEPIO:0004325' THEN 'DNBSEQ'          --MGI    
            ELSE NULL 
        END AS platform,
       -- Instrument model 
       CASE WHEN instrument IS NOT NULL THEN instrument 
            ELSE 'Unspecified'
        END AS instrument_model, 
       -- Design Description 
       NULL AS design_description,
       -- Filetype 
       CASE WHEN r1_fastq_filename IS NOT NULL THEN 'fastq'
            WHEN fast5_filename IS NOT NULL THEN 'OxfordNanopore_native'
            ELSE NULL
        END AS filetype,
       -- Filename
       CASE WHEN r1_fastq_filename IS NOT NULL THEN r1_fastq_filename 
            WHEN fast5_filename    IS NOT NULL THEN fast5_filename
            ELSE NULL
        END AS filename,
       -- Filename2
       CASE WHEN r2_fastq_filename IS NOT NULL THEN r2_fastq_filename 
            ELSE NULL
        END AS filename2,
       NULL AS filename3, 
       NULL AS filename4, 
       NULL AS assembly, 
       NULL AS fasta_file, 
       r1_irida_id, 
       r2_irida_id
FROM sel
WHERE r1_fastq_filename IS NOT NULL 
      OR 
      r2_fastq_filename IS NOT NULL
      OR 
      fast5_filename IS NOT NULL
;

