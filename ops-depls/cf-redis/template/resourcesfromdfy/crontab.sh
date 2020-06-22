#!/usr/bin/env bash

METRICS_DIR="/var/vcap/store/custom_exporter/"
CUSTOM_EXPORTER_DIR="/var/vcap/jobs/custom_exporter/"
GENERATE_METRICS_SCRIPT=${CUSTOM_EXPORTER_DIR}/bin/generate-metrics.sh
CUSTOM_EXPORTER_SCRIPT="/var/vcap/packages/custom_exporter/custom_monitoring_scripts/redis_shared_cluster_metrics.sh"
CUSTOM_EXPORTER_CONFIG="/var/vcap/jobs/custom_exporter/conf/custom_exporter.yml"


echo "Installing generate-metrics script"
cat >${GENERATE_METRICS_SCRIPT}<<EOL
#!/usr/bin/env bash

METRICS_DIR="/var/vcap/store/custom_exporter"
CUSTOM_EXPORTER_SCRIPT="/var/vcap/packages/custom_exporter/custom_monitoring_scripts/redis_shared_cluster_metrics.sh"

mkdir -p \$METRICS_DIR

for action in list_instances count_connected_clients database_keys_count get_used_memory get_maxmemory get_evicted_keys instance_health get_no_ttl_keys;
do
    result=\$(\${CUSTOM_EXPORTER_SCRIPT} \${action})
    echo "\$result" > \${METRICS_DIR}/\${action}
done
EOL
chmod +x $GENERATE_METRICS_SCRIPT

echo "First run"
$GENERATE_METRICS_SCRIPT > /dev/null 2>&1

echo "Setting up cron"
crontab -l > ${METRICS_DIR}/tmp_cron
cat >>${METRICS_DIR}/tmp_cron<<EOL
*/5 * * * * $GENERATE_METRICS_SCRIPT
EOL
crontab ${METRICS_DIR}/tmp_cron

echo "Configuring custom exporter"
cat >${CUSTOM_EXPORTER_CONFIG}<<EOL
---
credentials:
- name: shell_root
  type: bash
  user: root

metrics:
- commands:
  - "cat ${METRICS_DIR}/list_instances"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_list_instances
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/count_connected_clients"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_count_connected_clients
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/database_keys_count"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_database_keys_count
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/get_used_memory"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_get_used_memory
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/get_maxmemory"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_get_maxmemory
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/get_evicted_keys"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_get_evicted_keys
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/instance_health"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_instance_health
  separator: " "
  value_type: UNTYPED
- commands:
  - "cat ${METRICS_DIR}/get_no_ttl_keys"
  credential: shell_root
  mapping:
  - redis_instance_id
  - redis_instance_port
  name: redis_get_no_ttl_keys
  separator: " "
  value_type: UNTYPED
EOL

echo "Restarting custom exporter"
monit restart custom_exporter