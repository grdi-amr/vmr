--fixing some bioinf.kleborate columns

ALTER TABLE bioinf.kleborate
RENAME COLUMN spurious_virulence_hits TO spurious_resistance_hits;

ALTER TABLE bioinf.kleborate
ADD COLUMN truncated_resistance_hits TEXT;
ALTER TABLE bioinf.kleborate
ADD COLUMN flq_mutations TEXT;
