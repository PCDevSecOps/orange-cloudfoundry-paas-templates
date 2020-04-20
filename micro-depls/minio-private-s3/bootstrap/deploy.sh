#!/bin/sh
#===========================================================================
# Deploy micro-depls minio for bootstrap
#===========================================================================

#--- Deployment name
DEPLOYMENT="minio-private-s3"

#--- Load common bootstrap parameters and functions
. ~/bosh/template/bootstrap/tools/functions.sh

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Deploy micro-depls minio-private-s3 in bootstrap mode
OPERATORS_FILES="-o bootstrap-operators.yml"
VARS_FILE="../template/${DEPLOYMENT}-vars-tpl.yml"
cd ${TEMPLATE_BOOTSTRAP_DIR}
deployRelease "no-vars-store"
if [ $? = 1 ] ; then
	deployRelease "no-vars-store"
	if [ $? = 1 ] ; then
		display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
	fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"