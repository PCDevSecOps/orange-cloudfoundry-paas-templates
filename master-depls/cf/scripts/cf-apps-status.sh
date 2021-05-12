#!/bin/bash
#=================================================================================
# Get all CF applications status from all CF organization
# To be used from docker-bosh-cli (use log-cf before executing this script)
#=================================================================================

#--- Colors and styles
export GREEN='\033[0;32m'
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'
export REVERSE='\033[7m'

display() {
	case "$1" in
  	"TITLE") printf "\n%b%s :\n%b" "${REVERSE}${YELLOW}" "$2" "${STD}" ;;
		"INFO") printf "%b%s...\n%b" "${YELLOW}" "$2" "${STD}" ;;
		"ERROR") printf "\n%b%s.\n\n%b" "${REVERSE}${RED}" "$2" "${STD}" ;;
	esac
}

cfCurl() {
  value=$(cf curl "$1")
  result=$(echo "${value}" | jq -r '.errors + .error_code')
  if [ "${result}" != "null" ] ; then
    display "ERROR" "\"cf curl $1\" failed"
    echo "${value}" | jq
    exit 1
  fi
}

#--- Verify cf log-in
cf config --locale en-US
ORG=$(cf orgs > /dev/null 2>&1)
if [ $? != 0 ] ; then
  display "ERROR" "Use \"log-cf\" tool to log-in"
  exit 1
fi

#--- Get all oroganizations
cfCurl "v3/organizations"
organizations=$(echo "${value}" | jq -r '.resources|.[]|.guid + "|" + .name')

for organization in ${organizations} ; do
  orgGuid=$(echo "${organization}" | cut -d'|' -f1)
  orgName=$(echo "${organization}" | cut -d'|' -f2)
  display "TITLE" "Organization \"${orgName}\""
  numPage=0
  nbPages=1

  while [ ${numPage} -lt ${nbPages} ] ; do
    ((numPage++))
    cfCurl "v3/apps?organization_guids=${orgGuid}&page=${numPage}&per_page=1000"
    nbPages=$(echo "${value}" | jq -r '.pagination|.total_pages')
    appsStatus=$(echo "${value}" | jq -r '.resources|.[]|.state')
    nbAppsTotal=$(echo "${appsStatus}" | wc -w)
    nbAppsStarted=$(echo "${appsStatus}" | grep "STARTED" | wc -w)
    nbAppsStopped=$(echo "${appsStatus}" | grep "STOPPED" | wc -w)
    if [ ${nbAppsTotal} = 0 ] ; then
      printf "Apps total   : %b${nbAppsTotal}%b\n" "${RED}" "${STD}"
    else
      if [ ${nbAppsStopped} = 0 ] ; then
        printf "Apps started : %b${nbAppsStarted}%b\n" "${GREEN}" "${STD}"
      else
        printf "Apps started : %b${nbAppsStarted}%b\nApps stopped : %b${nbAppsStopped}%b\n" "${YELLOW}" "${STD}" "${RED}" "${STD}"
      fi
    fi
  done
done
printf "\n"