#!/bin/bash
#=========================================================================
# Create credhub, uaa key and cert files depending from internalCA
# and jwt ssh public and private key
#=========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script environment
TEMPLATE_BOOTSTRAP_DIR="${TEMPLATE_REPO_DIR}/micro-depls/credhub-ha/bootstrap"
CREDHUB_CERTS_DIR="${SECRETS_REPO_DIR}/micro-depls/credhub-ha/secrets/certs"

#--- Cert and key files
export CREDHUB_CA="${CREDHUB_CERTS_DIR}/credub-certs/server-ca.crt"
export CREDHUB_CERTIFICATE="${CREDHUB_CERTS_DIR}/credub-certs/server.crt"
export CREDHUB_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/credub-certs/server.key"
export UAA_CA="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server-ca.crt"
export UAA_CERTIFICATE="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.crt"
export UAA_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.key"
export UAA_SIGNING_KEY="${CREDHUB_CERTS_DIR}/uaa"
export UAA_VERIFICATION_KEY="${CREDHUB_CERTS_DIR}/uaa.pub"

#--- Generate cert in credhub
SetCredhubCert() {
  PATH_NAME="$1"
  CA_FILE="$2"
  CERT_FILE="$3"
  KEY_FILE="$4"
  printf "%b- Set \"${PATH_NAME}\" cert in credhub...%b\n" "${YELLOW}" "${STD}"

  #--- Check if credhub propertie exists
  flag_exist=$(credhub f | grep "name: ${PATH_NAME}")
  if [ "${flag_exist}" != "" ] ; then
    credhub delete -n ${PATH_NAME} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: \"${PATH_NAME}\" certificate deletion failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi

  #--- Set certificate in credhub
  credhub set -t certificate -n ${PATH_NAME} -r ${CA_FILE} -c ${CERT_FILE} -p ${KEY_FILE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    printf "\n%bERROR: \"${PATH_NAME}\" certificate creation failed.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi
}

#--- Check prerequisites
verifyDirectory "${TEMPLATE_BOOTSTRAP_DIR}"

#--- Generate credhub and uaa certificates and store them as files
display "INFO" "Generate credhub and uaa certs"
createDir "${CREDHUB_CERTS_DIR}/credub-certs"
createDir "${CREDHUB_CERTS_DIR}/uaa-credub-certs"
cd ${TEMPLATE_BOOTSTRAP_DIR}
spruce merge --prune secrets certs-credhub-vars-tpl.yml > certs-credhub-vars.yml
bosh int certs-credhub-uaa-tpl.yml --vars-file=certs-credhub-vars.yml --vars-store=certs-credhub-uaa.yml
bosh int certs-credhub-uaa.yml --path /credhub-certs/ca > ${CREDHUB_CA}
bosh int certs-credhub-uaa.yml --path /credhub-certs/certificate > ${CREDHUB_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /credhub-certs/private_key > ${CREDHUB_PRIVATE_KEY}
bosh int certs-credhub-uaa.yml --path /uaa-certs/ca > ${UAA_CA}
bosh int certs-credhub-uaa.yml --path /uaa-certs/certificate > ${UAA_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /uaa-certs/private_key > ${UAA_PRIVATE_KEY}
rm -f certs-credhub-vars.yml certs-credhub-uaa.yml > /dev/null 2>&1

#--- Insert certs in credhub (for automatic certs check)
logToCredhub
printf "\n%bSet keys and certs in credhub...%b\n" "${REVERSE}${YELLOW}" "${STD}"
SetCredhubCert "/micro-bosh/credhub-ha/credhub-certs" "${CREDHUB_CA}" "${CREDHUB_CERTIFICATE}" "${CREDHUB_PRIVATE_KEY}"
SetCredhubCert "/micro-bosh/credhub-ha/uaa-certs" "${UAA_CA}" "${UAA_CERTIFICATE}" "${UAA_PRIVATE_KEY}"

#--- Generate jwt private and public ssh keys
display "INFO" "Generate jwt private and public keys"
if [ ! -f ${UAA_SIGNING_KEY} ] ; then
  ssh-keygen -t rsa -b 4096 -f ${UAA_SIGNING_KEY} -q -N ""
  openssl rsa -in ${UAA_SIGNING_KEY} -pubout > ${UAA_VERIFICATION_KEY}
fi

#--- Push updates on secrets repository
display "INFO" "Commit \"credhub certs\" into secrets repository"
commitGit "${CREDHUB_CERTS_DIR}" "update_credhub_certs"

printf "\n%bCredhub certs generation done.%b\n\nCheck that concourse \"micro-depls/micro-depls-bosh-generated/deploy-credhub-ha\" deployment triggered.\n\n" "${REVERSE}${GREEN}" "${STD}"