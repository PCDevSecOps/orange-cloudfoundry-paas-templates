#!/bin/sh

#--- Parameters
HUAWEICLOUD_SERVICE_BROKER_VERSION="0.1.1"
SEC_GROUP_BROKER_FILTER_VERSION="2.2.0.RELEASE"

ROOT_DIR=$(pwd)
GENERATE_DIR=${GENERATE_DIR:-.}

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

printf "%bDownload code...%b\n" "${YELLOW}" "${STD}"
cd ${GENERATE_DIR}
git clone https://github.com/huaweicloud/huaweicloud-service-broker

printf "%Checkout on tag \"v${HUAWEICLOUD_SERVICE_BROKER_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
cd ${GENERATE_DIR}/huaweicloud-service-broker
git checkout v${HUAWEICLOUD_SERVICE_BROKER_VERSION}

printf "%bDownload sec group filter broker jar...%b\n" "${YELLOW}" "${STD}"
curl -L -s https://github.com/orange-cloudfoundry/sec-group-broker-filter/releases/download/v${SEC_GROUP_BROKER_FILTER_VERSION}/service-broker-filter-securitygroups-${SEC_GROUP_BROKER_FILTER_VERSION}.jar -o ${GENERATE_DIR}/service-broker-filter-securitygroups.jar

printf "%bConfigure sec group filter broker...%b\n" "${YELLOW}" "${STD}"
spruce json ${GENERATE_DIR}/config-json.yml > ${GENERATE_DIR}/huaweicloud-service-broker/config.json

cf create-space "${CF_SPACE}" -o "${CF_ORG}"
cf target -s "${CF_SPACE}" -o "${CF_ORG}"
cf bind-security-group wide-open ${CF_ORG} ${CF_SPACE}

cf s | grep "mysql-hws-service" > /dev/null
if [ $? = 0 ] ; then
  printf "%bFound existing service mysql-hws-service...%b\n" "${YELLOW}" "${STD}"
else
  printf "%bCreate mysql-hws-service instance...%b\n" "${YELLOW}" "${STD}"
  cf cs p-mysql 1gb mysql-hws-service
  if [ $? -ne 0 ] ; then
    exit 1
  fi
fi