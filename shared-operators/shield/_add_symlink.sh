#!/bin/bash
set -x
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

ROOT_DEPLOYMENT="master-depls"
MASTER_DEPLOYMENTS="cf-autoscaler"
PREFIX="2-shieldv8"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"

MASTER_DEPLOYMENTS="bosh-coab"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="bosh-kubo"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="bosh-ops"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="cf-autoscaler"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="cloudfoundry-datastores"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    PREFIX="1-shieldv8"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-mysql-errand-operators.yml ${PREFIX}-add-shield-import-asystems-mysql-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    PREFIX="5-shieldv8"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="metabase"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="openldap"
PREFIX="2-shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-fs-errand-operators.yml ${PREFIX}-add-shield-import-asystems-fs-errand-operators.yml
    cd -
done

MASTER_DEPLOYMENTS="shieldv8"
for deployment in $(echo ${MASTER_DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml 5-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml 6-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml 5-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml 5-create-bucket-scripting-pre-start-only-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml 7-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml 7-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml 7-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-fs-errand-operators.yml 7-add-shield-import-asystems-fs-errand-operators.yml
    cd -
done




