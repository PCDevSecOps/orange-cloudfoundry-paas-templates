#!/bin/bash
#====================================================================
# Renew InternalCA cert with same private key (change expiration date)
#====================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Expiration delay (in days)
EXPIRY_DAYS=3650

#--- Script parameters
NEW_INTERNAL_CA_CERT="${INTERNAL_CA_CERT}.new"
CSR_CONF_FILE="/tmp/ca.conf"
CSR_FILE="/tmp/ca.csr"

display "INFO" "Change expiration date on InternalCA cert file \"${INTERNAL_CA_CERT}\""
openssl x509 -in ${INTERNAL_CA_CERT} -enddate -noout

#--- Generate CSR file from old ca cert
openssl x509 -x509toreq -in ${INTERNAL_CA_CERT} -signkey ${INTERNAL_CA_KEY} -out ${CSR_FILE} > /dev/null 2>&1
if [ $? != 0 ] ; then
  display "ERROR" "CSR generation failed"
fi

#--- Complete generated CSR with extensions and regenerate cert
serialNumber=$(openssl x509 -in ${INTERNAL_CA_CERT} -serial -noout | cut -f2 -d=)
printf "[ v3_ca ]\nkeyUsage= critical,keyCertSign,cRLSign\nbasicConstraints= critical,CA:TRUE\n\n" > ${CSR_CONF_FILE}

openssl x509 -req -days ${EXPIRY_DAYS} -in ${CSR_FILE} -set_serial 0x${serialNumber} -signkey ${INTERNAL_CA_KEY} -extfile ${CSR_CONF_FILE} -out ${NEW_INTERNAL_CA_CERT} -extensions v3_ca > /dev/null 2>&1
if [ $? != 0 ] ; then
  display "ERROR" "Renew InternalCA cert file failed"
fi

rm -f ${CSR_FILE} ${CSR_CONF_FILE} > /dev/null 2>&1

#--- Save CA cert file and rotate key and CA files
INTERNAL_CA2_DIR="$(dirname ${INTERNAL_CA2_CERT})"
if [ ! -d ${INTERNAL_CA2_DIR} ] ; then
  mkdir -p ${INTERNAL_CA2_DIR}
fi

cp ${INTERNAL_CA_KEY} ${INTERNAL_CA2_KEY} > /dev/null 2>&1
cp ${INTERNAL_CA_CERT} ${INTERNAL_CA2_CERT} > /dev/null 2>&1
cp ${INTERNAL_CA_CERT} ${INTERNAL_CA_CERT}.$(date +%Y%m%d_%H%M%S) > /dev/null 2>&1
mv ${NEW_INTERNAL_CA_CERT} ${INTERNAL_CA_CERT} > /dev/null 2>&1

#--- Push updates on secrets repository
display "INFO" "Commit \"internalCA certs\" into secrets repository"
commitGit "secrets" "update_internalCA_certs"

#--- Display new enddate
display "OK" "InternalCA updates"
OPENSSL_OPTIONS="-serial -issuer -subject -issuer -startdate -enddate -purpose -noout"
diff -y <(openssl x509 ${OPENSSL_OPTIONS} -in ${INTERNAL_CA2_CERT}) <(openssl x509 ${OPENSSL_OPTIONS} -in ${INTERNAL_CA_CERT})
printf "\n"