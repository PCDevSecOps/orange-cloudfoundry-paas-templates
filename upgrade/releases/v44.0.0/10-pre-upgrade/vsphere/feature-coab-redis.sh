#!/usr/bin/env bash

CONFIG_DIR=$1
TERRAFORM_DIR=${CONFIG_DIR}/coab-depls/terraform-config/spec

if [[ ! -f ${TERRAFORM_DIR}/redis-broker-spaces.tf ]];then
    mkdir -p ${TERRAFORM_DIR} && touch ${TERRAFORM_DIR}/redis-broker-spaces.tf
else
    echo "Terrafom redis-broker-spaces.tf already disabled at ${TERRAFORM_DIR}"
fi

if [[ ! -f ${TERRAFORM_DIR}/redis-service-broker.tf ]];then
    mkdir -p ${TERRAFORM_DIR} && touch ${TERRAFORM_DIR}/redis-service-broker.tf
else
    echo "Terrafom redis-broker-spaces.tf already disabled at ${TERRAFORM_DIR}"
fi