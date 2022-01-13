SELECT mdb.db, FROM_UNIXTIME(UNIX_TIMESTAMP(MAX(t.update_time))) as last_update
FROM information_schema.tables t,
     mysql.db mdb
WHERE t.table_schema=mdb.db
  AND mdb.db NOT IN ('information_schema', 'mysql')
GROUP BY mdb.db, t.TABLE_SCHEMA;
