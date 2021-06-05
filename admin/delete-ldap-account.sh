#!/bin/bash
#===========================================================================
# Delete LDAP account
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script properties
UNLINK_GROUP_LDIF="unlink-group.ldif"

#--- Install ldap tools (if not available)
flag=$(which ldapadd > /dev/null 2>&1)
if [ $? != 0 ] ; then
  sudo apt-get install ldapscripts
fi

catchValue "LDAP_ROOT_PWD" "LDAP root password" "mask"
flag=$(ldapsearch -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -b "" -s base "objectclass=*")
if [ $? != 0 ] ; then
  printf "\n%bERROR: LDAP access failed.%b\n\n" "${RED}" "${STD}"
else
  #--- Delete account and link with group
  printf "\n"
  catchValue "USER_ID" "Account (first surname letter + name)"
  catchValue "GROUP_TYPE" "Group type (${ADMIN_GROUP})"
  result=$(echo " ${ADMIN_GROUP} " | grep " ${GROUP_TYPE} ")
  if [ "${result}" = "" ] ; then
    printf "\n%bERROR: LDAP \"${GROUP_TYPE}\" group type unauthorised.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  cat > ${UNLINK_GROUP_LDIF} <<EOF
dn: cn=${GROUP_TYPE},ou=paas-groups,ou=groups,dc=orange,dc=com
changetype: modify
delete: uniqueMember
uniqueMember: uid=${USER_ID},ou=users,dc=orange,dc=com
EOF

  #--- Unlink user from selected group
  ldapmodify -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f ${UNLINK_GROUP_LDIF}
  rm -f ${UNLINK_GROUP_LDIF} > /dev/null 2>&1

  #--- Delete user
  ldapdelete -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} "uid=${USER_ID},ou=users,dc=orange,dc=com"
fi