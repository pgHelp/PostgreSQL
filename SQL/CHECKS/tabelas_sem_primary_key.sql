select 
  table_schema,
	table_name
from information_schema.columns
where table_schema = 'SCHEMA_NAME'
group by 
  table_schema,
  table_name
having sum(if (column_key in ('PRI', 'UNI'), 1, 0)) = 0
