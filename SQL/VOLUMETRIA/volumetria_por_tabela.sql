-- script: volumetria por tabela
-- sgbd: PostgreSQL
-- data: 2018-11-11

select schema, count(*) from (SELECT
	n.nspname as "schema",
	c.relname as "table",
	pg_size_pretty(pg_relation_size(c.oid)) AS "size",
	pg_size_pretty(pg_total_relation_size(c.oid)) AS "total_size",
	tbs.spcname as "tablespace_name",
	-- tbs.spclocation	as "tablespace_location", 				-- VERSION < 9.0
	-- pg_tablespace_location(tbs.oid)	as "tablespace_location", 	-- VERSION >= 9.0
	pg_size_pretty(pg_tablespace_size(tbs.spcname)) as "tablespace_size"
FROM pg_class c
  INNER JOIN pg_namespace n ON (n.oid = c.relnamespace)
  LEFT JOIN pg_tablespace tbs on (c.reltablespace = tbs.oid)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
	AND n.nspname NOT LIKE 'pg%'
	and c.relkind IN ('r')
order by pg_relation_size(n.nspname||'.'||c.relname) desc)a group by 1
order by 1
