#!/bin/bash
#===========================================================================
# Display leaf certs for each ca cert in credhub
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Get all certs from credhub
clear
printf "\n%bCollect credhub certs (should take a while)...%b\n" "${REVERSE}${YELLOW}" "${STD}"
getCertsProperties

#--- Get CA certs and leaf certs names
CA_CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[]|select(.versions[].certificate_authority == true)|.name' | uniq | LC_ALL=C sort)"
for ca_cert_name in ${CA_CERT_NAMES} ; do
  certs_names="$(echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${ca_cert_name}" '.certificates[]|select(.name == $NAME)|.signs[]')"
  printf "\n%b\"${ca_cert_name}\" CA cert%b\n" "${REVERSE}${YELLOW}" "${STD}"
  if [ "${certs_names}" = "" ] ; then
    printf "%bNo certs signed with this CA cert%b\n" "${RED}" "${STD}"
  else
    printf "${certs_names}\n"
  fi
done

printf "\n"