
COPY public.state_province_regions (id, ontology_id, country_id, en_term, fr_term, en_description, fr_description, curated) FROM stdin;
1	GAZ:00002562	74	British Columbia	\N	\N	\N	t
2	GAZ:00002563	74	Ontario	\N	\N	\N	t
3	GAZ:00002564	74	Saskatchewan	\N	\N	\N	t
4	GAZ:00002565	74	Nova Scotia	\N	\N	\N	t
5	GAZ:00002566	74	Alberta	\N	\N	\N	t
6	GAZ:00002567	74	Newfoundland & Labrador	\N	\N	\N	t
7	GAZ:00002569	74	Quebec	\N	\N	\N	t
8	GAZ:00002570	74	New Brunswick	\N	\N	\N	t
9	GAZ:00002571	74	Manitoba	\N	\N	\N	t
10	GAZ:00002572	74	Prince Edward Island	\N	\N	\N	t
11	GAZ:00002574	74	Nunuvut	\N	\N	\N	t
12	GAZ:00002575	74	Northwest Territories	\N	\N	\N	t
13	GAZ:00002576	74	Yukon	\N	\N	\N	t
14	wikidata:Q1048064	74	Central region (Canada)	\N	\N	\N	t
15	wikidata:Q122953299	74	Pacific region (Canada)	\N	\N	\N	t
16	wikidata:Q1364746	74	Prairie region (Canada)	\N	\N	\N	t
17	wikidata:Q246972	74	Atlantic region (Canada)	\N	\N	\N	t
18	wikidata:Q764146	74	Northern region (Canada)	\N	\N	\N	t
\.

SELECT pg_catalog.setval('public.state_province_regions_id_seq', 18, true);

