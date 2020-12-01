#!/bin/bash
set +e
CONFIG_REPO=$1

echo "cfcr secrets cleanup..."
if [ -d ${CONFIG_REPO}/micro-depls/cfcr ] ; then
  rm -fr ${CONFIG_REPO}/micro-depls/cfcr
fi

if [ -d ${CONFIG_REPO}/master-depls/cfcr ] ; then
  rm -fr ${CONFIG_REPO}/master-depls/cfcr
fi

if [ -d ${CONFIG_REPO}/coab-depls/10-cfcr ] ; then
  rm -fr ${CONFIG_REPO}/coab-depls/10-cfcr
fi

echo "cfcr credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/micro-bosh/cfcr" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

properties_to_clean="$(credhub f | grep "/bosh-master/cfcr" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

properties_to_clean="$(credhub f | grep "/bosh-coab/10-cfcr" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
done
fi

set -e