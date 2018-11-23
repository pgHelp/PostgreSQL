SELECT d.datname,
        round((blks_hit::float/(blks_read+blks_hit+1)*100)::numeric, 2) as cachehitratio,
        FROM pg_stat_database sd
        JOIN pg_database d ON d.oid = sd.datid
        WHERE d.datallowconn AND NOT d.datistemplate
        AND (blks_read+blks_hit) > 0
        ORDER BY datname, cachehitratio;
