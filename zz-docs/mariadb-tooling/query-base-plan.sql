SELECT DISTINCT db.db, si.`max_storage_mb`
FROM mysql.db AS db, 
      mysql_broker.service_instances si
WHERE db.db NOT IN ('information_schema', 'mysql')
   AND db.db = si.`db_name`
ORDER BY db;
