#!/bin/sh -e
echo "Download admin-ui code..."
git clone https://github.com/cloudfoundry-incubator/admin-ui
cd admin-ui

#--- Checkout to admin-ui commit id (to use Gemfile with reference to ruby 7.2.1)
#echo "Checkout to ruby 2.7.1 commit id level..."
#git reset --hard 0146fef0bb27d88e1d4d87700d9208a74a420e7c

echo "Copy admin-ui generated config..."
cp ${GENERATE_DIR}/default.yml config/

echo "Copy admin-ui directories..."
cp -r . ${GENERATE_DIR}/..

echo "Create CF pre-requisite..."
cf create-space $CF_SPACE -o $CF_ORG
cf bind-security-group admin-ui $CF_ORG $CF_SPACE
cf target -s $CF_SPACE -o $CF_ORG