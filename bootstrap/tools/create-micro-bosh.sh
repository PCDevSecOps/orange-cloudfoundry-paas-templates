#!/bin/bash
#===========================================================================
# Create micro-bosh director from inception instance
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script parameters
MICRO_DEPLS_VERSION_FILE="${TEMPLATE_REPO_DIR}/micro-depls/micro-depls-versions.yml"

GIT_SECRET_DIR=$(echo "${MICRO_BOSH_BOOTSTRAP_DIR}" | sed -e "s+template+secrets+")
createDir "${GIT_SECRET_DIR}"

#--- Micro-bosh files
MICRO_BOSH_STATE="${GIT_SECRET_DIR}/state.json"
MICRO_BOSH_MANIFEST="${GIT_SECRET_DIR}/micro-bosh.yml"
MICRO_BOSH_SECRETS="${GIT_SECRET_DIR}/secrets/secrets.yml"

#--- Check prerequisites
verifyFile "${MICRO_DEPLS_VERSION_FILE}"
verifyFile "${BOSH_PEM_FILE}"
verifyFile "${INTERNAL_CA_KEY}"
verifyFile "${INTERNAL_CA_CERT}"
verifyFile "${INTERNAL_CA2_KEY}"
verifyFile "${INTERNAL_CA2_CERT}"

#--- Initialize logs
createDir "${BOOTSTRAP_LOG_DIR}"
LOG_FILE="${BOOTSTRAP_LOG_DIR}/create-micro-bosh.log"
> ${LOG_FILE}

#--- Get needed bosh releases version and sha1
export BOSH_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-version)
export BOSH_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-sha1)
export BPM_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bpm-version)
export BPM_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bpm-sha1)
export UAA_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /uaa-version)
export UAA_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /uaa-sha1)

#--- Download stemcell for micro-bosh
downloadStemcell "inception"

#--- Create link for bosh-deployment
display "INFO" "Checkout \"bosh-deployment\" submodule"
cd ${TEMPLATE_REPO_DIR}
createDir "submodules/bosh-deployment"
git config --global http.proxy ${PROXY_URL} > /dev/null 2>&1
git submodule update --init submodules/bosh-deployment
if [ $? != 0 ] ; then
  display "ERROR" "git checkout \"bosh-deployment\" submodule failed"
fi
git config --global --unset http.proxy > /dev/null 2>&1

display "INFO" "Create link on bosh-deployment repository"
cd ${MICRO_BOSH_BOOTSTRAP_DIR}
rm -fr bosh-deployment > /dev/null 2>&1
ln -s ${TEMPLATE_REPO_DIR}/submodules/bosh-deployment bosh-deployment

#--- Generate manifest
display "INFO" "Generate micro-bosh manifest"
spruce merge --prune secrets ${SHARED_SECRETS} template/micro-bosh-vars-tpl.yml template/${IAAS_TYPE}/${IAAS_TYPE}-vars-tpl.yml > micro-bosh-vars.yml
if [ $? != 0 ] ; then
  display "ERROR" "Generate micro-bosh vars failed"
fi

#--- Generate micro-bosh manifest
display "INFO" "Generate micro-bosh manifest"
bosh int bosh-deployment/bosh.yml \
  -o bosh-deployment/${CPI_IAAS_TYPE}/cpi.yml \
  -o bosh-deployment/misc/dns.yml \
  -o bosh-deployment/uaa.yml \
  -o template/${IAAS_TYPE}/${IAAS_TYPE}-operators.yml \
  -o template/${IAAS_TYPE}/dns-operators.yml \
  -o template/micro-bosh-operators.yml \
  --vars-file=micro-bosh-vars.yml \
  --var-file private_key=${BOSH_PEM_FILE} \
  --vars-store=${MICRO_BOSH_CREDENTIALS} > ${MICRO_BOSH_MANIFEST}

status=$? ; rm -fr bosh-deployment micro-bosh-vars.yml > /dev/null 2>&1
if [ ${status} != 0 ] ; then
  display "ERROR" "Generate micro-bosh manifest failed"
fi

#--- Replace external dns from secrets.yml
if [ -f ${MICRO_BOSH_MANIFEST} ] ; then
  display "INFO" "Update external dns in micro-bosh manifest"  
  mv ${MICRO_BOSH_MANIFEST} ${MICRO_BOSH_MANIFEST}.tmp
  spruce merge ${MICRO_BOSH_MANIFEST}.tmp ${MICRO_BOSH_SECRETS} > ${MICRO_BOSH_MANIFEST}
  if [ $? != 0 ] ; then
    display "ERROR" "Update external dns in micro-bosh manifest failed"
  fi
fi

rm -fr ${MICRO_BOSH_MANIFEST}.tmp > /dev/null 2>&1

#--- BOSH log level
if [ "$1" = "debug" ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Create micro-bosh instance
display "INFO" "Create micro-bosh instance"
(export http_proxy=${PROXY_URL} ; export no_proxy="127.0.0.1,localhost,192.168.0.0/16" ; bosh create-env -n --state=${MICRO_BOSH_STATE} --vars-store ${MICRO_BOSH_CREDENTIALS} ${MICRO_BOSH_MANIFEST} 2>&1 ; echo $? > ${STATUS_FILE}) | tee -a ${LOG_FILE}
status=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE} > /dev/null 2>&1
if [ ${status} != 0 ] ; then
  display "ERROR" "Create micro-bosh instance failed"
fi

unset BOSH_LOG_LEVEL

#--- Push updates on secrets repository
commitGit "secrets" "save_micro_bosh_configuration"

display "OK" "Create micro-bosh succeeded"