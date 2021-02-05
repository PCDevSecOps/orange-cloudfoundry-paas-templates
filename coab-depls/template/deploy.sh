#!/bin/bash
#===========================================================================
# Upload bosh releases not available in bosh.io
#===========================================================================

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

uploadRelease() {
  DOWLOAD_TYPE="$1"
  BOSH_RELEASE_NAME="$2"
  BOSH_RELEASE_URL="$3"
  BOSH_RELEASE_VERSION="$4"

  #--- Check if bosh release is loaded
  status=$(echo "${BOSH_RELEASES_LIST}" | grep "${BOSH_RELEASE_NAME}:${BOSH_RELEASE_VERSION}")
  if [ "${status}" != "" ] ; then
    printf "\n%bBosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\" already loaded...%b\n" "${YELLOW}" "${STD}"
  else
    printf "\n%bDownload bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
    case "${DOWLOAD_TYPE}" in
      "http")
        BOSH_RELEASE="$(echo "${BOSH_RELEASE_URL}" | sed -e "s+.*/++g")${BOSH_RELEASE_VERSION}"
        curl ${BOSH_RELEASE_URL}${BOSH_RELEASE_VERSION} -L -s -o ${BOSH_RELEASE}
        if [ $? != 0 ] ; then
          rm -fr ${BOSH_RELEASE} > /dev/null 2>&1
          printf "\n%bERROR: Download bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\" failed.%b\n\n" "${RED}" "${STD}" ; exit 1
        fi ;;

      "git")
        GIT_TAG="$5"
        CLONE_DIR="$(echo "${BOSH_RELEASE_URL}" | sed -e "s+.*/++g")"
        BOSH_RELEASE="releases/${BOSH_RELEASE_NAME}/${BOSH_RELEASE_NAME}-${BOSH_RELEASE_VERSION}.yml"
        git clone -b ${GIT_TAG} ${BOSH_RELEASE_URL}.git > /dev/null 2>&1
        if [ $? != 0 ] ; then
          cd .. ; rm -fr ${CLONE_DIR} > /dev/null 2>&1
          printf "\n%bERROR: Download bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\" failed.%b\n\n" "${RED}" "${STD}" ; exit 1
        fi
        cd ${CLONE_DIR} ;;

      "tgz")
        BOSH_RELEASE="$(echo "${BOSH_RELEASE_URL}" | sed -e "s+.*/++g")"
        curl ${BOSH_RELEASE_URL} -L -s -o ${BOSH_RELEASE}
        if [ $? != 0 ] ; then
          rm -fr ${BOSH_RELEASE} > /dev/null 2>&1
          printf "\n%bERROR: Download bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\" failed.%b\n\n" "${RED}" "${STD}" ; exit 1
        fi ;;

      *) printf "\n%bERROR: Download type \"${DOWLOAD_TYPE}\" unknown.%b\n\n" "${RED}" "${STD}" ; exit 1 ;;
    esac

    printf "\n%bUpload bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
    bosh -n upload-release ${BOSH_RELEASE}
    if [ $? != 0 ] ; then
      rm -f ${BOSH_RELEASE} > /dev/null 2>&1
      cd .. ; rm -fr ${CLONE_DIR} > /dev/null 2>&1
      printf "\n%bERROR: Upload bosh release \"${BOSH_RELEASE_NAME}\" version \"${BOSH_RELEASE_VERSION}\" failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
    rm -f ${BOSH_RELEASE} > /dev/null 2>&1
    cd .. ; rm -fr ${CLONE_DIR} > /dev/null 2>&1
  fi
}

#--- Install curl
printf "\n%bInstall curl tool...%b\n" "${YELLOW}" "${STD}"
apt-get update
apt-get install -y --no-install-recommends curl
if [ $? != 0 ] ; then
  printf "\n%bERROR: Install curl failed.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Check bosh loaded releases
printf "\n%bBosh release already loaded...%b\n" "${YELLOW}" "${STD}"
BOSH_RELEASES_LIST=$(bosh releases --json | sed 's/ //g' | sed 's/\"//g' | sed 's/,//g' | sed 's/*/ /g' | grep -E "name:|version:" | grep -vE "name:Name|version:Version" | awk -F ":" '{if($1 == "name") {name=$2} ; if($1 == "version") {print name ":" $2}}')
echo "${BOSH_RELEASES_LIST}"

uploadRelease "git" "cf-mysql" "https://github.com/orange-cloudfoundry/cf-mysql-release" "37.1.0" "37.1.0"

#--- Disable resurection for mysql extended "t_" and redis extended "s_" instances
ACTIVE_BOSH_DEPLOYMENTS=$(bosh deployments --json | sed 's/ //g' | sed 's/\"//g' | sed 's/,//g' | sed 's/*/ /g' | grep "name:" | awk -F ":" '{print $2}' | grep -v "Name")
DISABLE_RESURECTOR_DEPLOYMENTS=$(echo "${ACTIVE_BOSH_DEPLOYMENTS}" | grep -E '^t_|^s_')

if [ "${DISABLE_RESURECTOR_DEPLOYMENTS}" != "" ] ; then
  #--- Initalize resurrection config file
  RESURRECTION_FILE="$(pwd)/resurrection.yml"
cat > ${RESURRECTION_FILE} <<'EOF'
rules:
- enabled: false
  include:
    deployments:
EOF

  #--- Add deployments to exclude from resurrection
  printf "\n%bDisable resurection for...%b" "${YELLOW}" "${STD}"
  for deployment in ${DISABLE_RESURECTOR_DEPLOYMENTS} ; do
    printf "\n=> ${deployment}"
    printf "    - ${deployment}\n" >> ${RESURRECTION_FILE}
  done
  printf "\n"

  bosh update-config -n --type resurrection --name default ${RESURRECTION_FILE} > /dev/null 2>&1
  rm -f ${RESURRECTION_FILE} > /dev/null 2>&1
fi