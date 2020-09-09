#!/bin/bash
#=========================================================================
# Create credhub, uaa key and cert files depending from internalCA
# and jwt ssh public and private key
#=========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script environment
TEMPLATE_BOOTSTRAP_DIR="${TEMPLATE_REPO_DIR}/micro-depls/credhub-ha/bootstrap"
CREDHUB_CERTS_DIR="${SECRETS_REPO_DIR}/micro-depls/credhub-ha/secrets/certs"

#--- Cert and key files
export CREDHUB_CERTIFICATE="${CREDHUB_CERTS_DIR}/credub-certs/server.crt"
export CREDHUB_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/credub-certs/server.key"
export UAA_CERTIFICATE="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.crt"
export UAA_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.key"
export UAA_SIGNING_KEY="${CREDHUB_CERTS_DIR}/uaa"
export UAA_VERIFICATION_KEY="${CREDHUB_CERTS_DIR}/uaa.pub"

#--- Check prerequisites
verifyDirectory "${TEMPLATE_BOOTSTRAP_DIR}"

#--- Generate credhub and uaa certificates and store them as files
display "INFO" "Generate credhub and uaa certs"
createDir "${CREDHUB_CERTS_DIR}/credub-certs"
createDir "${CREDHUB_CERTS_DIR}/uaa-credub-certs"
cd ${TEMPLATE_BOOTSTRAP_DIR}
spruce merge --prune secrets certs-credhub-vars-tpl.yml > certs-credhub-vars.yml
bosh int certs-credhub-uaa-tpl.yml --vars-file=certs-credhub-vars.yml --vars-store=certs-credhub-uaa.yml
bosh int certs-credhub-uaa.yml --path /credhub-certs/certificate > ${CREDHUB_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /credhub-certs/private_key > ${CREDHUB_PRIVATE_KEY}
bosh int certs-credhub-uaa.yml --path /uaa-certs/certificate > ${UAA_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /uaa-certs/private_key > ${UAA_PRIVATE_KEY}
rm -f certs-credhub-vars.yml certs-credhub-uaa.yml > /dev/null 2>&1

#--- Generate jwt private and public ssh keys
display "INFO" "Generate jwt private and public keys"
if [ ! -f ${UAA_SIGNING_KEY} ] ; then
	ssh-keygen -t rsa -b 4096 -f ${UAA_SIGNING_KEY} -q -N ""
	openssl rsa -in ${UAA_SIGNING_KEY} -pubout > ${UAA_VERIFICATION_KEY}
fi

#--- Push updates on secrets repository
display "INFO" "Commit \"credhub certs\" into secrets repository"
commitGit "secrets" "update_credhub_certs"

printf "\n%bCredhub certs generation done.%b\n\nCheck that concourse \"micro-depls/micro-depls-bosh-generated/credhub-seeder\" deployment triggered.\n\n" "${REVERSE}${GREEN}" "${STD}"