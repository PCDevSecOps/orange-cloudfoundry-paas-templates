#!/usr/bin/env bash

CONFIG_DIR=$1
NEW_MYSQL="ops-depls/cloudfoundry-mysql-osb-region-2"

NEW_MYSQL_PATH=${CONFIG_DIR}/${NEW_MYSQL}
mkdir -p ${NEW_MYSQL_PATH}

if [[ ! -f ${NEW_MYSQL_PATH}/enable-deployment.yml ]];then
    touch ${NEW_MYSQL_PATH}/enable-deployment.yml
else
    echo "Deployment ${NEW_MYSQL} already activated at ${NEW_MYSQL_PATH}"
fi

mkdir -p ${NEW_MYSQL_PATH}/secrets
if [[ ! -f ${NEW_MYSQL_PATH}/secrets/meta.yml ]];then
    touch ${NEW_MYSQL_PATH}/secrets/meta.yml
else
    echo "Meta file for ${NEW_MYSQL} is already created at ${NEW_MYSQL_PATH}/secrets"
fi