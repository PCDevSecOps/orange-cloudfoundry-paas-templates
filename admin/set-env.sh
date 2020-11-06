#!/bin/bash -i
#===========================================================================
# Install tools and prerequisite on jumpbox and inception instance
#===========================================================================

#--- Tools versions (to adapt to each relase)
BOSH_CLI_VERSION="6.4.0"
CREDHUB_VERSION="2.8.0"
FLY_VERSION="6.5.1"
JQ_VERSION="1.6"
RUBY_VERSION="2.6"
RUBY_BUNDLER_VERSION="1.17.3"
SPRUCE_VERSION="1.27.0"
TERRAFORM_VERSION="0.11.14"

#--- Binary tools directory
BIN_DIR=${HOME}/bin

#--- Status file
SCRIPT_NAME="$(basename $0)"
STATUS_FILE="/tmp/${SCRIPT_NAME}_$$.res"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Set proxy variables
if [ -z "${PROXY_URL}" ] ; then
  printf "\n%bERROR: \"PROXY_URL\" var unknown.%b\n\n" "${REVERSE}${RED}" "${STD}" ; exit 1
fi
export PROXY_URL

#--- Create directory
createDir() {
  if [ ! -d $1 ] ; then
    mkdir -p $1 > /dev/null 2>&1
  fi
}

#--- Display information
display() {
  case "$1" in
    "INFO")  printf "\n%b%s...%b\n" "${REVERSE}${YELLOW}" "$2" "${STD}" ;;
    "ITEM")  printf "\n%b- %s%b" "${YELLOW}" "$2" "${STD}" ;;
    "OK")    printf "\n%b%s.%b\n\n" "${REVERSE}${GREEN}" "$2" "${STD}" ;;
    "ERROR") printf "\n%bERROR: %s.%b\n\n" "${REVERSE}${RED}" "$2" "${STD}" ; exit 1 ;;
  esac
}

#--- Install packages with apt-get install
aptInstall() {
  packageList=$(dpkg -l 2> /dev/null)
  flag=$(echo "${packageList}" | grep " $1[: ]")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install $1 package"
    sudo apt-get -o Acquire::http::proxy="${PROXY_URL}" install -y $1 2>&1
  fi
}

#--- Set git option
configureGit() {
  flag=$(echo "${GIT_OPTIONS}" | grep " $1 ")
  if [ "${flag}" = "" ] ; then
    git config --global $1 "$2"
  fi
}

#--- Add static route to a subnet via micro-bosh internal gateway
addRoute() {
  subnet="$(echo "$1" | sed -e "s+/.*++g")"
  flag="$(netstat -rn | grep "${subnet} ")"
  if [ "${flag}" = "" ] ; then
    sudo ip route add $1 via 192.168.10.1
  fi
}

#--- Check instance type
flag_instance_type=0
if [ -d /images ] ; then
  INSTANCE="jumpbox"
  flag_instance=1
fi

if [ -d /var/vcap/store ] ; then
  INSTANCE="inception"
  flag_instance=1
fi

if [ ${flag_instance} = 0 ] ; then
  display "ERROR" "You can use this script only for \"jumpbox\" and \"inception\" instances"
fi

createDir "${BIN_DIR}"
cd ${BIN_DIR}

flag="$(echo "${PS1}" | grep "${INSTANCE}-")"
if [ "${flag}" = "" ] ; then
  #--- Get instance type for PS1
  flag=0
  while [ ${flag} = 0 ] ; do
    flag=1 ; clear
    printf "%bInstance type :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
    printf "%b1%b : production\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b2%b : pre-production\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b3%b : integration\n" "${GREEN}${BOLD}" "${STD}"
    printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
    case "${choice}" in
      1) TYPE="prod" ;;
      2) TYPE="preprod" ;;
      3) TYPE="int" ;;
      *) flag=0 ;;
    esac
  done

  if [ "${INSTANCE}" = "jumpbox" ] ; then
    #--- Get region for PS1
    flag=0
    while [ ${flag} = 0 ] ; do
      flag=1 ; clear
      printf "%bRegion :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
      printf "%b1%b : R1\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b2%b : R2\n" "${GREEN}${BOLD}" "${STD}"
      printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
      case "${choice}" in
        1) REGION="R1" ;;
        2) REGION="R2" ;;
        *) flag=0 ;;
      esac
    done
    HOST_ENV="${INSTANCE}-${TYPE}-${REGION}"
  else
    HOST_ENV="${INSTANCE}-${TYPE}"
  fi

else
  HOST_ENV="$(echo ${PS1} | sed -e "s+.*${INSTANCE}-+${INSTANCE}-+" | sed -e "s+\\\.*++")"
fi

#--- Install system packages and associate dev headers (needed for cpi)
display "INFO" "Update package list"
sudo apt-get -o Acquire::http::proxy="${PROXY_URL}" update

#--- Install tools packages
aptInstall "apg"
aptInstall "colordiff"
aptInstall "curl"
aptInstall "git"
aptInstall "whois"
aptInstall "libxml2"
aptInstall "libxml2-dev"
aptInstall "libxslt1.1"
aptInstall "libxslt1-dev"
aptInstall "openssl"
aptInstall "libssl-dev"
aptInstall "zlib1g"
aptInstall "zlib1g-dev"

#--- Install ruby and tools (needed for cpi)
aptInstall "gawk"
aptInstall "autoconf"
aptInstall "automake"
aptInstall "bison"
aptInstall "libffi-dev"
aptInstall "libgdbm-dev"
aptInstall "libncurses5-dev"
aptInstall "libsqlite3-dev"
aptInstall "libtool"
aptInstall "libyaml-dev"
aptInstall "sqlite3"
aptInstall "libgmp-dev"
aptInstall "libreadline-dev"

#--- Update ruby
createDir "${HOME}/.rvm"

flag="$(ruby --version 2> /dev/null | grep "${RUBY_VERSION}")"
if [ "${flag}" = "" ] ; then
  display "INFO" "Update ruby to \"${RUBY_VERSION}\""
  curl --proxy ${PROXY_URL} -sSL https://rvm.io/mpapis.asc | gpg --import -
  curl --proxy ${PROXY_URL} -sSL https://rvm.io/pkuczynski.asc | gpg --import -
  curl --proxy ${PROXY_URL} -sSL https://get.rvm.io -o ${HOME}/.rvm/rvm-installer
  chmod 755 ${HOME}/.rvm/rvm-installer
  export rvm_proxy=${PROXY_URL}
  ${HOME}/.rvm/rvm-installer stable
  source ${HOME}/.rvm/scripts/rvm
  rvm install ${RUBY_VERSION}
  rvm cleanup all
fi

#--- Install ruby gem bundler
flag=$(gem list bundler 2> /dev/null | grep "${RUBY_BUNDLER_VERSION}")
if [ "${flag}" = "" ] ; then
  display "INFO" "Install gem ruby bundler \"${RUBY_BUNDLER_VERSION}\""
  source ${HOME}/.rvm/scripts/rvm
  gem install --http-proxy ${PROXY_URL} bundler -v ${RUBY_BUNDLER_VERSION} --no-document
fi

#--- Install bosh cli
flag=$(bosh --version 2> /dev/null | grep "${BOSH_CLI_VERSION}")
if [ "${flag}" = "" ] ; then
  display "INFO" "Install bosh cli version \"${BOSH_CLI_VERSION}\""
  (curl --proxy ${PROXY_URL} https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64 -L -s -o ${BIN_DIR}/bosh 2>&1 ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    display "ERROR" "Install bosh cli failed"
  fi
  sudo rm -f /usr/local/bin/bosh
  sudo mv bosh /usr/local/bin
fi

#--- Install spruce
flag=$(spruce -v 2> /dev/null | grep "${SPRUCE_VERSION}")
if [ "${flag}" = "" ] ; then
  display "INFO" "Install spruce version \"${SPRUCE_VERSION}\""
  (curl --proxy ${PROXY_URL} "https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64" -L -s -o ${BIN_DIR}/spruce 2>&1 ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    display "ERROR" "Install spruce failed"
  fi
  sudo rm -f /usr/local/bin/spruce
  sudo mv spruce /usr/local/bin
fi

#--- Install jq
flag=$(jq --version 2> /dev/null | grep "${JQ_VERSION}")
if [ "${flag}" = "" ] ; then
  display "INFO" "Install jq version \"${JQ_VERSION}\""
  (curl --proxy ${PROXY_URL} "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" -L -s -o ./jq 2>&1 ; echo $? > ${STATUS_FILE})
  result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
  if [ ${result} != 0 ] ; then
    display "ERROR" "Install jq failed"
  fi
  sudo rm -f /usr/local/bin/jq
  sudo mv jq /usr/local/bin 
fi

if [ "${INSTANCE}" = "inception" ] ; then
  #--- Install credhub cli
  flag=$(credhub --version 2> /dev/null | grep "${CREDHUB_VERSION}")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install credhub cli version \"${CREDHUB_VERSION}\""
    (curl --proxy ${PROXY_URL} https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz -L -s | tar -xz -C . ; echo $? > ${STATUS_FILE})
    result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
    if [ ${result} != 0 ] ; then
      display "ERROR" "Install credhub cli failed"
    fi
    sudo rm -f /usr/local/bin/credhub
    sudo mv credhub /usr/local/bin
  fi

  #--- Install concourse cli
  flag=$(fly --version 2> /dev/null | grep "${FLY_VERSION}")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install concourse cli version \"${FLY_VERSION}\""
    (curl --proxy ${PROXY_URL} "https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly-${FLY_VERSION}-linux-amd64.tgz" -L -s | tar -xz -C . ; echo $? > ${STATUS_FILE})
    result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
    if [ ${result} != 0 ] ; then
      display "ERROR" "Install concourse cli failed"
    fi
    sudo rm -f /usr/local/bin/fly
    sudo mv fly /usr/local/bin
  fi

  #--- Install terraform cli
  flag=$(terraform --version 2> /dev/null | grep "${TERRAFORM_VERSION}")
  if [ "${flag}" = "" ] ; then
    display "INFO" "Install terraform cli version \"${TERRAFORM_VERSION}\""
    (curl --proxy ${PROXY_URL} "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -L -s -o ${BIN_DIR}/terraform.zip 2>&1 ; echo $? > ${STATUS_FILE})
    result=$(cat ${STATUS_FILE}) ; rm -f ${STATUS_FILE}
    if [ ${result} != 0 ] ; then
      display "ERROR" "Install terraform cli failed"
    fi
    /usr/bin/unzip -q ${BIN_DIR}/terraform.zip -d ${BIN_DIR}
    rm ${BIN_DIR}/terraform.zip
    sudo rm -f /usr/local/bin/terraform
    sudo mv terraform /usr/local/bin
  fi
fi

#--- Add static routes to subnets (vcenter/esx, services private subnets)
display "INFO" "Set static routes"
addRoute "10.110.78.0/24"
addRoute "192.168.0.0/16"

#--- Add dns server in /etc/resolv.conf (only for jumpbox, inception has a bosh-dns which recurse to dns-recursor)
if [ "${INSTANCE}" = "jumpbox" ] ; then
  flag="$(grep "192.168.116.156" /etc/resolv.conf)"
  if [ "${flag}" = "" ] ; then
    display "INFO" "Set dns servers"
    sudo sed -i '1i #--- dns-recursor\nnameserver 192.168.116.156\nnameserver 192.168.116.166\n' /etc/resolv.conf
  fi
fi

#--- Set PS1 to instance profile
flag="$(grep "${HOST_ENV}" ~/.bashrc)"
if [ "${flag}" = "" ] ; then
  display "INFO" "Set PS1"
  printf "\nHOST_ENV=\"${HOST_ENV}\"\n\n" >> ${HOME}/.bashrc
  cat >> ${HOME}/.bashrc <<'EOF'
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
export BLUE='\033[34m'
export CYAN='\033[36m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export PS1="${GREEN}\[${HOST_ENV}\]${CYAN}\$(parse_git_branch)${BLUE}:\w${STD}\$ "
EOF
fi

#--- Set PATH to instance profile
flag="$(grep "PATH=" ~/.bashrc | grep "${HOME}/bosh/template/admin")"
if [ "${flag}" = "" ] ; then
  display "INFO" "Set PATH"
  sed -i -e "/export PATH=.*/d" ${HOME}/.bashrc
  printf "\nexport PATH=.:${HOME}/bin:${HOME}/.rvm/rubies/ruby-${RUBY_VERSION}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.rvm/bin:${HOME}/bosh/template/admin\n\n" >> ${HOME}/.bashrc
fi

#--- Set aliases
display "INFO" "Create aliases"
cat > ${HOME}/.bash_aliases <<'EOF'
#--- Git aliases
alias commit='function __gcm() { git add . ; git commit -m "$1" ; unset -f __gcm; }; __gcm'
alias gitlog='git log --graph --pretty=format:'\''%C(yellow)%H%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn %ci)%Creset'\'' --abbrev-commit'
alias pull='git pull --rebase ; git fetch --prune'
alias push='git pull --rebase ; git fetch --prune ; git push'
alias status='git status'

#--- instances ssh access
alias inception='ssh inception'
alias micro-bosh='ssh micro-bosh'

#--- Tools aliases
alias diff='colordiff'
alias f='function __f() { printf "%100s\n"|tr " " "=";find . ! -regex ".*[/]\.git[/]?.*" -type f,l -not -xtype l -not -xtype d -print0 | xargs -0 grep -I -i --color "$1";unset -f __f;printf "%100s\n"|tr " " "="; }; __f'
alias generate-password='apg -MCLN -n 1 -m 30'
EOF

if [ "${INSTANCE}" = "inception" ] ; then
  cat >> ${HOME}/.bash_aliases <<'EOF'
alias bosh-task='function __bt() { bosh task $1 --debug | grep -vE " BEGIN| COMMIT| SELECT |INSERT INTO|DELETE FROM| UPDATE | WHERE |Renewing lock"; }; __bt'
alias fly='fly -t concourse'
alias log-bosh='. log-bosh.sh'
alias log-credhub='. log-credhub.sh'
alias log-fly='. log-fly.sh'
alias switch='. switch.sh'
EOF
fi

#--- Config git options
display "INFO" "Set git configuration"
GIT_OPTIONS=$(git config --name-only -l | sed -e "s+^+ +g" | sed -e "s+$+ +g")
configureGit "user.name" "${USER}"
configureGit "user.email" "${USER}@orange.com"
configureGit "alias.co" "checkout"
configureGit "alias.br" "branch"
configureGit "alias.lol" "log --graph --decorate --pretty=oneline --abbrev-commit"
configureGit "alias.lola" "log --graph --decorate --pretty=oneline --abbrev-commit --all"
configureGit "alias.st" "status"
configureGit "alias.uncommit" "reset --soft HEAD~1"
configureGit "color.ui" "auto"
configureGit "core.editor" "vi"
configureGit "core.eol" "lf"
configureGit "core.autocrlf" "input"
configureGit "core.preloadindex" "true"
configureGit "credential.helper" "cache --timeout=86400"
configureGit "http.postbuffer" "524288000"
configureGit "grep.linenumber" "true"
configureGit "push.default" "tracking"

#--- Set tools scripts (bosh, fly, credhub and switch)
if [ "${INSTANCE}" = "inception" ] ; then
  display "INFO" "Set tools"
  cat > ${BIN_DIR}/log-bosh.sh <<'EOF'
#!/bin/bash
#===========================================================================
# Log with bosh cli V2
#===========================================================================

#--- Credentials
SHARED_SECRETS="${HOME}/bosh/secrets/shared/secrets.yml"
INTERNAL_CA_CERT="${HOME}/bosh/secrets/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Test presence of referent credentials files
if [ ! -s "${SHARED_SECRETS}" ] ; then
  printf "\n%bERROR: Credential file \"${SHARED_SECRETS}\" unknown.%b\n\n" "${RED}" "${STD}"
else
  if [ ! -s "${INTERNAL_CA_CERT}" ] ; then
    printf "\n%bERROR: CA cert file \"${INTERNAL_CA_CERT}\" unknown.%b\n\n" "${RED}" "${STD}"
  else
    #--- Identify BOSH director
    flag=0
    while [ ${flag} = 0 ] ; do
      flag=1
      clear
      printf "%bDirector BOSH :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
      printf "%b1%b : micro\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b2%b : master\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b3%b : ops\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b4%b : coab\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b5%b : remote-r2\n" "${GREEN}${BOLD}" "${STD}"
      printf "%b6%b : remote-r3\n" "${GREEN}${BOLD}" "${STD}"
      printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
      case "${choice}" in
        1) BOSH_TARGET="micro" ;;
        2) BOSH_TARGET="master" ;;
        3) BOSH_TARGET="ops" ;;
        4) BOSH_TARGET="coab" ;;
        5) BOSH_TARGET="remote-r2" ;;
        6) BOSH_TARGET="remote-r3" ;;
        *) flag=0 ;;
      esac
    done

    #--- BOSH variables (used by bosh cli V2)
    export BOSH_TARGET
    export BOSH_CA_CERT="${INTERNAL_CA_CERT}"
    unset BOSH_CLIENT
    unset BOSH_CLIENT_SECRET

    #--- Log to the director and list active deployments
    if [ "${BOSH_TARGET}" = "micro" ] ; then
      export BOSH_ENVIRONMENT="192.168.10.10"
    else
      export BOSH_ENVIRONMENT=$(host bosh-${BOSH_TARGET}.internal.paas | awk '{print $4}')
    fi
    bosh alias-env ${BOSH_TARGET} > /dev/null 2>&1
    printf "\n%bEnter CF LDAP user and password :%b\n" "${REVERSE}${GREEN}" "${STD}"
    bosh log-in
    if [ $? != 0 ] ; then
      printf "\n\n%bERROR : Log to bosh director \"${BOSH_TARGET}\" failed.%b\n\n" "${RED}" "${STD}"
    else
      clear
      deployments=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$")
      if [ "${deployments}" = "" ] ; then
        unset BOSH_DEPLOYMENT
      else
        printf "\n%bSelect a specific deployment in the list, or suffix your bosh commands with -d <deployment_name>:%b\n%s" "${REVERSE}${GREEN}" "${STD}" "${deployments}"
        printf "\n\n%bYour choice (<Enter> to select all) :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
        if [ "${choice}" = "" ] ; then
          unset BOSH_DEPLOYMENT
        else
          flag=$(echo "${deployments}" | grep "${choice}")
          clear
          if [ "${flag}" = "" ] ; then
            unset BOSH_DEPLOYMENT
          else
            export BOSH_DEPLOYMENT="${choice}"
            bosh instances
          fi
        fi
      fi
    fi
  fi
fi
printf "\n"
EOF

  cat > ${BIN_DIR}/switch.sh <<'EOF'
#!/bin/bash
#===========================================================================
# Switch to bosh deployment within the same bosh director
#===========================================================================

#--- Colors and styles
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

bosh env > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n\n%bERROR : You are not connected to bosh director.%b\n\n" "${RED}" "${STD}"
else
  #--- Select specific deployment (BOSH_DEPLOYMENT variable)
  deployments=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$")
  if [ "$1" != "" ] ; then
    flag=$(echo "${deployments}" | grep "$1")
    if [ "${flag}" = "" ] ; then
      unset BOSH_DEPLOYMENT
    else
      export BOSH_DEPLOYMENT="$1"
      bosh instances
    fi
  else
    printf "\n%bSelect a specific deployment in the list:%b\n%s" "${REVERSE}${GREEN}" "${STD}" "${deployments}"
    printf "\n\n%bYour choice (<Enter> to select all) :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
    if [ "${choice}" = "" ] ; then
      unset BOSH_DEPLOYMENT
    else
      flag=$(echo "${deployments}" | grep "${choice}")
      if [ "${flag}" = "" ] ; then
        unset BOSH_DEPLOYMENT
      else
        export BOSH_DEPLOYMENT="${choice}"
        bosh instances
      fi
    fi
  fi
  printf "\n"
fi
EOF

  cat > ${BIN_DIR}/log-credhub.sh <<'EOF'
#!/bin/bash
#===========================================================================
# Log with credhub cli
#===========================================================================

#--- Credentials
SHARED_SECRETS="${HOME}/bosh/secrets/shared/secrets.yml"
INTERNAL_CA_CERT="${HOME}/bosh/secrets/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'

#--- Test presence of referent credentials files
if [ ! -s "${SHARED_SECRETS}" ] ; then
  printf "\n%bERROR: Credential file \"${SHARED_SECRETS}\" unknown.%b\n\n" "${RED}" "${STD}"
else
  if [ ! -s "${INTERNAL_CA_CERT}" ] ; then
    printf "\n%bERROR: CA cert file \"${INTERNAL_CA_CERT}\" unknown.%b\n\n" "${RED}" "${STD}"
  else
    #--- Credhub API Endpoint
    export CREDHUB_SERVER="https://credhub.internal.paas:8844"
    export CREDHUB_CLIENT="director_to_credhub"
    export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
    export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)

    #--- Login to credhub
    credhub api > /dev/null 2>&1
    credhub login
    if [ $? = 1 ] ; then
      printf "\n%bERROR : Connexion failed.%b\n\n" "${RED}" "${STD}"
    else
      printf "\n\n%bLogged to credhub%b\n" "${GREEN}${BOLD}" "${STD}"
    fi
  fi
fi
EOF

  cat > ${BIN_DIR}/log-fly.sh <<'EOF'
#!/bin/bash
#===========================================================================
# Log with fly (concourse) cli
#===========================================================================

#--- Credentials
SHARED_SECRETS="${HOME}/bosh/secrets/shared/secrets.yml"
INTERNAL_CA_CERT="${HOME}/bosh/secrets/shared/certs/internal_paas-ca/server-ca.crt"

#--- Colors and styles
export RED='\033[1;31m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Log to credhub
flagError=0
if [ ! -s "${SHARED_SECRETS}" ] ; then
  printf "\n%bERROR : Credential file \"${SHARED_SECRETS}\" unknown.%b\n\n" "${RED}" "${STD}" ; flagError=1
else
  if [ ! -s "${INTERNAL_CA_CERT}" ] ; then
    printf "\n%bERROR : CA cert file \"${INTERNAL_CA_CERT}\" unknown.%b\n\n" "${RED}" "${STD}" ; flagError=1
  else
    #--- Credhub API Endpoint
    export CREDHUB_SERVER="https://credhub.internal.paas:8844"
    export CREDHUB_CLIENT="director_to_credhub"
    export CREDHUB_CA_CERT="${INTERNAL_CA_CERT}"
    export CREDHUB_SECRET=$(bosh int ${SHARED_SECRETS} --path /secrets/bosh_credhub_secrets)

    #--- Login to credhub
    credhub api > /dev/null 2>&1
    credhub login > /dev/null 2>&1
    if [ $? = 1 ] ; then
      printf "\n%bERROR : Connexion failed.%b\n\n" "${RED}" "${STD}" ; flagError=1
    else
      #--- Get user and password account for login
      FLY_USER=$(credhub g -k "username" -n /micro-bosh/concourse/local_user 2> /dev/null)
      if [ "${FLY_USER}" = "" ] ; then
        printf "\n\n%bERROR : fly user credhub value unknown.%b\n\n" "${RED}" "${STD}" ; flagError=1
      fi
      FLY_PASSWORD=$(credhub g -k "password" -n /micro-bosh/concourse/local_user 2> /dev/null)
      if [ "${FLY_PASSWORD}" = "" ] ; then
        printf "\n\n%bERROR : fly password credhub value unknown.%b\n\n" "${RED}" "${STD}" ; flagError=1
      fi
    fi
  fi
fi

#--- Choose concourse team
if [ ${flagError} = 0 ] ; then
  flag=0
  while [ ${flag} = 0 ] ; do
    flag=1
    printf "\n%bTeam concourse :%b\n\n" "${REVERSE}${GREEN}" "${STD}"
    printf "%b1%b  : main\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b2%b  : micro-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b3%b  : master-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b4%b  : ops-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b5%b  : coab-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b6%b  : remote-r2-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "%b7%b  : remote-r3-depls\n" "${GREEN}${BOLD}" "${STD}"
    printf "\n%bYour choice :%b " "${GREEN}${BOLD}" "${STD}" ; read choice
    case "${choice}" in
      1) TEAM="main" ;;
      2) TEAM="micro-depls" ;;
      3) TEAM="master-depls" ;;
      4) TEAM="ops-depls" ;;
      5) TEAM="coab-depls" ;;
      6) TEAM="remote-r2-depls" ;;
      7) TEAM="remote-r3-depls" ;;
      *) flag=0 ; clear ;;
    esac
  done

  #--- Check active mode ("bootstrap" or "standard") to "use intranet interco_relay external" ip or "ops_relay" domain
  status=$(nc -vz 192.168.116.160 8080 2>&1 | grep "succeeded")
  if [ "${status}" != "" ] ; then
    export FLY_ENDPOINT="http://192.168.116.160:8080"
  else
    OPS_DOMAIN=$(grep "ops_domain:" ${SHARED_SECRETS} | awk '{print $2}')
    export FLY_ENDPOINT="https://elpaaso-concourse.${OPS_DOMAIN}"
  fi

  #--- Log to concourse and display builds
  printf "\n"
  fly -t concourse login -c ${FLY_ENDPOINT} -u ${FLY_USER} -p ${FLY_PASSWORD} -n ${TEAM}
  if [ $? = 0 ] ; then
    fly -t concourse workers
    printf "\n"
  else
    printf "\n\n%bERROR : Fly login failed.%b\n\n" "${RED}" "${STD}"
  fi
fi
EOF

  sudo rm -f /usr/local/bin/log-*.sh /usr/local/bin/switch.sh
  sudo mv ${BIN_DIR}/log-*.sh /usr/local/bin
  sudo mv ${BIN_DIR}/switch.sh /usr/local/bin
fi

#--- Set root owner to bin files
cd /usr/local/bin
sudo chown root:root *
sudo chmod 755 *

#--- Set ssh config for inception and micro-bosh access
flag=$(grep "Host inception" ${HOME}/.ssh/config 2> /dev/null)
if [ "${flag}" = "" ] ; then
  cat <<EOT > ~/.ssh/config
#========================================
# inception instance
#========================================
Host inception
  IdentityFile ~/bosh/secrets/bootstrap/inception/inception.pem
  User inception
  Hostname 192.168.10.2

#========================================
# micro-bosh instance
#========================================
Host micro-bosh
  IdentityFile ~/bosh/secrets/shared/keypair/bosh.pem
  User vcap
  Hostname 192.168.10.10

#=====================================================
# SSH common properties
#=====================================================
Host *
  #LogLevel DEBUG3
  ForwardAgent yes
  ServerAliveInterval 30
  ServerAliveCountMax 5
  GSSAPIAuthentication no
  StrictHostKeyChecking no
  PasswordAuthentication no
  Port 22
EOT
fi

display "OK" "End of setting environment for \"${INSTANCE}\" instance"
printf "%bReload your environment:%b" "${REVERSE}${YELLOW}" "${STD}"
printf "\n\n%b$ . ~/.bashrc%b\n\n" "${YELLOW}" "${STD}"