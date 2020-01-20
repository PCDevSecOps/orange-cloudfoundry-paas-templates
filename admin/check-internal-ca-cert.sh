#!/bin/bash
#===========================================================================
# Check internalCA deployment on instances
#===========================================================================

#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export ORANGE='\033[0;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Certificate expiration (default: 60 days)
CERT_EXPIRATION_IN_DAYS=60

RES_FILE="/tmp/result.tmp"
TMP_CERT="/tmp/certs.tmp"
> ${TMP_CERT}

usage() {
  printf "\n%bUSAGE:" "${BOLD}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--expiry, -e" "Expiration delay (in days)"
  printf "%b\n\n"  "${STD}"
  exit
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-e"|"--expiry") CERT_EXPIRATION_IN_DAYS=$2 ; shift ; shift ;;
    *) usage ;;
  esac
done

#--- Check certificate expiration date
checkCertExpiration() {
  certEndTs=$(date -d "$3" +%s)
  if [ ${certEndTs} -le ${NOW_TS} ] ; then
    printf "\n- %b$3%b : $1 ($2)" "${RED}" "${STD}"
  else
    if [ ${certEndTs} -gt $((${NOW_TS} + ${CERT_EXPIRATION})) ] ; then
      printf "\n- %b$3%b : $1 ($2)" "${GREEN}" "${STD}"
    else
      printf "\n- %b$3%b : $1 ($2)" "${ORANGE}" "${STD}"
    fi
  fi
}

#--- Check certificate in bosh instances
checkinternalCACert() {
  boshInstances=$(bosh -d $1 instances | grep "running" | awk '{print $1}')
  for instance in ${boshInstances} ; do
    printf "\n%b- Collect \"${instance}\"...%b" "${YELLOW}" "${STD}"
    bosh -d $1 ssh ${instance} -c 'openssl crl2pkcs7 -nocrl -certfile /etc/ssl/certs/ca-certificates.crt | openssl pkcs7 -print_certs -text -noout | grep -B1 "Subject: .* CN=internalCA" | grep "Not After :"' | grep ": stdout" | sed -e "s+: stdout.*Not After : +|+" | sort -u  | head -1 > ${RES_FILE}
    sed -e "s+^+$1|+g" ${RES_FILE} | sed -e "s+\r++g" >> ${TMP_CERT}
  done
}

#--- Check if loged to bosh
bosh env > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bERROR : You are not login to bosh director. Use \"log-bosh\".%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Collect internalCA cert in bosh deployments instances
bosh_director=$(bosh env --json | jq -r '.Tables[].Rows[].name')
printf "\n%bCollect internalCA cert from \"${bosh_director}\" bosh instances%b\n" "${REVERSE}${YELLOW}" "${STD}"
CERT_EXPIRATION=$((${CERT_EXPIRATION_IN_DAYS} * 86400))
NOW_TS=$(date -d $(date +%H%M) +%s)
deployments=$(bosh deployments --json | jq '.Tables[].Rows[].name' | sed -e "s+\"++g")

for deployment in ${deployments} ; do
  checkinternalCACert "${deployment}"
done

#--- Check expiration date
printf "\n\n%bCheck \"${bosh_director}\" internalCA cert expiration date%b\n" "${REVERSE}${YELLOW}" "${STD}"

while IFS='|' read deployment instance expirationDate ; do
  if [ "${instance}" != "" ] ; then
    checkCertExpiration "${deployment}" "${instance}" "${expirationDate}"
  fi
done < ${TMP_CERT}

rm -fr ${RES_FILE} ${TMP_CERT} > /dev/null 2>&1
printf "\n\n"
