#!/bin/bash
#===========================================================================
# Create LDAP account
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script properties
LDAP_SERVER="elpaaso-ldap.internal.paas"
LDAP_ROOT_DN="cn=manager,dc=orange,dc=com"
ADMIN_GROUP="admin / auditor"
CREATE_ACCOUNT_LDIF="create-account.ldif"

#--- Install ldap tools (if not available)
flag=$(which ldapadd > /dev/null 2>&1)
if [ $? != 0 ] ; then
  sudo apt-get install ldapscripts
fi

catchValue "LDAP_ROOT_PWD" "LDAP root password"
flag=$(ldapsearch -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -b "" -s base "objectclass=*")
if [ $? != 0 ] ; then
  printf "\n%bERROR: LDAP access failed.%b\n\n" "${RED}" "${STD}"
else
  catchValue "SURNAME" "Surname (i.e: Harry)"
  catchValue "NAME" "Name (i.e: Potter)"
  fisrtSurnameLetter=$(echo ${SURNAME::1})
  LDAP_UID=$(echo "${fisrtSurnameLetter}${NAME}" | tr [A-Z] [a-z])
  catchValue "GROUP_TYPE" "Group type (${ADMIN_GROUP})"
  result=$(echo " ${ADMIN_GROUP} " | grep " ${GROUP_TYPE} ")
  if [ "${result}" = "" ] ; then
    printf "\n%bERROR: LDAP \"${GROUP_TYPE}\" group type unauthorised.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  #--- Create account
  cat > ${CREATE_ACCOUNT_LDIF} <<EOF
#--- Create account
dn: uid=${LDAP_UID},ou=users,dc=orange,dc=com
uid: ${LDAP_UID}
cn: ${SURNAME} ${NAME}
sn: ${NAME}
mail: ${SURNAME}.${NAME}.${GROUP_TYPE}@orange.com
givenname: ${SURNAME}
userpassword: {SSHA}HP9cAEIVfSx6iFKz9XVBq4MC0eaaOHjE
objectclass: organizationalPerson
objectclass: person
objectclass: inetOrgPerson
objectclass: top

#--- Link account to group
dn: cn=${GROUP_TYPE},ou=paas-groups,ou=groups,dc=orange,dc=com
changetype: modify
add: uniqueMember
uniqueMember: uid=${LDAP_UID},ou=users,dc=orange,dc=com
EOF

  ldapadd -c -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f ${CREATE_ACCOUNT_LDIF}

  #--- Change password
  ldappasswd -h ${LDAP_SERVER} -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -s ${LDAP_UID} "uid=${LDAP_UID},ou=users,dc=orange,dc=com"

  rm -f ${CREATE_ACCOUNT_LDIF} > /dev/null 2>&1
  printf "\n%bNOTES:%b\n" "${REVERSE}${GREEN}" "${STD}"
  printf "%b- Your ldap user name is \"${LDAP_UID}\".%b\n" "${GREEN}" "${STD}"
  printf "%b- You have to update this account password (choose mode ssha) with \"phpLDAPadmin\" webui tool from now.%b\n\n" "${GREEN}" "${STD}"
fi