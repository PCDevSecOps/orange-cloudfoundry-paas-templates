#!/bin/bash

CONFIG_DIR=$1

SHIELD_TLS=/bosh-master/shieldv8/shield-tls
echo "Delete credhub key ${SHIELD_TLS}"
credhub delete -n "${SHIELD_TLS}"


FLY_TARGET=${FLY_TARGET:-concourse}
FLY=${FLY:-fly}


credhub_available=$(credhub curl -p /version 2>/dev/null)
if [[ -n "$credhub_available" ]]; then
    CONCOURSE_URL="${CONCOURSE_URL:-https://elpaaso-concourse.${OPS_DOMAIN}}"
    echo "Getting Fly username from credhub"
    export FLY_USER=$(credhub g -n /concourse-micro/main/concourse-admin -k username)
    echo "Getting Fly password from credhub"
    export FLY_PWD=$(credhub g -n /concourse-micro/main/concourse-admin -k password)
else
    echo "Getting concourse URL from credentials-auto-init.yml"
    CONCOURSE_URL=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-target:"|cut -d' ' -f2)
    echo "Getting concourse username from credentials-auto-init.yml"
    FLY_USER=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-username:"|cut -d' ' -f2) # credential_leak_validated
    echo "Getting concourse password from credentials-auto-init.yml"
    FLY_PWD=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-password:"|cut -d' ' -f2) # credential_leak_validated
fi

set -e
printf "\n\n%bLog to fly%b\n" "${GREEN}${BOLD}" "${STD}"
${FLY} -t ${FLY_TARGET} login -c ${CONCOURSE_URL} -k -u ${FLY_USER} -p ${FLY_PWD} -n upload
pipeline="master-depls-s3-stemcell-upload-generated"
echo "Interacting with pipeline ${pipeline}"
${FLY} -t ${FLY_TARGET} unpause-pipeline -p "${pipeline}"

${FLY} -t ${FLY_TARGET} edit-target -n master-depls
pipeline="master-depls-bosh-generated"
job_name="deploy-shieldv8"
echo "Interacting with pipeline ${pipeline}/${job_name}"
${FLY} -t ${FLY_TARGET} unpause-job -j "${pipeline}/${job_name}"
${FLY} -t ${FLY_TARGET} trigger-job -j "${pipeline}/${job_name}" --watch
${FLY} -t ${FLY_TARGET} pause-job -j "${pipeline}/${job_name}"

