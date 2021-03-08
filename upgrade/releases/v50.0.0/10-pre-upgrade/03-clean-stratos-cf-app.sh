#!/bin/bash
set +e
CONFIG_REPO=$1

echo "stratos cf-app secrets cleanup..."
if [ -d ${CONFIG_REPO}/ops-depls/cf-apps-deployments/stratos-ui-v2 ] ; then
  rm -fr ${CONFIG_REPO}/ops-depls/cf-apps-deployments/stratos-ui-v2
fi

set -e