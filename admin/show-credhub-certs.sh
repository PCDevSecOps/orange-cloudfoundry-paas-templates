#!/bin/bash
#===========================================================================
# Show credhub certs properties
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

if [ "$#" = 0 ] ; then
  printf "\n%bUsage:\n$0 <credhub certs paths list>\n\nEg:\n$0 /bosh-master/bosh-ops/nats_ca /bosh-master/bosh-ops/nats_server_tls%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Get all certs from credhub
clear
printf "\n%bCollect credhub certs (should take a while)...%b\n\n" "${REVERSE}${YELLOW}" "${STD}"
getCertsProperties
CERT_NAMES="$(echo "${CERTS_PROPERTIES}" | jq -r '.certificates[].name' | uniq | LC_ALL=C sort)"

for cert_name in "$@" ; do
  printf "%b${cert_name}%b\n" "${REVERSE}${YELLOW}" "${STD}"
  flag=$(echo "${CERT_NAMES}" | grep "${cert_name}")
  if [ "${flag}" = "" ] ; then
    printf "%b\"${cert_name}\" certificate unknown in credhub%b\n\n" "${RED}" "${STD}"
  else
    echo "${CERTS_PROPERTIES}" | jq -r --arg NAME "${cert_name}" '.certificates[]|select(.name == $NAME)'
  fi
done

printf "\n"