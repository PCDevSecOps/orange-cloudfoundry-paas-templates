#!/bin/bash
#===========================================================================
# Deploy micro-depls internet-proxy for bootstrap
#===========================================================================

#--- Deployment name
DEPLOYMENT="internet-proxy"

#--- Load common bootstrap parameters and functions
. ~/bosh/template/bootstrap/tools/functions.sh

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Deploy micro-depls dns-recursor in bootstrap mode
OPERATORS_FILES="-o ../template/${IAAS_TYPE}/1-squid-service-operators.yml -o ../template/${IAAS_TYPE}/2-double-nic-proxy-operators.yml"
VARS_FILE="../template/proxy-vars-tpl.yml ../template/${IAAS_TYPE}/internet-proxy-vars-tpl.yml"
deployRelease
if [ $? = 1 ] ; then
  deployRelease
  if [ $? = 1 ] ; then
    display "ERROR" "Micro-depls \"${DEPLOYMENT}\" deployment failed"
  fi
fi

display "OK" "Micro-depls \"${DEPLOYMENT}\" deployment succeeded"