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


#--- Deploy micro-depls credhub in bootstrap mode
OPERATORS_FILES="-o ../template/1-credhub-backend-operators.yml -o ../template/1-credhub-rotate-operators.yml"
VARS_FILE="${DEPLOYMENT}-vars-tpl.yml"
deployRelease
if [ $? = 1 ] ; then
  deployRelease
  if [ $? = 1 ] ; then
    display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
  fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"
