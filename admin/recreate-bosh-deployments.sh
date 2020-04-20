#!/bin/bash
#===========================================================================
# Recreate all bosh deployments managed by a specific bosh director
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script properties
export BOSH_CLIENT="admin"
FLAG_ERROR=0

usage() {
  printf "\n%bUSAGE:\n$(basename -- $0) <bosh director (micro, master, ops, coab, kubo, remote-r2, remote-r3)>%b\n\n" "${RED}" "${STD}" ; exit 1
}

if [ "$#" != 1 ] ; then
  usage
fi

case "$1" in
  "micro")  DIRECTOR="micro-bosh" ; export BOSH_ENVIRONMENT="192.168.10.10" ; PASSWORD="/secrets/bosh_admin_password" ;;
  "master") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.116.158" ; PASSWORD="/micro-bosh/bosh-master/admin_password" ;;
  "ops") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.99.152" ; PASSWORD="/bosh-master/bosh-ops/admin_password" ;;
  "coab") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.99.155" ; PASSWORD="/bosh-master/bosh-coab/admin_password" ;;
  "kubo") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.99.154" ; PASSWORD="/bosh-master/bosh-kubo/admin_password" ;;
  "remote-r2") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.99.153" ; PASSWORD="/bosh-master/bosh-remote-r2/admin_password" ;;
  "remote-r3") DIRECTOR="bosh-$1" ; export BOSH_ENVIRONMENT="192.168.99.156" ; PASSWORD="/bosh-master/bosh-remote-r3/admin_password" ;;
  *) usage ;;
esac

#--- Collect active bosh deployments for selected root director
clear
printf "\n%bCollect bosh active deployment names (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
logToCredhub
CREDHUB_PROPERTIES="$(credhub f -j | jq -r '.credentials[].name')"
flag=$(echo "${CREDHUB_PROPERTIES}" | grep "${PASSWORD}")
if [ "${flag}" != "" ] ; then
  export BOSH_CLIENT_SECRET="$(credhub g -n ${PASSWORD} | grep 'value:' | awk '{print $2}')"
  bosh alias-env ${bosh_director} > /dev/null 2>&1
  bosh logout > /dev/null 2>&1
  bosh -n log-in > /dev/null 2>&1
  if [ $? = 1 ] ; then
    printf "\n%bERROR: Log to \"${bosh_director}\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  else
    ACTIVE_BOSH_DEPLOYMENTS=$(bosh deployments --json | jq -r '.Tables[].Rows[].name')
  fi
fi

#--- Delete obsolete credhub properties
printf "\n%bRecreate \"${DIRECTOR}\" deployments...%b\n" "${REVERSE}${YELLOW}" "${STD}"
for deployment in ${ACTIVE_BOSH_DEPLOYMENTS} ; do
  printf "\n- Recreate \"${deployment}\" deployment..."
  bosh -d ${deployment} -n recreate > /dev/null 2>&1
  if [ $? != 0 ] ; then
    printf "  %bfailed%b" "${RED}" "${STD}" ; FLAG_ERROR=1
  else
    printf "  %bdone%b" "${GREEN}" "${STD}"
  fi
done

printf "\n\n"
if [ ${FLAG_ERROR} = 1 ] ; then
  printf "\n%bERROR: Some \"${DIRECTOR}\" deployments failed to recreate%b\n\n" "${RED}" "${STD}" ; exit 1
fi