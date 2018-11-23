select 
  oid,datname, 
  pg_size_pretty(pg_database_size(oid))
from pg_database
