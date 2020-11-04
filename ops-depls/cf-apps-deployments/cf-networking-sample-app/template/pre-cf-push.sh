#!/bin/bash

set -x

echo "preparing cf-networking sample apps"

git clone https://github.com/cloudfoundry/cf-networking-examples ${GENERATE_DIR}/cf-networking-examples

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf target -o $CF_ORG -s $CF_SPACE

#enable tcp/udp from front to back
set +e #usefull for first deploy (cf apps not yet ready in pre push)
cf add-network-policy cf-networking-sample-frontend --destination-app cf-networking-sample-backend-a --port 7007 --protocol tcp
cf add-network-policy cf-networking-sample-frontend --destination-app cf-networking-sample-backend-a --port 9003 --protocol udp
exit 0
