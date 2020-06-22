#!/bin/bash
#===========================================================================
# Migrate bosh dns certs and key to cert files for credhub seeding
#===========================================================================

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Create file certificate and key
setCertificate() {
  credhub g -n /$1 -j | jq .value.certificate -r > ${BOSH_DNS_CERTS}/$1.crt
  credhub g -n /$1 -j | jq .value.private_key -r > ${BOSH_DNS_CERTS}/$1.key
}

#--- Check prerequisites
if [ -z "${SECRETS_REPOSITORY}" ] ; then
  printf "\n%bERROR : \"SECRETS_REPOSITORY\" is not set.\nIt should contain secrets clone path.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Log to credhub
flag=$(credhub f > /dev/null 2>&1)
if [ $? != 0 ] ; then
  printf "%bEnter CF LDAP user and password :%b\n" "${REVERSE}${YELLOW}" "${STD}"
  credhub api --server=https://credhub.internal.paas:8844 > /dev/null 2>&1
  credhub login
  if [ $? != 0 ] ; then
    printf "\n%bERROR : Bad LDAP authentication.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi
fi

BOSH_DNS_CERTS="${SECRETS_REPOSITORY}/shared/certs/bosh-dns"
if [ ! -d ${BOSH_DNS_CERTS} ] ; then
  mkdir -p ${BOSH_DNS_CERTS}
fi

setCertificate "dns_healthcheck_client_tls"
setCertificate "dns_healthcheck_server_tls"
setCertificate "dns_healthcheck_tls_ca"
setCertificate "dns_api_client_tls"
setCertificate "dns_api_server_tls"
setCertificate "dns_api_tls_ca"