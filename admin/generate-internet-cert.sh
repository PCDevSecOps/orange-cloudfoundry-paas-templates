#!/bin/bash
#===============================================================================
# Generate certificates for internet access
#===============================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Check prerequisites
verifyFile "${SHARED_SECRETS}"

#--- Internet certs directory
CERT_DIR="${SECRETS_REPO_DIR}/shared/certs/internet-certs"
SERVER_CN=$(getValue ${SHARED_SECRETS} "/secrets/internet_interco/apps_domain")

#--- Expiration delay
EXPIRY_DAYS=3650

#--- Generate certs
clear
printf "\n%bGenerate new internet private key and certificate (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice
if [ "${choice}" != "y" ] ; then
  printf "\n" ; exit 1
fi

#--- Save old key and cert
if [ ! -d ${CERT_DIR} ] ; then
  mkdir -p ${CERT_DIR} > /dev/null 2>&1
fi

#--- Create conf file
cd ${CERT_DIR}
cat > openssl.conf <<EOF
[ req ]
default_bits       = 2048
default_md         = sha256
prompt             = no
distinguished_name = dn
x509_extensions    = v3_req

[ dn ]
commonName         = "${SERVER_CN}"

[ v3_req ]
keyUsage               = critical, digitalSignature, keyEncipherment, keyEncipherment, dataEncipherment, keyAgreement
extendedKeyUsage       = serverAuth, clientAuth
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
subjectAltName         = @alt_names

[ alt_names ]
DNS.1 = *.${SERVER_CN}
EOF

printf "%b- Generate key and certificate...%b\n" "${YELLOW}" "${STD}"
openssl req -new -x509 -nodes -days ${EXPIRY_DAYS} -newkey rsa:2048 -keyout pkcs8.key -out server.crt -config openssl.conf > /dev/null 2>&1
if [ $? != 0 ] ; then
  display "ERROR" "Generate certificate failed"
fi

openssl rsa -in pkcs8.key -out server.key > /dev/null 2>&1
if [ $? != 0 ] ; then
  display "ERROR" "Convert pkcs8 key to pkcs1 failed"
fi
rm -f pkcs8.key > /dev/null 2>&1

openssl x509 -text -noout -in server.crt | grep -E "Issuer:|Not Before:|Not After :| Subject:|Public-Key:" | sed -e "s+^ *++g"
rm -fr openssl.conf > /dev/null 2>&1

#--- Push updates on secrets repository
display "INFO" "Commit \"internet certs\" into secrets repository"
commitGit "secrets" "update_internet_certs"
printf "\n"