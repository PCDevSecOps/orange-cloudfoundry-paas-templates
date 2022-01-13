#!/bin/sh
#===========================================================================
# Re-trigger failed concourse jobs
#===========================================================================

# We cannot use admin/function.sh due to 'set -E' cmd, not compatible with curl-ssl image
#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export ORANGE='\033[0;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'
export BLINK='\033[5m'


DEFAULT_SECRETS_PATH="${SECRETS_REPO_DIR}"
DEFAULT_TEMPLATES_PATH="${TEMPLATE_REPO_DIR}"
FLY_BIN=${FLY:-fly}
DEFAULT_FLY_TARGET="concourse"
FLY_TARGET="${DEFAULT_FLY_TARGET}"
DEFAULT_EXCLUDED_PIPELINE="sync-feature-branches coab-depls-bosh-generated coab-depls-model-migration-pipeline paas-templates-.*-upgrade"
DEFAULT_EXCLUDED_JOBS="approve-and-delete-disabled-deployments"

DEFAULT_POOL_SIZE=10

dry_run="false"
pool_size=${DEFAULT_POOL_SIZE}
excluded_pipelines="${DEFAULT_EXCLUDED_PIPELINE}"
included_pipelines=""
excluded_jobs="$DEFAULT_EXCLUDED_JOBS"
append_excluded_pipelines=""

usage(){
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-15s %s" "-i \"pipelines\"" "Space separated included pipelines list (default: All pipelines)"
  printf "\n  %-15s %s" "-x \"pipelines\"" "Space separated excluded pipelines list (default: ${DEFAULT_EXCLUDED_PIPELINE})"
  printf "\n  %-15s %s" "-a \"pipelines\"" "Space separated excluded pipelines list to append to default (default: ${DEFAULT_EXCLUDED_PIPELINE})"
  printf "\n  %-15s %s" "-j \"jobs\"" "Space separated excluded jobs list (default: ${DEFAULT_EXCLUDED_JOBS})"
  printf "\n  %-15s %s" "-d" "\"Dry run\" mode (default: disabled)"
  printf "\n  %-15s %s" "-t \"target\"" "Concourse target to use (default: ${DEFAULT_FLY_TARGET})"
  printf "\n  %-15s %s" "-z" "Number of jobs launched in parallel (default: ${DEFAULT_POOL_SIZE})"
  printf "%b\n\n" "${STD}" ; exit 1
}

while getopts "i:x:dt:z:hj:a:" option ; do
  case "${option}" in
    i) included_pipelines="${OPTARG}" ;;
    x) excluded_pipelines="${OPTARG}" ;;
    a) append_excluded_pipelines="${OPTARG}" ;;
    j) excluded_jobs="${OPTARG}" ;;
    d) dry_run="true" ;;
    t) FLY_TARGET="${OPTARG}" ;;
    z) pool_size=${OPTARG} ;;
    h) usage ;;
    *) usage;;
  esac
done

if [ "${dry_run}" = "true" ] ; then
  printf "\n\n%b/!\ Dry_run mode : enabled%b\n" "${YELLOW}" "${STD}"
fi

start_date="$(date)"
excluded_pipelines="$excluded_pipelines $append_excluded_pipelines"
paused_pipelines=$(${FLY_BIN} -t "${FLY_TARGET}" curl api/v1/pipelines -- -s -S -L -k| jq -r '.[]|select(.paused == true)|.name')
paused_pipelines="${paused_pipelines} ${excluded_pipelines}"

all_unsuccessful_jobs="$(${FLY_BIN} -t "${FLY_TARGET}" curl /api/v1/jobs -- -s -S -L -k| jq --arg fly_target ${FLY_TARGET} --arg fly_bin ${FLY_BIN} '.[]?|select(has("paused")|not)|.finished_build|select(.status != "succeeded")|select(values)| {"pipeline": .pipeline_name, "job_name": .job_name,"cmd": "\($fly_bin) -t \($fly_target) tj --team \(.team_name) -j \(.pipeline_name)/\(.job_name)"}')"
if [ -n "${included_pipelines}" ] ; then
  unsuccessful_jobs=""
  for pipeline in ${included_pipelines} ; do
    included_jobs=$(echo "${all_unsuccessful_jobs}" | jq --arg pipeline "${pipeline}" 'select(.pipeline == $pipeline)')
    unsuccessful_jobs="${unsuccessful_jobs}${included_jobs}"
  done
else
  unsuccessful_jobs="${all_unsuccessful_jobs}"
fi
if [ -z "${all_unsuccessful_jobs}" ] ; then
  echo "INFO: No unsuccessful jobs detected" ; exit 0
fi

echo "Potential jobs count: $(echo "${all_unsuccessful_jobs}" | jq '.pipeline' | wc -l)"
for pipeline in ${paused_pipelines} ; do
  jq_cmd="select(.pipeline|test(\"^${pipeline}$\";\"\")|not)"
  filtered_jobs=$(echo ${unsuccessful_jobs} | jq $jq_cmd)
  unsuccessful_jobs=$filtered_jobs
  echo "Excluded jobs from '${pipeline}' pipeline. Remaining jobs count: $(echo ${unsuccessful_jobs} | jq '.pipeline' | wc -l)"
done
echo "Excluding specific jobs: $excluded_jobs"

for job in ${excluded_jobs}; do
  unsuccessful_jobs=$(echo $unsuccessful_jobs|jq --arg job "${job}" 'select(.job_name == $job|not)')
done
echo "Remaining jobs count (ie: non paused jobs, non paused pipelines, non excluded pipelines, non excluded jobs): $(echo ${unsuccessful_jobs} | jq '.pipeline' | wc -l)"

total_jobs_counter=0
retriggered_jobs_counter=0
already_running_jobs_counter=0

old_IFS=${IFS}
IFS='
'
for command in $(echo "${unsuccessful_jobs}" | jq -r '.cmd' | sort) ; do
  team="$(echo "${command}" | cut -d' ' -f6)"
  pipeline_and_job="$(echo "${command}" | cut -d' ' -f8 | cut -d'"' -f1)"
  pipeline="$(echo "${pipeline_and_job}" | cut -d'/' -f1)"
  job="$(echo "${pipeline_and_job}" | cut -d'/' -f2)"
  pending_jobs=$(${FLY_BIN} -t "${FLY_TARGET}" curl "/api/v1/teams/${team}/pipelines/${pipeline}/jobs/${job}/builds" -- -s -S -L -k | jq '.[]?|select(.status=="pending" or .status=="started")' | wc -l)
  total_jobs_counter=$((total_jobs_counter + 1))
  if [ ${pending_jobs} -eq 0 ] ; then
    retriggered_jobs_counter=$((retriggered_jobs_counter + 1))
    if [ "${dry_run}" = "true" ] ; then
      echo "Executing ${command}"
    else
      eval ${command}
    fi
  else
    echo "Job already running - skipping ${command}"
    already_running_jobs_counter=$((already_running_jobs_counter + 1))
  fi
done
IFS=${old_IFS}

if [ "${dry_run}" = "true" ] ; then
  printf "\n%b/!\ Dry_run mode : enabled # remove -d to disable %b\n" "${YELLOW}" "${STD}"
fi

printf "\n\n%bSummary%b" "${REVERSE}${YELLOW}" "${STD}"
printf "\n%b- Total jobs count : ${total_jobs_counter}%b" "${YELLOW}" "${STD}"
printf "\n%b- Triggered        : ${retriggered_jobs_counter}%b" "${YELLOW}" "${STD}"
printf "\n%b- Running/Pending  : ${already_running_jobs_counter}%b" "${YELLOW}" "${STD}"
printf "\n%b- started at       : ${start_date}%b" "${YELLOW}" "${STD}"
printf "\n%b- ended at         : $(date)%b\n\n" "${YELLOW}" "${STD}"
printf "\n\n%b- skipped pipelines: \n${paused_pipelines}%b\n" "${YELLOW}" "${STD}"
