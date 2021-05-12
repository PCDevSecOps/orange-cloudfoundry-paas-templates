#!/bin/bash
#===========================================================================
# Check internalCA deployment on instances
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

RES_FILE="/tmp/result.tmp"
TMP_CERT="/tmp/certs.tmp"
> ${TMP_CERT}

usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--expiry, -e" "Expiration delay (in days)"
  printf "%b\n\n"  "${STD}"
  exit 1
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
    printf "\n- %b$3%b: $1 ($2)" "${RED}" "${STD}"
  else
    if [ ${certEndTs} -gt $((${NOW_TS} + ${CERT_EXPIRATION})) ] ; then
      printf "\n- %b$3%b: $1 ($2)" "${GREEN}" "${STD}"
    else
      printf "\n- %b$3%b: $1 ($2)" "${ORANGE}" "${STD}"
    fi
  fi
}

#--- Collect certificate in bosh instances
collectInternalCACert() {
  boshInstances="$(bosh -d $1 is --json | jq -r '.Tables[].Rows[]|select(.process_state == "running")|.instance')"
  for instance in ${boshInstances} ; do
    printf "\n%b- Collect cert on \"${instance}\"..." "${STD}"
    bosh -d $1 ssh ${instance} -c 'openssl crl2pkcs7 -nocrl -certfile /etc/ssl/certs/ca-certificates.crt | openssl pkcs7 -print_certs -text -noout | grep -B1 "Subject: .* CN=internalCA" | grep "Not After :"' | grep ": stdout" | sed -e "s+: stdout.*Not After : +|+" | sort -u  | head -1 > ${RES_FILE}
    sed -e "s+^+$1|+g" ${RES_FILE} | sed -e "s+\r++g" >> ${TMP_CERT}
  done
}

#--- Log to a specific bosh director
selectBoshDirector

#--- Collect internalCA cert in bosh deployments instances
printf "\n%bCollect internalCA cert from \"${BOSH_DIRECTOR_NAME}\" bosh instances%b\n" "${REVERSE}${YELLOW}" "${STD}"
CERT_EXPIRATION=$((${CERT_EXPIRATION_IN_DAYS} * 86400))
NOW_TS=$(date -d $(date +%H%M) +%s)
deployments=$(bosh deployments --json | jq -r '.Tables[].Rows[].name')

for deployment in ${deployments} ; do
  collectInternalCACert "${deployment}"
done

#--- Check expiration date
printf "\n\n%bCheck \"${BOSH_DIRECTOR_NAME}\" internalCA cert expiration date%b\n" "${REVERSE}${YELLOW}" "${STD}"

while IFS='|' read deployment instance expirationDate ; do
  if [ "${instance}" != "" ] ; then
    checkCertExpiration "${deployment}" "${instance}" "${expirationDate}"
  fi
done < ${TMP_CERT}

rm -fr ${RES_FILE} ${TMP_CERT} > /dev/null 2>&1
printf "\n\n"