#!/bin/sh

git clone https://github.com/mattmcneeney/overview-broker.git ${GENERATE_DIR}/overview-broker

echo "creating CF pre-requisite"
cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

