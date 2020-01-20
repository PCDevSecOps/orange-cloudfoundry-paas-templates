#!/bin/bash
#===========================================================================
# Recreate micro-bosh director
# Parameters :
# --proxy, -p             : Set internet proxy (http://xxxx:xxxx)
# --recreate-certs, -r    : Recreate micro-bosh certs
# --concourse, -c         : Use it in non-interactive mode from concourse pipeline
# --verbose, -v           : "debug" logs, otherwise "info" logs (default)
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Reference files
MICRO_BOSH_BOOTSTRAP_DIR="${TEMPLATE_REPO_DIR}/bootstrap/micro-bosh"
MICRO_DEPLS_VERSION_FILE="${TEMPLATE_REPO_DIR}/micro-depls/micro-depls-versions.yml"
BOSH_PEM_FILE="${SECRETS_REPO_DIR}/shared/keypair/bosh.pem"

#--- Create micro-bosh secrets repository
GIT_SECRET_DIR=$(echo "${MICRO_BOSH_BOOTSTRAP_DIR}" | sed -e "s+template+secrets+")
createDir "${GIT_SECRET_DIR}"

#--- Micro-bosh files
MICRO_BOSH_CREDENTIALS="${GIT_SECRET_DIR}/creds.yml"
MICRO_BOSH_STATE="${GIT_SECRET_DIR}/state.json"
MICRO_BOSH_MANIFEST="${GIT_SECRET_DIR}/micro-bosh.yml"
MICRO_BOSH_SECRETS="${GIT_SECRET_DIR}/secrets/secrets.yml"

#--- Check prerequisites
verifyDirectory "${MICRO_BOSH_BOOTSTRAP_DIR}"

verifyFile "${SHARED_SECRETS}"
verifyFile "${MICRO_DEPLS_VERSION_FILE}"
verifyFile "${BOSH_PEM_FILE}"
verifyFile "${MICRO_BOSH_CREDENTIALS}"
verifyFile "${MICRO_BOSH_STATE}"
verifyFile "${INTERNAL_CA2_KEY}"
verifyFile "${INTERNAL_CA2_CERT}"

#--- Check scripts options
FLAG_RECREATE_CERTS=0
FLAG_CONCOURSE=0
FLAG_DEBUG=0
PROXY_URL=""

usage() {
  printf "\n%bUSAGE:" "${BOLD}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--proxy, -p" "Set internet proxy (http://xxxx:xxxx)"
  printf "\n  %-40s %s" "--recreate-certs, -r" "Recreate micro-bosh with new certs"
  printf "\n  %-40s %s" "--concourse, -c" "Use it in non-interactive mode from concourse pipeline"
  printf "\n  %-40s %s" "--verbose, -v" "Recreate micro-bosh with debug logs"
  printf "%b\n\n"  "${STD}"
  exit
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-p"|"--proxy") export PROXY_URL="$2" ; shift ; shift ;;
    "-r"|"--recreate-certs") FLAG_RECREATE_CERTS=1 ; shift ;;
    "-c"|"--concourse") FLAG_CONCOURSE=1 ; shift ;;
    "-v"|"--verbose") FLAG_DEBUG=1 ; shift ;;
    *) usage ;;
  esac
done

#--- Identify IAAS type and set cpi and stemcell type
IAAS_TYPE=""
flag="$(grep " openstack:" ${SHARED_SECRETS})"
if [ "${flag}" != "" ] ; then
  IAAS_TYPE="openstack-hws"
  CPI_IAAS_TYPE="openstack"
  BOSH_STEMCELL_NAME="bosh-openstack-kvm-ubuntu-xenial-go_agent"
  BOSH_PERSISTENT_DIR="/data/shared/bosh"
  export BOSH_CPI_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-openstack-cpi-release-version)
  export BOSH_CPI_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-openstack-cpi-release-sha1)
fi

flag="$(grep " vsphere:" ${SHARED_SECRETS})"
if [ "${flag}" != "" ] ; then
  IAAS_TYPE="vsphere"
  CPI_IAAS_TYPE="vsphere"
  BOSH_STEMCELL_NAME="bosh-vsphere-esxi-ubuntu-xenial-go_agent"
  BOSH_PERSISTENT_DIR="/images/bosh"
  export BOSH_CPI_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-vsphere-cpi-release-version)
  export BOSH_CPI_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-vsphere-cpi-release-sha1)
fi

if [ "${IAAS_TYPE}" = "" ] ; then
  display "ERROR" "Iaas type unknown"
fi

#--- Get needed bosh releases version and sha1
export BOSH_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-version)
export BOSH_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bosh-sha1)
export BPM_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bpm-version)
export BPM_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /bpm-sha1)
export UAA_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} /uaa-version)
export UAA_SHA1=$(getValue ${MICRO_DEPLS_VERSION_FILE} /uaa-sha1)
export VCAP_PASSWORD=$(getValue ${SHARED_SECRETS} /secrets/bosh/root/decoded_password)

#--- Check internet proxy
if [ "${PROXY_URL}" = "" ] ; then
  usage
else
  curl ${PROXY_URL} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    display "ERROR" "Internet proxy \"${PROXY_URL}\" unavailable"
  fi
fi

#--- Initialize logs
LOG_DIR="${BOSH_DIR}/logs"
createDir "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/create-micro-bosh.log"
> ${LOG_FILE}

#--- Check instance to set persistent data disk directory for bosh releases and stemcell download
if [ -d /var/vcap/store ] ; then
  #--- Inception instance
  BOSH_PERSISTENT_DIR="/var/vcap/store/.bosh"
fi

#--- Create bosh download directory on persistent disk for bosh releases and stemcells download
if [ ! -d ${BOSH_PERSISTENT_DIR} ] ; then
  sudo mkdir -p ${BOSH_PERSISTENT_DIR}/downloads
  sudo chmod 777 ${BOSH_PERSISTENT_DIR} ${BOSH_PERSISTENT_DIR}/downloads
fi

#--- Change user/group on persistent directory and create link on local .bosh directory
user=$(id -un) ; group=$(id -gn)
sudo chown -R ${user}:${group} ${BOSH_PERSISTENT_DIR}
rm -fr ~/.bosh > /dev/null 2>&1
ln -s ${BOSH_PERSISTENT_DIR} ~/.bosh

if [ ${FLAG_CONCOURSE} = 0 ] ; then
  #--- Install system packages and associate dev headers (needed for cpi)
  aptInstall "libxml2"
  aptInstall "libxml2-dev"
  aptInstall "libxslt1.1"
  aptInstall "libxslt1-dev"
  aptInstall "openssl"
  aptInstall "libssl-dev"
  aptInstall "ruby"
  aptInstall "zlib1g"
  aptInstall "zlib1g-dev"
  aptInstall "apg"
  aptInstall "whois"
fi

#--- Download stemcell
BOSH_STEMCELL_VERSION=$(getValue ${MICRO_DEPLS_VERSION_FILE} "/stemcell-version")
STEMCELL_TGZ=${BOSH_PERSISTENT_DIR}/downloads/${BOSH_STEMCELL_NAME}-${BOSH_STEMCELL_VERSION}.tgz
if [ ! -s ${STEMCELL_TGZ} ] ; then
  display "INFO" "Download \"${BOSH_STEMCELL_NAME}\" stemcell version \"${BOSH_STEMCELL_VERSION}\""
  curl -x ${PROXY_URL} https://bosh.io/d/stemcells/${BOSH_STEMCELL_NAME}?v=${BOSH_STEMCELL_VERSION} -L -s -o ${STEMCELL_TGZ}
  status=$?
  if [ ${status} != 0 ] ; then
    display "ERROR" "Stemcell download failed (error: ${status})"
  fi
fi

#--- Export vars used in micro-bosh-vars.yml
export URL_STEMCELL=file://${STEMCELL_TGZ}
export SHA1_STEMCELL=$(sha1sum ${STEMCELL_TGZ} | awk '{print $1}')

if [ ${FLAG_CONCOURSE} = 0 ] ; then
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
fi

display "INFO" "Create link on bosh-deployment repository"
cd ${MICRO_BOSH_BOOTSTRAP_DIR}
rm -fr bosh-deployment > /dev/null 2>&1
ln -s ${TEMPLATE_REPO_DIR}/submodules/bosh-deployment bosh-deployment

#--- Update "default_ca" with new internalCA cert (keep private key)
display "INFO" "Update \"internalCA\" cert"
updateCert "${MICRO_BOSH_CREDENTIALS}"

#--- Delete certs entries in bosh credentials to force bosh regenerating keys and certs
if [ ${FLAG_RECREATE_CERTS} = 1 ] ; then
  display "INFO" "Clean bosh certs"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "director_ssl"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "mbus_bootstrap_ssl"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "uaa_ssl"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "uaa_service_provider_ssl"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "blobstore_ca"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "blobstore_server_tls"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "nats_ca"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "nats_clients_director_tls"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "nats_clients_health_monitor_tls"
  cleanCert "${MICRO_BOSH_CREDENTIALS}" "nats_server_tls"
fi

#--- Generate manifest
display "INFO" "Generate micro-bosh vars manifest"
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

if [ $? != 0 ] ; then
  display "ERROR" "Generate micro-bosh manifest failed"
fi

#--- Replace external dns from secrets.yml
if [ -f ${MICRO_BOSH_SECRETS} ] ; then
  display "INFO" "Update external dns in micro-bosh manifest"  
  mv ${MICRO_BOSH_MANIFEST} ${MICRO_BOSH_MANIFEST}.tmp
  spruce merge ${MICRO_BOSH_MANIFEST}.tmp ${MICRO_BOSH_SECRETS} > ${MICRO_BOSH_MANIFEST}
  if [ $? != 0 ] ; then
    display "ERROR" "Update external dns in micro-bosh manifest failed"
  fi
fi

rm -fr bosh-deployment micro-bosh-vars.yml ${MICRO_BOSH_MANIFEST}.tmp > /dev/null 2>&1

if [ ${FLAG_CONCOURSE} = 0 ] ; then
  #--- Confirm micro-bosh recreation
  printf "\n%bRecreate micro-bosh (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
  read choice
  printf "\n"
  if [ "${choice}" != "y" ] ; then
    exit
  fi
fi

#--- BOSH log level
if [ ${FLAG_DEBUG} = 1 ] ; then
  export BOSH_LOG_LEVEL=DEBUG
else
  export BOSH_LOG_LEVEL=INFO
fi

#--- Create micro-bosh instance
(export http_proxy=${PROXY_URL} ; export no_proxy="127.0.0.1,localhost,192.168.0.0/16" ; bosh create-env -n --state=${MICRO_BOSH_STATE} --vars-store ${MICRO_BOSH_CREDENTIALS} ${MICRO_BOSH_MANIFEST} 2>&1 ; echo $? > ${STATUS_FILE}) | tee -a ${LOG_FILE}
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} = 0 ] ; then
  display "OK" "Create micro-bosh instance succeeded"
else
  display "ERROR" "Create micro-bosh instance failed"
fi

#--- Commit updates in secrets repository
unset BOSH_LOG_LEVEL

if [ ${FLAG_CONCOURSE} = 0 ] ; then
  #--- Push updates on secrets repository
  display "INFO" "Commit \"micro-bosh\" instance configuration into secrets repository"
  commitGit "secrets" "update_micro-bosh"
fi

#--- Add clean director bosh tasks to micro-bosh instance
display "INFO" "Add bosh director tasks logs cleanup"
chmod 600 ${BOSH_PEM_FILE} > /dev/null 2>&1

cat > clean_tasks.sql <<'EOF'
delete from tasks where timestamp < now() - interval '60 days';
EOF

cat > task_logrotate <<'EOF'
#!/bin/bash
#--- Compress day-1 tasks files (usual bosh task)
echo "============================================================="
echo "$(date)"
cd /var/vcap/store/director/tasks
nb=$(find . -type f -mtime +1 -a -not -name "*.gz" | wc -l)
find . -type f -mtime +1 -a -not -name "*.gz" -exec gzip '{}' \; > /dev/null 2>&1
echo "- ${nb} tasks files compressed"

#--- Delete day-60 tasks files
nb=$(find . -type d -ctime +60 | wc -l)
find . -type d -ctime +60 -exec rm -fr {} \; > /dev/null 2>&1
echo "- ${nb} tasks files deleted"

#--- Cleanup day-60 tasks rows in postgres tasks table
psql_binary=$(ps -ef | grep "postgres -h" | grep -v "grep" | awk '{print $8}' | sed -e "s+/bin/postgres+/bin/psql+")
${psql_binary} -h 0.0.0.0 -p 5432 bosh postgres -a -f /var/vcap/jobs/director/bin/clean_tasks.sql
EOF

cat clean_tasks.sql | ssh -o "StrictHostKeyChecking no" -i ${BOSH_PEM_FILE} vcap@192.168.10.10 "cat > /tmp/clean_tasks.sql" 2> /dev/null
if [ $? != 0 ] ; then
  display "ERROR" "ssh acces to micro-bosh failed when uploading clean_tasks.sql"
fi

cat task_logrotate | ssh -o "StrictHostKeyChecking no" -i ${BOSH_PEM_FILE} vcap@192.168.10.10 "cat > /tmp/task_logrotate" 2> /dev/null
if [ $? != 0 ] ; then
  display "ERROR" "ssh acces to micro-bosh failed when uploading task_logrotate"
fi

rm -f clean_tasks.sql task_logrotate > /dev/null 2>&1

ssh -t -o "StrictHostKeyChecking no" -i ${BOSH_PEM_FILE} vcap@192.168.10.10 "echo ${VCAP_PASSWORD} | sudo -S bash -c 'cd /tmp ; chmod 750 clean_tasks.sql task_logrotate ; chown root clean_tasks.sql task_logrotate ; mv clean_tasks.sql /var/vcap/jobs/director/bin/clean_tasks.sql ; mv task_logrotate /var/vcap/jobs/director/bin/task_logrotate'" 2> /dev/null
if [ $? != 0 ] ; then
  display "ERROR" "ssh acces to micro-bosh failed when setting scripts"
fi

display "OK" "Create micro-bosh ended"