#!/bin/bash
set -x
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

ROOT_DEPLOYMENT="ops-depls"
PREFIX="2-shieldv8"
SHIELD_OPERATORS_RELATIVE_PATH="../../../shared-operators/shield"
SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH="../../../../shared-operators/shield"

DEPLOYMENTS="cassandra"
PREFIX="30-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    PREFIX="30-shieldv8-aa2"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-cassandra2-errand-operators.yml ${PREFIX}-add-shield-import-asystems-cassandra2-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    PREFIX="30-shieldv8-bb2"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-cassandra2-errand-operators.yml ${PREFIX}-add-shield-import-asystems-cassandra2-errand-operators.yml
    cd -
done

DEPLOYMENTS="cf-rabbit37"
PREFIX="30-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-cf-rabbit-errand-operators.yml ${PREFIX}-add-shield-import-asystems-cf-rabbit-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done


DEPLOYMENTS="cf-redis"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    PREFIX="20-shieldv8"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-cf-redis-errand-operators.yml ${PREFIX}-add-shield-import-asystems-cf-redis-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-post-start-only-operators.yml ${PREFIX}-create-bucket-scripting-post-start-only-operators.yml
    cd -
done

DEPLOYMENTS="cf-redis-osb"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    PREFIX="20-shieldv8"
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-cf-redis-errand-operators.yml ${PREFIX}-add-shield-import-asystems-cf-redis-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-post-start-only-operators.yml ${PREFIX}-create-bucket-scripting-post-start-only-operators.yml
    cd -
done

DEPLOYMENTS="cloudfoundry-mysql"
PREFIX="40-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-mysql-errand-operators.yml ${PREFIX}-add-shield-import-asystems-mysql-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="cloudfoundry-mysql-osb"
PREFIX="40-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-mysql-errand-operators.yml ${PREFIX}-add-shield-import-asystems-mysql-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="guardian-uaa"
PREFIX="02-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
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

DEPLOYMENTS="guardian-uaa-prod"
PREFIX="02-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
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

DEPLOYMENTS="mongodb"
PREFIX="02-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-proxy-operators.yml ${PREFIX}-add-shield-agent-proxy-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-shield-operators.yml ${PREFIX}-add-release-shield-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-scripting-operators.yml ${PREFIX}-add-release-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-release-minio-operators.yml ${PREFIX}-add-release-minio-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-mc-job-operators.yml ${PREFIX}-add-mc-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-agent-job-operators.yml ${PREFIX}-add-shield-agent-job-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-members-errand-operators.yml ${PREFIX}-add-shield-import-members-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-policies-errand-operators.yml ${PREFIX}-add-shield-import-policies-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-storage-errand-operators.yml ${PREFIX}-add-shield-import-storage-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/add-shield-import-systems-mongodb-errand-operators.yml ${PREFIX}-add-shield-import-asystems-mongodb-errand-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-operators.yml ${PREFIX}-create-bucket-scripting-operators.yml
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/create-bucket-scripting-pre-start-only-operators.yml ${PREFIX}-create-bucket-scripting-pre-start-only-operators.yml
    cd -
done

DEPLOYMENTS="postgresql-docker"
PREFIX="40-shieldv8"
for deployment in $(echo ${DEPLOYMENTS} | tr "|" " "); do
    echo "${deployment}";
    cd ../../${ROOT_DEPLOYMENT}/${deployment}/template
    ln -s ${SHIELD_OPERATORS_RELATIVE_PATH}/shieldv8-vars.yml common-shieldv8-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-internet-vars.yml openstack-hws/shieldv8-proxy-internet-vars.yml
    ln -s ${SHIELD_OPERATORS_IAAS_TYPE_RELATIVE_PATH}/shieldv8-proxy-intranet-vars.yml vsphere/shieldv8-proxy-intranet-vars.yml
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

