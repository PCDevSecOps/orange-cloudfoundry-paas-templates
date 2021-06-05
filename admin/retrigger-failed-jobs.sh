#!/bin/bash

DEFAULT_SECRETS_PATH=~/bosh/secrets
DEFAULT_TEMPLATES_PATH=~/bosh/template
DEFAULT_FLY_TARGET="concourse"
FLY_TARGET="$DEFAULT_FLY_TARGET"
DEFAULT_EXCLUDED_PIPELINE="sync-feature-branches"
DEFAULT_POOL_SIZE=10

usage(){
    echo "$0 [-i <included-pipeline-list>] [-x <excluded-pipeline-list>] [-t <concourse-target>] [-d] [-w] [-z <pool-size>]" 1>&2
    echo -e "\t -i \"<included-pipeline-list>\". Space separated list of root deployments - Default: empty (i.e: all pipelines" 1>&2
    echo -e "\t -x \"<excluded-pipelines-list>\". Space separated list of exluded pipeline - Default: $DEFAULT_EXCLUDED_PIPELINE" 1>&2
    echo -e "\t -t <concourse-target>. Concourse target to use - Default: $DEFAULT_FLY_TARGET" 1>&2
    echo -e "\t -d dry run mode. Default is disabled" 1>&2
    echo -e "\t -w launch jobs by group of $pool_size in parallel. Default : disabled" 1>&2
    echo -e "\t -z define the number of jobs per group - Default: $DEFAULT_POOL_SIZE but only used with '-w' is enabled" 1>&2
    exit 1
}

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

interactive_mode="true"
dry_run="false"
FLY_BIN=${FLY:-fly}
pool_size=10
wait_x="false"
excluded_pipelines=$DEFAULT_EXCLUDED_PIPELINE
included_pipelines=""
while getopts "r:t:z:x:i:fhrwd" option; do
    case "${option}" in
        x)
            excluded_pipelines=$OPTARG
            ;;
        i)
            included_pipelines=$OPTARG
            ;;
        t)
            FLY_TARGET=$OPTARG
            ;;
        w)
            wait_x="true"
            ;;
        z)
            pool_size=$OPTARG
            ;;
        d)
            dry_run="true"
            ;;
        \?)
          echo "Invalid option: $OPTARG" >&2
          usage
          ;;
        h | *)
            usage
            ;;
    esac
done

start_date="$(date)"
paused_pipelines=$($FLY_BIN -t "${FLY_TARGET}" curl api/v1/pipelines -- -s -S -L|jq -r '.[]|select(.paused == true)|.name')
paused_pipelines="$paused_pipelines $excluded_pipelines"
all_unsuccessful_jobs=$($FLY_BIN -t "${FLY_TARGET}" curl /api/v1/jobs -- -s -S -L|jq --arg fly_target ${FLY_TARGET} --arg fly_bin ${FLY_BIN} '.[]?|select(has("paused")|not)|.finished_build|select(.status != "succeeded")|select(values)| {"pipeline": .pipeline_name, "cmd": "\($fly_bin) -t \($fly_target) tj --team \(.team_name) -j \(.pipeline_name)/\(.job_name)"}')
if [ -n "$included_pipelines" ]; then
  unsuccessful_jobs=""
  for pipeline in $included_pipelines;do
    included_jobs=$(echo $all_unsuccessful_jobs|jq --arg pipeline "$pipeline" 'select(.pipeline == $pipeline)')
    unsuccessful_jobs="$unsuccessful_jobs$included_jobs"
  done
else
  unsuccessful_jobs=$all_unsuccessful_jobs
fi
if [ -z "$all_unsuccessful_jobs" ]; then
  echo "INFO - No unsuccessful jobs detected"
  exit 0
fi

echo "Potential jobs count: $(echo $all_unsuccessful_jobs|jq '.pipeline'|wc -l)"
for pipeline in $paused_pipelines;do
  filtered_jobs=$(echo $unsuccessful_jobs|jq --arg pipeline "$pipeline" 'select(.pipeline == $pipeline|not)')
  unsuccessful_jobs=$filtered_jobs
  echo "excluded jobs from $pipeline. Remaining jobs count: $(echo $unsuccessful_jobs|jq '.pipeline'|wc -l)"
done

echo "Remaining jobs count (ie: non paused jobs, non paused pipelines, non excluded pipelines): $(echo $unsuccessful_jobs|jq '.pipeline'|wc -l)"

total_jobs_counter=0
retriggered_jobs_counter=0
already_running_jobs_counter=0

old_IFS=$IFS
IFS=$'\n'
for command in $(echo $unsuccessful_jobs|jq -r '.cmd'|sort)
do
  team="$(echo $command|cut -d' ' -f6)"
  pipeline_and_job="$(echo $command|cut -d' ' -f8|cut -d'"' -f1)"
  pipeline="$(echo $pipeline_and_job|cut -d'/' -f1)"
  job="$(echo $pipeline_and_job|cut -d'/' -f2)"
  pending_jobs=$($FLY_BIN -t "${FLY_TARGET}" curl /api/v1/teams/$team/pipelines/$pipeline/jobs/$job/builds -- -s -S -L|jq '.[]?|select(.status=="pending" or .status=="started")'|wc -l)
  total_jobs_counter=$((total_jobs_counter + 1))
  if [ $pending_jobs -eq 0 ];then
    retriggered_jobs_counter=$((retriggered_jobs_counter + 1))
    if [ "$dry_run" = "true" ];then
      echo "Executing '$command'"
    else
      eval $command
    fi
  else
      echo "Job already running - skipping'$command'"
    already_running_jobs_counter=$((already_running_jobs_counter + 1))
  fi
done
IFS=$old_IFS

echo "************************************"
echo "****          Summary           ****"
echo "************************************"
echo "* Total jobs count: $total_jobs_counter"
echo "* Triggered       : $retriggered_jobs_counter"
echo "* Running/Pending : $already_running_jobs_counter"
echo "*"
if [ "$dry_run" = "true" ];then
  echo "* /!\ Dry_run mode enabled"
  echo "*"
fi
echo "* started at $start_date"
echo "* ended at $(date)"
echo "************************************"
