#!/bin/bash
export CONFIG_REPO=$1

set +e

CheckValue(){
  local value="$1"
  local old_key="$2"

  echo "$value"
  if [ -z "$value" ];then
    echo "Failed to retreive key: $old_key"
    exit 1
  fi

}
CheckCredhubProperty(){
  PATH_NAME="$1"

  #--- Check if credhub propertie exists
  flag_exist="$(credhub f | grep "name: ${PATH_NAME}")"
  if [ "$flag_exist" != "" ] ; then
    echo "Skipping - Value \"${PATH_NAME}\" already exists in credhub. To delete this value on credhub, run: credhub delete -n ${PATH_NAME}"
      return 1
    else
      return 0
  fi
}

SetCredhubMissingValue() {
  PATH_NAME="$1"
  VALUE="$2"
  TYPE="$3"
  TYPE=${TYPE:-value}
  echo "Set \"${PATH_NAME}\" ($TYPE) in credhub..."
  if [ -z "$VALUE" ]; then
    echo "WARNING - Skipping credhub update as value is not set"
  fi
  #--- Check if credhub propertie exists
  CheckCredhubProperty "${PATH_NAME}"
  if [ $? -eq 1 ] ; then
    return
  fi

  case $TYPE in
  value)
    VALUE_OPTION="-v"
    ;;
  password)
    VALUE_OPTION="-w"
    ;;

  esac
  credhub set -t value -n "${PATH_NAME}" ${VALUE_OPTION} "${VALUE}" > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo "ERROR: \"${PATH_NAME}\" setting value failed." ; exit 1
  fi
}

GetCredhubValue() {
  PATH_NAME="$1"
  KEY="$2"

  if [ -z "$PATH_NAME" ]; then
    echo "ERROR - Missing name of the credential to retrieve"
    exit 1
  fi
  local value="$(credhub get -q -n "${PATH_NAME}"  2>/dev/null)"
  echo "$value"
}

DuplicateKeyTypePassword(){
  local old_key="$1"
  local new_key="$2"
  echo "Getting '$old_key' from credhub"
  value=$(GetCredhubValue "$old_key")
  CheckValue "$value" "$old_key"
  SetCredhubMissingValue "$new_key" "$value" password

}


old_key="/micro-bosh/k8s-jcr/jcr_admin_password"
new_key="/micro-bosh/00-core-connectivity-k8s/jcr_admin_password"
DuplicateKeyTypePassword "$old_key" "$new_key"

old_key="/micro-bosh/k8s-jcr/postgresqlPassword"
new_key="/micro-bosh/00-core-connectivity-k8s/postgresqlPassword"
DuplicateKeyTypePassword "$old_key" "$new_key"

old_key="/micro-bosh/k8s-minio/minio-secret-key"
new_key="/micro-bosh/01-ci-k8s/minio-secret-key"
DuplicateKeyTypePassword "$old_key" "$new_key"

set -e
