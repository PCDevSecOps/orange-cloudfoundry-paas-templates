#!/bin/sh
curl -L -s  https://github.com/orange-cloudfoundry/static-creds-broker/releases/download/v2.2.0.RELEASE/static-creds-broker-2.2.0.RELEASE.jar -o ${GENERATE_DIR}/static-creds-broker.jar

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

#enable gitlab https access
cf bind-security-group ops "$CF_ORG" "$CF_SPACE"
