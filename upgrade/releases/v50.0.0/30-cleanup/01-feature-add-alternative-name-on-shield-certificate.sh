#!/bin/bash
#--- Disable automatic exit from bash shell script on error
set +e
echo "shield-ca credhub properties cleanup..."
properties_to_clean="$(credhub f | grep "shield-ca" | awk '{print $3}')"
if [ "${properties_to_clean}" != "" ] ; then
  for propertie in ${properties_to_clean} ; do
    echo "- delete propertie \"${propertie}\"..."
    credhub delete -n ${propertie}
  done
fi

#--- Enable automatic exit from bash shell script on error
set -e