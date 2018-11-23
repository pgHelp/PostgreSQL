select
	pg_get_functiondef(oid)||';' as "create function",
	pg_get_function_arguments(oid) as "arguments",
	pg_get_function_identity_arguments(oid),
	pg_get_function_result(oid)
from pg_proc 
order by proname;
