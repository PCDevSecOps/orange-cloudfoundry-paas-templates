#!/bin/sh

echo "Params: $*"
CONFIG_DIR="$1"

COAB_DEPLS_DIR="${CONFIG_DIR}/coab-depls"

if [ ! -d "${COAB_DEPLS_DIR}" ];then
    echo "COAB is not active, skipping"
    exit 0
fi

COAB_BROKERS_DIR="${COAB_DEPLS_DIR}/cf-apps-deployments"
cd ${COAB_BROKERS_DIR}
ENABLED_BROKERS=$(find . -name "enable-cf-app.yml")
for BROKER_FILE in ${ENABLED_BROKERS};do
  ORG=$(grep cf_org ${BROKER_FILE}|cut -d':' -f2|tr -d [:blank:])
  SPACE=$(grep cf_space ${BROKER_FILE}|cut -d':' -f2|tr -d [:blank:])
  cf target -o "$ORG" -s "$SPACE"
  cf start ${SPACE}
done

