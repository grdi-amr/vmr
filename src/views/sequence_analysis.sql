CREATE OR REPLACE FUNCTION get_tool_run_bool(table_name text)
   RETURNS TABLE (sequence_id integer, tool_was_run boolean)
AS $$
BEGIN
   RETURN QUERY EXECUTE format('
   with tool AS (
      select distinct sequencing_id, TRUE AS tool_run from %I
   )
       SELECT id AS sequence_id,
              CASE WHEN tool.tool_run IS NOT NULL THEN TRUE
                   WHEN tool.tool_run IS NULL     THEN FALSE
	       END AS tool_was_run
         FROM sequencing AS seq
    LEFT JOIN tool ON tool.sequencing_id = seq.id', table_name);
END;
$$ LANGUAGE plpgsql
SET search_path = bioinf, public;

CREATE OR REPLACE VIEW bioinf_tools_run_per_seq
AS
SELECT            seq.id           AS sequencing_id,
       digis_elements.tool_was_run AS digis_elements,
     ecoli_serotyping.tool_was_run AS ecoli_serotyping,
iceberg_blastn_genome.tool_was_run AS iceberg_blastn_genome,
 iceberg_blastp_genes.tool_was_run AS iceberg_blastp_genes,
      integron_finder.tool_was_run AS integron_finder,
          island_path.tool_was_run AS island_path,
                 mlst.tool_was_run AS mlst,
              mob_rgi.tool_was_run AS mob_rgi,
            kleborate.tool_was_run AS kleborate,
       plasmid_finder.tool_was_run AS plasmid_finder,
             qc_fastp.tool_was_run AS qc_fastp,
             qc_quast.tool_was_run AS qc_quast,
  phaster_blastp_hits.tool_was_run AS phaster_blastp_hits,
  qc_raw_read_quality.tool_was_run AS qc_raw_read_quality,
            resfinder.tool_was_run AS resfinder,
salmonella_serotyping.tool_was_run AS salmonella_serotyping,
         virulence_vf.tool_was_run AS virulence_vf,
       virulence_vfdb.tool_was_run AS virulence_vfdb,
      qc_seqkit_stats.tool_was_run AS qc_seqkit_stats,
        refseq_masher.tool_was_run AS refseq_masher,
               bacmet.tool_was_run AS bacmet
     FROM sequencing                                 AS seq
LEFT JOIN get_tool_run_bool('digis_elements')        AS digis_elements        ON        digis_elements.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('ecoli_serotyping')      AS ecoli_serotyping      ON      ecoli_serotyping.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('iceberg_blastn_genome') AS iceberg_blastn_genome ON iceberg_blastn_genome.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('iceberg_blastp_genes')  AS iceberg_blastp_genes  ON  iceberg_blastp_genes.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('integron_finder')       AS integron_finder       ON       integron_finder.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('island_path')           AS island_path           ON           island_path.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('mlst')                  AS mlst                  ON                  mlst.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('mob_rgi')               AS mob_rgi               ON               mob_rgi.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('kleborate')             AS kleborate             ON             kleborate.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('plasmid_finder')        AS plasmid_finder        ON        plasmid_finder.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('qc_fastp')              AS qc_fastp              ON              qc_fastp.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('qc_quast')              AS qc_quast              ON              qc_quast.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('phaster_blastp_hits')   AS phaster_blastp_hits   ON   phaster_blastp_hits.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('qc_raw_read_quality')   AS qc_raw_read_quality   ON   qc_raw_read_quality.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('resfinder')             AS resfinder             ON             resfinder.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('salmonella_serotyping') AS salmonella_serotyping ON salmonella_serotyping.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('virulence_vf')          AS virulence_vf          ON          virulence_vf.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('virulence_vfdb')        AS virulence_vfdb        ON        virulence_vfdb.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('qc_seqkit_stats')       AS qc_seqkit_stats       ON       qc_seqkit_stats.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('refseq_masher')         AS refseq_masher         ON         refseq_masher.sequence_id   = seq.id
LEFT JOIN get_tool_run_bool('bacmet')                AS bacmet                ON                bacmet.sequence_id   = seq.id;

CREATE OR REPLACE VIEW top_refseq_masher_taxon
AS
SELECT id, sequencing_id, top_taxonomy_name, taxonomic_species
  FROM ( SELECT *, RANK() OVER(PARTITION BY sequencing_id ORDER BY distance ASC, length(top_taxonomy_name) ASC) AS rn FROM bioinf.refseq_masher)
 WHERE rn = 1;

CREATE OR REPLACE VIEW percent_tools_run_per_species
AS
SELECT taxonomic_species                         AS species,
       ROUND(AVG(digis_elements::int),        2) AS digis_elements,
       ROUND(AVG(ecoli_serotyping::int),      2) AS ecoli_serotyping,
       ROUND(AVG(iceberg_blastn_genome::int), 2) AS iceberg_blastn_genome,
       ROUND(AVG(iceberg_blastp_genes::int),  2) AS iceberg_blastp_genes,
       ROUND(AVG(integron_finder::int),       2) AS integron_finder,
       ROUND(AVG(island_path::int),           2) AS island_path,
       ROUND(AVG(mlst::int),                  2) AS mlst,
       ROUND(AVG(mob_rgi::int),               2) AS mob_rgi,
       ROUND(AVG(kleborate::int),             2) AS kleborate,
       ROUND(AVG(plasmid_finder::int),        2) AS plasmid_finder,
       ROUND(AVG(qc_fastp::int),              2) AS qc_fastp,
       ROUND(AVG(qc_quast::int),              2) AS qc_quast,
       ROUND(AVG(phaster_blastp_hits::int),   2) AS phaster_blastp_hits,
       ROUND(AVG(qc_raw_read_quality::int),   2) AS qc_raw_read_quality,
       ROUND(AVG(resfinder::int),             2) AS resfinder,
       ROUND(AVG(salmonella_serotyping::int), 2) AS salmonella_serotyping,
       ROUND(AVG(virulence_vf::int),          2) AS virulence_vf,
       ROUND(AVG(virulence_vfdb::int),        2) AS virulence_vfdb,
       ROUND(AVG(qc_seqkit_stats::int),       2) AS qc_seqkit_stats,
       ROUND(AVG(refseq_masher::int),         2) AS refseq_masher,
       ROUND(AVG(bacmet::int),                2) AS bacmet
FROM bioinf_tools_run_per_seq AS x
LEFT JOIN top_refseq_masher_taxon AS top_taxon ON top_taxon.sequencing_id = x.sequencing_id
GROUP BY species;
