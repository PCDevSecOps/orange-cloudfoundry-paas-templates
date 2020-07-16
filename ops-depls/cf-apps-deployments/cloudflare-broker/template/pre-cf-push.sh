#!/bin/sh

set -x

curl -L -o ${GENERATE_DIR}/cf-ops-automation-cloudflare-broker.jar https://github.com/orange-cloudfoundry/cf-ops-automation-broker/releases/download/0.25.0/cf-ops-automation-cloudflare-broker-0.25.0.jar

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

#enable gitlab https access
cf bind-security-group ops "$CF_ORG" "$CF_SPACE"
