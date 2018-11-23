create view dba.monit_used_shared_buffers as 
select 
	trunc(sum(buffers)*8192/1024/1024/1024,2)||' GB' as used_shared_buffer,
	(select setting::bigint*8192/1024/1024/1024 from pg_settings where name = 'shared_buffers')||' GB' as total_shared_buffer,
	trunc((sum(buffers)*8192/1024/1024/1024)/(select setting::bigint*8192/1024/1024/1024 from pg_settings where name = 'shared_buffers')*100,2)||'%' as "utilization_ratio"
	
from 
(SELECT c.relname, count(*) AS buffers
             FROM pg_buffercache b INNER JOIN pg_class c
             ON b.relfilenode = pg_relation_filenode(c.oid) AND
                b.reldatabase IN (0, (SELECT oid FROM pg_database
                                      WHERE datname = current_database()))
             GROUP BY c.relname
             ORDER BY 2 DESC
             LIMIT 10)a;
