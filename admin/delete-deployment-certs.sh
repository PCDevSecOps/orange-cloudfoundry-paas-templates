#!/bin/bash
#===========================================================================
# Delete bosh deployment keys and certs (not used for "bosh-" directors)
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Select specific bosh deployment
bosh env > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n\n%bERROR : You are not connected to bosh director.%b\n\n" "${RED}" "${STD}" ; exit
else
  deployments=$(bosh deployments --json | jq '.Tables[].Rows[].name' | grep -v "\"bosh-" | sed -e "s+\"++g")
  printf "\n\n%bSelect a deployment in the list:%b\n%s" "${REVERSE}${YELLOW}" "${STD}" "${deployments}"
  printf "\n\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read bosh_deployment
  if [ "${bosh_deployment}" = "" ] ; then
    flag=1
  else
    result=$(echo "${deployments}" | grep "${bosh_deployment}")
    if [ -n "${result}" ] ; then
      #--- Log to credhub
      credhub f > /dev/null 2>&1
      if [ $? != 0 ] ; then
        printf "%bEnter CF LDAP user and password :%b\n" "${REVERSE}${YELLOW}" "${STD}"
        credhub api --server=${CREDHUB_API} > /dev/null 2>&1
        credhub login
        if [ $? != 0 ] ; then
          printf "\n%bERROR : Bad LDAP authentication.%b\n\n" "${RED}" "${STD}" ; exit
        fi
      fi

      #--- Identify credhub credentials for the deployment
      printf "\n%bDelete \"${bosh_deployment}\" credhub certificates...%b\n" "${REVERSE}${YELLOW}" "${STD}"
      bosh_director=$(bosh env --json | jq -r '.Tables[].Rows[].name')
      credentials=$(credhub f | grep "name: /${bosh_director}/${bosh_deployment}/" | sed -e "s+.*name: ++g")
      for credential in ${credentials} ; do
        credential_type=$(credhub g -n ${credential} | grep "type: certificate")
        if [ "${credential_type}" != "" ] ; then
          printf "\n%b- Delete \"${credential}\" credhub cert%b" "${YELLOW}" "${STD}"
          credhub d -n ${credential} > /dev/null 2>&1
          if [ $? != 0 ] ; then
            printf "\n%bERROR: credhub cert deletion failed.%b\n" "${RED}" "${STD}" ; exit
          fi
        fi
      done
    fi
  fi
fi

printf "\n\n"