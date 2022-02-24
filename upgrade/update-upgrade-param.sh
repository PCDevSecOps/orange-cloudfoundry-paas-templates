#!/bin/bash

DEFAULT_PAAS_TEMPLATES_DIR=$HOME/bosh/template
DEFAULT_SECRETS_DIR=$HOME/bosh/secrets
FLY=~/bin/fly-5.3
FORCE_UPDATE="false"
set -e

. $(dirname $0)/common.sh

META_INF_YML_PATH=$(echo "$(dirname $0)/../meta-inf.yml")

usage(){
    echo "$0 -v <X.Y.Z> -c <X.Y.Z> -e <X.Y> -f" 1>&2
    echo "Update credhub versions used by pipelines." 1>&2
    echo -e "\t -v <version> paas templates version to upgrade to. Default: use version defined in $META_INF_YML_PATH" 1>&2
    echo -e "\t -c <version> cf-ops-automation version to upgrade to. Default: use version defined in $META_INF_YML_PATH " 1>&2
    echo -e "\t -f force update of Paas Templates version" 1>&2
    exit 1
}

PAAS_TEMPLATES_VERSION=""
CF_OPS_AUTOMATION_VERSION=""

while getopts "v:c:hf" option; do
    case "${option}" in
        v)
            PAAS_TEMPLATES_VERSION=$OPTARG
            ;;
        c)
            CF_OPS_AUTOMATION_VERSION=$OPTARG
            ;;
        h)
            usage
            ;;
        f)
            FORCE_UPDATE="true"
            ;;
        *)
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
    esac
done

if [[ -z "${PAAS_TEMPLATES_VERSION}" ]]; then
   PAAS_TEMPLATES_VERSION=$(ruby -ryaml -e 'yaml_file=ARGV[0]; yaml = YAML.load_file(yaml_file); puts yaml&.fetch("meta-inf",nil)&.fetch("versions",nil)&.fetch("paas-templates","")' ${META_INF_YML_PATH})
fi

if [[ -z "${CF_OPS_AUTOMATION_VERSION}" ]]; then
   CF_OPS_AUTOMATION_VERSION=$(ruby -ryaml -e 'yaml_file=ARGV[0]; yaml = YAML.load_file(yaml_file); puts yaml&.fetch("meta-inf",nil)&.fetch("versions",nil)&.fetch("cf-ops-automation","")' ${META_INF_YML_PATH})
fi

if [[ -z "${PAAS_TEMPLATES_VERSION}"  && -z "${CF_OPS_AUTOMATION_VERSION}" ]]; then
    usage
fi

log-credhub.sh


CREDHUB_PREFIX="/concourse-micro/main"

set +e
redacted_value="false"

echo "Setting Paas-templates version to $PAAS_TEMPLATES_VERSION"
if [ "$FORCE_UPDATE" = "false" ]; then
  current=$(credhub g -n "${CREDHUB_PREFIX}/paas-templates-version" -q 2>/dev/null)
  if [[ -n "$current" && "$current" != "latest" && "$PAAS_TEMPLATES_VERSION" != "latest" ]]; then
    if [[ "$current" != "$PAAS_TEMPLATES_VERSION" && "$current" > "$PAAS_TEMPLATES_VERSION" ]];then
      echo "ERROR: cannot update paas-templates to an older version. Current version is $current, requested version is $PAAS_TEMPLATES_VERSION."
      echo "    Please use '-f' option to force update or wait for concourse cache to expire"
      exit 1
    fi
  fi
else
  echo "INFO - force update activated, skipping increase version only check"
fi
update-credhub-value "${CREDHUB_PREFIX}" paas-templates-version "${PAAS_TEMPLATES_VERSION}" ${redacted_value}

echo "Setting COA version to $CF_OPS_AUTOMATION_VERSION"
update-credhub-value "${CREDHUB_PREFIX}" cf-ops-automation-version "${CF_OPS_AUTOMATION_VERSION}" ${redacted_value}

echo "=== Install summary ==="
echo "You are going to install: (from paas-templates/meta-inf.yml)"
echo "  - paas-templates: ${PAAS_TEMPLATES_VERSION}"
echo "  - cf-ops-automation: ${CF_OPS_AUTOMATION_VERSION}"
