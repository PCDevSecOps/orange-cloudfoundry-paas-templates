#!/bin/sh
#===========================================================================
# Clean unused docker volumes and images to avoid disk full
#===========================================================================

#--- Parameters
BOSH_CLI_VERSION="6.4.0"
CREDHUB_CLI_VERSION="2.8.0"
ADMIN_PASSWORD_PATH="/bosh-master/bosh-ops/admin_password"
export BOSH_ENVIRONMENT="192.168.99.152"
export BOSH_DEPLOYMENT="postgresql-docker"

ROOT_DIR=$(pwd)
STATUS_FILE="/tmp/$$.res"
SHARED_SECRETS="${ROOT_DIR}/credentials-resource/shared/secrets.yml"
INTERNAL_CA_CERT="${ROOT_DIR}/credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"
DOCKER_BIN="/var/vcap/packages/docker/bin/docker"
DOCKER_OPTS="--host unix:///var/vcap/sys/run/docker/docker.sock"

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

#--- Install ssh in Alpine container
printf "%bInstall openssh...%b\n" "${YELLOW}" "${STD}"
apk update
apk add --no-cache --no-progress openssh
if [ $? != 0 ] ; then
  printf "\n%bERROR: Install openssh failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi

#--- Install bosh cli
printf "%bInstall bosh cli \"${BOSH_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
curl -L -s -o /usr/local/bin/bosh "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64"
if [ $? != 0 ] ; then
  printf "\n%bERROR: Install bosh cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/bosh

#--- Install credhub cli
printf "%bInstall credhub cli \"${CREDHUB_CLI_VERSION}\"...%b\n" "${YELLOW}" "${STD}"
(curl "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-linux-${CREDHUB_CLI_VERSION}.tgz" -L -s | tar -xz -C /usr/local/bin ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  printf "\n%bERROR: Install credhub cli failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi
chmod 755 /usr/local/bin/credhub

#--- Log to credhub
printf "%bLog to credhub...%b\n" "${YELLOW}" "${STD}"
export CREDHUB_SERVER="https://credhub.internal.paas:8844"
export CREDHUB_CLIENT="director_to_credhub"
export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)
credhub api > /dev/null 2>&1
credhub login > /dev/null 2>&1
if [ $? = 1 ] ; then
  printf "\n%bLog to credhub failed.%b\n\n" "${RED}" "${STD}" ; exit 0
fi

#--- Log to bosh director
printf "%bLog to bosh director...%b\n" "${YELLOW}" "${STD}"
export BOSH_CLIENT="admin"
export BOSH_CLIENT_SECRET="$(credhub g -n ${ADMIN_PASSWORD_PATH} | grep 'value:' | awk '{print $2}')"
export BOSH_CA_CERT="${INTERNAL_CA_CERT}"
bosh alias-env bosh > /dev/null 2>&1
bosh -n log-in
if [ $? != 0 ] ; then
  printf "\n%bLog to bosh director failed%b\n\n" "${RED}" "${STD}" ; exit 0
fi

#--- Clean dandling volumes and images (if docker bosh release present in deployment)
boshInstances=$(bosh instances | grep "running" | awk '{print $1}')
for instance in ${boshInstances} ; do
  printf "%bClean dandling docker images on \"${instance}\"...%b\n" "${YELLOW}" "${STD}"
  bosh ssh ${instance} -c "if [ -s ${DOCKER_BIN} ] ; then ${DOCKER_BIN} ${DOCKER_OPTS} images -qf dangling=true | /usr/bin/xargs -r ${DOCKER_BIN} ${DOCKER_OPTS} rmi ; fi" | grep " stdout "
  printf "%bClean dandling docker volumes on \"${instance}\"...%b\n" "${YELLOW}" "${STD}"
  bosh ssh ${instance} -c "if [ -s ${DOCKER_BIN} ] ; then ${DOCKER_BIN} ${DOCKER_OPTS} volume ls -qf dangling=true | /usr/bin/xargs -r ${DOCKER_BIN} ${DOCKER_OPTS} volume rm ; fi" | grep " stdout "
done
exit 0