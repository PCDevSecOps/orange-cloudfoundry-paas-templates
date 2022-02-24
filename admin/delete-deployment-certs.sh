#!/bin/bash
#===========================================================================
# Delete bosh deployment keys and certs except deployments which use MTLS certs
# (bosh-coab, credhub-ha, dns-recursor and cf)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Select specific bosh deployment
selectBoshDirector
deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name' | grep -vE "^bosh-coab$|^cf$|^credhub-ha$|^dns-recursor$")
printf "\n%bSelect a deployment in the list:%b\n%s" "${REVERSE}${GREEN}" "${STD}" "${deployments}"
printf "\n\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read bosh_deployment
if [ "${bosh_deployment}" = "" ] ; then
  flag=1
else
  result=$(echo "${deployments}" | grep "${bosh_deployment}")
  if [ -n "${result}" ] ; then
    #--- Identify credhub credentials for the deployment
    logToCredhub
    printf "\n%bDelete \"${bosh_deployment}\" credhub certificates...%b\n" "${REVERSE}${YELLOW}" "${STD}"
    bosh_director=$(bosh env --json | jq -r '.Tables[].Rows[].name')
    credentials=$(credhub f | grep "name: /${bosh_director}/${bosh_deployment}/" | sed -e "s+.*name: ++g")
    for credential in ${credentials} ; do
      credential_type=$(credhub g -n ${credential} | grep "type: certificate")
      if [ "${credential_type}" != "" ] ; then
        printf "\n%b- Delete \"${credential}\" credhub cert" "${STD}"
        credhub d -n ${credential} > /dev/null 2>&1
        if [ $? != 0 ] ; then
          printf "\n%bERROR: credhub cert deletion failed.%b\n" "${RED}" "${STD}" ; exit 1
        fi
      fi
    done
  fi
fi

printf "\n\n"