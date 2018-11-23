select 
	io.schemaname,
	io.relname,
	round((heap_blks_hit::float/(heap_blks_read+heap_blks_hit+1)*100)::numeric, 2) as cachehitratio,
	round((idx_blks_hit::float/(idx_blks_read+idx_blks_hit+1)*100)::numeric, 2) as cache_hit_ratio_index
from pg_statio_user_tables io 
order by 3 desc


select 
	io.schemaname,
	io.relname,
	pg_size_pretty(pg_relation_size(io.schemaname||'.'||io.relname)),
	round((heap_blks_hit::float/(heap_blks_read+heap_blks_hit+1)*100)::numeric, 2) as cache_hit_ratio_table ,
	round((idx_blks_hit::float/(idx_blks_read+idx_blks_hit+1)*100)::numeric, 2) as cache_hit_ratio_index
from pg_statio_user_tables io 
	inner join pg_class c on io.relid = c.oid
	left join tbom_p92_prmt_part p92 on io.relname = p92.p92_vc_nom_tbl
where c.relpersistence = 'p'
order by pg_relation_size(io.schemaname||'.'||io.relname) desc
