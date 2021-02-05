#!/usr/bin/env bash

CONFIG_DIR=$1
COAB_PIPELINE="coab-depls/model-migration-pipeline"

COAB_PIPELINE_PATH=${CONFIG_DIR}/${COAB_PIPELINE}
mkdir -p ${COAB_PIPELINE_PATH}
if [[ ! -f ${COAB_PIPELINE_PATH}/enable-deployment.yml ]];then
    touch ${COAB_PIPELINE_PATH}/enable-deployment.yml
else
    echo "Pipeline ${COAB_PIPELINE} already activated at ${COAB_PIPELINE_PATH}"
fi