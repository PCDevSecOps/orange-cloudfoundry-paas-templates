#!/bin/bash
#==========================================================================================
# Pause temporarly concourse pipelines
# Parameters :
# --exclude-pipelines, -e : Pause all pipelines except list (space separated)
#==========================================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

EXCLUDED_PIPELINES=""

#--- Check scripts options
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--exclude-pipelines, -e \"pipelines list\"" "Pause all pipelines except list (space separated)"
  printf "%b\n\n" "${STD}" ; exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-e"|"--exclude-pipelines")
      EXCLUDED_PIPELINES="$2"
      if [ "${EXCLUDED_PIPELINES}" = "" ] ; then
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

#--- Pause pipelines
TEAMS=$(fly -t concourse teams | head -n -1)
for team in ${TEAMS} ; do
  #--- Switch to team associated with pipeline
  fly -t concourse etg -n ${team} > /dev/null 2>&1

  #--- Check pipeline
  active_pipelines="$(fly -t concourse ps --json | jq -r '.[].name')"
  display "INFO" "Pause team \"${team}\" pipelines"
  for pipeline in ${active_pipelines} ; do
    status=$(echo " ${EXCLUDED_PIPELINES} " | grep " ${pipeline} ")
    if [ "${status}" = "" ] ; then
      printf " - %s\n" "${pipeline}"
      fly -t concourse pp -p ${pipeline} > /dev/null 2>&1
    fi
  done
done

printf "\n"