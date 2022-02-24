#!/usr/bin/env bash

CONFIG_DIR=$1
COAB_TERRAFORM="coab-depls/terraform-config"

COAB_TERRAFORM_PATH=${CONFIG_DIR}/${COAB_TERRAFORM}

#remove entries in terraform
cd ${COAB_TERRAFORM_PATH}
terraform state rm cloudfoundry_service_broker.tf-coab-cf-rabbit
terraform state rm cloudfoundry_service_broker.tf-coab-cf-rabbit-extended
terraform state rm cloudfoundry_service_broker.tf-coab-mongodb
terraform state rm cloudfoundry_service_broker.tf-coab-redis
terraform state rm cloudfoundry_service_broker.tf-coab-redis-extended
terraform state rm cloudfoundry_service_broker.tf-coab-cf-mysql
terraform state rm cloudfoundry_service_broker.tf-coab-cf-mysql-extended
terraform state rm cloudfoundry_service_broker.tf-coab-noop

#find ${CONFIG_DIR}/${COAB_TERRAFORM}/spec/*.tf -mindepth 1 -delete
set +e
rm -rf ${COAB_TERRAFORM_PATH}/spec/*.tf 2>/dev/null
set -e
