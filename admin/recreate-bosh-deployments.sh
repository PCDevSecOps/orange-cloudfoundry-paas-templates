#!/bin/bash
#===========================================================================
# Recreate all bosh deployments managed by a specific bosh director 
# except "docker-bosh-cli" which is used to run the script, and
# "cfcr" which can't be currently recreated 
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script properties
export BOSH_CLIENT="admin"
FLAG_ERROR=0 ; DIRECTORS=""

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--all, -a" "Recreate deployments on each bosh-directors"
  printf "\n  %-40s %s" "--directors, -d \"bosh-directors\"" "Bosh-directors \"space separated\" (${BOSH_DIRECTORS})"
  printf "%b\n\n" "${STD}"
  exit 1
}

#--- Check options
if [ "$#" = 0 ] ; then
  usage
fi

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-a"|"--all")
      DIRECTORS="${BOSH_DIRECTORS}" ; shift ;;

    "-d"|"--directors")
        DIRECTORS="$2"
        for director in ${DIRECTORS} ; do
          flag="$(echo " ${BOSH_DIRECTORS} " | grep " ${director} ")"
          if [ "${flag}" = "" ] ; then
            usage
          fi
        done
        shift ; shift ;;
    *) usage ;;
  esac
done

#--- Confirm recreation
printf "\n%bRecreate \"${DIRECTORS}\" deployments (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit
fi

#--- Receate deployments in each bosh directors
clear
for director in ${DIRECTORS} ; do
  case "${director}" in
    "micro")  DIRECTOR="micro-bosh" ; export BOSH_ENVIRONMENT="192.168.10.10" ; PASSWORD="/secrets/bosh_admin_password" ;;
    "master") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.116.158" ; PASSWORD="/micro-bosh/bosh-master/admin_password" ;;
    "ops") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.99.152" ; PASSWORD="/bosh-master/bosh-ops/admin_password" ;;
    "coab") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.99.155" ; PASSWORD="/bosh-master/bosh-coab/admin_password" ;;
    "kubo") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.99.154" ; PASSWORD="/bosh-master/bosh-kubo/admin_password" ;;
    "remote-r2") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.99.153" ; PASSWORD="/bosh-master/bosh-remote-r2/admin_password" ;;
    "remote-r3") DIRECTOR="bosh-${director}" ; export BOSH_ENVIRONMENT="192.168.99.156" ; PASSWORD="/bosh-master/bosh-remote-r3/admin_password" ;;
    *) usage ;;
  esac

  #--- Collect active bosh deployments for selected root director
  printf "\n\n%bRecreate \"${DIRECTOR}\" deployments...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  logToCredhub
  CREDHUB_PROPERTIES="$(credhub f -j | jq -r '.credentials[].name')"
  flag=$(echo "${CREDHUB_PROPERTIES}" | grep "${PASSWORD}")
  if [ "${flag}" != "" ] ; then
    export BOSH_CLIENT_SECRET="$(credhub g -n ${PASSWORD} | grep 'value:' | awk '{print $2}')"
    bosh alias-env ${DIRECTOR} > /dev/null 2>&1
    bosh logout > /dev/null 2>&1
    bosh -n log-in > /dev/null 2>&1
    if [ $? = 1 ] ; then
      printf "\n%bERROR: Log to \"${DIRECTOR}\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
    else
      ACTIVE_BOSH_DEPLOYMENTS=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | grep -vE "docker-bosh-cli|cfcr$")
    fi
  fi

  #--- Recreate bosh deployment
  for deployment in ${ACTIVE_BOSH_DEPLOYMENTS} ; do
    printf "\n- Recreate \"${deployment}\" deployment..."
    bosh -d ${deployment} -n recreate --max-in-flight=1 > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf " %bfailed%b" "${RED}" "${STD}" ; FLAG_ERROR=1
    else
      printf " %bdone%b" "${GREEN}" "${STD}"
    fi
  done
done

if [ ${FLAG_ERROR} = 0 ] ; then
  printf "\n\n%bDeployments have been recreated successfully%b\n\n" "${GREEN}" "${STD}"
else
  printf "\n\n%bERROR: Some deployments failed to recreate.%b\n\n" "${RED}" "${STD}" ; exit 1
fi