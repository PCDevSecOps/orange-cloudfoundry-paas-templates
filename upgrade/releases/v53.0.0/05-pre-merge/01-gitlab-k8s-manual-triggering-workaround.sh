#!/usr/bin/env bash

CONFIG_DIR=$1

FLY_TARGET=${FLY_TARGET:-concourse}
FLY=${FLY:-fly}

#--- Log to concourse with fly cli
printf "\n\n%bLog to fly%b\n" "${GREEN}${BOLD}" "${STD}"

credhub_available=$(credhub curl -p /version 2>/dev/null)
if [[ -n "$credhub_available" ]]; then
    CONCOURSE_URL="${CONCOURSE_URL:-https://elpaaso-concourse.${OPS_DOMAIN}}"
    echo "Getting Fly username from credhub"
    export FLY_USER=$(credhub g -n /concourse-micro/main/concourse-admin -k username)
    echo "Getting Fly password from credhub"
    export FLY_PWD=$(credhub g -n /concourse-micro/main/concourse-admin -k password)
else
    echo "Getting concourse URL from credentials-auto-init.yml"
    CONCOURSE_URL=$(grep -e "^concourse-micro-depls-target:" ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|cut -d' ' -f2)
    echo "Getting concourse username from credentials-auto-init.yml"
    FLY_USER=$(grep -e "^concourse-micro-depls-username:" ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|cut -d' ' -f2) # credential_leak_validated
    echo "Getting concourse password from credentials-auto-init.yml"
    FLY_PWD=$(grep -e "^concourse-micro-depls-password:" ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|cut -d' ' -f2) # credential_leak_validated
fi

### Log to concourse with fly cli
team="micro-depls"
pipeline="micro-depls-bosh-generated"
job_name="run-errand-k8s-gitlab-action"
${FLY} -t "${FLY_TARGET}" login -c "${CONCOURSE_URL}" -k -u "${FLY_USER}" -p "${FLY_PWD}" -n $team

echo "Interacting with pipeline '${pipeline}' in '${team}' team"
${FLY} -t "${FLY_TARGET}" pause-job -j "${pipeline}/${job_name}"
