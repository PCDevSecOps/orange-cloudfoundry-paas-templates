#!/usr/bin/env bash

SECRETS_DIR=$(dirname $0)/../../../../int-secrets/
FLY=fly

set -e
usage(){
    echo "$0 -v <X.Y.Z>" 1>&2
    echo -e "\t -x skip old pipeline backup" 1>&2
    echo -e "\t -g skip git update" 1>&2
    echo -e "\t -f skip fly sync" 1>&2
    echo -e "\t -i use insecure mode with fly" 1>&2
    exit 1
}

SKIP_FLY_SYNC="false"
INSECURE="false"

while getopts "c:fi" option; do
    case "${option}" in
        c)
            SECRETS_DIR=$OPTARG
            ;;
        f)
            SKIP_FLY_SYNC="true"
            ;;
        i)
            INSECURE="true"
            ;;
        h)
            usage
            ;;
        \?)
          echo "Invalid option: $OPTARG" >&2
          ;;
        *)
            usage
            ;;
    esac
done

if ! [ -d ${SECRETS_DIR} ];then
    echo "Please clone secrets into ~/bosh/secrets"
    exit 1
fi

CONCOURSE_TEAM=main
CONCOURSE_TARGET=int

CONCOURSE_URL=$(cat ${SECRETS_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-target:"|cut -d' ' -f2)
CONCOURSE_USERNAME=$(cat ${SECRETS_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-username:"|cut -d' ' -f2) # credential_leak_validated
CONCOURSE_PASSWORD=$(cat ${SECRETS_DIR}/coa/config/credentials-auto-init.yml|grep -e "^concourse-micro-depls-password:"|cut -d' ' -f2) # credential_leak_validated

${FLY} -t ${CONCOURSE_TARGET} login -u ${CONCOURSE_USERNAME} -p ${CONCOURSE_PASSWORD} -c ${CONCOURSE_URL} -k

CONCOURSE_CONFIG_FILES=$(ls ${SECRETS_DIR}/coa/config/*.yml| grep -v "\-pipeline.yml")

for VAR_FILE in ${CONCOURSE_CONFIG_FILES};do
 VAR_FILES="$VAR_FILES -l $VAR_FILE"
done

DIFF_FILE="${CREDENTIAL_FILE%%-generated.yml}-diff.yml"

#spruce merge $(dirname $0)/pipeline-vars-tpl.yml ${SECRETS_DIR}/shared/secrets.yml ${SECRETS_DIR}/micro-depls/release-mgmt/secrets/secrets.yml > $(dirname $0)/"private-pipeline-vars.yml"
#VAR_FILES="$VAR_FILES -l $(dirname $0)/private-pipeline-vars.yml"

#PIPELINE_NAME="release-management-test"
PIPELINE_NAME="coab-depls-model-migration-pipeline"
#--non-interactive
${FLY} -t ${CONCOURSE_TARGET} set-pipeline  --non-interactive \
  -p ${PIPELINE_NAME} -c "$(dirname $0)/model-migration-pipeline.yml" \
  -v concourse-url=${CONCOURSE_URL} \
  -v concourse-insecure="true" \
  ${VAR_FILES}
${FLY} -t ${CONCOURSE_TARGET} unpause-pipeline -p ${PIPELINE_NAME}
