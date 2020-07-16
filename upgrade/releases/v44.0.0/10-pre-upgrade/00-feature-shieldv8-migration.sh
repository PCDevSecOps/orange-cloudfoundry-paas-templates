#!/usr/bin/env bash

CONFIG_DIR=$1
SHIELD_DEPLOYMENT="master-depls/shieldv8"

SHIELD_PATH=${CONFIG_DIR}/${SHIELD_DEPLOYMENT}
mkdir -p ${SHIELD_PATH}
if [[ ! -f ${SHIELD_PATH}/enable-deployment.yml ]];then
    touch ${SHIELD_PATH}/enable-deployment.yml
else
    echo "Deployment ${SHIELD_DEPLOYMENT} already activated at ${SHIELD_PATH}"
fi