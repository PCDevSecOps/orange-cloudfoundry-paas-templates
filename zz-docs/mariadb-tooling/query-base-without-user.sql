SELECT s.schema_name,  0 AS nbuser
FROM information_schema.schemata s
      LEFT OUTER JOIN mysql.db AS db on db.db =  s.schema_name
WHERE s.schema_name LIKE ('cf%')
    AND db.USER IS NULL
UNION ALL    
SELECT s.schema_name,  COUNT(*) AS nbuser
FROM information_schema.schemata s
      LEFT OUTER JOIN mysql.db AS db on db.db =  s.schema_name
WHERE s.schema_name LIKE ('cf%')
    AND db.USER IS NOT NULL    
GROUP BY s.schema_name;

