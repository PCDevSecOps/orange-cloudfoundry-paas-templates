#!/usr/bin/env bash

CONFIG_DIR=$1


FLY_TARGET=${FLY_TARGET:-concourse}

#--- Log to concourse with fly cli
printf "\n\n%bLog to fly%b\n" "${GREEN}${BOLD}" "${STD}"
CONCOURSE_URL="${CONCOURSE_URL:-https://elpaaso-concourse.${OPS_DOMAIN}}"
echo "Getting Fly username from credhub"
export FLY_USER=$(credhub g -n /concourse-micro/main/concourse-admin -k username)
echo "Getting Fly password from credhub"
export FLY_PWD=$(credhub g -n /concourse-micro/main/concourse-admin -k password)

### Log to concourse with fly cli
fly -t ${FLY_TARGET} login -c ${CONCOURSE_URL} -k -u ${FLY_USER} -p ${FLY_PWD} -n main

ALL_PIPELINES=$(fly -t ${FLY_TARGET} pipelines -a --json)
TF_GENERATED_PIPELINES=$(echo ${ALL_PIPELINES}|jq -r '.[]|.name| select(test(".*-depls-tf-generated"))')
echo "Selected pipelines: <$TF_GENERATED_PIPELINES>"
for pipeline in ${TF_GENERATED_PIPELINES};do
    echo "Processing pipeline $pipeline"
    TEAM=$(echo ${ALL_PIPELINES}|jq --arg pipeline ${pipeline} '.[]|select(.name == $pipeline)|.team_name')
    if [[ -z ${TEAM} ]]; then
        echo "ERROR: cannot extract team from"
        exit 1
    fi
    fly -t ${FLY_TARGET} edit-target -n ${TEAM}
    fly -t ${FLY_TARGET} unpause-pipeline -p ${pipeline}
done
