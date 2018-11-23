-- LISTA OBJETOS VINCULADOS À TABLESPACE "DEFAULT"
select 
	c.oid,
	nsp.nspname,
	c.relname,
	case
		when c.relkind = 'r' then 'TABELA'
		when c.relkind = 'i' then 'INDEX'
		when c.relkind = 'S' then 'SEQUENCE'
		when c.relkind = 'v' then 'VIEW'
		when c.relkind = 'm' then 'MAT_VIEW'
		when c.relkind = 'c' then 'Composite_Type'
		when c.relkind = 't' then 'Toast'
		when c.relkind = 'f' then 'Foreign_Table'
	end as relkind,
	pg_size_pretty(pg_relation_size(c.oid))
from pg_class c
inner join pg_namespace nsp on c.relnamespace = nsp.oid
where c.reltablespace = 0
	and nsp.nspname not in ('information_schema','pg_catalog','pg_toast')
	and c.relkind not in ('s','v','c')
order by relkind, pg_relation_size(c.oid) desc;
