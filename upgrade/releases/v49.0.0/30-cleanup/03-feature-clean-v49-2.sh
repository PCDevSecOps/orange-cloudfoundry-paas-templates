#!/bin/bash
#--- Disable automatic exit from bash shell script on error
set +e
CONFIG_REPO=$1

echo "micro-depls/bosh-master secrets cleanup..."
if [ -d ${CONFIG_REPO}/micro-depls/bosh-master/secrets ] ; then
  rm -fr ${CONFIG_REPO}/micro-depls/bosh-master/secrets
fi

echo "master-depls/bosh-coab secrets cleanup..."
if [ -d ${CONFIG_REPO}/master-depls/bosh-coab/secrets ] ; then
  rm -fr ${CONFIG_REPO}/master-depls/bosh-coab/secrets
fi

echo "master-depls/bosh-ops secrets cleanup..."
if [ -d ${CONFIG_REPO}/master-depls/bosh-ops/secrets ] ; then
  rm -fr ${CONFIG_REPO}/master-depls/bosh-ops/secrets
fi

#--- Enable automatic exit from bash shell script on error
set -e