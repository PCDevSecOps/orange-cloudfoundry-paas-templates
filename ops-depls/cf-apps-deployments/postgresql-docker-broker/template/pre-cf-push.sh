#!/bin/sh
curl -L -s https://github.com/orange-cloudfoundry/postgresql-cf-service-broker/releases/download/3.0.3-SNAPSHOT/postgresql-cf-service-broker-3.0.3-SNAPSHOT.jar -o ${GENERATE_DIR}/postgresql-cf-service-broker-3.0.3-SNAPSHOT.jar

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

#enable gitlab https access
cf bind-security-group ops "$CF_ORG" --space "$CF_SPACE"
