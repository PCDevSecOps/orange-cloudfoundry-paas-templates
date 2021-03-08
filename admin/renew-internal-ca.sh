#!/bin/bash
#====================================================================
# Renew InternalCA cert with (change expiration date)
#====================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Expiration delay (in days)
EXPIRY_DAYS=3650

#--- Script parameters
TMP_CERT_DIR="/tmp/internalCA"
CONF_FILE="internalCA.cnf"
CSR_FILE="internalCA.csr"
NEW_INTERNAL_CA_CERT="internalCA.new"

printf "\n%bChange exiration date (+ ${EXPIRY_DAYS} days) on \"InternalCA\" cert file...%b\n" "${REVERSE}${YELLOW}" "${STD}"
rm -fr ${TMP_CERT_DIR} > /dev/null 2>&1
createDir ${TMP_CERT_DIR}
cd ${TMP_CERT_DIR}

#--- Generate configuration file for CSR
cat <<EOF > ${CONF_FILE}
[ v3_ca ]
keyUsage= critical,keyCertSign,cRLSign
basicConstraints= critical,CA:TRUE
EOF

#--- Generate CSR
openssl x509 -x509toreq -in ${INTERNAL_CA_CERT} -signkey ${INTERNAL_CA_KEY} -out ${CSR_FILE} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bERROR: CSR generation failed.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Regenerate cert
serialNumber=$(openssl x509 -in ${INTERNAL_CA_CERT} -serial -noout | cut -f2 -d=)
openssl x509 -req -days ${EXPIRY_DAYS} -set_serial 0x${serialNumber} -extfile ${CONF_FILE} -extensions v3_ca \
  -in ${CSR_FILE} -signkey ${INTERNAL_CA_KEY} -out ${NEW_INTERNAL_CA_CERT} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bERROR: Renew cert file failed.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

rm -f ${CSR_FILE} ${CONF_FILE} > /dev/null 2>&1

#--- Save CA cert file and rotate key and CA files
INTERNAL_CA2_DIR="$(dirname ${INTERNAL_CA2_CERT})"
createDir ${INTERNAL_CA2_DIR}
cp ${INTERNAL_CA_KEY} ${INTERNAL_CA2_KEY} > /dev/null 2>&1
cp ${INTERNAL_CA_CERT} ${INTERNAL_CA2_CERT} > /dev/null 2>&1
cp ${INTERNAL_CA_CERT} ${INTERNAL_CA_CERT}.$(date +%Y%m%d_%H%M%S) > /dev/null 2>&1
mv ${NEW_INTERNAL_CA_CERT} ${INTERNAL_CA_CERT} > /dev/null 2>&1

#--- Display difference between old cert and new one and check cert validity
OPENSSL_DISPLAY="openssl x509 -serial -issuer -subject -startdate -enddate -purpose -noout"
diff --suppress-common-lines -y <(${OPENSSL_DISPLAY} -in ${INTERNAL_CA_CERT}) <(${OPENSSL_DISPLAY} -in ${NEW_INTERNAL_CA_CERT})
result="$(diff --suppress-common-lines -y <(${OPENSSL_DISPLAY} -in ${INTERNAL_CA_CERT} | grep -vE "notBefore|notAfter" ) <(${OPENSSL_DISPLAY} -in ${NEW_INTERNAL_CA_CERT} | grep -vE "notBefore|notAfter"))"
if [ "${result}" != "" ] ; then
  printf "\n%bERROR: New cert file is not valid.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Push updates on secrets repository
printf "\n%bCommit \"internalCA\" cert files into secrets repository...%b\n" "${REVERSE}${YELLOW}" "${STD}"
commitGit "secrets" "update_internalCA_certs"
printf "\n"