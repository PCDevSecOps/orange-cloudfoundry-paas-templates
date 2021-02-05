#!/bin/sh -e
#===========================================================================
# Hook script to overide shield shared operator pre-start scripting
#===========================================================================

GENERATE_DIR=${GENERATE_DIR:-.}

#--- Overide shield shared operator to change openldap loglevel to "stats" only (without acl logs)
echo '      echo "Set openldap loglevel to stats"' >> ${GENERATE_DIR}/2-shieldv8-create-bucket-scripting-pre-start-only-operators.yml
echo '      sed -i "s+stats,acl+stats+" /var/vcap/jobs/ldap-server/bin/ctl' >> ${GENERATE_DIR}/2-shieldv8-create-bucket-scripting-pre-start-only-operators.yml