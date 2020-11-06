#!/bin/bash
#===========================================================================
# Init LDAP schemas for PAAS and PWM
#===========================================================================

LDAP_SERVER="elpaaso-ldap.internal.paas"
LDAP_ROOT_DN="cn=manager,dc=orange,dc=com"
INIT_SCHEMA_LDIF="init-schema.ldif"
PWM_LDIF="pwm.schema.ldif"
DEFAULT_USERS="default-users.ldif"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

catchValue() {
  flag=0
  while [ ${flag} = 0 ] ; do
    clear
    printf "%b%s :%b " "${REVERSE}${YELLOW}" "$2" "${STD}" ; read value
    if [ "${value}" != "" ] ; then
      flag=1
    fi
  done
  eval "$1=${value}"
}

flagError=0
if [ ! -s ${INIT_SCHEMA_LDIF} ] ; then
  printf "\n%bERROR : File \"${INIT_SCHEMA_LDIF}\" unknown.%b\n\n" "${RED}" "${STD}"
  flagError=1
fi
if [ ! -s ${PWM_LDIF} ] ; then
  printf "\n%bERROR : File \"${PWM_LDIF}\" unknown.%b\n\n" "${RED}" "${STD}"
  flagError=1
fi
if [ ! -s ${DEFAULT_USERS} ] ; then
  printf "\n%bERROR : File \"${DEFAULT_USERS}\" unknown.%b\n\n" "${RED}" "${STD}"
  flagError=1
fi

if [ ${flagError} = 0 ] ; then
  #--- Install ldap tools (if not available)
  flag=$(which ldapadd > /dev/null 2>&1)
  if [ $? != 0 ] ; then
    sudo http_proxy=http://system-internet-http-proxy.internal.paas:3128 apt-get install -y ldapscripts 2>&1
  fi

  #--- Verify LDAP access
  catchValue "LDAP_ROOT_PWD" "LDAP root password"
  catchValue "LDAP_DB_PWD" "LDAP database password"
  flag=$(ldapsearch -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -b "" -s base "objectclass=*")
  if [ $? != 0 ] ; then
    printf "\n%bERROR : LDAP access failed.%b\n\n" "${RED}" "${STD}"
  else
    #--- Create LDAP structure
    clear
    printf "%bInitialize PAAS LDAP schema:%b\n" "${REVERSE}${YELLOW}" "${STD}"
    ldapadd -c -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f ${INIT_SCHEMA_LDIF}
    printf "%bInitialize PWM LDAP schema:%b\n" "${REVERSE}${YELLOW}" "${STD}"
    ldapadd -c -x -D "cn=config" -w ${LDAP_DB_PWD} -h ${LDAP_SERVER} -p 389 -f ${PWM_LDIF}
    printf "\n%bCreate default users:%b\n\n" "${REVERSE}${YELLOW}" "${STD}"
    ldapadd -c -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f "${DEFAULT_USERS}"
    printf "\n%bLDAP schemas completed.%b\n\n" "${REVERSE}${GREEN}" "${STD}"
  fi
fi