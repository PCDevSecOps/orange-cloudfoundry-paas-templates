#!/bin/bash
#===========================================================================
# Common parameters and functions used by admin scripts
#===========================================================================

#--- Directories
BOSH_DIR=~/bosh
SECRETS_REPO_DIR="${BOSH_DIR}/secrets"
TEMPLATE_REPO_DIR="${BOSH_DIR}/template"

#--- Shared secrets file
SHARED_SECRETS="${SECRETS_REPO_DIR}/shared/secrets.yml"
BOOTSTRAP_VARS_FILE="${SECRETS_REPO_DIR}/bootstrap/bootstrap-vars.yml"
FLY_CREDENTIALS="${SECRETS_REPO_DIR}/coa/config/credentials-auto-init.yml"

#--- InternalCA and intranet key and cert files
ROOT_CERT_DIR="${SECRETS_REPO_DIR}/shared/certs"
export INTERNAL_CA_KEY="${ROOT_CERT_DIR}/internal_paas-ca/server-ca.key"
export INTERNAL_CA_CERT="${ROOT_CERT_DIR}/internal_paas-ca/server-ca.crt"
export INTERNAL_CA2_KEY="${ROOT_CERT_DIR}/internal_paas-ca-2/server-ca.key"
export INTERNAL_CA2_CERT="${ROOT_CERT_DIR}/internal_paas-ca-2/server-ca.crt"
export INTRANET_CA_CERTS="${ROOT_CERT_DIR}/intranet-ca.crt"

#--- Credhub api
CREDHUB_API="https://credhub.internal.paas:8844"

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
    printf "\n%b%s :%b " "${REVERSE}${GREEN}" "$1" "${STD}" >&2 ; read value
    if [ "${value}" != "" ] ; then
      flag=1
    fi
  done
  printf "${value}"
}

#--- Trap errors to exit from subshells (for "getValue" and "getCredhubValue" functions)
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

#--- Get a parameter in credhub
getCredhubValue() {
  #--- Credhub API Endpoint
  export CREDHUB_SERVER="https://credhub.internal.paas:8844"
  export CREDHUB_CLIENT="director_to_credhub"
  export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
  export CREDHUB_SECRET=$(getValue ${SHARED_SECRETS} "/secrets/bosh_credhub_secrets")

  #--- Login to credhub
  credhub api > /dev/null 2>&1
  credhub login > /dev/null 2>&1
  if [ $? != 0 ] ; then
    printf "\n%bERROR: Credhub login failed.%b\n\n" "${REVERSE}${RED}" "${STD}" >&2 ; exit 77
  fi

  #--- Get value
  value=$(credhub g -n $1 2> /dev/null)
  if [ $? != 0 ] ; then
    printf "\n%bERROR: Propertie \"$1\" unknown in \"credhub\".%b\n\n" "${REVERSE}${RED}" "${STD}" >&2 ; exit 77
  else
    value=$(echo "${value}" | grep 'value:' | awk '{print $2}')
    printf "${value}"
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

#--- Update internalCA in credentials file
updateCert() {
  CREDENTIALS_FILE="$1"
  CREDENTIALS_TMP_FILE="${CREDENTIALS_FILE}.tmp"
  > ${CREDENTIALS_TMP_FILE}
  awk -v ca_file="${INTERNAL_CA_CERT}" -v new_file="${CREDENTIALS_TMP_FILE}" 'BEGIN {flag_default_ca = 0 ; flag_ca = 0 ; flag_print = 1}
  {
    if (match($0, /^[a-zA-Z0-9_-]*:/) == 1) {
      if (match($0, /^default_ca:/) == 1) {
        flag_print = 0
        printf("default_ca:\n  ca: |\n") >> new_file
        while (getline < ca_file) {printf("    %s\n", $0) >> new_file}
        close (ca_file)
        printf("  certificate: |\n") >> new_file
        while (getline < ca_file) {printf("    %s\n", $0) >> new_file}
        close (ca_file)
      }
    }

    if (match($0, /^  private_key: \|/) == 1) {flag_print = 1}

    if (flag_print == 1) {printf("%s\n", $0) >> new_file}
  }' ${CREDENTIALS_FILE}

  mv ${CREDENTIALS_TMP_FILE} ${CREDENTIALS_FILE}
}

#--- Clean cert in credentials file
cleanCert() {
  CREDENTIALS_FILE="$1"
  CREDENTIALS_TMP_FILE="${CREDENTIALS_FILE}.tmp"
  > ${CREDENTIALS_TMP_FILE}
  awk -v key="$2" -v new_file="${CREDENTIALS_TMP_FILE}" 'BEGIN {flag_print = 1}
  {
    if (match($0, /^[a-zA-Z0-9_-]*:/) == 1) {
      if (index($0, key":") == 1) {flag_print = 0}
      else {flag_print = 1}
    }
    if (flag_print == 1) {printf("%s\n", $0) >> new_file}
  }' ${INCEPTION_CREDENTIALS}

  mv ${CREDENTIALS_TMP_FILE} ${CREDENTIALS_FILE}
}

#--- Check prerequisites
verifyDirectory "${SECRETS_REPO_DIR}"
verifyDirectory "${TEMPLATE_REPO_DIR}"
verifyFile "${INTERNAL_CA_KEY}"
verifyFile "${INTERNAL_CA_CERT}"
verifyFile "${INTRANET_CA_CERTS}"