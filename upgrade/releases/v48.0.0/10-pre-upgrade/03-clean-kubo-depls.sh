#!/bin/bash
set +e
CONFIG_REPO=$1

echo "kubo-depls secrets cleanup..."
if [ -d ${CONFIG_REPO}/kubo-depls ] ; then
  rm -fr ${CONFIG_REPO}/kubo-depls
fi

echo "kubo-depls concourse secrets cleanup..."
find ${CONFIG_REPO}/coa -type d -name *kubo* -exec rm -fr {} \;
find ${CONFIG_REPO}/coa -name *kubo* -exec rm -f {} \;

echo "kubo-depls credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/kubo-depls/" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

set -e