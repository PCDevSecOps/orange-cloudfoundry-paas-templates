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
    CONCOURSE_URL=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-target:"|cut -d' ' -f2)
    echo "Getting concourse username from credentials-auto-init.yml"
    FLY_USER=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-username:"|cut -d' ' -f2) # credential_leak_validated
    echo "Getting concourse password from credentials-auto-init.yml"
    FLY_PWD=$(cat ${CONFIG_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-password:"|cut -d' ' -f2) # credential_leak_validated
fi

### Log to concourse with fly cli
${FLY} -t ${FLY_TARGET} login -c ${CONCOURSE_URL} -k -u ${FLY_USER} -p ${FLY_PWD} -n main

ALL_PIPELINES=$(${FLY} -t ${FLY_TARGET} pipelines -a --json)
BOSH_GENERATED_PIPELINES=$(echo ${ALL_PIPELINES}|jq -r '.[]|.name| select(endswith("depls-bosh-generated"))')
echo "Selected pipelines: <$BOSH_GENERATED_PIPELINES>"
for pipeline in ${BOSH_GENERATED_PIPELINES};do
  echo "Processing pipeline $pipeline"
  TEAM=$(echo ${ALL_PIPELINES}|jq --arg pipeline ${pipeline} '.[]|select(.name == $pipeline)|.team_name')
  if [[ -z ${TEAM} ]]; then
    echo "ERROR: cannot extract team from"
    exit 1
  fi
  echo "Applying unpause-job on <$pipeline> in $TEAM team"
  ${FLY} -t ${FLY_TARGET} unpause-job -j "${pipeline}/upload-stemcell-to-director" --team ${TEAM}
  ${FLY} -t ${FLY_TARGET} unpause-job -j "${pipeline}/upload-stemcell-to-s3" --team ${TEAM}
done

