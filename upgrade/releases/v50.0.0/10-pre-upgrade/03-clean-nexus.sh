#!/bin/bash
set +e
CONFIG_REPO=$1

echo "nexus secrets cleanup..."
if [ -d ${CONFIG_REPO}/micro-depls/nexus ] ; then
  rm -fr ${CONFIG_REPO}/micro-depls/nexus
fi

echo "nexus credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/micro-bosh/nexus" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

set -e