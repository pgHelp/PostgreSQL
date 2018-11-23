 CREATE OR REPLACE VIEW <seu_schema>.lock_tree AS 
 WITH RECURSIVE list_lock(nivel, i, pid_pai, pid, "user", ip, query_start, xact_start, connection_start, locktype, mode, "table", granted, query) AS (
         SELECT 1 AS nivel,
            'LOCKER'::text AS i,
            NULL::integer AS pid_pai,
            locker_locks.pid AS pid1,
            locker_activity.usename AS "user",
            locker_activity.client_addr AS ip,
            (to_char(locker_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.query_start), 'HH24:MI:SS'::text) AS query_start,
            (to_char(locker_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.xact_start), 'HH24:MI:SS'::text) AS xact_start,
            (to_char(locker_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.backend_start), 'HH24:MI:SS'::text) AS connection_start,
            locker_locks.locktype,
            string_agg(DISTINCT locker_locks.mode, ','::text) AS mode,
            locker_locks.relation::regclass AS "table",
            locker_locks.granted,
            locker_activity.query
           FROM pg_locks waiting_locks
             JOIN pg_stat_activity waiting_activity ON waiting_activity.pid = waiting_locks.pid
             JOIN pg_locks locker_locks ON waiting_locks.database = locker_locks.database AND waiting_locks.relation = locker_locks.relation OR waiting_locks.transactionid = locker_locks.transactionid
             JOIN pg_stat_activity locker_activity ON locker_activity.pid = locker_locks.pid
          WHERE waiting_locks.granted = false AND waiting_locks.pid <> locker_locks.pid AND waiting_locks.pid <> pg_backend_pid() AND locker_locks.pid <> pg_backend_pid() AND locker_locks.granted
          GROUP BY 1::integer, 'LOCKER'::text, NULL::integer, locker_locks.pid, locker_activity.usename, locker_activity.client_addr, (to_char(locker_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.query_start), 'HH24:MI:SS'::text), (to_char(locker_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.xact_start), 'HH24:MI:SS'::text), (to_char(locker_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.backend_start), 'HH24:MI:SS'::text), locker_locks.locktype, locker_locks.relation::regclass, locker_locks.granted, locker_activity.query
        UNION
         SELECT llock.nivel + 1,
            'WAITING'::text AS i,
            locker_locks.pid AS pid_pai,
            waiting_locks.pid,
            waiting_activity.usename AS "user",
            waiting_activity.client_addr AS ip,
            (to_char(waiting_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, clock_timestamp() - waiting_activity.query_start), 'HH24:MI:SS'::text) AS query_start,
            (to_char(waiting_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.xact_start), 'HH24:MI:SS'::text) AS xact_start,
            (to_char(waiting_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.backend_start), 'HH24:MI:SS'::text) AS connection_start,
            waiting_locks.locktype,
            waiting_locks.mode,
            waiting_locks.relation::regclass AS "table",
            waiting_locks.granted,
            waiting_activity.query
           FROM pg_locks waiting_locks
             JOIN pg_stat_activity waiting_activity ON waiting_activity.pid = waiting_locks.pid
             JOIN pg_locks locker_locks ON waiting_locks.database = locker_locks.database AND waiting_locks.relation = locker_locks.relation OR waiting_locks.transactionid = locker_locks.transactionid
             JOIN pg_stat_activity locker_activity ON locker_activity.pid = locker_locks.pid
             JOIN list_lock llock ON locker_locks.pid = llock.pid::bigint
          WHERE waiting_locks.granted = false AND waiting_locks.pid <> locker_locks.pid AND waiting_locks.pid <> pg_backend_pid() AND locker_locks.pid <> pg_backend_pid() AND locker_locks.granted
        )
 SELECT
        CASE
            WHEN a.i = 'LOCKER'::text THEN ('['::text || a.pid) || ']'::text
            WHEN a.i = 'WAITING'::text THEN (((('['::text || a.pid_pai) || '] '::text) || '['::text) || a.pid) || ']'::text
            ELSE NULL::text
        END AS sequence,
        CASE
            WHEN a.i = 'WAITING'::text THEN (('  '::text || lpad(''::text, a.nivel, '>'::text)) || ' '::text) || a.i
            ELSE (lpad(''::text, a.nivel, '>'::text) || ' '::text) || a.i
        END AS status,
        CASE
            WHEN a.i = 'LOCKER'::text THEN (('. /home/postgres/dba/gustavo/scripts/shell/raster_pid.sh '::text || a.pid) || ' '::text) || (( SELECT string_agg(sub_a.pid::character varying::text, ' '::text ORDER BY sub_a.pid) AS string_agg
               FROM list_lock sub_a
              WHERE sub_a.pid_pai = a.pid))
            ELSE '-'::text
        END AS "raster_pid.sh",
        CASE
            WHEN a.i = 'LOCKER'::text THEN ('select pg_terminate_backend('::text || a.pid) || ');'::text
            ELSE NULL::text
        END AS "pg_terminate_backend()",
    a.pid_pai AS parent_pid,
    a.pid,
    a."user",
    a.ip,
    a.query_start,
    a.xact_start,
    a.connection_start,
    a.locktype,
    a.mode,
    a."table",
    a.query
   FROM list_lock a
  ORDER BY
        CASE
            WHEN a.i = 'LOCKER'::text THEN ('['::text || a.pid) || ']'::text
            WHEN a.i = 'WAITING'::text THEN (((('['::text || a.pid_pai) || '] '::text) || '['::text) || a.pid) || ']'::text
            ELSE NULL::text
        END;
