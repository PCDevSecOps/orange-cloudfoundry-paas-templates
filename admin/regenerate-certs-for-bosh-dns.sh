#!/bin/bash
#===========================================================================
# Generate bosh dns certs with credhub and export them to files
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
DNS_CERT_DIR="${HOME}/bosh/secrets/shared/certs/bosh-dns"

#--- Generate cert in credhub
generateCredhubCert() {
  PATH_NAME="$2"
  COMMON_NAME="$3"
  FILE_NAME=$(echo "${PATH_NAME}" | sed -e "s+/++")
  printf "%b- Generate \"${PATH_NAME}\" cert...%b\n" "${YELLOW}" "${STD}"

  #--- Check if credhub propertie exists
  flag_exist=$(credhub f | grep "name: ${PATH_NAME}")
  if [ "${flag_exist}" != "" ] ; then
    credhub delete -n ${PATH_NAME} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: \"${PATH_NAME}\" certificate deletion failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi

  #--- Generate credhub certificate
  if [ "$1" = "CA" ] ; then
    credhub generate -t certificate -n ${PATH_NAME} -c ${COMMON_NAME} --is-ca --self-sign > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: \"${PATH_NAME}\" certificate creation failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  else
    credhub generate -t certificate -n ${PATH_NAME} -c ${COMMON_NAME} -a *.${COMMON_NAME} --ca=$4 -e $5 > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: \"${PATH_NAME}\" certificate creation failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi

  #--- Save key and cert in cert secrets directory
  credhub g -n ${PATH_NAME} -k private_key > ${DNS_CERT_DIR}/${FILE_NAME}.key
  if [ $? != 0 ] ; then
    printf "\n%bERROR: \"${PATH_NAME}\" private key extraction failed.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  credhub g -n ${PATH_NAME} -k certificate > ${DNS_CERT_DIR}/${FILE_NAME}.crt
  if [ $? != 0 ] ; then
    printf "\n%bERROR: \"${PATH_NAME}\" certificate extraction failed.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  openssl x509 -noout -in ${DNS_CERT_DIR}/${FILE_NAME}.crt -subject -issuer -dates
}

#--- Generate keys and certs
logToCredhub
printf "\n%bGenerate keys and certs in credhub...%b\n" "${REVERSE}${YELLOW}" "${STD}"
if [ ! -d ${DNS_CERT_DIR} ] ; then
  mkdir -p ${DNS_CERT_DIR}
fi

generateCredhubCert "CA" "/dns_api_tls_ca" "dns-api-tls-ca"
generateCredhubCert "CERT" "/dns_api_server_tls" "api.bosh-dns" "/dns_api_tls_ca" "server_auth"
generateCredhubCert "CERT" "/dns_api_client_tls" "api.bosh-dns" "/dns_api_tls_ca" "client_auth"

generateCredhubCert "CA" "/dns_healthcheck_tls_ca" "dns-healthcheck-tls-ca"
generateCredhubCert "CERT" "/dns_healthcheck_server_tls" "health.bosh-dns" "/dns_healthcheck_tls_ca" "server_auth"
generateCredhubCert "CERT" "/dns_healthcheck_client_tls" "health.bosh-dns" "/dns_healthcheck_tls_ca" "client_auth"

#--- Push updates on secrets repository
display "INFO" "Commit \"bosh-dns certs\" into secrets repository"
commitGit "secrets" "update_bosh-dns_certs"

printf "\n%bbosh-dns certs generation done.%b\n\n" "${REVERSE}${GREEN}" "${STD}"