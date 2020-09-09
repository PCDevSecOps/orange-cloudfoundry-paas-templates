#!/bin/bash
#===========================================================================
# Check external certificate consistency and validity
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Certificate expiration in seconds (60 days)
CERT_EXPIRATION=5184000

#--- Script status
RETCODE=0

display()
{
  case "$1" in
    "OK") printf " %bOK%b: %s\n" "${GREEN}" "${STD}" "$2"  ;;
    "KO") printf " %bKO%b: %s\n" "${RED}" "${STD}" "$2" ;;
    "INFO") printf "\n%b%s...\n%b" "${REVERSE}${YELLOW}" "$2" "${STD}" ;;
    "ERROR") printf "\n%b%s.\n\n%b" "${REVERSE}${RED}" "$2" "${STD}" ; exit 1 ;;
  esac
}

checkCertificate() {
  if [ -d ${ROOT_CERT_DIR}/${CERT_DIR} ] ; then
    #--- Private key and certificate files
    printf "%bCheck certificate on \"${CERT_DIR}\"%b\n" "${REVERSE}${YELLOW}" "${STD}"
    KEY_FILE="${ROOT_CERT_DIR}/${CERT_DIR}/server.key"
    CERT_FILE="${ROOT_CERT_DIR}/${CERT_DIR}/server.crt"
    flagNext=0

    #--- Check private key an certs file
    if [ ! -s ${KEY_FILE} ] ; then
      display "KO" "Key file \"${KEY_FILE}\" unknown"
      flagNext=1
      RETCODE=1
    fi

    if [ ! -s ${CERT_FILE} ] ; then
      display "KO" "Cert file \"${CERT_FILE}\" unknown"
      flagNext=1
      RETCODE=1
    fi

    if [ ${flagNext} = 0 ] ; then
      #--- Check if cert/key contains CR/LF
      flagKey=$(grep -U $'\015' ${KEY_FILE})
      if [ "${flagKey}" = "" ] ; then
        display "OK" "Key uses LF character"

      else
        display "KO" "Key uses CR/LF characters"
        RETCODE=1
      fi

      flagCert=$(grep -U $'\015' ${CERT_FILE})
      if [ "${flagCert}" = "" ] ; then
        display "OK" "Cert uses LF character"

      else
        display "KO" "Cert uses CR/LF characters"
        RETCODE=1
      fi

      #--- Check private key and certificate consistency
      modulusKey=$(openssl rsa -noout -modulus -in ${KEY_FILE} | openssl md5)
      modulusCert=$(openssl x509 -noout -modulus -in ${CERT_FILE} | openssl md5)

      if [ "${modulusKey}" = "${modulusCert}" ] ; then
        display "OK" "Private key and certificate are consistent"
      else
        display "KO" "Private key and certificate are inconsistent"
        RETCODE=1
      fi

      #--- Check SHA2 algorithm
      x509InfoCert=$(openssl x509 -text -noout -in ${CERT_FILE})
      certAlgorithm=$(echo "${x509InfoCert}" | grep "Signature Algorithm: sha256WithRSAEncryption")

      if [ "${certAlgorithm}" = "" ] ; then
        display "KO" "Certificate algorithm is not SHA2"
        RETCODE=1
      else
        display "OK" "Certificate use SHA2 algorithm"
      fi

      #--- Check PKI issuer
      certIssuer=$(echo "${x509InfoCert}" | grep "Issuer: .*Orange Internal G2 Server CA")

      if [ "${certIssuer}" = "" ] ; then
        display "KO" "Certificate issuer is not PKI"
        RETCODE=1
      else
        display "OK" "Certificate issuer is PKI"
      fi

      #--- Check if cert is defined on wildcard domain
      DomainWildcard=$(echo "${x509InfoCert}" | grep "Subject:.*CN =" | sed -e "s+.*Subject:.*CN = ++")

      if [ "${DomainWildcard}" = "" ] ; then
        display "KO" "No wildcard domain defined for certificate"
        RETCODE=1
      else
        display "OK" "Certificate is defined for domain \"${DomainWildcard}\""
      fi

      DNSWildcard=$(echo "${x509InfoCert}" | grep "DNS:\*" | sed -e "s+DNS:++g" | sed -e "s+^ *++g")

      if [ "${DNSWildcard}" = "" ] ; then
        display "KO" "No wildcard DNS defined for certificate"
        RETCODE=1
      else
        display "OK" "Certificate is defined for wildcard DNS \"${DNSWildcard}\""
      fi

      #--- Check certificate expiration date
      nowTS=$(date -d $(date +%H%M) +%s)
      certEndDateExpiration=$(echo "${x509InfoCert}" | grep "Not After :" | sed -e "s+ *Not After : ++")
      certEndTs=$(date -d "${certEndDateExpiration}" +%s)
      certBeginDateExpiration=$(echo "${x509InfoCert}" | grep "Not Before:" | sed -e "s+ *Not Before: ++")
      certBeginTs=$(date -d "${certBeginDateExpiration}" +%s)

      if [ ${certBeginTs} -lt ${nowTS} ] ; then
        display "OK" "Certificate is active since ${certBeginDateExpiration}"
      else
        display "KO" "Certificate will be active on (${certBeginDateExpiration})"
        RETCODE=1
      fi

      if [ ${certEndTs} -gt $((${nowTS} + ${CERT_EXPIRATION})) ] ; then
        display "OK" "Certificate will expire on ${certEndDateExpiration}"
      else
        display "KO" "Certificate has expired or will do soon (${certEndDateExpiration})"
        RETCODE=1
      fi
    fi

    if [ ${RETCODE} = 0 ] ; then
      printf "%b%s%b\n\n" "${GREEN}" "Certificate \"${CERT_FILE}\" is valid" "${STD}"
    else
      printf "%b%s%b\n\n" "${RED}" "Certificate \"${CERT_FILE}\" is not valid" "${STD}"
    fi
  fi
}

#===========================================================================
# Check certificates
#===========================================================================
cpt=0

while [ ${cpt} -lt 5 ]
do
  RETCODE=0
  cpt=$(expr ${cpt} + 1)
  case ${cpt} in
    1) CERT_DIR="api-certs" ;;
    2) CERT_DIR="intranet-1-certs" ;;
    3) CERT_DIR="intranet-2-certs" ;;
    4) CERT_DIR="ops-certs" ;;
    5) CERT_DIR="osb-certs" ;;
  esac

  checkCertificate
done