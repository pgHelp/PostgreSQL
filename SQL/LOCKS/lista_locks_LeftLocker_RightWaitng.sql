SELECT waiting_locks.pid AS waiting_pid,
    waiting_activity.usename AS waiting_user,
    waiting_activity.client_addr AS waiting_ip,
    (to_char(waiting_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, clock_timestamp() - waiting_activity.query_start), 'HH24:MI:SS'::text) AS waiting_query_start,
    (to_char(waiting_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.xact_start), 'HH24:MI:SS'::text) AS waiting_xact_start,
    (to_char(waiting_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.backend_start), 'HH24:MI:SS'::text) AS waiting_connection_start,
    waiting_locks.locktype AS waiting_locktype,
    waiting_locks.mode AS waiting_mode,
    waiting_locks.relation::regclass AS waiting_table,
    waiting_locks.granted AS waiting_granted,
    waiting_activity.query AS waiting_query,
    locker_locks.pid AS locker_pid,
    locker_activity.usename AS locker_user,
    locker_activity.client_addr AS locker_ip,
    (to_char(locker_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.query_start), 'HH24:MI:SS'::text) AS locker_query_start,
    (to_char(locker_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.xact_start), 'HH24:MI:SS'::text) AS locker_xact_start,
    (to_char(locker_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.backend_start), 'HH24:MI:SS'::text) AS locker_connection_start,
    locker_locks.locktype AS locker_locktype,
    string_agg(locker_locks.mode, ','::text) AS locker_mode,
    locker_locks.relation::regclass AS locker_table,
    locker_locks.granted AS locker_granted,
    locker_activity.query AS locker_query
   FROM pg_locks waiting_locks
     JOIN pg_stat_activity waiting_activity ON waiting_activity.pid = waiting_locks.pid
     JOIN pg_locks locker_locks ON waiting_locks.database = locker_locks.database AND waiting_locks.relation = locker_locks.relation OR waiting_locks.transactionid = locker_locks.transactionid
     JOIN pg_stat_activity locker_activity ON locker_activity.pid = locker_locks.pid
  WHERE waiting_locks.granted = false AND waiting_locks.pid <> locker_locks.pid AND waiting_locks.pid <> pg_backend_pid() AND locker_locks.pid <> pg_backend_pid() AND locker_locks.granted
  GROUP BY waiting_locks.pid, waiting_activity.usename, waiting_activity.client_addr, (to_char(waiting_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, clock_timestamp() - waiting_activity.query_start), 'HH24:MI:SS'::text), (to_char(waiting_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.xact_start), 'HH24:MI:SS'::text), (to_char(waiting_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.backend_start), 'HH24:MI:SS'::text), waiting_locks.locktype, waiting_locks.mode, waiting_locks.relation::regclass, waiting_locks.granted, waiting_activity.query, locker_locks.pid, locker_activity.usename, locker_activity.client_addr, (to_char(locker_activity.query_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.query_start), 'HH24:MI:SS'::text), (to_char(locker_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.xact_start), 'HH24:MI:SS'::text), (to_char(locker_activity.backend_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.backend_start), 'HH24:MI:SS'::text), locker_locks.locktype, locker_locks.relation::regclass, locker_locks.granted, locker_activity.query
  ORDER BY locker_locks.granted, (to_char(waiting_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - waiting_activity.xact_start), 'HH24:MI:SS'::text), (to_char(locker_activity.xact_start, 'DD HH24:MI:SS'::text) || ' | '::text) || to_char(date_trunc('second'::text, now() - locker_activity.xact_start), 'HH24:MI:SS'::text);
