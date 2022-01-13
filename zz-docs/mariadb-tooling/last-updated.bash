#!/bin/bash
schema=$(ls -alq /var/vcap/store/mysql | grep cf | awk '{print $9}' | tr -d '/')
cat > /tmp/last-updated.sql <<EOF
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(MAX(UPDATE_TIME))) as last_update FROM information_schema.tables WHERE TABLE_SCHEMA='${schema}';
EOF
mysql --defaults-file=/var/vcap/jobs/mysql/config/mylogin.cnf ${schema} < /tmp/last-updated.sql > /tmp/last-updated.out