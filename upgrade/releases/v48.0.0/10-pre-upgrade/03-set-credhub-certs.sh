#!/bin/bash
#--- Set credhub/uaa certs from secrets files into credhub
set -e
CONFIG_REPO=$1

#--- Cert and key files
CREDHUB_CERTS_DIR="${CONFIG_REPO}/micro-depls/credhub-ha/secrets/certs"
export CREDHUB_CERTIFICATE="${CREDHUB_CERTS_DIR}/credub-certs/server.crt"
export CREDHUB_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/credub-certs/server.key"
export UAA_CERTIFICATE="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.crt"
export UAA_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.key"

#--- Generate cert in credhub
SetCredhubCert() {
  PATH_NAME="$1"
  CERT_FILE="$2"
  KEY_FILE="$3"
  echo "Set \"${PATH_NAME}\" cert in credhub..."

  #--- Check if credhub propertie exists
  flag_exist=$(credhub f | grep "name: ${PATH_NAME}")
  if [ "${flag_exist}" != "" ] ; then
    credhub delete -n ${PATH_NAME} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      echo "ERROR: \"${PATH_NAME}\" certificate deletion failed." ; exit 1
    fi
  fi

  #--- Set certificate in credhub
  credhub set -t certificate -n ${PATH_NAME} -c ${CERT_FILE} -p ${KEY_FILE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo "ERROR: \"${PATH_NAME}\" certificate creation failed." ; exit 1
  fi
}

#--- Insert certs in credhub (for automatic certs check)
SetCredhubCert "/micro-bosh/credhub-ha/credhub-certs" "${CREDHUB_CERTIFICATE}" "${CREDHUB_PRIVATE_KEY}"
SetCredhubCert "/micro-bosh/credhub-ha/uaa-certs" "${UAA_CERTIFICATE}" "${UAA_PRIVATE_KEY}"

set +e