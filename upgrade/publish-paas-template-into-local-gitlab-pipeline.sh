#!/usr/bin/env bash

DEFAULT_PAAS_TEMPLATES_DIR=~/bosh/template
DEFAULT_SECRETS_DIR=~/bosh/secrets
SECRETS_DIR=""
PAAS_TEMPLATES_DIR=""
SKIP_PIPELINE_RENAME="false"
SKIP_PAAS_TEMPLATES_UPDATE="false"
SKIP_SECRETS_UPDATE="false"

set -e
. $(dirname $0)/scripts/common.sh

usage(){
  printf "\n%bUSAGE:" "${BOLD}" 1>&2
  printf "\n  $(basename -- $0) -v <X.Y.Z> [OPTIONS]\n\nOPTIONS:" 1>&2
  printf "\n  %-40s %s" "-v  <X.Y.Z> paas-templates version to install" " - Default: value read from meta-inf.yml" 1>&2
  printf "\n  %-40s %s" "-t \"path-to-paas-templates-dir\"" "Default: ${DEFAULT_PAAS_TEMPLATES_DIR}" 1>&2
  printf "\n  %-40s %s" "-s \"path-to-secrets-dir\"" "Default: ${DEFAULT_SECRETS_DIR}" 1>&2
  printf "\n  %-40s %s" "-g use this flag to skip git repository update" "Default: ${SKIP_PAAS_TEMPLATES_UPDATE}" 1>&2
  printf "%b\n\n" "${STD}" 1>&2
  exit 1
}

while getopts "v:t:s:gh" option; do
    case "${option}" in
        v)
            PAAS_TEMPLATES_VERSION=$OPTARG
            ;;
        t)
            PAAS_TEMPLATES_DIR=$OPTARG
            ;;
        s)
            SECRETS_DIR=$OPTARG
            ;;
        g)
            SKIP_PAAS_TEMPLATES_UPDATE="true"
            SKIP_SECRETS_UPDATE="true"
            ;;
        h)
            usage
            ;;
        *)
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
    esac
done
if [ -z "${PAAS_TEMPLATES_DIR}" ];then
    PAAS_TEMPLATES_DIR=${DEFAULT_PAAS_TEMPLATES_DIR}
fi

if [ -z "${SECRETS_DIR}" ];then
    SECRETS_DIR=${DEFAULT_SECRETS_DIR}
fi

if ! [ -d "${PAAS_TEMPLATES_DIR}" ];then
    echo "Please clone paas-templates into ~/bosh/template or to another dir using -t <dir>"
    exit 1
echo
fi

if ! [ -d "${SECRETS_DIR}" ];then
    echo "Please clone secrets into ~/bosh/secrets or to another dir using -s <dir> "
    exit 1
fi

if [[ "$PAAS_TEMPLATES_VERSION" = "" ]];then
    PAAS_TEMPLATES_VERSION=$(grep -e '[ ]*paas-templates:' ${PAAS_TEMPLATES_DIR}/meta-inf.yml|cut -d':' -f2|tr -d [:blank:])
fi
validate_version ${PAAS_TEMPLATES_VERSION}


if [[ "${SKIP_PAAS_TEMPLATES_UPDATE}" = "false" ]];then
    update_paas_templates
fi

if [[ "${SKIP_SECRETS_UPDATE}" = "false" ]];then
    update_secrets
fi


LOCAL_GITLAB_URL=$(cat ${SECRETS_DIR}/coa/config/credentials-git-config.yml|grep -e "^paas-templates-uri:"|cut -d' ' -f2)
GIT_CURRENT_BRANCH_NAME=$(git branch --contains HEAD | tail -1 | xargs|cut -c3-)
GIT_TARGET_BRANCH_NAME="pre-install-v${PAAS_TEMPLATES_VERSION}"

git_remote_add "$HOME/bosh/template" automated-install ${LOCAL_GITLAB_URL}

git_push "$HOME/bosh/template" automated-install ${GIT_TARGET_BRANCH_NAME}
echo "=== Install summary ==="
echo "You are going to install '$GIT_CURRENT_BRANCH_NAME' to '$GIT_TARGET_BRANCH_NAME'"
echo "'$GIT_TARGET_BRANCH_NAME' is going to be your working branch on docker bosh cli"

