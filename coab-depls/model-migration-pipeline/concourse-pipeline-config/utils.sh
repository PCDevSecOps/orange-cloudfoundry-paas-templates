#!/bin/bash
trigger_job() {
  team=$1
  pipeline=$2
  job=$3
  logs_dir=${4:-logs}
  FLY_BIN=${FLY:-fly}
  echo "TJ ! team: <$team> pipeline: <$pipeline> job: <$job>"
  $FLY_BIN -t $FLY_TARGET unpause-job -j $pipeline/$job --team $team
  pending_jobs=$($FLY_BIN -t "${FLY_TARGET}" curl /api/v1/teams/$team/pipelines/$pipeline/jobs/$job/builds -- -s -S -L -k|jq '.[]?|select(.status=="pending" or .status=="started")'|wc -l)
  if [ ! -d $logs_dir ]; then
    echo "ERROR: logs dir (<$logs_dir>) does not exist"
    exit 1
  fi
  if [ $pending_jobs -eq 0 ];then
    $FLY_BIN -t $FLY_TARGET tj -j $pipeline/$job --team $team -w 2>&1 >$logs_dir/trigger-job-$job.log &
  else
    echo "Job already running - skipping'$command'"
  fi
}

upgrade_one_instance_per_service(){
  logs_dir=../logs
  services=$(git --no-pager log --date=format:'%Y-%m-%d %H:%M:%S' --grep "generated manifest auto update" --grep ".*deploy-[a-zA-Z][-|_].*" --all-match --pretty=format:"%b%n" coab-depls|cut -c49-|cut -d'/' -f1|cut -c-8|sort|uniq)
  for s in $(echo $services); do
    echo "Processing $s services";
    deployed_services=$(git --no-pager log --date=format:'%Y-%m-%d-%H:%M:%S' --grep "generated manifest auto update" --grep ".*${s}[-|_].*\/1 \-.*" --all-match --pretty=tformat:"%cd/%b" coab-depls|cut -d'/' -f1,4);

    service_name=""
    service_creation_date=""
    service_job_name=""
    for candidate in $(echo $deployed_services);do
      echo "> $candidate";
      service_candidate_creation_date=$(echo $candidate|cut -d'/' -f1)
      service_candidate_job_name=$(echo $candidate|cut -d'/' -f2)
      service_candidate_name="${service_candidate_job_name##deploy-}"
      service_paas_template_version_raw=$(grep -E '^  paas_templates_version:' ${BASE_DIR}/${service_candidate_name}/${service_candidate_name}.yml 2>/dev/null|cut -d':' -f2 2>/dev/null)
      service_paas_template_version=${service_paas_template_version_raw## } # remove leading space
      if [ -e "${BASE_DIR}/${service_candidate_name}/enable-deployment.yml" ] && [ -e "${BASE_DIR}/${service_candidate_name}/${service_candidate_name}.yml" ] && [ "$PAAS_TEMPLATES_VERSION" != "$service_paas_template_version" ]; then
        service_creation_date=$service_candidate_creation_date
        service_job_name=$service_candidate_job_name
        service_name=$service_candidate_name
        echo "Found an active deployment: ${service_job_name}"
        break
      else
        if [ "$PAAS_TEMPLATES_VERSION" = "$service_paas_template_version" ]; then
          echo "Continue searching, ${service_candidate_name} already updated to expected Paas Templates version: '$PAAS_TEMPLATES_VERSION' "
        else
          echo "Continue searching, ${service_candidate_name} has been deleted, or does not match criteria (Expected Paas Templates version: '$PAAS_TEMPLATES_VERSION'. Service Paas Templates current version: '$service_paas_template_version')."
        fi
      fi
    done

    if [[ -z "$service_name" ]] || [[ -z "$service_creation_date" ]] || [[ -z "$service_job_name" ]];then
      echo "#####################################################";
      echo "WARNING - No active deployment of type $s found !"
      echo "#####################################################";
      continue
    fi
    echo "Found $service_name"
    trigger_job $TEAM $PIPELINE $service_job_name $logs_dir
    echo "$PIPELINE/$service_job_name" >> ../$WATCHED_JOBS_FILEPATH
    echo "######";
  done
}


wait_for_job_ends() {
  running_fly=$(ps --no-headers -o pid= -C fly)
  echo "Waiting for models triggering to end. (Running jobs count:  $(echo $running_fly|wc -w))"
  while [ -n "$running_fly" ]; do
    for pid in $(ps --no-headers -o pid= -C fly); do
      echo "waiting for process $pid to end"
      wait $pid
      echo "process $pid ended"
    done
    running_fly=$(ps --no-headers -o pid= -C fly)
    echo "Still waiting for models triggering to end. (Running jobs count : $(echo $running_fly|wc -w))"
  done
  echo "Jobs triggering ended"
}

