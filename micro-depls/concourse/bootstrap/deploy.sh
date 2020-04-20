#!/bin/bash
#===========================================================================
# Deploy micro-depls concourse for bootstrap
#===========================================================================

#--- Deployment name
DEPLOYMENT="concourse"

#--- Load common bootstrap parameters and functions
. ~/bosh/template/bootstrap/tools/functions.sh

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Initialyse concourse-deployment submodule
cd ${TEMPLATE_REPO_DIR}
display "INFO" "Checkout \"concourse-deployment\" submodule"
executeGit "submodule update --init micro-depls/concourse/template/concourse-bosh-deployment" "proxy"

#--- Deploy micro-depls minio S3 in bootstrap mode
if [ "${IAAS_TYPE}" = "vsphere" ] ; then
  OPERATORS_FILES="-o ../template/02-create-local-user-into-credhub-operators.yml \
  -o ../template/03-add-bosh-dns-requirements-on-worker-operators.yml \
  -o ../template/1-use-http-proxy-for-garden-docker-operators.yml \
  -o ../template/basic-auth-operators.yml \
  -o ../template/credential-manager-enable-cache-operators.yml \
  -o ../template/credential-manager-tuning-operators.yml \
  -o ../template/credhub-operators.yml \
  -o ../template/enable-global-resources-operators.yml \
  -o ../template/scale-operators.yml \
  -o ../template/static-web-custom-operators.yml \
  -o ../template/worker-swap-size-operators.yml \
  -o ../template/zz-customize-credhub-operators.yml \
  -o ../template/zz-force-offline-releases-operators.yml \
  -o bootstrap-operators.yml"
  VARS_FILE="../template/${DEPLOYMENT}-vars-tpl.yml ../template/versions-vars.yml bootstrap-vars-tpl.yml"
else
  OPERATORS_FILES="-o ../template/enable-credhub-operators.yml -o bootstrap-operators.yml"
  VARS_FILE="../template/${DEPLOYMENT}-vars-tpl.yml"
fi

deployRelease "no-vars-store"
if [ $? = 1 ] ; then
  deployRelease "no-vars-store"
  if [ $? = 1 ] ; then
    display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
  fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"