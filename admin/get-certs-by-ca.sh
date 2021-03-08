#!/bin/bash
#===========================================================================
# Display leaf certs for each ca cert in credhub
# It doesn't display coab instances, so you can refer to caob template to check dependencies
# (eg.: /coab-depls/cf-mysql)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Get all certs from credhub
clear
printf "\n%bCollect credhub certs (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
executeCredhubCurl "GET" "certificates"
CA_CERT_NAMES="$(echo "${CREDHUB_API_RESULT}" | jq -r '.certificates[]|select(.versions[].certificate_authority == true)|.name' | LC_ALL=C sort | uniq)"
CA_CERT_NAMES="$(echo "${CA_CERT_NAMES}" | grep -v "/bosh-coab/._")"

#--- Get CA certs and leaf certs names
for ca_cert_name in ${CA_CERT_NAMES} ; do
  certs_names="$(echo "${CREDHUB_API_RESULT}" | jq -r --arg NAME "${ca_cert_name}" '.certificates[]|select(.name == $NAME)|.signs[]' | LC_ALL=C sort)"
  printf "\n%b\"${ca_cert_name}\" CA cert%b\n" "${REVERSE}${YELLOW}" "${STD}"
  if [ "${certs_names}" = "" ] ; then
    printf "%bNo certs signed with this CA cert%b\n" "${RED}" "${STD}"
  else
    if [ "${ca_cert_name}" = "/internalCA" ] ; then
      associated_deployments="$(echo "${certs_names}" | awk -F "/" '{print "/" $2 "/" $3}' | LC_ALL=C sort | uniq)"
      printf "%bDeployments which use CA cert:%b\n${associated_deployments}\n%bLeaf certs:%b\n${certs_names}\n" "${BOLD}${YELLOW}" "${STD}" "${BOLD}${YELLOW}" "${STD}"
    else
      printf "${certs_names}\n"
    fi
  fi
done

printf "\n"