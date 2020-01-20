#!/bin/bash
#==========================================================================================
# Pause temporarly concourse pipelines and jobs (except "cloud-config-and-runtime-config")
# Parameters :
# --exclude-jobs, -e : Pause all jobs except job list (space separated)
# --pipeline, -p     : Target pipelines (space separated) for pausing jobs (default: all directors pipelines)
#==========================================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Concourse pipelines where jobs will be paused
BOSH_PIPELINES="micro master ops coab kubo"

#--- Check prerequisites
verifyFile "${FLY_CREDENTIALS}"

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${BOLD}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--exclude-jobs, -e \"job list\"" "Pause all jobs except job list (space separated)"
  printf "\n  %-40s %s" "--pipeline, -p \"pipelines\"" "Target pipelines (space separated) for pausing jobs (micro master ops coab kubo)"
  printf "%b\n\n" "${STD}"
  exit 1
}

EXCLUDED_JOBS=""
PIPELINES=""

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-e"|"--exclude-jobs")
      EXCLUDED_JOBS="$2"
      if [ "${EXCLUDED_JOBS}" = "" ] ; then
        usage
      fi
      shift ; shift ;;
    "-p"|"--pipeline")
        PIPELINES="$2"
        if [ "${PIPELINES}" = "" ] ; then
          usage
        fi
        shift ; shift ;;
    *) usage ;;
  esac
done

#--- Log to concourse with fly cli
display "INFO" "Log to fly"
FLY_ENDPOINT="${FLY_ENDPOINT:-https://elpaaso-concourse.${OPS_DOMAIN}}"
export FLY_USER=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-username")
export FLY_PWD=$(getValue ${FLY_CREDENTIALS} "/concourse-micro-depls-password")

fly -t concourse login -c ${FLY_ENDPOINT} -k -u ${FLY_USER} -p ${FLY_PWD}

if [ "${PIPELINES}" != "" ] ; then
  BOSH_PIPELINES="${PIPELINES}"
fi

TEAMS=$(fly -t concourse teams | head -n -1)

#--- Pause pipelines and jobs
for bosh_pipeline in ${BOSH_PIPELINES} ; do
  team="${bosh_pipeline}-depls"
  status=$(echo "${TEAMS}" | grep "${team}")
  if [ "${status}" != "" ] ; then
    #--- Switch to team associated with pipeline
    fly -t concourse etg -n ${team} > /dev/null 2>&1
    
    #--- Check pipeline
    pipeline="${bosh_pipeline}-depls-bosh-generated"
    active_pipelines="$(fly -t concourse ps | awk '{printf(" %s ", $1)}')"
    status=$(echo " ${active_pipelines} " | grep " ${pipeline} ")
    if [ "${status}" != "" ] ; then
      display "INFO" "Pause pipeline \"${pipeline}\" jobs"
      activeJobs="$(fly -t concourse js -p ${pipeline} | awk '{print $1}')"
      EXCLUDED_JOBS="cloud-config-and-runtime-config-for-${bosh_pipeline}-depls execute-deploy-script init-concourse-boshrelease-and-stemcell-for-${bosh_pipeline}-depls ${EXCLUDED_JOBS}"
      for job in ${activeJobs} ; do
        status=$(echo " ${EXCLUDED_JOBS} " | grep " ${job} ")
        if [ "${status}" = "" ] ; then
          printf " - %s\n" "${job}"
          fly -t concourse pj -j ${pipeline}/${job} > /dev/null 2>&1
        fi
      done
    fi
  fi
done

printf "\n"