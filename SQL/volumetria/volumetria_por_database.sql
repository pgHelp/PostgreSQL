-- script: volumetria por Database
-- sgbd: PostgreSQL
-- data: 2018-11-23
select 
  oid,datname, 
  pg_size_pretty(pg_database_size(oid))
from pg_database
