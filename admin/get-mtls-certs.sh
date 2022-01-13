#!/bin/bash
#===========================================================================
# Get deployments which use MTLS certs
# (certs used locally inside deployments are not display)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Get file list containing MTLS certs
cd ${SECRETS_REPO_DIR}
MTLS_CERTS=""
FILES="$(find * -type f ! -regex ".*last-deployment-failure\.yml" -wholename "*/*.yml" -print0 | xargs -0 grep -I -i --color "_auth" | grep -E "client_auth|server_auth" | awk '{print $1}' | LC_ALL=C sort | uniq | sed -e "s+:$++g")"

#--- Get MTLS cert names in yaml files
for file in ${FILES} ; do
  deployment="$(dirname ${file})"
  deployment="$(echo "${deployment}" | sed -e "s+micro-depls+micro-bosh+")"
  deployment="$(echo "${deployment}" | sed -e "s+master-depls+bosh-master+")"
  deployment="$(echo "${deployment}" | sed -e "s+ops-depls+bosh-ops+")"
  deployment="$(echo "${deployment}" | sed -e "s+coab-depls+bosh-coab+")"
  deployment="$(echo "${deployment}" | sed -e "s+remote-r2-depls+bosh-remote-r2+")"
  deployment="$(echo "${deployment}" | sed -e "s+remote-r3-depls+bosh-remote-r3+")"

  CERTS="$(grep -E " name: | (server|client)_auth" ${file} | grep -v "/" | awk -v deployment="${deployment}" '{
    currentLine = $0 ; gsub("^ *- ", "", currentLine)
    if (index(currentLine, "name: ") == 1) {gsub("name: ", "", currentLine) ; prop_name = currentLine ; flag = 1}
    if (flag == 1) {
      if (index(currentLine, "_auth") >= 1) {printf("/%s/%s\n", deployment, prop_name) ; flag = 0}
    }
  }' | LC_ALL=C sort | uniq)"

  MTLS_CERTS="${MTLS_CERTS}\n${CERTS}"
done

MTLS_CERTS="$(echo -e "${MTLS_CERTS}" | LC_ALL=C sort | uniq)"

#--- Get deployments which use MTLS certs (check fingerprints.json files)
#"name": "/bosh-master/cf/nats_internal_cert"
for cert in ${MTLS_CERTS} ; do
  deployment="$(echo "${cert}" | awk -F "/" '{print $3}')"
  result="$(find * -type f -wholename "*/*fingerprints.json" -print0 | xargs -0 grep -I -i --color "${cert}" | awk '{print $1}' | awk -F "/" '{print "/" $1 "/" $2}' | grep -v "/${deployment}$" | LC_ALL=C sort | uniq)"
  if [ "${result}" != "" ] ; then
    printf "\n%bDeployments which use \"${cert}\" MTLS certs%b\n" "${REVERSE}${YELLOW}" "${STD}"
    printf "${result}\n"
  fi
done