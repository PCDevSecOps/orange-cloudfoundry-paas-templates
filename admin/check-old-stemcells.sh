#!/bin/bash
#===========================================================================
# Check obsolete stemcells by deployments for all bosh directors
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

ACTIVE_STEMCELL="${STEMCELL_TYPE}-go_agent/${BOSH_STEMCELL_VERSION}"

#--- Collect bosh informations
printf "\n%bCheck old stemcells from bosh-directors...\n%b" "${REVERSE}${YELLOW}" "${STD}"
for bosh_director in ${BOSH_DIRECTORS} ; do
  logToBosh "${bosh_director}"
  if [ $? != 1 ] ; then
    printf "\n%b${bosh_director}\n%b" "${REVERSE}${YELLOW}" "${STD}"
    deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | sed -e "s+\"++g")
    for deployment in ${deployments} ; do
      stemcell="$(bosh -d ${deployment} vms --json | jq -r '.Tables[].Rows[].stemcell' | grep -v "${ACTIVE_STEMCELL}" | sort -r | uniq)"
      if [ "${stemcell}" != "" ] ; then
        printf "%b=> ${bosh_director}/${deployment} => ${stemcell}\n" "${STD}"
      fi
    done
  fi
done

printf "\n"