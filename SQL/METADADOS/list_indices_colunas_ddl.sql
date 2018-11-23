SELECT 
	n.nspname as "SchemaName", 
	t.relname as "TableName",
	c.relname as "IndexName", 
	case when i.indisvalid is true then 'SIM' else 'NÃO' end as "Válido?", 
	case when i.indisready is true then 'SIM' else 'NÃO' end as "Pronto para uso?",
	replace(split_part(pg_get_indexdef(c.oid),'(',2),')','') as "Colunas",
	pg_get_indexdef(c.oid) as "DDL"
FROM pg_class c 
	inner join pg_index i on i.indexrelid = c.oid
	inner join pg_namespace n on c.relnamespace = n.oid
	inner join pg_class t ON i.indrelid=t.oid
WHERE  
	--(i.indisvalid = false OR i.indisready = false) AND /*TRAZER VÁLIDOS E/OU INVÁLIDOS?*/
	n.nspname != 'pg_catalog' AND
	n.nspname != 'information_schema' AND
	n.nspname != 'pg_toast' and 
	t.relname like '%n10%' /*NOME DA TABELA*/
