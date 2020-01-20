#!/bin/bash
#===========================================================================
# Delete director keys and certs (except nats and coab instances)
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Select BOSH director
flag=0
while [ ${flag} = 0 ] ; do
  flag_next=1
  printf "\n%bSelect bosh director :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
  printf "%b1%b : master\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b2%b : ops\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b3%b : coab\n" "${GREEN}${BOLD}" "${STD}"
  printf "%b4%b : kubo\n" "${GREEN}${BOLD}" "${STD}"
  printf "%bq%b : quit\n" "${GREEN}${BOLD}" "${STD}"
  printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
  case "${choice}" in
    1) director="bosh-master" ; namespace="micro-bosh" ;;
    2) director="bosh-ops" ; namespace="bosh-master" ;;
    3) director="bosh-coab" ; namespace="bosh-master" ;;
    4) director="bosh-kubo" ; namespace="bosh-master" ;;
    q) printf "\n" ; exit ;;
    *) flag_next=0 ;;
  esac

  if [ ${flag_next} = 1 ] ; then
    #--- Log to credhub
    credhub f > /dev/null 2>&1
    if [ $? != 0 ] ; then
      printf "\n%bEnter CF LDAP user and password :%b\n" "${REVERSE}${YELLOW}" "${STD}"
      credhub api --server=${CREDHUB_API} > /dev/null 2>&1
      credhub login
      if [ $? != 0 ] ; then
        printf "\n%bERROR : Bad LDAP authentication.%b\n\n" "${RED}" "${STD}" ; exit
      fi
    fi

    #--- Identify every director certs in credhub
    printf "\n%bDelete \"${director}\" director credhub certificates...%b\n" "${REVERSE}${YELLOW}" "${STD}"
    director_certs="blobstore_ca blobstore_server_tls default_ca director_ssl mbus_bootstrap_ssl nats_clients_health_monitor_tls nats_server_tls nats_clients_director_tls nats_ca uaa_service_provider_ssl uaa_ssl"

    for cert in ${director_certs} ; do
      cert_path="/${namespace}/${director}/${cert}"
      printf "\n%b- Delete credhub cert \"${cert_path}\"%b" "${YELLOW}" "${STD}"
      credhub d -n ${cert_path} > /dev/null 2>&1
    done
    printf "\n"
  fi
done

printf "\n\n"