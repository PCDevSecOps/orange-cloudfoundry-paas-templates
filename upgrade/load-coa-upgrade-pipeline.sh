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
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:" 1>&2
  printf "\n  %-40s %s" "--paas-templates-dir, -t \"path-to-paas-templates-dir\"" "Default: ${DEFAULT_PAAS_TEMPLATES_DIR}" 1>&2
  printf "\n  %-40s %s" "--secrets-dir, -s \"path-to-secrets-dir\"" "Default: ${DEFAULT_SECRETS_DIR}" 1>&2
  printf "\n  %-40s %s" "--skip-git-update, -g use this flag to skip git Secrets repository update" "- Default: ${SKIP_SECRETS_UPDATE}" 1>&2
  printf "\n  %-40s %s" "--update-paas-templates, -u use this flag to force Paas Templates repository update" "- Default: ${SKIP_PAAS_TEMPLATES_UPDATE}" 1>&2

  printf "\n  %-40s %s" "--skip-backup-pipeline, -b use this flag to skip pipeline backup when uploading a new version" "Default: ${DEFAULT_SECRETS_DIR}" 1>&2
  printf "%b\n\n" "${STD}" 1>&2
  exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-t"|"--paas-templates-dir")
      PAAS_TEMPLATES_DIR="$2"
      if [ "${PAAS_TEMPLATES_DIR}" = "" ] ; then
        usage
      fi
      shift ; shift ;;
    "-s"|"--secrets-dir")
        SECRETS_DIR="$2"
        if [ "${SECRETS_DIR}" = "" ] ; then
          usage
        fi
        shift ; shift ;;
    "-g"|"--skip-git-update")
        SKIP_SECRETS_UPDATE="true"
        shift ;;
    "-u"|"--update-paas-templates")
        SKIP_PAAS_TEMPLATES_UPDATE="false"
        shift ;;
    "-b"|"--skip-backup-pipeline")
        SKIP_PIPELINE_RENAME="true"
        shift ;;
    *) usage ;;
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
    exit 1
fi


if [[ "${SKIP_PAAS_TEMPLATES_UPDATE}" = "false" ]];then
    update_paas_templates
fi

if [[ "${SKIP_SECRETS_UPDATE}" = "false" ]];then
    update_secrets
fi


ENABLE_COA_UPGRADE_PIPELINE=$(bosh int "${PAAS_TEMPLATES_DIR}"/upgrade/metadata.yml --path /feature-flags/coa-upgrade-pipeline/enable 2>/dev/null)
if [ "$ENABLE_COA_UPGRADE_PIPELINE" = "false" ] || [ "$ENABLE_COA_UPGRADE_PIPELINE" = "False" ];then
  echo "WARNING: COA upgrade pipeline is disabled. Please update '${PAAS_TEMPLATES_DIR}/upgrade/upgrade-metadata.yml' file to enable"
  exit 0
fi

FLY=${FLY:-fly}
CONCOURSE_TEAM=main
#CONCOURSE_TARGET=automated-upgrade
if [ -z "${CONCOURSE_TARGET}" ]; then
 echo "Error: missing CONCOURSE_TARGET"
 exit
fi

CONCOURSE_CONFIG_FILES=$(ls $HOME/bosh/secrets/coa/config/*.yml| grep -v "\-pipeline.yml")
echo "select concourse vars files"
for VAR_FILE in ${CONCOURSE_CONFIG_FILES};do
 VAR_FILES="$VAR_FILES -l $VAR_FILE"
done

PIPELINE_NAME="${PIPELINE_NAME:-coa-upgrade}"
PIPELINE_TO_LOAD="${PIPELINE_TO_LOAD:-$HOME/bosh/template/upgrade/pipelines/coa-upgrade-pipeline.yml}"

echo "loading $PIPELINE_NAME using $PIPELINE_TO_LOAD"
${FLY} -t ${CONCOURSE_TARGET} set-pipeline --non-interactive \
  -p ${PIPELINE_NAME} -c ${PIPELINE_TO_LOAD} \
  -v concourse-url=${CONCOURSE_URL} \
  -v cf-ops-automation-version-static=${COA_VERSION} \
  -v concourse-insecure="true" \
  ${VAR_FILES}
${FLY} -t ${CONCOURSE_TARGET} unpause-pipeline -p ${PIPELINE_NAME}

#  -v concourse-admin.username=${CONCOURSE_USERNAME} \
#  -v concourse-admin.password=${CONCOURSE_PASSWORD} \

