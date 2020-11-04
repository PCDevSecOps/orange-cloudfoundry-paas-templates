#!/bin/sh -e
echo "Download admin-ui code"
git clone https://github.com/cloudfoundry-incubator/admin-ui
cd admin-ui
##checkout cf-deployment level commit id
git reset  5f182bd221b7cf58ed29c0c88a16c68e774b6072

echo "Copy admin-ui generated config"
cp ${GENERATE_DIR}/default.yml config/

echo "Copy admin-ui directories"
cp -r . ${GENERATE_DIR}/..

echo "Create CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf bind-security-group admin-ui $CF_ORG $CF_SPACE
cf target -s $CF_SPACE -o $CF_ORG