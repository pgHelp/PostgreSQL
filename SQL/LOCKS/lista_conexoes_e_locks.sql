CREATE OR REPLACE VIEW dba.connections_n_locks AS 
 SELECT '[connections]'::text AS label,
    '[state] = '::text || pg_stat_activity.state AS description,
    count(*) AS counter
   FROM pg_stat_activity
  GROUP BY pg_stat_activity.state
UNION
 SELECT '[connections]'::text AS label,
    '[total]'::text AS description,
    count(*) AS counter
   FROM pg_stat_activity
UNION
 SELECT '[locks]'::text AS label,
    NULL::text AS description,
    count(DISTINCT waiting_locks.pid) AS counter
   FROM pg_locks waiting_locks
     JOIN pg_stat_activity waiting_activity ON waiting_activity.pid = waiting_locks.pid
     JOIN pg_locks locker_locks ON waiting_locks.database = locker_locks.database AND (waiting_locks.relation = locker_locks.relation OR waiting_locks.transactionid = locker_locks.transactionid)
     JOIN pg_stat_activity locker_activity ON locker_activity.pid = locker_locks.pid
  WHERE waiting_locks.granted = false AND waiting_locks.pid <> locker_locks.pid AND waiting_locks.pid <> pg_backend_pid() AND locker_locks.pid <> pg_backend_pid() AND locker_locks.granted
  ORDER BY 1, 2;
