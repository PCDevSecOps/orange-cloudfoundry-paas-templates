#!/usr/bin/env bash

DEFAULT_PAAS_TEMPLATES_DIR=$HOME/bosh/template
DEFAULT_SECRETS_DIR=$HOME/bosh/secrets

set -e

. $(dirname $0)/common.sh

usage(){
    echo "$0" 1>&2
    exit 1
}

SKIP_PIPELINE_RENAME="false"
SKIP_PAAS_TEMPLATES_UPDATE="false"
SKIP_SECRETS_UPDATE="false"
SKIP_FLY_SYNC="false"

while getopts "h" option; do
    case "${option}" in
        h)
            usage
            ;;
        *)
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
    esac
done

if ! [ -d ${DEFAULT_PAAS_TEMPLATES_DIR} ];then
    echo "Please clone paas-templates into $HOME/bosh/template"
    exit 1
fi

if ! [ -d ${DEFAULT_SECRETS_DIR} ];then
    echo "Please clone secrets into $HOME/bosh/secrets"
    exit 1
fi

SECRETS_DIR=${DEFAULT_SECRETS_DIR}
PAAS_TEMPLATES_DIR=${DEFAULT_PAAS_TEMPLATES_DIR}

PT_REFERENCE_BRANCH=$(cat ${SECRETS_DIR}/coa/config/credentials-sync-feature-branches-pipeline.yml|grep -e "^paas-templates-reference-branch:"|cut -d' ' -f2)
STEMCELL_MICRO=$(cat ${PAAS_TEMPLATES_DIR}/micro-depls/micro-depls-versions.yml|grep -e "^stemcell-version:"|cut -d' ' -f2|cut -d'"' -f2)

CREDHUB_CLIENT_SECRET=$(credhub-get /secrets/bosh_credhub_secrets)
IAAS_TYPE=$(credhub-get /secrets/iaas_type)

CREDHUB_PREFIX="/concourse-micro/main"

set +e
redacted_value="false"

PUBLIC_DOCKER_REGISTRY="registry.hub.docker.com"
DOCKER_REGISTRY=$(ruby -ryaml -e 'filename=ARGV[0]; secrets = YAML.load_file(filename) || {};puts secrets.dig("secrets","coa","config","docker-registry-url")' ${SECRETS_DIR}/shared/secrets.yml)

if [[ -z ${DOCKER_REGISTRY} ]];then
    DOCKER_REGISTRY_CREDENTIALS_FILE=${SECRETS_DIR}/coa/config/credentials-docker-registry.yml #DO NOT use " otherwise ~/ is not resolved
    if [[ -e ${DOCKER_REGISTRY_CREDENTIALS_FILE} ]]; then
        DOCKER_REGISTRY=$(cat ${DOCKER_REGISTRY_CREDENTIALS_FILE}|grep -e "^docker-registry-url:"|cut -d' ' -f2)
        echo "Using docker registry url defined in credentials (ie ${DOCKER_REGISTRY_CREDENTIALS_FILE})"
    fi
else
    echo "Using docker registry url defined in shared/secrets.yml"
fi

if [[ -z ${DOCKER_REGISTRY} ]];then
    DOCKER_REGISTRY=${PUBLIC_DOCKER_REGISTRY}
    echo "Using PUBLIC docker registry url (ie ${PUBLIC_DOCKER_REGISTRY})"
fi

update-credhub-value "${CREDHUB_PREFIX}/init-upgrade-pipelines" docker-registry-url "${DOCKER_REGISTRY}" ${redacted_value}

for p in ${PIPELINE_NAMES};do
    echo "Processing pipeline $p"
    update-credhub-value "${CREDHUB_PREFIX}/${p}" credhub-secret "${CREDHUB_CLIENT_SECRET}"
    update-credhub-value "${CREDHUB_PREFIX}/${p}" paas-templates-reference-branch "${PT_REFERENCE_BRANCH}" ${redacted_value}
    update-credhub-value "${CREDHUB_PREFIX}/${p}" stemcell-version "${STEMCELL_MICRO}" ${redacted_value}
done
