#!/bin/bash
#===========================================================================
# Check pki and credhub certs
# Parameters :
# --coab-excluded, -c : Check certs without coab instances
# --expiry, -e        : Expiration delay (in days)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script parameters
TMP_CERT="/tmp/cert.crt"
FLAG_CHECK_ALL=1

#--- Current date
NOW_TS=$(date -d $(date +%H%M) +%s)

#--- Check prerequisites
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--coab-excluded, -c" "Check certs without coab instances"
  printf "\n  %-40s %s" "--expiry, -e" "Expiration delay (in days)"
  printf "%b\n\n"  "${STD}"
  exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-c"|"--coab-excluded") FLAG_CHECK_ALL=0 ; shift ;;
    "-e"|"--expiry") CERT_EXPIRATION_IN_DAYS=$2 ; shift ; shift ;;
    *) usage ;;
  esac
done

#--- Certificates expiration in seconds
CERT_EXPIRATION=$((${CERT_EXPIRATION_IN_DAYS} * 86400))

#--- Check PKI certificates
checkPKICert() {
  CERT_DIR="$1"
  if [ -d ${SHARED_CERT_DIR}/${CERT_DIR} ] ; then
    #--- Private key and certificate files
    printf "%bCheck \"${CERT_DIR}\"%b\n" "${REVERSE}${YELLOW}" "${STD}"
    KEY_FILE="${SHARED_CERT_DIR}/${CERT_DIR}/server.key"
    CERT_FILE="${SHARED_CERT_DIR}/${CERT_DIR}/server.crt"
    flagNext=0

    #--- Check private key an cert files
    if [ ! -s ${KEY_FILE} ] ; then
      printf "%bKO%b: Key file \"${KEY_FILE}\" unknown\n" "${RED}" "${STD}" ; flagNext=1
    fi

    if [ ! -s ${CERT_FILE} ] ; then
      printf "%bKO%b: Certificate file \"${CERT_FILE}\" unknown\n" "${RED}" "${STD}" ; flagNext=1
    fi

    if [ ${flagNext} = 0 ] ; then
      #--- Check if cert/key contains CR/LF
      flagKey=$(grep -U $'\015' ${KEY_FILE})
      if [ "${flagKey}" != "" ] ; then
        printf "%bKO%b: Key uses CR/LF characters\n" "${RED}" "${STD}"
      fi

      flagCert=$(grep -U $'\015' ${CERT_FILE})
      if [ "${flagCert}" != "" ] ; then
        printf "%bKO%b: Certificate uses CR/LF characters\n" "${RED}" "${STD}"
      fi

      #--- Check private key and certificate consistency
      modulusKey=$(openssl rsa -noout -modulus -in ${KEY_FILE} | openssl md5)
      modulusCert=$(openssl x509 -noout -modulus -in ${CERT_FILE} | openssl md5)
      if [ "${modulusKey}" != "${modulusCert}" ] ; then
        printf "%bKO%b: Private key and certificate are inconsistent\n" "${RED}" "${STD}"
      fi

      #--- Check SHA2 algorithm
      x509InfoCert=$(openssl x509 -text -noout -in ${CERT_FILE})
      certAlgorithm=$(echo "${x509InfoCert}" | grep "Signature Algorithm: sha256WithRSAEncryption")
      if [ "${certAlgorithm}" = "" ] ; then
        printf "%bKO%b: Certificate algorithm is not SHA2\n" "${RED}" "${STD}"
      fi

      #--- Check PKI issuer
      certIssuer=$(echo "${x509InfoCert}" | grep "Issuer: .*Orange Internal G2 Server CA")
      if [ "${certIssuer}" = "" ] ; then
        printf "%bKO%b: Certificate issuer is not PKI\n" "${RED}" "${STD}"
      fi

      #--- Check if cert is defined on wildcard domain
      DomainWildcard=$(echo "${x509InfoCert}" | grep "Subject:.*CN =" | sed -e "s+.*Subject:.*CN = ++")
      if [ "${DomainWildcard}" = "" ] ; then
        printf "%bKO%b: No CN defined for certificate\n" "${RED}" "${STD}"
      else
        printf "%bOK%b: CN \"${DomainWildcard}\"\n" "${GREEN}" "${STD}"
      fi

      DNSWildcard=$(echo "${x509InfoCert}" | grep "DNS:\*" | sed -e "s+DNS:++g" | sed -e "s+^ *++g")
      if [ "${DNSWildcard}" = "" ] ; then
        printf "%bKO%b: No SAN defined for certificate\n" "${RED}" "${STD}"
      fi
      if [ "${CERT_DIR}" = "ops-certs" ] ; then
        flag="$(echo "${DNSWildcard}" | grep "*.jcr.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "%bKO%b: SAN \"*.jcr.${OPS_DOMAIN}\" not defined\n" "${RED}" "${STD}"
        fi
        flag="$(echo "${DNSWildcard}" | grep "*.jcr-k8s.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "%bKO%b: SAN \"*.jcr-k8s.${OPS_DOMAIN}\" not defined\n" "${RED}" "${STD}"
        fi
        flag="$(echo "${DNSWildcard}" | grep "*.k8s-serv.${OPS_DOMAIN}")"
        if [ "${flag}" = "" ] ; then
          printf "%bKO%b: SAN \"*.k8s-serv.${OPS_DOMAIN}\" not defined\n" "${RED}" "${STD}"
        fi
      fi

      #--- Check certificate expiration date
      nowTS=$(date -d $(date +%H%M) +%s)
      certEndDateExpiration=$(echo "${x509InfoCert}" | grep "Not After :" | sed -e "s+ *Not After : ++")
      certEndTs=$(date -d "${certEndDateExpiration}" +%s)
      certBeginDateExpiration=$(echo "${x509InfoCert}" | grep "Not Before:" | sed -e "s+ *Not Before: ++")
      certBeginTs=$(date -d "${certBeginDateExpiration}" +%s)
      if [ ${certBeginTs} -gt ${nowTS} ] ; then
        printf "%bKO%b: Certificate will be active on (${certBeginDateExpiration})\n" "${RED}" "${STD}"
      fi

      if [ ${certEndTs} -gt $((${nowTS} + ${CERT_EXPIRATION})) ] ; then
        printf "%bOK%b: Certificate will expire on ${certEndDateExpiration}\n" "${GREEN}" "${STD}"
      else
        printf "%bKO%b: Certificate has expired or will do soon (${certEndDateExpiration})\n" "${RED}" "${STD}"
      fi
    fi
  fi
}

#--- Check certificate expiration date
checkCertExpiration() {
  name="$1"
  expirationDate="$2"
  certEndTs=$(date -d "${expirationDate}" +%s)

  if [ ${certEndTs} -le ${NOW_TS} ] ; then
    printf "\n- %b${expirationDate}%b: ${name}" "${RED}" "${STD}"
  else
    if [ ${certEndTs} -gt $((${NOW_TS} + ${CERT_EXPIRATION})) ] ; then
      next=1
    else
      printf "\n- %b${expirationDate}%b: ${name}" "${ORANGE}" "${STD}"
    fi
  fi
}

#--- Check certificate expiration date
checkCredhubCert() {
  certName=$(echo "$1" | awk -F "|" '{print $2}')
  certExpiration=$(echo "$1" | awk -F "|" '{print $1}')
  certExpiration=$(date -d "${certExpiration}" "+%Y-%m-%d")
  checkCertExpiration "${certName}" "${certExpiration}"
}

#--- Log to credhub-uaa to get a bearer token, and get all certs defined in credhub (except unused "internalCA2")
executeCredhubCurl "GET" "data?name-like=/&expires-within-days=${CERT_EXPIRATION_IN_DAYS}"

#===========================================================================
# Check PKI certificates secrets files
#===========================================================================
printf "\n%bCheck PKI certificates...%b\n\n" "${REVERSE}${GREEN}" "${STD}"
checkPKICert "api-certs"
checkPKICert "ops-certs"
checkPKICert "osb-certs"
checkPKICert "intranet-1-certs"
checkPKICert "intranet-2-certs"
checkPKICert "dnsaas-certs"

#===========================================================================
# Check credhub certificates
#===========================================================================
if [ "${CREDHUB_API_RESULT}" = "" ] ; then
  printf "\n%bCheck credhub certificates...%b\n" "${REVERSE}${GREEN}" "${STD}"
  printf "\n%bNo credhub certificate will expire within ${CERT_EXPIRATION_IN_DAYS} days.%b\n\n" "${GREEN}" "${STD}"
else
  certs_names=$(echo "${CREDHUB_API_RESULT}" | jq -r '.credentials[]|.expiry_date + "|" + .name' | grep -v "/internalCA2$" | LC_ALL=C sort)

  if [ ${FLAG_CHECK_ALL} = 1 ] ; then
    msg="(with coab instances)"
  else
    msg="(without coab instances)"
    certs_names=$(echo "${certs_names}" | grep -v "|/bosh-coab/[a-z][-_]")
  fi

  printf "\n%bCheck credhub certificates ${msg} that will expire within ${CERT_EXPIRATION_IN_DAYS} days...%b\n" "${REVERSE}${GREEN}" "${STD}"
  if [ "${certs_names}" = "" ] ; then
    printf "\n%bNo credhub certificate will expire within ${CERT_EXPIRATION_IN_DAYS} days.%b\n\n" "${GREEN}" "${STD}"
  else
    #--- Check every certs in credhub
    for cert in ${certs_names} ; do
      checkCredhubCert "${cert}"
    done
    printf "\n\n"
  fi
fi