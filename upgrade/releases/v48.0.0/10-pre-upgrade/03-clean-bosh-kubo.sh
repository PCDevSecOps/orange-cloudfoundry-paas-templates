#!/bin/bash
set +e
CONFIG_REPO=$1

echo "bosh-kubo secrets cleanup..."
if [ -d ${CONFIG_REPO}/master-depls/bosh-kubo ] ; then
  rm -fr ${CONFIG_REPO}/master-depls/bosh-kubo
fi

echo "bosh-kubo credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-master/bosh-kubo/" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

set -e