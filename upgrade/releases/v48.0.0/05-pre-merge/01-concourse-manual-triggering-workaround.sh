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

if [[ -z "${PAAS_TEMPLATES_VERSION}" ]]; then
    echo "Using meta-inf.yml to determine paas-templates version"
    META_INF_YML_PATH=$(echo "$(dirname $0)/../../../../meta-inf.yml")
    PAAS_TEMPLATES_VERSION=$(ruby -ryaml -e 'yaml_file=ARGV[0]; yaml = YAML.load_file(yaml_file); puts yaml&.dig("meta-inf","versions","paas-templates")' ${META_INF_YML_PATH})
fi

pipeline="paas-templates-${PAAS_TEMPLATES_VERSION}-upgrade"
job_name=step-9-upgrade-micro-depls-concourse
echo "Interacting with pipeline ${pipeline}"
${FLY} -t ${FLY_TARGET} pause-job -j "${pipeline}/${job_name}"
