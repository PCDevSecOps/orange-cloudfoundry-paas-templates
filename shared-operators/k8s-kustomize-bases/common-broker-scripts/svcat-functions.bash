#!/bin/bash
# This file contains functions used to assert service catalog use-cases

#Cheat sheet for running individual commands in fly
function interactive_debug_in_fly() {
  # window 1
  (cd template-resource/; git fetch origin feature-coab-v52; git reset --hard 5466b879e1da697b5b3867a71447b38541627e77) #reset to last commit from our branch in development, e.g. feature-coab-v52
  ( cd template-resource/; git pull origin feature-coab-v52 --rebase;  );  source template-resource/coab-depls/common-broker-scripts/setup_interactive_debug_env.bash ; export DEBUG_MODE=false; set +x

  # window 2
  source template-resource/coab-depls/common-broker-scripts/setup_interactive_debug_env.bash
  export DEBUG_MODE=false; set +x

  # Source env vars declaration from section "Required env vars for running k8s svcat tests" in concourse output

  # then execute functions with arguments observed with debugging traces

  execute_service_catalog_tests
  test_svcat_service_bind_unbind osb-cmdb-brokered-services-org-client-0-smoke-tests-1624439707 p-mysql-smoke-test1624439741 p-mysql
}

# Prereq env vars
# CF_SMOKE_TEST_ORG
# CF_SMOKE_TEST_SPACE
# BROKER_NAME
# BROKER_USER_NAME
# BROKER_USER_PASSWORD
# BROKER_URL
# SERVICE
# PLAN
function execute_service_catalog_tests() {
  install_kubectl_cli_if_needed
  k3s_login_if_needed
# not yet used
#  install_kubectl_kuttl_cli_if_needed
#  install_gomplate_cli_cli_if_needed
  install_svcat_cli_if_needed

  check_preq_env_vars "false" CF_SMOKE_TEST_ORG CF_SMOKE_TEST_SPACE BROKER_NAME BROKER_USER_NAME BROKER_USER_PASSWORD BROKER_URL SERVICE PLAN
  check_preq_env_vars "true" SERVICE_INSTANCE_CONFIGURATION_PARAMETERS

  local service_instance_name_prefix="${SERVICE}-smoke-test" # prefix used in service instance names for provisionning and leak cleanup
  local namespace_prefix="${CF_SMOKE_TEST_ORG}-${CF_SMOKE_TEST_SPACE}-"
  clean_up_leaking_namespaces "${namespace_prefix}"

  local smoke_test_namespace=$(generate_unique_prefixed_name "${namespace_prefix}")
  create_smoke_test_namespace_if_needed "${smoke_test_namespace}"
  register_broker_in_svcat "${BROKER_NAME}" "${BROKER_URL}" "${BROKER_USER_NAME}" "${BROKER_USER_PASSWORD}" "${smoke_test_namespace}"
  display_svcat_catalog "${smoke_test_namespace}"

  local service_instance_name=$(generate_unique_prefixed_name "${service_instance_name_prefix}")
  test_svcat_service_provisionning "${smoke_test_namespace}" "${service_instance_name}" "${SERVICE}" "${PLAN}" "${SERVICE_INSTANCE_CONFIGURATION_PARAMETERS}"
  test_svcat_service_bind_unbind "${smoke_test_namespace}" "${service_instance_name}" "${SERVICE}"

  test_svcat_service_deprovisionning "${smoke_test_namespace}" "${service_instance_name}"

  clean_up_namespace "${smoke_test_namespace}"
}

# $1 - the msg to display
# $2... - the command to run
retry_with_svcat_defaults() {
  local -r msg="$1"
  shift
  local -r cmd="$@"
  local -r sleep_time=2
  local nb_attempts=$((${MAX_TIME} / ${sleep_time}))

  retry ${sleep_time} ${nb_attempts} "${msg}" ${cmd}
}



# Display the content of an env var to ease replaying
# $1: is_variable_optional: "true" to accept empty missing variables, "false" otherwise
# arguments: the names of the env var to display
function check_preq_env_vars() {
  local is_variable_optional="$1"; shift
  echo

  if [ "${is_variable_optional}" == "true" ]; then
    echo_comment "# Required env vars for running k8s svcat tests"
  else
    echo_comment "# Optional env vars for running k8s svcat tests"
  fi

  for var_name in "$@"
  do
      #See https://stackoverflow.com/a/32913408/1484823 for use of envsubst
      local var_value=$(echo "\$${var_name}" | envsubst)
      if [[ "${var_value}" =~ '"' ]]; then
        echo "read -r -d '' ${var_name} <<'EOF' || true"
        echo "${var_value}"
        echo "EOF"
      else
        echo "export ${var_name}=\"${var_value}\""
      fi
      local var_value=$(echo "\$${var_name}" | envsubst)
      if [[ "${var_value}" == "" ]]; then
        if [ "${is_variable_optional}" == "false" ]; then
          echo "variable ${var_name} is undefined"
          false
        fi
      fi
  done
}

function install_kubectl_cli() {
  # In the future, make it consistent with https://github.com/orange-cloudfoundry/orange-cf-bosh-cli/blob/600e65d50aa114b00c98a0104a2cfd6e19d01c43/Dockerfile#L104

  #--- Parameters
  local KUBECTL_CLI_VERSION="1.18.8"

  #--- Install kubectl cli
  printf "%bInstall kubectl cli ${KUBECTL_CLI_VERSION}...%b" "${YELLOW}" "${STD}"
  # https://curl.haxx.se/docs/manpage.html
  # Previously redirected stderr to stdout and stdout to /dev/null
  # 2>&1 is dangerous as order matters
  #   https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Moving-File-Descriptors
  #   https://github.com/koalaman/shellcheck/wiki/SC2069
  # Preferring &> syntax
  # https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirecting-Standard-Output-and-Standard-Error
  # https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators/159514#159514

  curl -L --silent --show-error "https://dl.k8s.io/release/v${KUBECTL_CLI_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
  if [[ $? != 0 ]]; then
    printf "\n%bERROR: Install kubectl cli failed%b\n\n" "${RED}" "${STD}"
    exit 1
  else
    printf "%bOK %b\n" "${YELLOW}" "${STD}"
  fi
  chmod 755 /usr/local/bin/kubectl
  ! run_with_traces /usr/local/bin/kubectl version
}

# stdout: none
# stderr: potentially kubectl cli install logs
function install_kubectl_cli_if_needed() {
  if ! type -a kubectl >/dev/null 2>&1; then
    install_kubectl_cli >/dev/stderr
  fi
}

function install_kubectl_kuttl_cli() {
  # In the future, make it consistent with https://github.com/orange-cloudfoundry/orange-cf-bosh-cli/blob/600e65d50aa114b00c98a0104a2cfd6e19d01c43/Dockerfile#L104

  #--- Parameters
  local KUBECTL_KUTTL_CLI_VERSION="0.10.0"

  #--- Install kubectl cli
  printf "%bInstall kubectl_kuttl cli ${KUBECTL_KUTTL_CLI_VERSION}...%b" "${YELLOW}" "${STD}"

  curl -L --silent --show-error "https://github.com/kudobuilder/kuttl/releases/download/v${KUBECTL_KUTTL_CLI_VERSION}/kubectl-kuttl_${KUBECTL_KUTTL_CLI_VERSION}_linux_x86_64" -o /usr/local/bin/kubectl-kuttl
  if [[ $? != 0 ]]; then
    printf "\n%bERROR: Install kubectl-kuttl cli failed%b\n\n" "${RED}" "${STD}"
    exit 1
  else
    printf "%bOK %b\n" "${YELLOW}" "${STD}"
  fi
  chmod 755 /usr/local/bin/kubectl-kuttl
  /usr/local/bin/kubectl-kuttl version
}

# stdout: none
# stderr: potentially kubectl cli install logs
function install_kubectl_kuttl_cli_if_needed() {
  if ! type -a kubectl-kuttl >/dev/null 2>&1; then
    install_kubectl_kuttl_cli >/dev/stderr
  fi
}

function install_gomplate_cli() {
  # In the future, make it consistent with https://github.com/orange-cloudfoundry/orange-cf-bosh-cli/blob/600e65d50aa114b00c98a0104a2cfd6e19d01c43/Dockerfile#L104

  #--- Parameters
  local GOMPLATE_CLI_VERSION="3.8.0"

  #--- Install kubectl cli
  printf "%bInstall gomplate cli ${KUBECTL_KUTTL_CLI_VERSION}...%b" "${YELLOW}" "${STD}"

  curl -L --silent --show-error "https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_CLI_VERSION}/gomplate_linux-amd64" -o /usr/local/bin/gomplate
  if [[ $? != 0 ]]; then
    printf "\n%bERROR: Install gomplate cli failed%b\n\n" "${RED}" "${STD}"
    exit 1
  else
    printf "%bOK %b\n" "${YELLOW}" "${STD}"
  fi
  chmod 755 /usr/local/bin/gomplate
  /usr/local/bin/gomplate -v
}

# stdout: none
# stderr: potentially kubectl cli install logs
function install_gomplate_cli_cli_if_needed() {
  if ! type -a gomplate >/dev/null 2>&1; then
    install_gomplate_cli >/dev/stderr
  fi
}


function install_svcat_cli() {
  # In the future, consiser making this consistent with https://github.com/orange-cloudfoundry/orange-cf-kubectl-cli/blob/600e65d50aa114b00c98a0104a2cfd6e19d01c43/Dockerfile#L104

  #--- Parameters
  local SVCAT_CLI_VERSION="0.3.1"

  #--- Install svcat cli
  printf "%bInstall svcat cli ${SVCAT_CLI_VERSION}...%b" "${YELLOW}" "${STD}"
  # https://curl.haxx.se/docs/manpage.html
  # Previously redirected stderr to stdout and stdout to /dev/null
  # 2>&1 is dangerous as order matters
  #   https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Moving-File-Descriptors
  #   https://github.com/koalaman/shellcheck/wiki/SC2069
  # Preferring &> syntax
  # https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirecting-Standard-Output-and-Standard-Error
  # https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators/159514#159514
  curl -L --silent --show-error "https://download.svcat.sh/cli/v${SVCAT_CLI_VERSION}/linux/amd64/svcat" -o /usr/local/bin/svcat
  if [[ $? != 0 ]]; then
    printf "\n%bERROR: Install svcat cli failed%b\n\n" "${RED}" "${STD}"
    exit 1
  else
    printf "%bOK %b\n" "${YELLOW}" "${STD}"
  fi
  chmod 755 /usr/local/bin/svcat
}

# stdout: none
# stderr: potentially svcat cli install logs
function install_svcat_cli_if_needed() {
  if ! type -a svcat >/dev/null 2>&1; then
    install_svcat_cli >/dev/stderr
  fi
}

# Currently fails with DNS lookup error when using bosh DNS endpoint
# Currently fails with a 401 with IP addresses (due to http_proxy env
function configure_kubectl_using_admin_token() {
  setup_credhub_if_needed
  local k8s_token
  k8s_token=$(fetch_credhub_value "/micro-bosh/00-gitops-management/admin_token")
#  local K8S_API_ENDPOINT="gitops-management-api.internal.paas"
#  local K8S_API_ENDPOINT="0.server.net-bosh-2.00-gitops-management.bosh"
  K8S_API_ENDPOINT="https://192.168.116.218:6443"
  kubectl config set-cluster "svcat-cluster" --server="${K8S_API_ENDPOINT}" --insecure-skip-tls-verify=true
  kubectl config set-credentials "admin" --token="${k8s_token}"
  kubectl config set-context "svcat-cluster" --cluster="svcat-cluster" --user="admin"
  kubectl config use-context "svcat-cluster"

  # Check whether auth is properly configured: check whether access to svcat ServiceInstance CR is granted
  # can-i       Check whether an action is allowed
  https_proxy= http_proxy= kubectl auth can-i read serviceinstance
#
}



#Adapted from paas-templates/admin/set-env.sh
function logToBosh() {
  #Install host command to avoid modify parsing with nslookup
  #See https://unix.stackexchange.com/a/447184/381792
  ! apk add -q bind-tools &> /tmp/install-bind-tools

  case "$1" in
    "micro-bosh") director_dns_name="bosh-micro" ; credhub_bosh_password="/secrets/bosh_admin_password" ;;
    "bosh-master") director_dns_name="$1" ; credhub_bosh_password="/micro-bosh/$1/admin_password" ;;
    *) director_dns_name="$1" ; credhub_bosh_password="/bosh-master/$1/admin_password" ;;
  esac

  export BOSH_ENVIRONMENT=$(host ${director_dns_name}.internal.paas | awk '{print $4}')
  flag=$(credhub f | grep "${credhub_bosh_password}")
  if [ "${flag}" = "" ] ; then
    printf "\n%bERROR: bosh director \"$1\" password unknown.%b\n\n" "${REVERSE}${RED}" "${STD}" ; flagError=1
  else
    export BOSH_CLIENT_SECRET="$(credhub g -n ${credhub_bosh_password} -j | jq -r '.value')"
    bosh alias-env $1 > /tmp/bosh-alias.txt 2>&1
    bosh logout > /tmp/bosh-logout  2>&1
    bosh -n log-in > /dev/bosh-login 2>&1
    if [ $? = 1 ] ; then
      printf "\n%bERROR: Log to \"$1\" director failed.%b\n\n" "${REVERSE}${RED}" "${STD}" ; flagError=1
    fi
    # bosh env
    # bosh deployments
  fi
}


function k3s_login_if_needed() {
  #try to remove no proxy env var by parsing kubeconfig before calling kubectl
  update_http_no_proxy_with_k8s_cluster_if_exists
  if [ "$(kubectl auth can-i read pod 2>&1)" != "yes"  ]; then
    echo "Configuring kubectl..."
    fetch_k3s_kubeconfig
  fi
}

#extracts the ip from kubeconfig or returns "" if kubeconfig is missing
function extract_cluster_ip_from_kubeconfig() {
  # Swallow non zero exit status by declaring and assigning local variable
  #See https://stackoverflow.com/a/53403319/1484823
  local kubeconfig=$(kubectl config view --minify -o json 2>/tmp/kubeconfig-view)
  if [[ $? == 0 ]]; then
    echo "${kubeconfig}" | jq -r .clusters[0].cluster.server | sed 's#https://\(.*\):.*#\1#'
  else
    echo ""
  fi
}

function update_http_no_proxy_with_k8s_cluster_if_exists() {
  local cluster_ip_address=$(extract_cluster_ip_from_kubeconfig)
  if [[ "${cluster_ip_address}" != "" && ! "$no_proxy" =~ "${cluster_ip_address}" ]]; then
    export no_proxy="${no_proxy},${cluster_ip_address}"
    echo_comment "no_proxy updated to exclude k8s cluster at ${cluster_ip_address} resulting into:"
    echo "${no_proxy}"
    echo
  fi
}

# Currently fails with a 401, not yet diagnosed
#Adapted from paas-templates/admin/set-env.sh
function fetch_k3s_kubeconfig() {
    setup_credhub_if_needed

    #--- Credentials
    INTERNAL_CA_CERT="credentials-resource/shared/certs/internal_paas-ca/server-ca.crt"
    K8S_TYPE="k3s" ; K8S_DIRECTOR="micro-bosh" ; BOSH_K8S_DEPLOYMENT="00-gitops-management" ; K8S_CLUSTER="gitops-management"

    echo_comment "Fetching kubeconfig.yml from k8s-cluster=${K8S_CLUSTER} within bosh-depl=${BOSH_K8S_DEPLOYMENT} root-depls=${K8S_DIRECTOR}"

    #--- Get k3s cluster configuration
    export BOSH_CLIENT="admin"
    export BOSH_CA_CERT="${INTERNAL_CA_CERT}"
    flagError=0
    logToBosh "${K8S_DIRECTOR}"
    if [ ${flagError} = 0 ] ; then
      export KUBECONFIG=${HOME}/.kube/config
      mkdir -p ${HOME}/.kube/
      instance="$(bosh -d ${BOSH_K8S_DEPLOYMENT} is | grep "server/" | awk '{print $1}')"

      # Add missing scp to the container image
      ! apk add -q openssh-client &> /tmp/install-openssh-client
      bosh -d ${BOSH_K8S_DEPLOYMENT} scp ${instance}:/var/vcap/store/k3s-server/kubeconfig.yml ${KUBECONFIG} > /tmp/bosh-scp.txt 2>&1
      if [ $? != 0 ] ; then
        printf "\n\n%bERROR : Get cluster configuration failed.%b\n\n" "${RED}" "${STD}" ; flagError=1
      fi
      chmod 600 ${KUBECONFIG} > /dev/null 2>&1
    fi

    update_http_no_proxy_with_k8s_cluster_if_exists

    # Check whether auth is properly configured: check whether access to svcat ServiceInstance CR is granted
    # can-i       Check whether an action is allowed
    echo "Checking kubectl access to k8s cluster"
    run_with_traces kubectl auth can-i read serviceinstance
}

#Draft, not tested, to be removed
function fetch_k8s_server_certs() {
  #  #Adapted from paas-templates/admin/set-env.sh
    K8S_TYPE="k3s" ; K8S_DIRECTOR="micro-bosh" ; BOSH_K8S_DEPLOYMENT="00-gitops-management" ; K8S_CLUSTER="gitops-management"
  #
  #
  #  if [ ! -d ${HOME}/.kube ] ; then
  #    mkdir ${HOME}/.kube > /dev/null 2>&1
  #  fi
  #
  #  if [ "${K8S_TYPE}" = "k8s" ] ; then
  #    #--- Check if bosh dns exists
  #    flag_host="$(host ${K8S_API_ENDPOINT} | awk '{print $4}')"
  #    if [ "${flag_host}" = "found:" ] ; then
  #      printf "\n\n%bERROR : Kubernetes cluster endpoint \"${K8S_API_ENDPOINT}\" unknown (no dns record).%b\n\n" "${RED}" "${STD}" ; flagError=1
  #    else
  #      #--- Set kubernetes configuration
  #      printf "\n"
        CRT_DIR=${HOME}/.kube/certs
        if [ ! -d ${CRT_DIR} ] ; then
          mkdir ${CRT_DIR} > /dev/null 2>&1
        fi
  #
  #        address="https://${endpoint}:${port}"
  #      kubectl config set-cluster "svcat-cluster" --server="${K8S_API_ENDPOINT}" --insecure-skip-tls-verify=${insecure}
  #      kubectl config set-credentials "admin" --token="<%= p('kubernetes.password') %>"
  #      kubectl config set-context "svcat-cluster" --cluster="svcat-cluster" --user="admin"
  #      kubectl config use-context "svcat-cluster"
  #      chmod go-r /var/vcap/jobs/action/config/kubeconfig
  #
        bosh int <(credhub get -n "/${K8S_DIRECTOR}/${BOSH_K8S_DEPLOYMENT}/tls-ca" --output-json) --path=/value/ca > ${CRT_DIR}/${K8S_CLUSTER}_ca.pem
        bosh int <(credhub get -n "/${K8S_DIRECTOR}/${BOSH_K8S_DEPLOYMENT}/tls-admin" --output-json) --path=/value/certificate > ${CRT_DIR}/${K8S_CLUSTER}_cert.pem
        bosh int <(credhub get -n "/${K8S_DIRECTOR}/${BOSH_K8S_DEPLOYMENT}/tls-admin" --output-json) --path=/value/private_key > ${CRT_DIR}/${K8S_CLUSTER}_key.pem
  #      export KUBECONFIG=${HOME}/.kube/config
  #
  #      kubectl config set-cluster "${K8S_CLUSTER}" --server="https://${K8S_API_ENDPOINT}" --certificate-authority="${CRT_DIR}/${K8S_CLUSTER}_ca.pem" --embed-certs=true > /dev/null 2>&1
  #      if [ $? != 0 ] ; then
  #        printf "\n\n%bERROR : Set cluster \"${K8S_CLUSTER}\" configuration failed.%b\n\n" "${RED}" "${STD}" ; flagError=1
  #      else
  #        kubectl config set-credentials "admin" --client-key ${CRT_DIR}/${K8S_CLUSTER}_key.pem --client-certificate ${CRT_DIR}/${K8S_CLUSTER}_cert.pem --embed-certs > /dev/null 2>&1
  #        #kubectl config set-credentials "admin" --client-key ${CRT_DIR}/${K8S_CLUSTER}_key.pem --client-certificate ${CRT_DIR}/${K8S_CLUSTER}_cert.pem --embed-certs > /dev/null 2>&1
  #        if [ $? != 0 ] ; then
  #          printf "\n\n%bERROR : Set cluster \"${K8S_CLUSTER}\" credentials failed.%b\n\n" "${RED}" "${STD}" ; flagError=1
  #        else
  #          kubectl config set-context "${K8S_CLUSTER}" --cluster="${K8S_CLUSTER}" --user="admin" > /dev/null 2>&1
  #          if [ $? != 0 ] ; then
  #            printf "\n\n%bERROR : Set cluster \"${K8S_CLUSTER}\" context failed.%b\n\n" "${RED}" "${STD}" ; flagError=1
  #          else
  #            kubectl config use-context "${K8S_CLUSTER}" > /dev/null 2>&1
  #          fi
  #        fi
  #      fi
  #    fi
  #  fi

}

# $1 namespace
function create_smoke_test_namespace_if_needed() {
    local smoke_test_namespace="$1"

    #See https://stackoverflow.com/a/54248723/1484823
     run_with_traces "kubectl create namespace "${smoke_test_namespace}" --dry-run=client -o yaml | kubectl apply -f -"
}

# $1 broker name (e.g. "osb-cmdb-0"): used in naming the secret
# $2 broker url (without basic auth) (e.g. "https://osb-cmdb-broker-0.redacted-domain.org")
# $3 basic auth login
# $4 basic auth password
# $5 namespace
function register_broker_in_svcat() {
  local broker_name="$1"
  local broker_url="$2"
  local broker_user_name="$3" # credential_leak_validated
  local broker_user_pwd="$4"
  local smoke_test_namespace="$5"

  echo_comment "Registering service broker in namespace: ${smoke_test_namespace} (if missing). \n Typically done by an admin cluster-wide in consummer platforms "
  echo
  run_with_traces svcat get brokers --namespace "${smoke_test_namespace}"
  if svcat get brokers --namespace "${smoke_test_namespace}" | grep -q "${broker_name}" ; then
    echo_comment "Broker is already registered. Request to refreshing its catalog"
    run_with_traces svcat sync broker "${broker_name}" -n "${smoke_test_namespace}"
    sleep 5
    run_with_traces "kubectl get servicebrokers.servicecatalog.k8s.io --namespace \"${smoke_test_namespace}\" \"${broker_name}\" -o json | jq '.status'"
  else
    echo_comment "No existing broker, creating a new broker"
    local secret_name="${broker_name}-svcat-basic-auth"
    kubectl delete secret "${secret_name}" --namespace "${smoke_test_namespace}" > /tmp/delete-secre 2>&1 || echo "Ok no previous secret requires cleanup"
    run_with_traces kubectl create secret generic "${secret_name}" --from-literal username="${broker_user_name}" --from-literal password="${broker_user_pwd}" --namespace "${smoke_test_namespace}"

    run_with_traces svcat register "${broker_name}" --url "${broker_url}" --scope namespace --namespace "${smoke_test_namespace}" --basic-secret "${secret_name}" --skip-tls


    local MSG="Waiting for broker loading"
    retry_with_svcat_defaults "${MSG}" is_broker_registration_complete "${smoke_test_namespace}" "${broker_name}"

    if ! is_broker_ready "${smoke_test_namespace}" "${broker_name}" ; then
      echo "service broker provisionning failed, leaving it for manual inspection"
      run_with_traces svcat get broker "${broker_name}" --namespace "${smoke_test_namespace}" -o yaml
      false # fail script when strict mode enabled
    fi

    # Display broker current state which should be Ready
    run_with_traces svcat get broker "${broker_name}" --namespace "${smoke_test_namespace}"
  fi
  echo
}

# $1 namespace
function display_svcat_catalog() {
  local smoke_test_namespace="$1"

  echo_comment "Marketplace content from K8S consumer"

  #Display cluster scope and namespaced service classes
  run_with_traces "svcat marketplace --namespace=\"${smoke_test_namespace}\""
  echo
  run_with_traces "kubectl get serviceclasses.servicecatalog.k8s.io -n \"${smoke_test_namespace}\""
  echo
  run_with_traces "kubectl get serviceplans.servicecatalog.k8s.io -n \"${smoke_test_namespace}\""
}

# $1 template_file_to_render
# stdout: rendered file content expanded with env vars
function render_kuttle_template() {
  local template_file_to_render="$1"

  # see https://serverfault.com/a/699377
  # TODO: check local vars in caller functions are expanded
  # if not consider inlining in callers or export env vars
  eval "echo \"\$(cat ${template_file_to_render})\""
}

# $1 kuttle assertion file name
function run_kuttle_assertion_from_file() {
  local template_file_to_render="$1"
  local rendered_template=$(render_kuttle_template template_file_to_render)
  echo "${rendered_template}" > /tmp/rendered-template
  # step 1: render the kuttle template to
  kubectl-kuttl assert  /tmp/rendered-template  --namespace service-sandbox-overview-broker-smoke-tests 2> /tmp/assert
}

# $1 namespace
# $2 kuttle assertion string
function run_kuttle_assertion() {
  # TODO: not yet tested
  local smoke_test_namespace="$1"
  local rendered_template="$2"
  echo "${rendered_template}" > /tmp/rendered-template
  #Possibly failon non zero exit status
  kubectl-kuttl assert  /tmp/rendered-template  --namespace "${smoke_test_namespace}" 2> /tmp/assert
}

# One shot check if a service instance provisionning is complete
# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service name
is_svcat_provisionning_complete() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"

  # kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}"
  # svcat output is initially missing the status displayed as "", making it hard to assert it
  #                  NAME                                       NAMESPACE                      CLASS   PLAN      STATUS
  #+---------------------------------------+-------------------------------------------------+-------+------+--------------+
  #  noop-ondemand-smoke-test1623073614-14   service-sandbox-coa-noop-smoke-tests-1623073612                  Provisioning

  # instead we extract it in json format
  # store in a local variable to make it visible in debugging traces
  local svcat_instance_status
  svcat_instance_status=$(kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}" -o json | jq -r ".status.lastConditionState")

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  ! echo "${svcat_instance_status}"  | grep -q -E 'null|ProvisionRequestInFlight|Provisioning'
}

# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service binding name
is_svcat_binding_complete() {
  local smoke_test_namespace="$1"
  local service_binding_name="$2"

  # store in a local variable to make it visible in debugging traces
  local svcat_instance_status
  svcat_instance_status=$(kubectl get servicebindings.servicecatalog.k8s.io  "${service_binding_name}" -n "${smoke_test_namespace}" -o json | jq -r ".status.lastConditionState")

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  # See related code defining statuses at https://github.com/kubernetes-sigs/service-catalog/blob/7942106ffe59d1579c33fff573dd20376e242887/pkg/controller/controller_binding.go#L55-L65
  ! echo "${svcat_instance_status}"  | grep -q -E 'null|BindingRequestInFlight|Binding'
}

# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service binding name
is_svcat_unbinding_complete() {
  local smoke_test_namespace="$1"
  local service_binding_name="$2"

  kubectl get servicebindings.servicecatalog.k8s.io  "${service_binding_name}" -n "${smoke_test_namespace}" > /tmp/unbinding 2>&1
  if [ $? != 0 ] ; then
    # Binding is now missing
    return 0
  else
    return 1
  fi
}

# One shot check if a service instance provisionning is complete
# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service binding name
is_svcat_binding_successfull() {
  local smoke_test_namespace="$1"
  local service_binding_name="$2"

  # kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}"
  # svcat output is initially missing the status displayed as "", making it hard to assert it
  #                  NAME                                       NAMESPACE                      CLASS   PLAN      STATUS
  #+---------------------------------------+-------------------------------------------------+-------+------+--------------+
  #  noop-ondemand-smoke-test1623073614-14   service-sandbox-coa-noop-smoke-tests-1623073612                  Provisioning

  # instead we extract it in json format
  # store in a local variable to make it visible in debugging traces
  local svcat_binding_status
  svcat_binding_status=$(kubectl get servicebindings.servicecatalog.k8s.io  "${service_binding_name}" -n "${smoke_test_namespace}" -o json | jq -r ".status.lastConditionState")

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  echo "${svcat_binding_status}"  | grep -q 'Ready'
  return $?
}

# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2: resource_name (e.g. "serviceinstances.servicecatalog.k8s.io")
has_namespace_remaining_named_resources() {
  local smoke_test_namespace="$1"
  local resource_name="$2"

  # store in a local variable to make it visible in debugging traces
  local svcat_instance_status
  svcat_instance_status=$(kubectl get "${resource_name}"  -n "${smoke_test_namespace}")
  #expecting exit status 0 even if resource is missing

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  ! echo "${svcat_instance_status}"  | grep -q 'No resources found'
}

# One shot check if a service instance provisionning is complete
# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service name
is_svcat_deprovisionning_complete() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"

  kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}" > /tmp/unprovision-status 2>&1

  if [ $? != 0 ] ; then
    # Binding is now missing
    return 0
  else
    return 1
  fi
}

# $1: namespace
# $2 - broker_name
is_broker_registration_complete() {
  local smoke_test_namespace="$1"
  local broker_name="$2"

  # store in a local variable to make it visible in debugging traces
  local broker_status
  broker_status=$(kubectl get servicebrokers.servicecatalog.k8s.io  "${broker_name}" -n "${smoke_test_namespace}" -o json | jq -r ".status.lastConditionState")

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  ! echo "${broker_status}"  | grep -q -E 'null'
}

# $1: namespace
# $2 - broker_name
is_broker_ready() {
  local smoke_test_namespace="$1"
  local broker_name="$2"

  # store in a local variable to make it visible in debugging traces
  local broker_status
  broker_status=$(kubectl get servicebrokers.servicecatalog.k8s.io  "${broker_name}" -n "${smoke_test_namespace}" -o json | jq -r ".status.lastConditionState")

  # Status is initially empty (null) then evolves in svcat state machine before reaching "Ready"
  echo "${broker_status}"  | grep 'Ready'
}


# TODO: not yet tested
wait_until_svcat_instance_ready() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"

  local kuttle_template
  # Note: read exit status is non zero when reaching EOF, so we are applying a logical OR with true
  # $ read --help
  # [...]
  #  The return code is zero, unless end-of-file is encountered, read times out
  #    (in which case it's greater than 128), a variable assignment error occurs,
  #    or an invalid file descriptor is supplied as the argument to -u.
  read -r -d '' kuttle_template <<'EOF' || true
apiVersion: servicecatalog.k8s.io/v1beta1
kind: ServiceInstance
metadata:
  name: ${service_instance_name}
  namespace: ${smoke_test_namespace}
status:
  lastConditionState: Ready

  return $?
}
EOF

  run_kuttle_assertion "${smoke_test_namespace}" "${kuttle_template}"

}

# One shot check if a service instance provisionning is successfull
# Should be called within a if block to not fail on non zero exit status
# see https://tldp.org/LDP/abs/html/options.html
# -e	errexit	Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
#
# $1: namespace
# $2 - service name
is_svcat_service_operation_successful() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"
  shift
  run_with_traces svcat get instance "${service_instance_name}" -n "${smoke_test_namespace}"
  svcat get instance "${service_instance_name}" -n "${smoke_test_namespace}" | grep -q 'Ready'
  return $?
}

# $1: namespace
# $2: service instance name to provision
# $3: service offering name
# $4: service plan name
# $4: service configuration parameters in json or ""
function test_svcat_service_provisionning() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"
  local service_offering_name="$3"
  local service_plan_name="$4"
  local service_instance_configuration_parameters="$5"

  echo_comment "Testing provisionning ${service_offering_name} ..."

  local params_option=""
  if [ "${service_instance_configuration_parameters}" != "" ]; then
    local expanded_config_params_json=$(echo "${service_instance_configuration_parameters}" | envsubst)
    params_option="--params-json '${expanded_config_params_json}'"
  fi

  run_with_traces svcat provision "${service_instance_name}" -n "${smoke_test_namespace}" --class "${service_offering_name}" --plan "${service_plan_name}" ${params_option}

  local service_instance_guid
  service_instance_guid=$(get_serviceinstance_guid "${smoke_test_namespace}" "${service_instance_name}")

  local MSG="Waiting for provisioning of service with guid=${service_instance_guid}"
  local NB_ATTEMPTS=$((${MAX_TIME} / 15))
  retry 15 ${NB_ATTEMPTS} "${MSG}" is_svcat_provisionning_complete "${smoke_test_namespace}" "${service_instance_name}"

  if ! is_svcat_service_operation_successful "${smoke_test_namespace}" "${service_instance_name}" ; then
    echo "service instance provisionning failed, leaving it for manual inspection"
    false # fail script when strict mode enabled
  fi
  echo "Dashboard url"
  run_with_traces "svcat get instance ${service_instance_name} -n ${smoke_test_namespace} -o json | jq '.status.dashboardURL'"
  echo_comment "Testing provisionning ${service_offering_name} ...ok"
}

# $1: namespace
# $2: service instance name to lookup
function get_serviceinstance_guid() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"

  local service_instance_guid
  service_instance_guid=$(svcat get instance "${service_instance_name}" -n "${smoke_test_namespace}" -o json | jq -r '.spec.externalID')

  echo "${service_instance_guid}"
}

# $1: namespace
# $2: service instance name to provision
function test_svcat_service_bind_unbind() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"
  local service_offering_name="$3"

  # How to name bindings ?
  # Do we need to test support for multiple bindings ? Not yet, possibly in the future => avoid naming conflict in the same namespace
  # Do we need to test support for multiple service offerings ? Likely => prefix binding name with service offering name

  local service_binding_name=$(generate_unique_prefixed_name "${service_offering_name}-smoke-test")
  # How to name secrets ?
  # Reused the same name as binding to avoid conflicts in the binding scenarios
  local secret_binding_name=$(generate_unique_prefixed_name "${service_offering_name}-smoke-test")

  #See https://svc-cat.io/docs/walkthrough/#step-5---requesting-a-servicebinding-to-use-the-serviceinstance

  echo_comment "Testing binding..."

  run_with_traces svcat bind --namespace ${smoke_test_namespace} ${service_instance_name} --name "${service_binding_name}" --secret-name "${secret_binding_name}"

  local service_instance_guid
  service_instance_guid=$(get_serviceinstance_guid "${smoke_test_namespace}" "${service_instance_name}")

  local MSG="Waiting for binding completion of service binding for instance with guid=${service_instance_guid}"
  retry_with_svcat_defaults "${MSG}" is_svcat_binding_complete "${smoke_test_namespace}" "${service_binding_name}"

  if ! is_svcat_binding_successfull "${smoke_test_namespace}" "${service_binding_name}" ; then
    echo "service binding failed, leaving it for manual inspection"
    false # fail script when strict mode enabled
  fi

  # run_with_traces svcat get bindings --namespace ${smoke_test_namespace} "${service_binding_name}"
  run_with_traces svcat describe binding --namespace ${smoke_test_namespace} "${service_binding_name}"

  #See https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/#decoding-secret (-ojsondata broken)
  # and https://stackoverflow.com/a/60178693/1484823
  run_with_traces "kubectl get secret "${secret_binding_name}" --namespace ${smoke_test_namespace} -o json | jq '.data |  map_values(@base64d)'"

  echo_comment "Testing binding...ok"

  echo_comment "Testing unbinding..."

  run_with_traces svcat unbind --namespace ${smoke_test_namespace} --name "${service_binding_name}"

  local MSG="Waiting for unbinding completion of service with guid=${service_instance_guid}"
  retry_with_svcat_defaults "${MSG}" is_svcat_unbinding_complete "${smoke_test_namespace}" "${service_binding_name}"

  echo_comment "Testing unbinding...ok"

}


# $1: namespace
# $2: service instance name to provision
function test_svcat_service_deprovisionning() {
  local smoke_test_namespace="$1"
  local service_instance_name="$2"

  echo_comment "Testing deprovisionning..."
  run_with_traces svcat deprovision "${service_instance_name}" -n "${smoke_test_namespace}"

  local service_instance_guid
  service_instance_guid=$(svcat get instance "${service_instance_name}" -n "${smoke_test_namespace}" -o json | jq -r '.spec.externalID')

  local MSG="Waiting for deprovisioning of service with guid=${service_instance_guid}"
  local NB_ATTEMPTS=$((${MAX_TIME} / 15))
  retry 15 ${NB_ATTEMPTS} "${MSG}" is_svcat_deprovisionning_complete "${smoke_test_namespace}" "${service_instance_name}"

  if kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}" 2>/tmp/deprovision-status ; then
    echo "service instance deprovisionning failed, leaving it for manual inspection"
    run_with_traces kubectl get serviceinstances.servicecatalog.k8s.io  "${service_instance_name}" -n "${smoke_test_namespace}"
    false
  else
    echo_comment "Testing deprovisionning... ok"
  fi

}

#See https://github.com/orange-cloudfoundry/paas-templates/issues/1112

function test_svcat_service_instance_params_update() {

  run_with_traces svcat provision "${service_instance_name}" -n "${smoke_test_namespace}" --class "${service_offering_name}" --plan "${service_plan_name}"
  #--params-json '{"p1":"value1"}'
  #  Name:        p-mysql-gberche
  #  Namespace:   catalog
  #  Status:
  #  Class:
  #  Plan:
  #
  #Parameters:
  #  p1: value1

  cat <<EOF > svcat-serviceinstance-patch.yml
spec:
  parameters:
    p1: "new value"
    p2: value2
EOF

  # Note: --type=merge is required although not shown in examples, see https://github.com/kubernetes/kubernetes/issues/97423
  kubectl patch serviceinstances.servicecatalog.k8s.io -n catalog p-mysql-gberche --type=merge --patch "$(cat svcat-serviceinstance-patch.yml)"
  #serviceinstance.servicecatalog.k8s.io/p-mysql-gberche patched



}

# $1: namespace-prefix
clean_up_leaking_namespaces() {
  local namespace_prefix="$1"
  if [ "${namespace_prefix}" == "" ]; then
    echo "missing $1 namespace_prefix"
    false
  fi

  #Clean up services to keep only a small number for now, way before quota (quota=15 services)
  local first_namespace_index_to_clean=2
  local namespaces_to_clean
  namespaces_to_clean=$(kubectl get namespaces -o json | jq -r ".items[].metadata.name | select( startswith(\"${namespace_prefix}\"))" | sort | tail -n +${first_namespace_index_to_clean})
  if [[ ! -z ${namespaces_to_clean} ]]; then
    echo "Cleaning up $(echo "${namespaces_to_clean}" | wc -l) namespaces with prefix ${namespace_prefix}."
    for s in ${namespaces_to_clean}; do
      clean_up_namespace "${s}"
    done
  else
    echo "No previous namespace needs clean up with prefix ${namespace_prefix}."
  fi
}

# $1: namespace
clean_up_namespace() {
  local namespace="$1"
  echo_comment "Cleaning up namespace ${namespace} (deleting bindings, serviceinstance, broker to avoid that finalizers hang)"
  # We need to delete the service instance and bindings before the broker otherwise their finalizers will hang
  # We can't have a broker is a namespace and instances/bindings unless the broker is cluster-wide
  # We don't want to use cluster-wide broker as this creates conflicting names among smoke tests
  run_with_traces kubectl delete servicebinding --all -n  ${namespace}
  run_with_traces kubectl delete serviceinstance --all -n  ${namespace}

  local MSG="Waiting for deprovisioning of any service instances in ${namespace}"
  retry_with_svcat_defaults "${MSG}" has_namespace_remaining_named_resources "${namespace}" "serviceinstances.servicecatalog.k8s.io"

  run_with_traces kubectl delete servicebroker --all -n  ${namespace}

  local MSG="Waiting for deprovisioning of any service broker in ${namespace}"
  retry_with_svcat_defaults "${MSG}" has_namespace_remaining_named_resources "${namespace}" "servicebrokers.servicecatalog.k8s.io"

  run_with_traces "kubectl delete namespace  ${namespace}"
}
