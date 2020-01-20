#!/bin/sh

TFVARS_FILE=${GENERATE_DIR}/terraform.tfvars.yml
if [ -f ${TFVARS_FILE} ];then
    spruce json ${TFVARS_FILE} > ${GENERATE_DIR}/terraform.tfvars.json
else
    echo "WARNING - No ${TFVARS_FILE} detected, skipping Json transformation"
fi
