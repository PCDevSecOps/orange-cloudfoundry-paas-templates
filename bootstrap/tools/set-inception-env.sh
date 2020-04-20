#!/bin/bash
#===========================================================================
# Install tools and prerequisite for micro-bosh on bootstrap instance
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Tools versions (adapt to each bootstrap operation)
CREDHUB_VERSION="2.5.3"
FLY_VERSION="5.3.0"
JQ_VERSION="1.6"
TERRAFORM_VERSION="0.11.14"

#--- Binary tools directory
BIN_DIR="/home/inception/bin"

#--- Install apg package (password management)
aptInstall "apg"
aptInstall "whois"

#--- Install system package (needed for cpi creation)
aptInstall "ruby"

#--- Install credhub cli
cd ${BIN_DIR}
display "INFO" "Install credhub cli version \"${CREDHUB_VERSION}\""
rm -f credhub
(curl ${CURL_OPTION} https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz -L -s | tar -xz -C . ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install credhub cli failed"
fi

#--- Install minio cli
display "INFO" "Install minio cli"
rm -f mc
(curl ${CURL_OPTION} "https://dl.minio.io/client/mc/release/linux-amd64/mc" -L -s -o ./mc 2>&1 ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install minio failed"
fi

#--- Install concourse cli
display "INFO" "Install concourse cli version \"${FLY_VERSION}\""
rm -f fly
(curl ${CURL_OPTION} "https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly-${FLY_VERSION}-linux-amd64.tgz" -L -s | tar -xz -C . ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install concourse cli failed"
fi

#--- Install Terraform cli
if [ "${IAAS_TYPE}" = "openstack-hws" ] ; then
  #--- Install openstack cli (python package)
  aptInstall "python-pip"

  flag=$(pip list 2> /dev/null | grep "python-keystoneclient")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install openstack cli"
    pip install --user python-openstackclient 2>&1
  fi

  #--- Install terraform cli
  display "INFO" "Install terraform cli version \"${TERRAFORM_VERSION}\""
  rm -f terraform
  (curl ${CURL_OPTION} "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -L -s -o /tmp/terraform.zip 2>&1 ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    display "ERROR" "Install terraform cli failed"
  fi
  /usr/bin/unzip -q /tmp/terraform.zip -d ${BIN_DIR}
  rm /tmp/terraform.zip
fi

#--- Install jq
display "INFO" "Install jq version \"${JQ_VERSION}\""
rm -f jq
(curl ${CURL_OPTION} "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" -L -s -o ./jq 2>&1 ; echo $? > ${STATUS_FILE})
result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
if [ ${result} != 0 ] ; then
  display "ERROR" "Install jq failed"
fi

chmod 755 ${BIN_DIR}/* > /dev/null 2>&1

#--- Add env vars (to be used with log* tools)
display "INFO" "Add env vars to \".bashrc\" file"
addVarToEnv "IAAS_TYPE"
if [ "${IAAS_TYPE}" = "openstack-hws" ] ; then
  KEYSTONE="3"
  addVarToEnv "KEYSTONE"
fi
addVarToEnv "SHARED_SECRETS"
addVarToEnv "INTERNAL_CA_CERT"

#--- Update site name and set it to bootstrap PS1
if [ "${SITE_ENV}" = "" ] ; then
  SITE_ENV="$(getValue ${BOOTSTRAP_VARS_FILE} /site_name)"
  addVarToEnv "SITE_ENV"

  cat <<'EOF' >> ~/.bashrc

#--- Set git branch in prompt
parse_git_branch()
{
  local BRANCH=$(git symbolic-ref HEAD --short 2> /dev/null)
  if [ ! -z "${BRANCH}" ] ; then
    echo "(${BRANCH})"
  else
    echo ""
  fi
}

#--- Colors and styles
export GREEN='\[\033[1;32m\]'
export BLUE='\[\033[1;34m\]'
export CYAN='\[\033[1;36m\]'
export STD='\[\033[0m\]'

export PS1="${GREEN}\[${SITE_ENV}\]${CYAN}\$(parse_git_branch)${BLUE}:\w${STD}\$ "
EOF
fi

display "INFO" "Create tools aliases"
echo "alias f='function __f() { printf \"\n\";find . ! -regex \".*[/]\.git[/]?.*\" -type f -print0 | xargs -0 grep -I -i --color \"\$1\";unset -f __f;printf \"\n\"; }; __f'" > ~/.bash_aliases
echo "alias fly='fly -t concourse'" >> ~/.bash_aliases
echo "alias gitlog=\"git log --graph --pretty=format:'%C(yellow)%H%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn %ci)%Creset' --abbrev-commit\"" >> ~/.bash_aliases
echo "alias log-bosh='. log-bosh'" >> ~/.bash_aliases
echo "alias log-credhub='. log-credhub'" >> ~/.bash_aliases
echo "alias log-fly='. log-fly'" >> ~/.bash_aliases
echo "alias micro-bosh='ssh vcap@192.168.10.10'" >> ~/.bash_aliases
echo "alias switch='. switch'" >> ~/.bash_aliases

if [ "${IAAS_TYPE}" = "openstack-hws" ] ; then
  echo "alias log-openstack='. log-openstack'" >> ~/.bash_aliases
  echo "alias openstack='openstack --insecure'" >> ~/.bash_aliases
  echo "alias os='openstack --insecure'" >> ~/.bash_aliases
fi

display "OK" "Bootstrap instrumentation ended"
printf "\n%bReload your environment:%b" "${REVERSE}${YELLOW}" "${STD}"
printf "\n\n%b$ . ~/.bashrc%b\n\n" "${YELLOW}" "${STD}"