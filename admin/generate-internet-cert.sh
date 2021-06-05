#!/bin/bash
#===============================================================================
# Generate certificates for internet access
#===============================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Internet certs directory
INTERNET_CERT_DIR="${SECRETS_REPO_DIR}/shared/certs/internet-certs"
SERVER_CN=$(getValue ${SHARED_SECRETS} "/secrets/internet_interco/apps_domain")

#--- Expiration delay in days (2 years)
EXPIRY_DAYS=730

#--- Generate cert in credhub
SetCredhubCert() {
  PATH_NAME="$1"
  CERT_FILE="$2"
  KEY_FILE="$3"
  printf "%b- Set \"${PATH_NAME}\" cert in credhub...%b\n" "${YELLOW}" "${STD}"

  #--- Check if credhub propertie exists
  flag_exist=$(credhub f | grep "name: ${PATH_NAME}")
  if [ "${flag_exist}" != "" ] ; then
    credhub delete -n ${PATH_NAME} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bERROR: \"${PATH_NAME}\" certificate deletion failed.%b\n\n" "${RED}" "${STD}" ; exit 1
    fi
  fi

  #--- Set certificate in credhub
  credhub set -t certificate -n ${PATH_NAME} -c ${CERT_FILE} -p ${KEY_FILE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    printf "\n%bERROR: \"${PATH_NAME}\" certificate creation failed.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi
}

#--- Generate cert
clear
printf "\n%bGenerate new internet private key and certificate (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
if [ "${choice}" != "y" ] ; then
  printf "\n" ; exit 1
fi

#--- Create conf file
createDir "${INTERNET_CERT_DIR}"
cd ${INTERNET_CERT_DIR}
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

#--- Insert certs in credhub (for automatic certs check)
logToCredhub
printf "\n%bSet keys and certs in credhub...%b\n" "${REVERSE}${YELLOW}" "${STD}"
SetCredhubCert "/micro-bosh/credhub-ha/credhub-certs" "server.crt" "server.key"

#--- Push updates on secrets repository
display "INFO" "Commit \"internet certs\" into secrets repository"
commitGit "secrets" "update_internet_certs"

printf "\n%bInternet cert generation done.%b\n\nCheck that concourse \"master-depls/master-depls-bosh-generated/deploy-cf-internet-rps\" deployment triggered.\n\n" "${REVERSE}${GREEN}" "${STD}"