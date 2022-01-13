#!/usr/bin/env bash

DEFAULT_PAAS_TEMPLATES_DIR=$HOME/bosh/template
DEFAULT_SECRETS_DIR=$HOME/bosh/secrets
SECRETS_DIR=""
PAAS_TEMPLATES_DIR=""
SKIP_PIPELINE_RENAME="false"
SKIP_PAAS_TEMPLATES_UPDATE="true"
SKIP_SECRETS_UPDATE="false"

set -e
. $(dirname $0)/common.sh

usage(){
  printf "\n%bUSAGE:" "${BOLD}" 1>&2
  printf "\n  $(basename -- $0) -v <X.Y.Z> [OPTIONS]\n\nOPTIONS:" 1>&2
  printf "\n  %-40s %s" "-v  <X.Y.Z> paas-templates version to install" " - Default: value read from meta-inf.yml" 1>&2
  printf "\n  %-40s %s" "-t \"path-to-paas-templates-dir\"" "- Default: ${DEFAULT_PAAS_TEMPLATES_DIR}" 1>&2
  printf "\n  %-40s %s" "-s \"path-to-secrets-dir\"" "- Default: ${DEFAULT_SECRETS_DIR}" 1>&2
  printf "\n  %-40s %s" "-g use this flag to skip git Secrets repository update" "- Default: ${SKIP_SECRETS_UPDATE}" 1>&2
  printf "\n  %-40s %s" "-u use this flag to force Paas Templates repository update" "- Default: ${SKIP_PAAS_TEMPLATES_UPDATE}" 1>&2
  printf "\n  %-40s %s" "-l url to gitlab " "- Default: <empty>, will use credhub" 1>&2
  printf "\n  %-40s %s" "-h display help message" 1>&2
  printf "%b\n\n" "${STD}" 1>&2
  exit 1
}

while getopts "v:t:s:ghul:" option; do
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
            SKIP_SECRETS_UPDATE="true"
            ;;
        u)
            SKIP_PAAS_TEMPLATES_UPDATE="false"
            ;;
        l)
            LOCAL_GITLAB_URL=$OPTARG
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
    echo "Please clone paas-templates into $HOME/bosh/template or to another dir using -t <dir>"
    exit 1
echo
fi

if ! [ -d "${SECRETS_DIR}" ];then
    echo "Please clone secrets into $HOME/bosh/secrets or to another dir using -s <dir> "
    usage
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

if [ -z "$LOCAL_GITLAB_URL" ]; then
  TMP_LOCAL_GITLAB_URL=$(cat ${SECRETS_DIR}/coa/config/credentials-git-config.yml|grep -e "^paas-templates-uri:"|cut -d' ' -f2)
  echo "Use credhub to expand git url: $TMP_LOCAL_GITLAB_URL"
  set +e
  cloudfoundry_ops_domain=$(credhub g -n /secrets/cloudfoundry_ops_domain -q 2>/dev/null)
  if [ -z "$cloudfoundry_ops_domain" ]; then
    echo "Please ensure credhub key '/secrets/cloudfoundry_ops_domain' is defined, and you are logged to credhub"
    usage
  fi
  set -e
  LOCAL_GITLAB_URL=$(echo $TMP_LOCAL_GITLAB_URL |sed -e "s+((cloudfoundry_ops_domain))+$cloudfoundry_ops_domain+")
else
  echo "Use provided Git url: $LOCAL_GITLAB_URL"
fi

GIT_CURRENT_BRANCH_NAME=$(git branch --contains HEAD | tail -1 | xargs|cut -c3-)
GIT_TARGET_BRANCH_NAME="pre-install-v${PAAS_TEMPLATES_VERSION}"

git_remote_add "$HOME/bosh/template" automated-install ${LOCAL_GITLAB_URL}

git_push "$HOME/bosh/template" automated-install ${GIT_TARGET_BRANCH_NAME}
echo "=== Install summary ==="
echo "You are going to install '$GIT_CURRENT_BRANCH_NAME' to '$GIT_TARGET_BRANCH_NAME'"
echo "'$GIT_TARGET_BRANCH_NAME' is going to be your working branch on docker bosh cli"

