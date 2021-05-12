#!/bin/sh
echo "creating php info application"
cat << EOF > ${GENERATE_DIR}/index.php
<?php
  phpinfo();
?>
EOF


echo "downloading blackbox-exporter binary"
BLACKBOX_EXPORTER_VERSION=0.12.0
curl -L -s https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_EXPORTER_VERSION}/blackbox_exporter-${BLACKBOX_EXPORTER_VERSION}.linux-amd64.tar.gz -o ${GENERATE_DIR}/blackbox_exporter.tgz
tar xzvf ${GENERATE_DIR}/blackbox_exporter.tgz -C ${GENERATE_DIR}/
mv ${GENERATE_DIR}/blackbox_exporter-${BLACKBOX_EXPORTER_VERSION}* ${GENERATE_DIR}/blackbox_exporter

echo "set specific blackbox.yml configuration file"
mv ${GENERATE_DIR}/blackbox-proxy.yml ${GENERATE_DIR}/blackbox_exporter


echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf target -o $CF_ORG  -s $CF_SPACE
cf create-service o-internet-ha-access default o-internet-ha-access-service

