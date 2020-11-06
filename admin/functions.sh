#!/bin/bash
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

#--- Default certificate expiration (in days)
CERT_EXPIRATION_IN_DAYS=60

#--- Bosh directors
BOSH_DIRECTORS="micro-bosh bosh-master bosh-ops bosh-coab bosh-remote-r2 bosh-remote-r3"

#--- micro-bosh certs (except "default_ca" wich is set with internalCA cert and must not be deleted)
MICRO_BOSH_DIRECTOR_CERTS="blobstore_ca blobstore_server_tls director_ssl mbus_bootstrap_ssl nats_ca nats_clients_director_tls nats_clients_health_monitor_tls nats_server_tls uaa_service_provider_ssl uaa_ssl"

#--- Bosh properties
export BOSH_CLIENT="admin"
export BOSH_CA_CERT="/etc/ssl/certs/ca-certificates.crt"

#--- Directories
BOSH_DIR="${HOME}/bosh"
SECRETS_REPO_DIR="${BOSH_DIR}/secrets"
TEMPLATE_REPO_DIR="${BOSH_DIR}/template"

#--- Micro-depls versions file
MICRO_DEPLS_VERSION_FILE="${TEMPLATE_REPO_DIR}/micro-depls/root-deployment.yml"

#--- Shared secrets file
SHARED_SECRETS="${SECRETS_REPO_DIR}/shared/secrets.yml"
BOOTSTRAP_VARS_FILE="${SECRETS_REPO_DIR}/bootstrap/bootstrap-vars.yml"
FLY_CREDENTIALS="${SECRETS_REPO_DIR}/coa/config/credentials-auto-init.yml"

#--- InternalCA and intranet key and cert files
SHARED_CERT_DIR="${SECRETS_REPO_DIR}/shared/certs"
export INTERNAL_CA_KEY="${SHARED_CERT_DIR}/internal_paas-ca/server-ca.key"
export INTERNAL_CA_CERT="${SHARED_CERT_DIR}/internal_paas-ca/server-ca.crt"
export INTERNAL_CA2_KEY="${SHARED_CERT_DIR}/internal_paas-ca-2/server-ca.key"
export INTERNAL_CA2_CERT="${SHARED_CERT_DIR}/internal_paas-ca-2/server-ca.crt"
export INTRANET_CA_CERTS="${SHARED_CERT_DIR}/intranet-ca.crt"

#--- bosh-dns key and cert files
export BOSH_DNS_CA_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_api_tls_ca.crt"
export BOSH_DNS_CLIENT_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_api_client_tls.crt"
export BOSH_DNS_CLIENT_KEY="${SHARED_CERT_DIR}/bosh-dns/dns_api_client_tls.key"
export BOSH_DNS_SERVER_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_api_server_tls.crt"
export BOSH_DNS_SERVER_KEY="${SHARED_CERT_DIR}/bosh-dns/dns_api_server_tls.key"

export BOSH_DNS_HC_CA_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_healthcheck_tls_ca.crt"
export BOSH_DNS_HC_CLIENT_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_healthcheck_client_tls.crt"
export BOSH_DNS_HC_CLIENT_KEY="${SHARED_CERT_DIR}/bosh-dns/dns_healthcheck_client_tls.key"
export BOSH_DNS_HC_SERVER_CERT="${SHARED_CERT_DIR}/bosh-dns/dns_healthcheck_server_tls.crt"
export BOSH_DNS_HC_SERVER_KEY="${SHARED_CERT_DIR}/bosh-dns/dns_healthcheck_server_tls.key"

#--- Credhub properties
export CREDHUB_SERVER="https://credhub.internal.paas:8844"
export CREDHUB_API="${CREDHUB_SERVER}/api/v1"

#--- Status file
SCRIPT_NAME="$(basename $0)"
STATUS_FILE="/tmp/${SCRIPT_NAME}_$$.res"

#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export ORANGE='\033[0;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'
export BLINK='\033[5m'

#--- Display information
display() {
  if [ -n "${LOG_FILE}" ] ; then
    case "$1" in
      "INFO") printf "\n%b%s...%b\n" "${REVERSE}${YELLOW}" "$2" "${STD}" | tee -a ${LOG_FILE} ;;
      "OK") printf "\n%b%s.%b\n\n" "${REVERSE}${GREEN}" "$2" "${STD}" | tee -a ${LOG_FILE} ;;
      "ERROR") printf "\n%b%s.%b\n\n" "${REVERSE}${RED}" "$2" "${STD}" | tee -a ${LOG_FILE} ; exit 1 ;;
    esac
  else
    case "$1" in
      "INFO")  printf "\n%b%s...%b\n" "${REVERSE}${YELLOW}" "$2" "${STD}" ;;
      "ITEM")  printf "\n%b- %s%b" "${YELLOW}" "$2" "${STD}" ;;
      "OK")    printf "\n%b%s.%b\n\n" "${REVERSE}${GREEN}" "$2" "${STD}" ;;
      "ERROR") printf "\n%bERROR: %s.%b\n\n" "${REVERSE}${RED}" "$2" "${STD}" ; exit 1 ;;
    esac
  fi
}

#--- Check if directory exists
verifyDirectory() {
  if [ ! -d $1 ] ; then
    display "ERROR" "Directory \"$1\" unavailable"
  fi
}

#--- Check if file exists
verifyFile() {
  if [ ! -s $1 ] ; then
    display "ERROR" "File \"$1\" unavailable"
  fi
}

#--- Create directory
createDir() {
  directory=$1
  if [ ! -d ${directory} ] ; then
    mkdir -p ${directory}
  fi
}

#--- Catch a parameter
catchValue() {
  flag=0
  while [ ${flag} = 0 ] ; do
    printf "\n%b%s :%b " "${REVERSE}${YELLOW}" "$2" "${STD}" >&2 ; read value
    if [ "${value}" != "" ] ; then
      flag=1
    fi
  done
  eval "$1=${value}"
}

#--- Trap errors to exit from subshells (for "getValue" function)
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR

#--- Get a parameter in specified yaml file
getValue() {
  value=$(bosh int $1 --path $2 2> /dev/null)
  if [ $? != 0 ] ; then
    printf "\n%bERROR: Propertie \"$2\" unknown in \"$1\".%b\n\n" "${REVERSE}${RED}" "${STD}" >&2 ; exit 77
  else
    printf "${value}"
  fi
}

#--- Log to credhub
logToCredhub() {
  export CREDHUB_CA_CERT="${BOSH_CA_CERT}"
  export CREDHUB_CLIENT="director_to_credhub"
  export CREDHUB_SECRET="$(getValue ${SHARED_SECRETS} "/secrets/bosh_credhub_secrets")"
  credhub f > /dev/null 2>&1
  if [ $? != 0 ] ; then
    credhub login > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: Bad LDAP authentication.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi
}

#--- Log to bosh director
logToBosh() {
  case "$1" in
    "micro-bosh") director_dns_name="bosh-micro" ; credhub_bosh_password="/secrets/bosh_admin_password" ;;
    "bosh-master") director_dns_name="$1" ; credhub_bosh_password="/micro-bosh/$1/admin_password" ;;
    *) director_dns_name="$1" ; credhub_bosh_password="/bosh-master/$1/admin_password" ;;
  esac
  export BOSH_ENVIRONMENT=$(host ${director_dns_name}.internal.paas | awk '{print $4}')
  logToCredhub
  flag=$(credhub f | grep "${credhub_bosh_password}")
  if [ "${flag}" = "" ] ; then
    return 1
  else
    export BOSH_CLIENT_SECRET="$(credhub g -n ${credhub_bosh_password} -j | jq -r '.value')"
    bosh alias-env $1 > /dev/null 2>&1
    bosh logout > /dev/null 2>&1
    bosh -n log-in > /dev/null 2>&1
    if [ $? = 1 ] ; then
      printf "\n%bERROR: Log to \"$1\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; return 1
    fi
  fi
}

#--- Select a BOSH director and log on it
selectBoshDirector() {
  printf "\n%bSelect bosh director :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
  printf "%b1%b : micro-bosh\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b2%b : bosh-master\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b3%b : bosh-ops\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b4%b : bosh-coab\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b5%b : bosh-remote-r2\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b6%b : bosh-remote-r3\n" "${GREEN}${BOLD}" "${STD}"
  printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
  case "${choice}" in
    1) BOSH_DIRECTOR_NAME="micro-bosh" ;;
    2) BOSH_DIRECTOR_NAME="bosh-master" ;;
    3) BOSH_DIRECTOR_NAME="bosh-ops" ;;
    4) BOSH_DIRECTOR_NAME="bosh-coab" ;;
    5) BOSH_DIRECTOR_NAME="bosh-remote-r2" ;;
    6) BOSH_DIRECTOR_NAME="bosh-remote-r3" ;;
    *) printf "\n%bERROR: Unavailable choice.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1 ;;
  esac

  logToBosh "${BOSH_DIRECTOR_NAME}"
  if [ $? = 1 ] ; then
    exit 1
  fi
}

#--- Log to credhub-uaa to get a bearer token
getCredhubToken() {
  uaa_secrets="$(getValue ${SHARED_SECRETS} "/secrets/bosh_credhub_secrets")"
  uaac token delete --all > /dev/null 2>&1
  uaac target https://uaa-credhub.internal.paas:8443 --ca-cert ${BOSH_CA_CERT} > /dev/null 2>&1
  uaac token client get director_to_credhub -s ${uaa_secrets} > /dev/null 2>&1
  TOKEN=$(uaac contexts | grep "access_token:" | sed -e "s+ *access_token:++g" | sed -e "s+^+Authorization: Bearer+")
  if [ "${TOKEN}" = "" ] ; then
    printf "\n%bERROR: Unable to get credhub token.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi
}

#--- Execute curl request on credhub api
executeCredhubCurl() {
  RES_FILE="/tmp/res.tmp" ; flagCheckError=""
  if [ "$1" = "no_chek_errors" ] ; then
    flagCheckError="no_chek_errors" ; shift
  fi

  http_method=$1 ; shift
  request=${CREDHUB_API}/$1 ; shift
  post_data=$@
  getCredhubToken

  case "${http_method}" in
    "GET"|"DELETE") status=$(curl -X ${http_method} -w %{http_code} -o ${RES_FILE} -s -H "Content-Type: application/json" -H "${TOKEN}" ${request}) ;;
    "POST"|"PUT") status=$(curl -X ${http_method} -w %{http_code} -o ${RES_FILE} -s -H "Content-Type: application/json" -H "${TOKEN}" ${request} -d {${post_data}}) ;;
  esac

  CREDHUB_API_RESULT="$(cat ${RES_FILE})" ; rm -f ${RES_FILE} > /dev/null 2>&1

  if [ "${flagCheckError}" != "no_chek_errors" ] ; then
    if [ "${status}" != "200" ] ; then
      printf "\n%bERROR: ${http_method} ${request} (http ${status})\n${CREDHUB_API_RESULT}%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi
}

#--- Update yml file
updateYaml() {
  update-yml.sh $1 $2 $3
  if [ $? != 0 ] ; then
    display "ERROR" "Update yaml failed"
  fi
}

#--- Execute git command
executeGit() {
  if [ "$2" = "proxy" ] ; then
    git -c "http.proxy=${PROXY_URL}" $1
  else
    git $1
  fi

  if [ $? != 0 ] ; then
    display "ERROR" "git command failed"
  fi
}

#--- Commit updates on git repository
commitGit() {
  if [ "$1" = "secrets" ] ; then
    cd ${SECRETS_REPO_DIR}
  else
    cd ${TEMPLATE_REPO_DIR}
  fi

  #--- Check if exist updates
  unset http_proxy https_proxy no_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
  flagUpdates="$(git status 2>&1 | grep -E 'nothing to commit|rien à valider')"
  if [ "${flagUpdates}" = "" ] ; then
    display "INFO" "Commit updates on \"$1\" git repository"
    executeGit "add ."
    executeGit "commit -m $2"
    executeGit "pull --rebase"
    executeGit "push"
  fi
}

#--- Install packages with apt-get install
aptInstall() {
  packageList=$(dpkg -l 2> /dev/null)
  flag=$(echo "${packageList}" | grep " $1[: ]")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install $1 package"
    sudo http_proxy=${PROXY_URL} apt-get update
    sudo http_proxy=${PROXY_URL} apt-get install -y $1 2>&1
  fi
}

#--- Clean cert in credentials file
cleanCert() {
  CREDENTIALS_FILE="$1"
  CREDENTIALS_TMP_FILE="${CREDENTIALS_FILE}.tmp"
  > ${CREDENTIALS_TMP_FILE}
  printf "[$2]\n"
  awk -v key="$2" -v new_file="${CREDENTIALS_TMP_FILE}" 'BEGIN {flag_print = 1}
  {
    if (match($0, /^[a-zA-Z0-9_-]*:/) == 1) {
      if (index($0, key":") == 1) {flag_print = 0}
      else {flag_print = 1}
    }
    if (flag_print == 1) {printf("%s\n", $0) >> new_file}
  }' ${CREDENTIALS_FILE}

  mv ${CREDENTIALS_TMP_FILE} ${CREDENTIALS_FILE}
}

#--- Check prerequisites
verifyDirectory "${SECRETS_REPO_DIR}"
verifyDirectory "${TEMPLATE_REPO_DIR}"
verifyFile "${MICRO_DEPLS_VERSION_FILE}"
verifyFile "${SHARED_SECRETS}"
verifyFile "${INTERNAL_CA_KEY}"
verifyFile "${INTERNAL_CA_CERT}"
verifyFile "${INTRANET_CA_CERTS}"