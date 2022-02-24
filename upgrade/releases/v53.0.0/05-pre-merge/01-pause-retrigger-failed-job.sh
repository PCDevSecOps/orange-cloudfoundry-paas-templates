#!/usr/bin/env bash

# Script required to fix https://github.com/orange-cloudfoundry/paas-templates/issues/1295

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
    CONCOURSE_URL=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-target:"|cut -d' ' -f2)
    echo "Getting concourse username from credentials-auto-init.yml"
    FLY_USER=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-username:"|cut -d' ' -f2) # credential_leak_validated
    echo "Getting concourse password from credentials-auto-init.yml"
    FLY_PWD=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-password:"|cut -d' ' -f2) # credential_leak_validated
fi

team="main"
pipeline="ops-depls-recurrent-tasks"
job_name="retrigger-failed-jobs"

### Log to concourse with fly cli
${FLY} -t "${FLY_TARGET}" login -c "${CONCOURSE_URL}" -k -u "${FLY_USER}" -p "${FLY_PWD}" -n $team

searched_job="$(${FLY} -t "${FLY_TARGET}" jobs -p "${pipeline}" --json|jq -r --arg job_name "${job_name}" '.[]?.name|select(test($job_name))')"
if [ "$searched_job" = "$job_name" ]; then
  echo "Interacting with pipeline ${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline}/jobs/${job}"
  ${FLY} -t "${FLY_TARGET}" pause-job -j "${pipeline}/${job_name}"
else
  echo "Info: pipeline does not exist: ${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline}/jobs/${job}"
fi