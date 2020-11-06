#!/bin/sh


curl -L -s https://github.com/orange-cloudfoundry/static-creds-broker/releases/download/v2.2.0.RELEASE/static-creds-broker-2.2.0.RELEASE.jar -o ${GENERATE_DIR}/static-creds-broker.jar

SEC_GROUP_BROKER_FILTER_VERSION=2.5.0.RELEASE

curl -L -s https://github.com/orange-cloudfoundry/sec-group-broker-filter/releases/download/v${SEC_GROUP_BROKER_FILTER_VERSION}/service-broker-filter-securitygroups-${SEC_GROUP_BROKER_FILTER_VERSION}.jar -o ${GENERATE_DIR}/service-broker-filter-securitygroups.jar

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

#enable gitlab https access
cf bind-security-group ops "$CF_ORG" "$CF_SPACE"
 
