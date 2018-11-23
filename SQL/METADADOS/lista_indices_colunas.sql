select 
	n.nspname as schema,
	c.relname as table,
	i.relname as "index_name",
	i.oid as "index_oid",
	--string_agg(att.attname,',') as "columns",
	replace(split_part(pg_get_indexdef(i.oid),'(',2),')',''),
	pg_get_indexdef(i.oid) as "index_definition"
from pg_attribute att
	INNER JOIN pg_class c ON c.oid = att.attrelid 
	INNER JOIN pg_namespace n ON c.relnamespace = n.oid
	INNER JOIN pg_index AS ix ON att.attnum = ANY(ix.indkey) 
		and c.oid = att.attrelid 
		and c.oid = ix.indrelid 
	LEFT JOIN pg_class AS i ON i.oid = ix.indexrelid
--where 
	--n.nspname = ''		-- SCHEMA NAME
	--c.relname = '' 		-- TABLE NAME
	--and i.relname = '' 		-- INDEX NAME
	group by 1,2,3,4
	order by 1,2,3
