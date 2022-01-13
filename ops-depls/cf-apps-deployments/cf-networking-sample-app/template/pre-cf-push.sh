#!/bin/bash

set -e

echo "preparing cf-networking sample apps"
echo "git clone https://github.com/cloudfoundry/cf-networking-examples ${GENERATE_DIR}/cf-networking-examples"
git clone https://github.com/cloudfoundry/cf-networking-examples ${GENERATE_DIR}/cf-networking-examples

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf target -o $CF_ORG -s $CF_SPACE

#enable tcp/udp from front to back
echo "Getting deployed apps"
deployed_apps=$(cf apps|grep -E "^cf-"|cut -d' ' -f1)
echo "$deployed_apps"
deployed_apps_count=$(echo $deployed_apps|wc -w)

if [ $deployed_apps_count -ge 2 ]; then
  cf add-network-policy cf-networking-sample-frontend cf-networking-sample-backend-a --port 7007 --protocol tcp
  cf add-network-policy cf-networking-sample-frontend cf-networking-sample-backend-a --port 9003 --protocol udp
fi

