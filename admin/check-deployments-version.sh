#!/bin/bash
#===========================================================================
# Check "paas-templates-version" tag in all bosh manifests from secrets repository
# usage : check-deployments-version.sh -s <SECRETS_PATH> -t <TAG_VALUE> -r <ROOT_DEPLOYMENT>
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
DEFAULT_ROOT_DEPLOYMENT="*-depls"
DEFAULT_TAG="latest"
TAG_NAME="paas_templates_version:"
FLAG_CONCOURSE=0
excluded_service_prefixes=""
excluded_models=""

usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-10s %s" "-r" "Root deployment (e.g: master-depls)"
  printf "\n  %-10s %s" "-s" "Secret repository path"
  printf "\n  %-10s %s" "-t" "Tag value (e.g: 51.0.5)"
  printf "\n  %-10s %s" "-x" "Exclude service prefix list (e.g: [x, y, z])"
  printf "\n  %-10s %s" "-m" "Exclude model list (e.g: [cf-mysql])"
  printf "%b\n\n" "${STD}"
  exit 1
}

while getopts "cr:s:t:x:m:h" option ; do
  case "${option}" in
    c) FLAG_CONCOURSE=1 ;;
    r) root_deployment=${OPTARG} ;;
    s) secrets_path=${OPTARG} ;;
    t) tag_value=${OPTARG} ;;
    x) excluded_service_prefixes=${OPTARG} ;;
    m) excluded_models=${OPTARG} ;;
    h) usage ;;
    *) break ;;
  esac
done

#--- Set default script properties
if [[ -z "${root_deployment}" ]] ; then
  root_deployment="${DEFAULT_ROOT_DEPLOYMENT}"
fi

if [[ -z "${secrets_path}" ]] ; then
  secrets_path="${SECRETS_REPO_DIR}"
fi

if [[ -z "${tag_value}" ]] ; then
  tag_value="${DEFAULT_TAG}"
fi

if [ ! -d ${secrets_path} ] ; then
  printf "\n%bERROR: \"${secrets_path}\" secrets path unknown%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Check deployments
if [ ${FLAG_CONCOURSE} = 0 ] ; then
  printf "\n%bCheck deployments on \"${root_deployment}\" without \"${tag_value}\" tag - Excluded models <$excluded_models> and excluded service instance prefixes: <$excluded_service_prefixes> ...%b\n" "${REVERSE}${YELLOW}" "${STD}"
fi
cd ${secrets_path}
paths_list="$(find . -maxdepth 2 -type d -wholename "./${root_deployment}/*" | sed -e "s+^\./++g")"
if [ "${paths_list}" = "" ] ; then
  printf "\n\n%bERROR: \"${root_deployment}\" root deployment path unknown%b\n\n" "${RED}" "${STD}" ; exit 1
fi

for path in ${paths_list} ; do
  deployment="$(basename ${path})"
  deployment_manifest="${path}/${deployment}.yml"
  deployment_service_type="${deployment:0:1}"
  deployment_service_separator="${deployment:1:1}"
#  echo "prefix: $deployment_service_type"

  if [[ "$deployment_service_separator" = "-" || "$deployment_service_separator" = "_"  ]];then
    # it is an instance, we apply service instance prefix filter
    exclusion_required="$(echo "$excluded_service_prefixes"|grep -c ${deployment_service_type}||true)"
    if [ "$exclusion_required" != "0" ] ; then
      continue
    fi
  else
    # it is a model, we apply model filter
    exclusion_required="$(echo "$excluded_models"|grep -c "${deployment}"||true)"
    if [ "$exclusion_required" != "0" ] ; then
      continue
    fi
  fi

  if [ -e ${path}/enable-deployment.yml ] ; then      #--- Deployment is enabled
    if [ -e ${deployment_manifest} ] ; then           #--- Deployment manifest exists
      result="$(grep "${TAG_NAME}" ${deployment_manifest})"
      if [ "${result}" = "" ] ; then                  #--- Check tag existence
        printf "\n${path}: %bunknown%b" "${RED}" "${STD}"
      else
        value=$(echo ${result} | cut -d' ' -f2)
        if [ "${value}" != "${tag_value}" ] ; then    #--- Check tag value
          printf "\n${path}: %b${value}%b" "${RED}" "${STD}"
        fi
      fi
    fi
  fi
done

if [ ${FLAG_CONCOURSE} = 0 ] ; then
  printf "\n"
fi