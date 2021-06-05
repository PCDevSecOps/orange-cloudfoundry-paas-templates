#!/bin/sh -e
echo "Download admin-ui code..."
git clone https://github.com/cloudfoundry-incubator/admin-ui
cd admin-ui

#--- Checkout to admin-ui commit id (to use ruby 2.7.2)
echo "Checkout to ruby 2.7.2 commit id level..."
git reset --hard 17b2a8e0228d866937cf2938e5986cc2dfe6552a

echo "Copy admin-ui generated config..."
cp ${GENERATE_DIR}/default.yml config/

echo "Copy admin-ui directories..."
cp -r . ${GENERATE_DIR}/..

echo "Create CF pre-requisite..."
cf create-space $CF_SPACE -o $CF_ORG
cf bind-security-group admin-ui $CF_ORG --space $CF_SPACE
cf target -s $CF_SPACE -o $CF_ORG