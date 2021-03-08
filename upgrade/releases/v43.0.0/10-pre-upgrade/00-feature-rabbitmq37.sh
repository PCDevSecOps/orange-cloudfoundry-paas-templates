#!/usr/bin/env bash

CONFIG_DIR=$1
RABBIT_DEPLOYMENT="ops-depls/cf-rabbit37"

RABBIT_PATH=${CONFIG_DIR}/${RABBIT_DEPLOYMENT}
mkdir -p ${RABBIT_PATH}
if [[ ! -f ${RABBIT_PATH}/enable-deployment.yml ]];then
    touch ${RABBIT_PATH}/enable-deployment.yml
else
    echo "Deployment ${RABBIT_DEPLOYMENT} already activated at ${RABBIT_PATH}"
fi