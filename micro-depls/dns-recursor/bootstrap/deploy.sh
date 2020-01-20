#!/bin/bash
#===========================================================================
# Deploy micro-depls dns-recursor for bootstrap
#===========================================================================

#--- Deployment name
DEPLOYMENT="dns-recursor"

#--- Load common bootstrap parameters and functions
. ~/bosh/template/bootstrap/tools/functions.sh

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Deploy micro-depls dns-recursor in bootstrap mode
OPERATORS_FILES="-o ../template/1-dns-aliases-operators.yml -o ../template/${IAAS_TYPE}/2-double-nic-operators.yml -o ../template/${IAAS_TYPE}/3-bosh-dns-aliases-operators.yml -o bootstrap-operators.yml"
VARS_FILE="../template/${DEPLOYMENT}-vars-tpl.yml ../template/${IAAS_TYPE}/2-double-nic-vars-tpl.yml ../template/${IAAS_TYPE}/3-bosh-dns-aliases-vars-tpl.yml"
deployRelease
if [ $? = 1 ] ; then
  deployRelease
  if [ $? = 1 ] ; then
    display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
  fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"