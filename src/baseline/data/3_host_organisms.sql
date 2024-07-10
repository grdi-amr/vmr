
COPY public.host_organisms (id, ontology_id, scientific_name, en_common_name, fr_common_name, en_description, fr_description, curated) FROM stdin;
1	NCBITaxon:8782	\N	Bird	\N	\N	\N	t
2	NCBITaxon:9031	Gallus gallus	Chicken	\N	\N	\N	t
3	FOODON:00004504	\N	Seabird	\N	\N	\N	t
4	NCBITaxon:9206	\N	Cormorant	\N	\N	\N	t
5	NCBITaxon:56069	Phalacrocorax auritus	Double Crested Cormorant	\N	\N	\N	t
6	NCBITaxon:9109	\N	Crane	\N	\N	\N	t
7	NCBITaxon:9117	Grus americana	Whooping Crane	\N	\N	\N	t
8	NCBITaxon:8911	\N	Gull (Seagull)	\N	\N	\N	t
9	NCBITaxon:119606	Larus glaucescens	Glaucous-winged Gull	\N	\N	\N	t
10	NCBITaxon:8912	Larus marinus	Great Black-backed Gull	\N	\N	\N	t
11	NCBITaxon:35669	Larus argentatus	Herring Gull	\N	\N	\N	t
12	NCBITaxon:126683	Larus delawarensis	Ring-billed Gull	\N	\N	\N	t
13	NCBITaxon:50366	\N	Eider	\N	\N	\N	t
14	NCBITaxon:76058	Somateria mollissima	Common Eider	\N	\N	\N	t
15	NCBITaxon:9103	Meleagris gallopavo	Turkey	\N	\N	\N	t
16	FOODON:03411222	\N	Fish	\N	\N	\N	t
17	NCBITaxon:8022	Oncorhynchus mykiss	Rainbow Trout	\N	\N	\N	t
18	NCBITaxon:229290	Anoplopoma fimbria	Sablefish	\N	\N	\N	t
19	FOODON:00003473	\N	Salmon	\N	\N	\N	t
20	NCBITaxon:8030	Salmo salar	Atlantic Salmon	\N	\N	\N	t
21	NCBITaxon:8019	Oncorhynchus kisutch	Coho Salmon	\N	\N	\N	t
22	NCBITaxon:74940	Oncorhynchus tshawytscha	Chinook salmon	\N	\N	\N	t
23	FOODON:03411134	\N	Mammal	\N	\N	\N	t
24	FOODON:03000300	\N	Companion animal	\N	\N	\N	t
25	NCBITaxon:9913	Bos taurus	Cow	\N	\N	\N	t
26	NCBITaxon:9606	Homo sapiens	Human	\N	\N	\N	t
27	NCBITaxon:9823	\N	Pig	\N	\N	\N	t
28	NCBITaxon:9940	Ovis aries	Sheep	\N	\N	\N	t
29	FOODON:03411433	\N	Shellfish	\N	\N	\N	t
30	NCBITaxon:6706	Homarus americanus	Atlantic Lobster	\N	\N	\N	t
31	NCBITaxon:6565	Crassostrea virginica	Atlantic Oyster	\N	\N	\N	t
32	NCBITaxon:6550	Mytilus edulis	Blue Mussel	\N	\N	\N	t
33	GENEPIO:0001619	Not Applicable	Not Applicable	\N	\N	\N	t
34	GENEPIO:0001620	Not Collected	Not Collected	\N	\N	\N	t
35	GENEPIO:0001668	Not Provided	Not Provided	\N	\N	\N	t
36	GENEPIO:0001618	Missing	Missing	\N	\N	\N	t
37	GENEPIO:0001810	Restricted Access	Restricted Access	\N	\N	\N	t
38	NCBITaxon:9825	Sus scrofa domesticus	\N	\N	\N	\N	t
\.

SELECT pg_catalog.setval('public.host_organisms_id_seq', 38, true);

