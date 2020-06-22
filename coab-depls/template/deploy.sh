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

#--- Http bosh releases
uploadRelease "http" "bosh-dns" "https://bosh.io/d/github.com/cloudfoundry/bosh-dns-release?v=" "1.17.0"
uploadRelease "http" "bpm" "https://bosh.io/d/github.com/cloudfoundry/bpm-release?v=" "1.1.8"
uploadRelease "http" "node-exporter" "https://bosh.io/d/github.com/cloudfoundry-community/node-exporter-boshrelease?v=" "4.2.0"
uploadRelease "http" "os-conf" "https://bosh.io/d/github.com/cloudfoundry/os-conf-release?v=" "21.0.0"
uploadRelease "http" "syslog" "https://bosh.io/d/github.com/cloudfoundry/syslog-release?v=" "11.6.0"

#--- Git bosh releases
uploadRelease "git" "bui" "https://github.com/cloudfoundry-community/bui-boshrelease" "1.0.3" "v1.0.3"
uploadRelease "git" "cassandra" "https://github.com/orange-cloudfoundry/cassandra-cf-service-boshrelease" "12" "v12"
uploadRelease "git" "generic-scripting" "https://github.com/orange-cloudfoundry/generic-scripting-release" "3" "v3"
uploadRelease "git" "helm-kubectl" "https://github.com/orange-cloudfoundry/helm-kubectl-boshrelease" "23" "23.0"
uploadRelease "git" "k3s" "https://github.com/orange-cloudfoundry/k3s-boshrelease" "3" "v3"
uploadRelease "git" "rke" "https://github.com/orange-cloudfoundry/rke-boshrelease" "2" "v2"
uploadRelease "git" "open-iscsi" "https://github.com/orange-cloudfoundry/open-iscsi-boshrelease" "1" "1.0"
uploadRelease "git" "mongodb-services" "https://github.com/orange-cloudfoundry/mongodb-boshrelease" "10" "10"
uploadRelease "git" "redis-service" "https://github.com/orange-cloudfoundry/redis-orange" "3" "v3"
uploadRelease "git" "shield-addon-mongodb" "https://github.com/shieldproject/shield-addon-mongodb-boshrelease" "1.0.0" "v1.0.0"

#--- Tgz bosh releases
uploadRelease "tgz" "shield-addon-cassandra" "https://github.com/orange-cloudfoundry/shield-addon-cassandra-boshrelease/releases/download/v1.0.0/shield-addon-cassandra-boshrelease-1.0.0.tgz" "1.0.0"
uploadRelease "tgz" "weave-scope" "https://github.com/cloudfoundry-community/weavescope-boshrelease/releases/download/v0.0.18/weave-scope.tgz" "0.0.18"
uploadRelease "tgz" "prometheus-addons" "https://github.com/orange-cloudfoundry/prometheus-addons-boshrelease/releases/download/v3.1.1/prometheus-addons-v3.1.1.tgz" "3.1.1"

uploadRelease "tgz" "elasticsearch" "https://github.com/bosh-elastic-stack/elasticsearch-boshrelease/releases/download/0.23.2/elasticsearch-boshrelease-0.23.2.tgz" "0.23.2"
uploadRelease "tgz" "logstash" "https://github.com/bosh-elastic-stack/logstash-boshrelease/releases/download/0.15.2/logstash-boshrelease-0.15.2.tgz" "0.15.2"
uploadRelease "tgz" "kibana" "https://github.com/bosh-elastic-stack/kibana-boshrelease/releases/download/0.16.3/kibana-boshrelease-0.16.3.tgz" "0.16.3"
uploadRelease "tgz" "curator" "https://github.com/bosh-elastic-stack/curator-boshrelease/releases/download/0.3.1/curator-boshrelease-0.3.1.tgz" "0.3.1"
uploadRelease "tgz" "openjdk" "https://github.com/making/openjdk-boshrelease/releases/download/8.0.4/openjdk-boshrelease-8.0.4.tgz" "8.0.4"
