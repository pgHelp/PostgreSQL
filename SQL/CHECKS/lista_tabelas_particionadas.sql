select 
	parent.relname
from pg_class parent
	inner join pg_inherits inh on (inh.inhparent=parent.oid)
	inner join pg_class child on (inh.inhrelid=child.oid)
group by 1
order by 1;
