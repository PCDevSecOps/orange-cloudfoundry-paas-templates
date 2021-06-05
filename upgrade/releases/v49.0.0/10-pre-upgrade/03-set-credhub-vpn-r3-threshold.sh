#!/bin/bash
#--- Set credhub/uaa certs from secrets files into credhub
set +e

#--- Generate cert in credhub
SetCredhubValue() {
  PATH_NAME="$1"
  VALUE="$2"
  echo "Set \"${PATH_NAME}\" value in credhub..."

  #--- Check if credhub propertie exists
  flag_exist="$(credhub f | grep "name: ${PATH_NAME}")"
  if [ "${flag_exist}" != "" ] ; then
    credhub delete -n ${PATH_NAME} > /dev/null 2>&1
    if [ $? != 0 ] ; then
      echo "ERROR: \"${PATH_NAME}\" certificate deletion failed." ; exit 1
    fi
  fi

  #--- Set certificate in credhub
  credhub set -t value -n ${PATH_NAME} -v ${VALUE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo "ERROR: \"${PATH_NAME}\" certificate creation failed." ; exit 1
  fi
}

#--- Insert thresholds in credhub
SetCredhubValue "/secrets/multi_region_region_3_max_upload_speed_kbps" "100000"
SetCredhubValue "/secrets/multi_region_region_3_max_download_speed_kbps" "100000"

set -e