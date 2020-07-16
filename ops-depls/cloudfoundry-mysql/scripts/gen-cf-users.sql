-- Launch this script with "mysql --silent -p < gen-cf-users.sql > cf-users.sql"

use mysql;
SELECT
  CONCAT("GRANT USAGE ON *.* TO '", user,"'@'%' IDENTIFIED BY PASSWORD '", password, "' WITH MAX_USER_CONNECTIONS 40;")
FROM
  user
WHERE
  user NOT IN ('root','quota-enforcer','cf-mysql-broker','cluster-health-logger','galera-healthcheck','roadmin');

SELECT
  CONCAT("GRANT ALL PRIVILEGES ON `", db.db,"`.* TO '", user.user, "'@'%';")
FROM
  user,db
WHERE
  user.user NOT IN ('root','quota-enforcer','cf-mysql-broker','cluster-health-logger','galera-healthcheck','roadmin') AND
  user.user = db.user AND
  user.host = db.host;

