#!/bin/sh -e
echo "Download admin-ui code"
git clone https://github.com/cloudfoundry-incubator/admin-ui
cd admin-ui
##checkout cf-deployment level commit id
git reset  64028a614eb975f8b355dda157a6ba2ff4c27fa9

echo "Copy admin-ui generated config"
cp ${GENERATE_DIR}/default.yml config/

echo "Copy admin-ui directories"
cp -r . ${GENERATE_DIR}/..

echo "Create CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG
cf bind-security-group admin-ui $CF_ORG $CF_SPACE
cf target -s $CF_SPACE -o $CF_ORG