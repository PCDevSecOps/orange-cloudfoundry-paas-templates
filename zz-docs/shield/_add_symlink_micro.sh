#!/bin/bash
set -x
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

ROOT_DEPLOYMENT="micro-depls"
PREFIX="2-shieldv8"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"
SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH="../../../../shared-operators/shield"

DEPLOYMENTS="bosh-master"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/remove-shieldv8-operators.yml ../bootstrap/remove-shieldv8-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-postgres-errand-operators.yml ${PREFIX}-add-shield-import-asystems-postgres-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="concourse"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/remove-shieldv8-operators.yml ../bootstrap/remove-shieldv8-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
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

DEPLOYMENTS="credhub-ha"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/remove-shieldv8-operators.yml ../bootstrap/remove-shieldv8-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
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

DEPLOYMENTS="gitlab"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/remove-shieldv8-operators.yml ../bootstrap/remove-shieldv8-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-ope*rators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-fs-errand-operators.yml ${PREFIX}-add-shield-import-asystems-fs-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-post-start-only-operators.yml ${PREFIX}-create-bucket-scripting-post-start-only-operators.yml
    cd -
done