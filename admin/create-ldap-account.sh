#!/bin/bash
#===========================================================================
# Create LDAP account
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Script properties
CREATE_ACCOUNT_LDIF="create-account.ldif"

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
  printf "\n"
  catchValue "SURNAME" "Surname (i.e: Harry)"
  catchValue "NAME" "Name (i.e: Potter)"
  fisrtSurnameLetter=$(echo ${SURNAME::1})
  USER_ID=$(echo "${fisrtSurnameLetter}${NAME}" | tr [A-Z] [a-z])
  PWD_USER=${USER_ID}
  catchValue "GROUP_TYPE" "Group type (${ADMIN_GROUP})"
  result=$(echo " ${ADMIN_GROUP} " | grep " ${GROUP_TYPE} ")
  if [ "${result}" = "" ] ; then
    printf "\n%bERROR: LDAP \"${GROUP_TYPE}\" group type unauthorised.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  #--- Create account and link it to selected group
  cat > ${CREATE_ACCOUNT_LDIF} <<EOF
#--- Create account
dn: uid=${USER_ID},ou=users,dc=orange,dc=com
uid: ${USER_ID}
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
uniqueMember: uid=${USER_ID},ou=users,dc=orange,dc=com
EOF

  ldapadd -c -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -f ${CREATE_ACCOUNT_LDIF}

  #--- Change password
  ldappasswd -h ${LDAP_SERVER} -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -s ${PWD_USER} "uid=${USER_ID},ou=users,dc=orange,dc=com"
  rm -f ${CREATE_ACCOUNT_LDIF} > /dev/null 2>&1
  printf "%bNOTES:%b\n" "${REVERSE}${YELLOW}" "${STD}"
  printf "%bYour ldap user name is \"${USER_ID}\".%b\n" "${YELLOW}" "${STD}"
  printf "%bPlease update your password from now (choose mode ssha) with \"phpLDAPadmin\" webui tool.%b\n" "${YELLOW}" "${STD}"
  printf "%b  Login DN: uid=${USER_ID},ou=users,dc=orange,dc=com\n  Password: ${PWD_USER}%b\n\n" "${YELLOW}" "${STD}"
fi