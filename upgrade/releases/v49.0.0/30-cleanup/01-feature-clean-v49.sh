#!/bin/bash
#--- Disable automatic exit from bash shell script on error
set +e
CONFIG_REPO=$1

echo "coab-depls/bui secrets cleanup..."
if [ -d ${CONFIG_REPO}/coab-depls/bui ] ; then
  rm -fr ${CONFIG_REPO}/coab-depls/bui
fi

echo "ops-depls/cassandra secrets cleanup..."
if [ -d ${CONFIG_REPO}/ops-depls/cassandra ] ; then
  rm -fr ${CONFIG_REPO}/ops-depls/cassandra
fi

echo "coab-depls/cassandra secrets cleanup..."
if [ -d ${CONFIG_REPO}/coab-depls/cassandra ] ; then
  rm -fr ${CONFIG_REPO}/coab-depls/cassandra
fi

echo "coab-depls/cf-apps-deployments/coa-cassandra-broker secrets cleanup..."
if [ -d ${CONFIG_REPO}/coab-depls/cf-apps-deployments/coa-cassandra-broker ] ; then
  rm -fr ${CONFIG_REPO}/coab-depls/cf-apps-deployments/coa-cassandra-broker
fi

echo "coab-depls/bui credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-coab/bui" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

echo "ops-depls/cassandra credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-ops/cassandra" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

echo "coab-depls/cassandra credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-coab/cassandra" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

echo "coab-depls/cassandra credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-coab/cassandra" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

echo "coab-depls/c_* credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "/bosh-coab/c_" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

#--- Enable automatic exit from bash shell script on error
set -e