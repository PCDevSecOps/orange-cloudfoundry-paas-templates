#!/usr/bin/env bash

DEFAULT_PAAS_TEMPLATES_DIR=~/bosh/template
DEFAULT_SECRETS_DIR=~/bosh/secrets

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
    echo "Please clone paas-templates into ~/bosh/template"
    exit 1
fi

if ! [ -d ${DEFAULT_SECRETS_DIR} ];then
    echo "Please clone secrets into ~/bosh/secrets"
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

for p in ${PIPELINE_NAMES};do
    echo "Processing pipeline $p"
    update-credhub-value "${CREDHUB_PREFIX}/${p}" credhub-secret "${CREDHUB_CLIENT_SECRET}"
    update-credhub-value "${CREDHUB_PREFIX}/${p}" paas-templates-reference-branch "${PT_REFERENCE_BRANCH}" ${redacted_value}
    update-credhub-value "${CREDHUB_PREFIX}/${p}" stemcell-version "${STEMCELL_MICRO}" ${redacted_value}
done
