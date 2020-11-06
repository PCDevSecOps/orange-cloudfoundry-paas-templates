#!/bin/bash
#--- Disable automatic exit from bash shell script on error
set +e
CONFIG_REPO=$1

clean_secrets() {
  if [ -d ${CONFIG_REPO}/${ROOT_DEPLOYMENT}/${DEPLOYMENT} ] ; then
    echo "${DEPLOYMENT} secrets cleanup..."
    rm -fr ${CONFIG_REPO}/${ROOT_DEPLOYMENT}/${DEPLOYMENT}
  fi
}

clean_credhub_properties() {
  properties_to_clean="$(credhub f | grep "/${DIRECTOR}/${DEPLOYMENT}/" | awk '{print $3}')"
  if [ "${properties_to_clean}" != "" ] ; then
    echo "${DEPLOYMENT} credhub properties cleanup..."
    for propertie in ${properties_to_clean} ; do
      echo "- delete propertie \"${propertie}\"..."
      credhub delete -n ${propertie}
    done
  fi
}

#--- Cleanup deployments properties
DEPLOYMENT="vpn-interco"
DIRECTOR="bosh-master"
ROOT_DEPLOYMENT="master-depls"
clean_secrets
clean_credhub_properties

#--- Enable automatic exit from bash shell script on error
set -e