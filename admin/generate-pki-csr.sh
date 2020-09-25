#!/bin/bash
#===========================================================================
# Generate private key and CSR for PKI certs
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- CSR and keys files
KEY_FILE="server.key"
CSR_FILE="server.csr"

#--- Identify cert to create
flag=0
while [ ${flag} = 0 ] ; do
  clear
  printf "%bSelect cert to generate :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
  printf "%b1%b : CF API cert\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b2%b : APPS intranet-1 cert\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b3%b : APPS intranet-2 cert\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b4%b : OPS cert\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b5%b : OSB cert\n" "${GREEN}${BOLD}" "${STD}"
  printf "%bq%b : Quit\n" "${GREEN}${BOLD}" "${STD}"
  printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
  case "${choice}" in
    1) CERT_DIR="api-certs" ; CERT_DOMAIN="/secrets/cloudfoundry/system_domain" ;;
    2) CERT_DIR="intranet-1-certs" ; CERT_DOMAIN="/secrets/cloudfoundry/apps_domain" ;;
    3) CERT_DIR="intranet-2-certs" ; CERT_DOMAIN="/secrets/intranet_interco_2/apps_domain" ;;
    4) CERT_DIR="ops-certs" ; CERT_DOMAIN="/secrets/ops_interco/ops_domain" ;;
    5) CERT_DIR="osb-certs" ; CERT_DOMAIN="/secrets/osb_interco/osb_domain" ;;
    *) printf "\n" ; exit 1 ;;
  esac
done

#--- Create CSR and keys directory
CERT_DIR="${SECRETS_REPO_DIR}/shared/certs/${CERT_DIR}/ongoing"
if [ -d ${CERT_DIR} ] ; then
  rm -fr ${CERT_DIR} > /dev/null 2>&1
fi
mkdir -p ${CERT_DIR} > /dev/null 2>&1
cd ${CERT_DIR}

clear
SERVER_CN=$(getValue ${SHARED_SECRETS} ${CERT_DOMAIN})
printf "\n%bDo you want to generate new private key for \"${CERT_DIR}\" (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read confirmation
if [ "${confirmation}" = "y" ] ; then
  #--- Generate private key
  display "INFO" "Generate private key \"${KEY_FILE}\""
  openssl genrsa -out ${KEY_FILE} 2048
  if [ $? != 0 ] ; then
    display "ERROR" "Private key \"${KEY_FILE}\" generation failed"
  fi
else
  if [ -f ../${KEY_FILE} ] ; then
    cp ../${KEY_FILE} ./${KEY_FILE} > /dev/null 2>&1
  else
    display "ERROR" "Private key \"${KEY_FILE}\" unknown"
  fi
fi

#--- Create CSR conf file
cat > csr.conf <<EOF
[ req ]
default_bits       = 2048
default_md         = sha256
default_keyfile    = server.key
prompt             = no
encrypt_key        = no
distinguished_name = dn
req_extensions     = v3_req

[ dn ]
countryName            = "FR"
organizationName       = "ORANGE"
commonName             = "${SERVER_CN}"

[ v3_req ]
subjectAltName = @alt_names

EOF

if [ "${choice}" = "4" ] ; then
cat >> csr.conf <<EOF
[ alt_names ]
DNS.1 = *.${SERVER_CN}
DNS.2 = *.k8s-micro.${SERVER_CN}
DNS.3 = *.k8s-master.${SERVER_CN}
DNS.4 = *.k8s-serv.${SERVER_CN}
DNS.5 = *.jcr.${SERVER_CN}

EOF
else
cat >> csr.conf <<EOF
[ alt_names ]
DNS.1 = *.${SERVER_CN}

EOF
fi

display "INFO" "Generate CSR file \"${CSR_FILE}\""
openssl req -config csr.conf -new -key ${KEY_FILE} -out ${CSR_FILE} -verbose
if [ $? != 0 ] ; then
  display "ERROR" "CSR file \"${CSR_FILE}\" generation failed"
fi
rm -f csr.conf > /dev/null 2>&1

display "OK" "Private key \"${KEY_FILE}\" and CSR \"${CSR_FILE}\" generated"
openssl req -noout -text -in ${CSR_FILE}

display "INFO" "Commit private key \"${KEY_FILE}\" and CSR \"${CSR_FILE}\" into secrets repository"
commitGit "secrets" "update_pki_csr"
printf "\n"