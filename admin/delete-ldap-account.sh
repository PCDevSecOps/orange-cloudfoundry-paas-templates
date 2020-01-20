#!/bin/bash
#===========================================================================
# Delete LDAP account
#===========================================================================

LDAP_SERVER="elpaaso-ldap.internal.paas"
LDAP_ROOT_DN="cn=manager,dc=orange,dc=com"
ADMIN_GROUP="admin / auditor"
DELETE_ACCOUNT_LDIF="delete-account.ldif"

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

#--- Install ldap tools (if not available)
flag=$(which ldapadd > /dev/null 2>&1)
if [ $? != 0 ] ; then
  sudo apt-get install ldapscripts
fi

catchValue "LDAP_ROOT_PWD" "LDAP root password"
flag=$(ldapsearch -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -b "" -s base "objectclass=*")
if [ $? != 0 ] ; then
  printf "\n%bERROR : LDAP access failed.%b\n\n" "${RED}" "${STD}"
else
  #--- Delete account and link with group
  catchValue "UID" "Account (first surname letter + name)"
  catchValue "GROUP_TYPE" "Group type (${ADMIN_GROUP})"
  result=$(echo " ${ADMIN_GROUP} " | grep " ${GROUP_TYPE} ")
  if [ "${result}" = "" ] ; then
    printf "\n%bERROR : LDAP \"${GROUP_TYPE}\" group type unauthorised.%b\n\n" "${RED}" "${STD}"
    exit 1
  fi

  ldapdelete -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} "uid=${UID},ou=users,dc=orange,dc=com"

  cat > ${DELETE_ACCOUNT_LDIF} <<EOF
dn: cn=${GROUP_TYPE},ou=paas-groups,ou=groups,dc=orange,dc=com
changetype: modify
delete: uniqueMember
uniqueMember: uid=${UID},ou=users,dc=orange,dc=com
EOF

  ldapmodify -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f ${DELETE_ACCOUNT_LDIF}
  rm -f ${DELETE_ACCOUNT_LDIF} > /dev/null 2>&1
fi