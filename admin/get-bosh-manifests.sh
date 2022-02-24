#!/bin/bash
#===========================================================================
# Get cloud/runtime config and deployment manifests for all bosh directors
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
BOSH_MANIFEST_DIR="${BOSH_DIR}/manifests"
rm -fr ${BOSH_MANIFEST_DIR} > /dev/null 2>&1
mkdir -p ${BOSH_MANIFEST_DIR} > /dev/null 2>&1
cd ${BOSH_MANIFEST_DIR}

#--- Collect bosh informations
clear
for bosh_director in ${BOSH_DIRECTORS} ; do
  logToBosh "${bosh_director}"
  if [ $? != 1 ] ; then
    printf "\n\n%bCollect cloud and runtime config manifests from bosh director \"%s\"...%b" "${REVERSE}${YELLOW}" "${bosh_director}" "${STD}"
    bosh cloud-config > ${bosh_director}-cloud-config.yml
    bosh runtime-config > ${bosh_director}-runtime-config.yml
    printf "\n\n%bCollect \"%s\" bosh director deployments manifests...%b" "${REVERSE}${YELLOW}" "${bosh_director}" "${STD}"
    deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+\"++g")
    for deployment in ${deployments} ; do
      result=$(bosh -d ${deployment} manifest > ${deployment}.yml)
      if [ $? != 0 ] ; then
        printf "\n%b- Collect \"${deployment}\" manifest failed%b" "${RED}" "${STD}"
      else
        printf "\n%b- Collect \"${deployment}\" manifest%b" "${STD}"
      fi
    done
  fi
done

printf "\n\n%bResult available in \"${BOSH_MANIFEST_DIR}\"%b\n\n" "${REVERSE}${GREEN}" "${STD}"