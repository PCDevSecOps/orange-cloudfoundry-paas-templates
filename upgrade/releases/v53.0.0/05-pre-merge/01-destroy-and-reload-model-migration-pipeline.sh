#!/usr/bin/env bash

# Script required to fix https://github.com/orange-cloudfoundry/paas-templates/issues/1460

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
pipeline="coab-depls-model-migration-pipeline"

### Log to concourse with fly cli
${FLY} -t "${FLY_TARGET}" login -c "${CONCOURSE_URL}" -k -u "${FLY_USER}" -p "${FLY_PWD}" -n $team

searched_pipeline_count="$(${FLY} -t "${FLY_TARGET}" pipelines --json|jq -r --arg pipeline "${pipeline}" '.[]?.name|select(. == $pipeline)'|wc -l)"
if [ "$searched_pipeline_count" = "1" ]; then
  echo "Deleting $pipeline: (${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline})"
  ${FLY} -t "${FLY_TARGET}" destroy-pipeline -p "${pipeline}" --non-interactive
else
  echo "Info: pipeline $pipeline does not exist at ${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline}"
fi

team="coab-depls"
pipeline="coab-depls-concourse-generated"
job_name="deploy-concourse-model-migration-pipeline-pipeline"
echo "Reloading using $pipeline"
${FLY} -t "${FLY_TARGET}" etg -n $team
searched_pipeline_count="$(${FLY} -t "${FLY_TARGET}" pipelines --json|jq -r --arg pipeline "${pipeline}" '.[]?.name|select(. == $pipeline)'|wc -l)"
if [ "$searched_pipeline_count" = "1" ]; then
  ${FLY} -t ${FLY_TARGET} unpause-pipeline -p "${pipeline}"
  searched_job_count="$(${FLY} -t "${FLY_TARGET}" jobs -p $pipeline --json|jq -r --arg job "${job_name}" '.[]?.name|select(. == $job)'|wc -l)"
  if [ "$searched_job_count" = "1" ]; then
    ${FLY} -t ${FLY_TARGET} unpause-job -j "${pipeline}/${job_name}"
    echo "Trigger and wait ${pipeline}/${job_name}"
    ${FLY} -t ${FLY_TARGET} trigger-job -j "${pipeline}/${job_name}" --watch >/dev/null
  else
    echo "ERROR: job $job_name does not exist at ${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline}"
    exit 1
  fi
else
  echo "ERROR: pipeline $pipeline does not exist at ${CONCOURSE_URL}/teams/${team}/pipelines/${pipeline}"
  exit 1
fi
