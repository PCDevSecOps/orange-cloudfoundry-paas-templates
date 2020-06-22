#!/bin/bash
#===========================================================================
# Deploy micro-depls credhub-ha for bootstrap
#===========================================================================

#--- Deployment name
DEPLOYMENT="credhub-ha"

#--- Load common bootstrap parameters and functions
. ~/bosh/template/bootstrap/tools/functions.sh

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Script environment
CREDHUB_CERTS_DIR="${SECRETS_REPO_DIR}/micro-depls/${DEPLOYMENT}/secrets/certs"

#--- Variables needed for spruce
export BOSH_PRIVATE_KEY="${SECRETS_REPO_DIR}/shared/certs/internal_paas-ca/server-ca.key"
export CREDHUB_CERTIFICATE="${CREDHUB_CERTS_DIR}/credub-certs/server.crt"
export CREDHUB_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/credub-certs/server.key"
export UAA_CERTIFICATE="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.crt"
export UAA_PRIVATE_KEY="${CREDHUB_CERTS_DIR}/uaa-credub-certs/server.key"
export UAA_SIGNING_KEY="${CREDHUB_CERTS_DIR}/uaa"
export UAA_VERIFICATION_KEY="${CREDHUB_CERTS_DIR}/uaa.pub"

#--- Generate credhub and uaa certificates and store them as files
display "INFO" "Generate credhub and uaa certs"
cd ${TEMPLATE_BOOTSTRAP_DIR}
spruce merge --prune secrets certs-credhub-vars-tpl.yml > certs-credhub-vars.yml
bosh int certs-credhub-uaa-tpl.yml --vars-file=certs-credhub-vars.yml --vars-store=certs-credhub-uaa.yml
bosh int certs-credhub-uaa.yml --path /credhub-certs/certificate > ${CREDHUB_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /credhub-certs/private_key > ${CREDHUB_PRIVATE_KEY}
bosh int certs-credhub-uaa.yml --path /uaa-certs/certificate > ${UAA_CERTIFICATE}
bosh int certs-credhub-uaa.yml --path /uaa-certs/private_key > ${UAA_PRIVATE_KEY}
rm -f certs-credhub-vars.yml certs-credhub-uaa.yml > /dev/null 2>&1

#--- Generate jwt private and public keys
display "INFO" "Generate jwt private and public keys"
if [ ! -s ${UAA_SIGNING_KEY} ] ; then
  ssh-keygen -t rsa -b 4096 -f ${CREDHUB_CERTS_DIR}/uaa -q -N ""
  openssl rsa -in ${CREDHUB_CERTS_DIR}/uaa -pubout > ${UAA_VERIFICATION_KEY}
fi

#--- Save certs into secrets repository
commitGit "secrets" "Add_credhub_and_uaa_certs"

#--- Deploy micro-depls credhub in bootstrap mode
OPERATORS_FILES="-o ../template/1-credhub-backend-operators.yml -o bootstrap-operators.yml"
VARS_FILE="${DEPLOYMENT}-vars-tpl.yml"
deployRelease
if [ $? = 1 ] ; then
  deployRelease
  if [ $? = 1 ] ; then
    display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
  fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"