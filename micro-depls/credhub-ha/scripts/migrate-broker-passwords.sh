#!/bin/bash
#===========================================================================
# Migrate broker password from legacies paths
#                           CAUTION
# THIS SCRIPT ONLY WORKS IF THERE IS ONLY ONE INSTANCE OF credhub backend !!
#===========================================================================

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

getCredhub() {
  credhubGet=$(credhub g -n $2 -j | jq .value -r)
  if [ $? = 0 ] ; then
    eval $1='$(echo "${credhubGet}")'
  else
    printf "\n\n%bERROR : \"$2\" credhub value unknown.%b\n\n" "${RED}" "${STD}"
  fi
}

#--- Log to credhub
flagError=0
flag=$(credhub f > /dev/null 2>&1)
if [ $? != 0 ] ; then
  printf "%bEnter CF LDAP user and password :%b\n" "${REVERSE}${YELLOW}" "${STD}"
  credhub api --server=https://credhub.internal.paas:8844 > /dev/null 2>&1
  credhub login
  if [ $? != 0 ] ; then
    printf "\n%bERROR : Bad LDAP authentication.%b\n\n" "${RED}" "${STD}"
    flagError=1
  fi
fi

#--- Process input file in order to migrate values
if [ "${flagError}" = "0" ] ; then
    for line in $(cat path.lst); do
        SOURCE_BROKER_PASSWORD_PATH=$(echo "$line" | cut -d'|' -f1);echo ${SOURCE_BROKER_PASSWORD_PATH};
        TARGET_BROKER_PASSWORD_PATH=$(echo "$line" | cut -d'|' -f2);echo ${TARGET_BROKER_PASSWORD_PATH};
        getCredhub "SOURCE_BROKER_PASSWORD_VALUE" ${SOURCE_BROKER_PASSWORD_PATH}
        echo "migrate ${SOURCE_BROKER_PASSWORD_VALUE} value from ${SOURCE_BROKER_PASSWORD_PATH} to ${TARGET_BROKER_PASSWORD_PATH}"
        credhub generate --name ${TARGET_BROKER_PASSWORD_PATH} --type password
        credhub set --name ${TARGET_BROKER_PASSWORD_PATH} --type password --password ${SOURCE_BROKER_PASSWORD_VALUE}
    done
fi