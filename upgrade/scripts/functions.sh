#!/bin/bash
#===========================================================================
# Common parameters and functions used by check scipts
#===========================================================================
set +e

#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export ORANGE='\033[0;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Check if file exists
verifyFile() {
  if [ ! -s $1 ] ; then
    printf "\n%bERROR: File \"$1\" unavailable.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  fi
}

#--- Check if directory exists
verifyDirectory() {
  if [ ! -d $1 ] ; then
    printf "\n%bERROR: Directory \"$1\" unavailable.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  fi
}

#--- dosplay title
display() {
  printf "\n\n%b$1...%b\n" "${REVERSE}${YELLOW}" "${STD}"
}

#--- Check if profile is set
checkProfile() {
  profile="$1"

  status="$(grep "^profiles: " ${COA_PROFILES} | sed -e "s+ +,+g" | sed -e "s+$+,+" | grep ",${profile},")"
  if [ "${status}" = "" ] ; then
    printf "\n%bKO : Profile \"${profile}\" not set in \"${COA_PROFILES}\"%b" "${RED}" "${STD}"
  else
    printf "\n%bOK%b : Profile \"${profile}\" is set" "${GREEN}" "${STD}"
  fi
}

#--- Check port
checkPort() {
  ip="$1"
  port="$2"
  expected_status="$3"

  status="$(nc -vz ${ip} ${port} 2>&1 | grep "succeeded")"
  if [ "${expected_status}" = "disable" ] ; then
    if [ "${status}" = "" ] ; then
      printf "\n%bOK%b : Port \"${port}\" is closed for \"${ip}\"" "${GREEN}" "${STD}"
    else
      printf "\n%bKO : Port \"${port}\" should be closed for \"${ip}\"%b" "${RED}" "${STD}"
    fi
  else
    if [ "${status}" = "" ] ; then
      printf "\n%bKO : Port \"${port}\" is closed for \"${ip}\"%b" "${RED}" "${STD}"
    else
      printf "\n%bOK%b : Port \"${port}\" is open for \"${ip}\"" "${GREEN}" "${STD}"
    fi
  fi
}

#--- Check host domain
checkHost() {
  host="$1"
  ip="$2"
  port="$3"

  status="$(host ${host} | grep "${ip}")"
  if [ "${status}" = "" ] ; then
    printf "\n%bKO : Host \"${host}\" not available on \"${ip}\"%b" "${RED}" "${STD}"
  else
    printf "\n%bOK%b : Host \"${host}\" available on \"${ip}\"" "${GREEN}" "${STD}"
    if [ "$3" != "" ] ; then
      checkPort "${ip}" "${port}"
    fi
  fi
}

#--- Check access with curl request (http, ldap)
checkAccess() {
  expected_status="$1"
  protocole="$2"
  domain="$3"
  target_ip="$4"

  case "${protocole}" in
    "ldap") status="$(curl -s -o /dev/null -w "%{http_code}" ${protocole}://${domain})" ;;
    "http") status="$(curl -s -o /dev/null -w "%{http_code}" ${protocole}://${domain})" ;;
    "https")
      if [ "${target_ip}" = "" ] ; then
        status="$(curl -s -o /dev/null -w "%{http_code}" ${protocole}://${domain})"
      else
        status="$(curl -s -o /dev/null -w "%{http_code}" --connect-to "${domain}:443:${target_ip}" ${protocole}://${domain})"
      fi ;;
  esac

  if [ "${status}" != "${expected_status}" ] ; then
    printf "\n%bKO : Error on \"${protocole}://${domain}\" (status: ${status})%b" "${RED}" "${STD}"
  else
    printf "\n%bOK%b : \"${protocole}://${domain}\" (status: ${status})" "${GREEN}" "${STD}"
  fi
}

#--- Check PKI certificates
checkPKICert() {
  CERT_DIR="$1"
  flagNext=0
  if [ ! -d ${SHARED_CERT_DIR}/${CERT_DIR} ] ; then
    printf "\n%bKO : cert directory \"${SHARED_CERT_DIR}/${CERT_DIR}\" unknown%b" "${RED}" "${STD}"
  else
    #--- Private key and certificate files
    KEY_FILE="${SHARED_CERT_DIR}/${CERT_DIR}/server.key"
    CERT_FILE="${SHARED_CERT_DIR}/${CERT_DIR}/server.crt"

    #--- Check private key an cert files
    if [ ! -s ${KEY_FILE} ] ; then
      printf "\n%bKO : Key file \"${KEY_FILE}\" unknown%b" "${RED}" "${STD}" ; flagNext=1
    fi

    if [ ! -s ${CERT_FILE} ] ; then
      printf "\n%bKO : Certificate file \"${CERT_FILE}\" unknown%b" "${RED}" "${STD}" ; flagNext=1
    fi

    if [ ${flagNext} = 0 ] ; then
      #--- Check if cert/key contains CR/LF
      flagKey=$(grep -U $'\015' ${KEY_FILE})
      if [ "${flagKey}" != "" ] ; then
        printf "\n%bKO : Key file \"${KEY_FILE}\" uses CR/LF characters%b" "${RED}" "${STD}"
      fi

      flagCert=$(grep -U $'\015' ${CERT_FILE})
      if [ "${flagCert}" != "" ] ; then
        printf "\n%bKO : Certificate file \"${CERT_FILE}\" uses CR/LF characters%b" "${RED}" "${STD}"
      fi

      #--- Check private key and certificate consistency
      modulusKey=$(openssl rsa -noout -modulus -in ${KEY_FILE} | openssl md5)
      modulusCert=$(openssl x509 -noout -modulus -in ${CERT_FILE} | openssl md5)
      if [ "${modulusKey}" != "${modulusCert}" ] ; then
        printf "\n%bKO : Private key and certificate for \"${CERT_DIR}\" are inconsistent%b" "${RED}" "${STD}"
      fi

      #--- Check SHA2 algorithm
      x509InfoCert=$(openssl x509 -text -noout -in ${CERT_FILE})
      certAlgorithm=$(echo "${x509InfoCert}" | grep "Signature Algorithm: sha256WithRSAEncryption")
      if [ "${certAlgorithm}" = "" ] ; then
        printf "\n%bKO : Certificate algorithm in \"${CERT_FILE}\" is not SHA2%b" "${RED}" "${STD}"
      fi

      #--- Check PKI issuer
      certIssuer=$(echo "${x509InfoCert}" | grep "Issuer: .*Orange Internal G2 Server CA")
      if [ "${certIssuer}" = "" ] ; then
        printf "\n%bKO : Certificate issuer in \"${CERT_FILE}\" is not PKI%b" "${RED}" "${STD}"
      fi

      #--- Check if cert is defined on wildcard domain
      DomainWildcard=$(echo "${x509InfoCert}" | grep "Subject:.*CN =" | sed -e "s+.*Subject:.*CN = ++")
      if [ "${DomainWildcard}" = "" ] ; then
        printf "\n%bKO : No CN defined for \"${CERT_FILE}\"%b" "${RED}" "${STD}"
      fi

      DNSWildcard=$(echo "${x509InfoCert}" | grep "DNS:\*" | sed -e "s+DNS:++g" | sed -e "s+^ *++g")
      if [ "${DNSWildcard}" = "" ] ; then
        printf "\n%bKO : No SAN defined for \"${CERT_FILE}\"%b" "${RED}" "${STD}"
      fi
      if [ "${CERT_DIR}" = "ops-certs" ] ; then
        flag="$(echo "${DNSWildcard}" | grep "*.jcr.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "\n%bKO : SAN \"*.jcr.${OPS_DOMAIN}\" not defined for \"${CERT_FILE}\"%b" "${RED}" "${STD}"
        fi
        flag="$(echo "${DNSWildcard}" | grep "*.jcr-k8s.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "\n%bKO : SAN \"*.jcr-k8s.${OPS_DOMAIN}\" not defined for \"${CERT_FILE}\"%b" "${RED}" "${STD}"
        fi
        flag="$(echo "${DNSWildcard}" | grep "*.k8s-serv.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "\n%bKO : SAN \"*.k8s-serv.${OPS_DOMAIN}\" not defined for \"${CERT_FILE}\"%b" "${RED}" "${STD}"
        fi
      fi

      #--- Check certificate expiration date
      nowTS=$(date -d $(date +%H%M) +%s)
      certEndDateExpiration=$(echo "${x509InfoCert}" | grep "Not After :" | sed -e "s+ *Not After : ++")
      certEndTs=$(date -d "${certEndDateExpiration}" +%s)
      certBeginDateExpiration=$(echo "${x509InfoCert}" | grep "Not Before:" | sed -e "s+ *Not Before: ++")
      certBeginTs=$(date -d "${certBeginDateExpiration}" +%s)
      if [ ${certBeginTs} -gt ${nowTS} ] ; then
        printf "\n%bKO : Certificate will be active on (${certBeginDateExpiration})%b" "${RED}" "${STD}"
      fi

      if [ ${certEndTs} -gt $((${nowTS} + ${CERT_EXPIRATION})) ] ; then
        next=1
      else
        printf "\n%bKO : Certificate \"${CERT_FILE}\" has expired or will do soon (${certEndDateExpiration})%b" "${RED}" "${STD}"
      fi
    fi
  fi
}

#--- Check string in secrets files
checkSecretsFiles() {
  string="$1"

  nb=$(find . -name "*.yml" ! -regex ".*enable-deployment\.yml" ! -regex ".*last-deployment-failure\.yml" ! -wholename "./coa/pipelines/*/*.yml" -type f -print0 | xargs -0 grep -v "^ *#" | grep -c "${string}")
  if [ ${nb} != 0 ] ; then
    printf "\n%bKO : Found ${nb} occurences of \"${string}\" in secrets repository%b\n" "${RED}" "${STD}"
    find . -name "*.yml" ! -regex ".*enable-deployment\.yml" ! -regex ".*last-deployment-failure\.yml" ! -wholename "./coa/pipelines/*/*.yml" -type f -print0 | xargs -0 grep --color=always -v "^ *#" | grep --color=always "${string}"
  else
    printf "\n%bOK%b : No \"${string}\" found in secrets repository" "${GREEN}" "${STD}"
  fi
}

#--- Get a parameter in specified yaml file (trap propertie error to exit from all subshells levels)
set -E
trap '[ "$?" -ne 77 ] || exit 77' ERR
getValue() {
  path="$1"
  file="$2"
  mode="$3"

  value=$(bosh int ${file} --path ${path} 2> /dev/null)
  if [ $? != 0 ] ; then
    printf "\n%bERROR: Propertie \"${path}\" unknown in \"${file}\".%b\n\n" "${REVERSE}${RED}" "${STD}" >&2
    if [ "${mode}" = "exit" ] ; then
      exit 77
    else
      printf ""
    fi
  else
    printf "${value}"
  fi
  trap - ERR
}

#--- Get a property in credhub
checkCredhubValue() {
  path="$1"
  expected_value="$2"
  type_value="$3"

  if [ "${type_value}" = "" ] ; then
    value="$(credhub g -n ${path} -j | jq -r '.value' 2> /dev/null)"
  else
    value="$(credhub g -k ${type_value} -n ${path} -j | jq -r '.value' 2> /dev/null)"
  fi

  if [ "${value}" != "${expected_value}" ] ; then
    printf "\n%bKO : Property \"${path}\" not set with \"${expected_value}\" in credhub%b" "${RED}" "${STD}"
  else
    printf "\n%bOK%b : Property \"${path}\" correctly set in credhub" "${GREEN}" "${STD}"
  fi
}

#--- Check if bucket exist
checkBucket() {
  buckets="$(mc ls minio)"
  for bucket in ${BUCKETS_LIST} ; do
    result="$(echo "${buckets}" | grep "${bucket}")"
    if [ "${result}" = "" ] ; then
      printf "\n%bKO : Bucket \"${bucket}\" is not available%b" "${RED}" "${STD}"
    else
      nb="$(mc find minio/${bucket} | wc -l)"
      if [ "${nb}" = 0 ] ; then
        printf "\n%bKO : Bucket \"${bucket}\" is empty%b" "${RED}" "${STD}"
      else
        printf "\n%bOK%b : Bucket \"${bucket}\" is available (${nb} components)" "${GREEN}" "${STD}"
      fi
    fi
  done
}

#--- Log to credhub
logToCredhub() {
  credhub f > /dev/null 2>&1
  if [ $? != 0 ] ; then
    credhub login > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: LDAP authentication failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
    fi
  fi
}

#--- Configure host in minio cli
configureMinioHost() {
  alias="minio"
  endpoint="http://private-s3.internal.paas:9000"
  accessKey="private-s3"
  secretKey="$(credhub g -n  /micro-bosh/01-ci-k8s/minio-secret-key -q 2> /dev/null)"
  if [ -z "$secretKey" ]; then
    echo "WARNING - '/micro-bosh/01-ci-k8s/minio-secret-key' not defined, trying '/micro-bosh/k8s-minio/minio-secret-key'"
    secretKey="$(credhub get -n "/micro-bosh/k8s-minio/minio-secret-key" -q 2>/dev/null)"
  fi
  if [ -z "$secretKey" ]; then
    echo "ERROR - '/micro-bosh/01-ci-k8s/minio-secret-key' not defined, nor '/micro-bosh/k8s-minio/minio-secret-key'"
    exit 1
  fi


  if [ "${secretKey}" = "" ] ; then
    printf "\n\n%bERROR : minio secret key unknown.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  fi

  mc config host rm ${alias}
  mc config host add ${alias} ${endpoint} ${accessKey} ${secretKey} -api S3v2
  if [ $? != 0 ] ; then
    printf "\n\n%bERROR : Set minio config failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
  fi
}

#--- Script properties
SECRETS_REPO_DIR="${HOME}/bosh/secrets"
SHARED_CERT_DIR="${SECRETS_REPO_DIR}/shared/certs"
SHARED_SECRETS="${SECRETS_REPO_DIR}/shared/secrets.yml"
COA_PROFILES="${SECRETS_REPO_DIR}/coa/config/credentials-active-profiles.yml"

#--- Check files availability
verifyDirectory "${SECRETS_REPO_DIR}"
verifyDirectory "${SHARED_CERT_DIR}"
verifyFile "${SHARED_SECRETS}"
verifyFile "${COA_PROFILES}"

#--- Default certificate expiration (in days)
CERT_EXPIRATION_IN_DAYS=60

#--- Certificates expiration in seconds
CERT_EXPIRATION=$((${CERT_EXPIRATION_IN_DAYS} * 86400))

#export CREDHUB_SERVER="https://credhub.internal.paas:8844"
export CREDHUB_CA_CERT="${BOSH_CA_CERT}"
export CREDHUB_CLIENT="director_to_credhub"
export CREDHUB_SECRET="$(getValue "/secrets/bosh_credhub_secrets" ${SHARED_SECRETS} "exit")"
OPS_DOMAIN="$(getValue "/secrets/ops_interco/ops_domain" ${SHARED_SECRETS} "exit")"
OPS_DOMAIN_IP="$(getValue "/secrets/intranet_interco_ips/ops" ${SHARED_SECRETS} "exit")"

logToCredhub
configureMinioHost

display "Update your secrets repository"
cd ${SECRETS_REPO_DIR}
git pull --rebase ; git fetch --prune