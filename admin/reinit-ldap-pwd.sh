#!/bin/bash
#===========================================================================
# Reinitialize LDAP account passwords (except "concourse")
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

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

  USER_IDS="$(ldapsearch -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -h ${LDAP_SERVER} -b "ou=users,dc=orange,dc=com" -s sub "(objectclass=*)" -LLL uid=* | grep "uid=" | sed -e "s+dn: uid=++g" | sed -e "s+,.*++g" | grep -v "concourse" | sort)"
  if [ "${USER_IDS}" = "" ] ; then
    printf "\n%bERROR: No user ids in ldap server.%b\n\n" "${RED}" "${STD}" ; exit 1
  fi

  #--- Change password for all users
  for user_id in ${USER_IDS} ; do
    printf "\n%b- Update \"${user_id}\" password..." "${STD}"
    new_password="$(apg -MCLN -n 1 -m 30)"
    ldappasswd -h ${LDAP_SERVER} -x -D ${LDAP_ROOT_DN} -w ${LDAP_ROOT_PWD} -s ${new_password} "uid=${user_id},ou=users,dc=orange,dc=com"
  done

  printf "\n\n%bNOTES:%b\n" "${REVERSE}${YELLOW}" "${STD}"
  printf "%bPlease inform all users to update passwords from now (choose mode ssha) with \"phpLDAPadmin\" webui tool.%b\n" "${YELLOW}" "${STD}"
  printf "%b  Login DN: ${LDAP_ROOT_DN}\n  Password: <ldap root password>%b\n\n" "${YELLOW}" "${STD}"
fi