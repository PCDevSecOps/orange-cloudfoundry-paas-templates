#!/bin/bash
export CONFIG_REPO=$1

set +e

#--- Generate cert in credhub
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
  flag_exist="$(credhub f | grep "name: ${PATH_NAME}")"
  if [ "${flag_exist}" != "" ] ; then
    echo "Skipping - Value \"${PATH_NAME}\" already exists in credhub. To delete this value on credhub, run: credhub delete -n ${PATH_NAME}"
    return
  fi
  #--- Set certificate in credhub
  credhub set -t value -n ${PATH_NAME} -v ${VALUE} > /dev/null 2>&1
  if [ $? != 0 ] ; then
    echo "ERROR: \"${PATH_NAME}\" setting value failed." ; exit 1
  fi
}

echo "getting info from shared/secrets"
SECRETS_URI=$(ruby -ryaml -e 'shared=YAML.load_file(File.join(ENV["CONFIG_REPO"],"shared","secrets.yml")); puts shared.dig("secrets","concourse","git","secrets","uri")')
CONCOURSE_LDAP_USERNAME=$(ruby -ryaml -e 'shared=YAML.load_file(File.join(ENV["CONFIG_REPO"],"shared","secrets.yml")); puts shared.dig("secrets","concourse","git","secrets","user")') # credential_leak_validated
CONCOURSE_LDAP_PASSWORD=$(ruby -ryaml -e 'shared=YAML.load_file(File.join(ENV["CONFIG_REPO"],"shared","secrets.yml")); puts shared.dig("secrets","concourse","git","secrets","password")')

SetCredhubMissingValue "/secrets/concourse_git_secrets_uri" "$SECRETS_URI"
SetCredhubMissingValue "/secrets/concourse_git_secrets_user" "$CONCOURSE_LDAP_USERNAME"
if [[ "$CONCOURSE_LDAP_PASSWORD" =~ \(\(.*\)\) ]]; then
  echo "Skipping - Concourse password is already using a credhub reference: $CONCOURSE_LDAP_PASSWORD"
else
  SetCredhubMissingValue "/secrets/concourse_git_secrets_password" "$CONCOURSE_LDAP_PASSWORD" "password"
fi

set -e