#!/bin/bash
set -x
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

ROOT_DEPLOYMENT="micro-depls"
PREFIX="2-shieldv8"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"

DEPLOYMENTS="bosh-master"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-remote-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-postgres-errand-operators.yml ${PREFIX}-add-shield-import-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="concourse"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-remote-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-postgres-errand-operators.yml ${PREFIX}-add-shield-import-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="credhub-ha"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-remote-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-postgres-errand-operators.yml ${PREFIX}-add-shield-import-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="gitlab"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-remote-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-fs-errand-operators.yml ${PREFIX}-add-shield-import-fs-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-fs-system-errand-operators.yml ${PREFIX}-add-shield-import-fs-system-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-post-start-only-operators.yml ${PREFIX}-create-bucket-scripting-post-start-only-operators.yml
    cd -
done