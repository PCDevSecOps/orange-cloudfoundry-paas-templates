#!/bin/bash
# This file contains functions shared between the pre-cf-push and post-deploy.sh scripts

# Debug mode
#DEBUG_MODE=$(bosh int "${SECRETS_DIR}/secrets/meta.yml" --path /meta/db-dumper/debug_mode)
#DEBUG_MODE=true
DEBUG_MODE=${DEBUG_MODE:-false}

# Sets verbose mode if $$DEBUG_MODE is set to true
# Never clears verbose mode
# Always exits on errors
function setVerboseExitMode() {
    set -o errexit # exit on errors
    shopt -s extdebug # extended debugging variables, see https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin

    if [[ "$DEBUG_MODE" == "true" ]]
    then
        set -o xtrace # debug mode
        #Format prompt to display function and line number, as suggested into http://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
        export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    fi
}
setVerboseExitMode

# $1 command name
# exit: 0 is defined, non-zero otherwise
function is_command_defined {
    # https://stackoverflow.com/a/677212/1484823  how-to-check-if-a-program-exists-from-a-bash-script
    if ! type -a $1 > /dev/null 2>&1
    then
        return 1
    fi
}

# prints the current stack trace on stdout
function display_current_stack_trace() {
        # Inspired by
        # https://www.runscripts.com/support/guides/scripting/bash/debugging-bash/stack-trace
        declare frame=0
        declare argv_offset=0

        while caller_info=( $(caller $frame) ) ; do
           if shopt -q extdebug ; then

               declare argv=()
               declare argc
               declare frame_argc

               for ((frame_argc=${BASH_ARGC[frame]},frame_argc--,argc=0; frame_argc >= 0; argc++, frame_argc--)) ; do
                   argv[argc]=${BASH_ARGV[argv_offset+frame_argc]}
                   case "${argv[argc]}" in
                       *[[:space:]]*) argv[argc]="'${argv[argc]}'" ;;
                   esac
               done
               argv_offset=$((argv_offset + ${BASH_ARGC[frame]}))
               echo "${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}(): ${FUNCNAME[frame]} ${argv[*]}"
           fi

           frame=$((frame+1))
        done

        # This original last part seems a duplicate, we skip it
        #        if [[ $frame -eq 1 ]] ; then
        #           caller_info=( $(caller 0) )
        #           echo ":: ${caller_info[2]}: Line ${caller_info[0]}: ${caller_info[1]}"
        #        fi
}

# Sample output 1: with faulty_fuction call
# =========================================================
# [..]/common-lib.bash: line 123: noSuchCommand: command not found
#
#"noSuchCommand with some args" command failed with exit code 127 at:
#[..]/common-lib.bash: Line 93: display_diagnostics_on_exit(): display_current_stack_trace
#[..]/common-lib.bash: Line 123: install_bosh_cli(): display_diagnostics_on_exit
#[..]/common-lib.bash: Line 153: install_bosh_cli_if_needed(): install_bosh_cli
#[..]/common-lib.bash: Line 164: fetch_deployment_secret_prop(): install_bosh_cli_if_needed
#[..]/post-deploy.sh: Line 13: main(): fetch_deployment_secret_prop broker_name missing_broker_name_from_secrets_file
#
# "BROKER_NAME=$(fetch_deployment_secret_prop "broker_name" "missing_broker_name_from_secrets_file")" command failed with exit code 127 at:
#[..]/post-deploy.sh: Line 13: main(): display_diagnostics_on_exit
#[..]/common-lib.bash: Line 93: display_diagnostics_on_exit(): display_current_stack_trace
#
# Sample output 2: with B=$(faulty_function)
# =========================================================
# "bosh int "${SHARED_SECRETS}" --path /secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password" command failed with exit code 1 at:
#
#"BROKER_USER_PASSWORD="${BROKER_USER_PASSWORD:-$(bosh int "${SHARED_SECRETS}" --path /secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password)}"" command failed with exit code 1 at:
#[..]/common-lib.bash: Line 93: display_diagnostics_on_exit(): display_current_stack_trace
#[..]/common-post-deploy.sh: Line 93: main(): display_diagnostics_on_exit
#
#"${BASE_TEMPLATE_DIR}/common-post-deploy.sh" command failed with exit code 1 at:
#[..]/common-lib.bash: Line 93: display_diagnostics_on_exit(): display_current_stack_trace
#[..]/post-deploy.sh: Line 131: main(): display_diagnostics_on_exit
function display_diagnostics_on_err() {
    exit_code=$?
    last_command="${BASH_COMMAND}"

    if [[ ${exit_code} -ne 0 ]]; then
        # Redirect stdout to stderr. Otherwise, errors occuring within a valued function faulty-function such as in b=$(faulty-function ) are swallowed by callers
        >&2 printf "\n\"${last_command}\" command failed with exit code ${exit_code} at:\n"
        display_current_stack_trace
    fi
    # Additional steps expected to be defined in caller, and inclure assertions such as searching for broker exceptions
    if ! is_command_defined exec_additional_steps_on_exit ; then
        printf "" # noop
    else
       exec_additional_steps_on_exit
    fi
    exit ${exit_code}
}

# We trap ERR and not EXIT to preserve the root cause faulty functions to be available for dump. With EXIT we always get the trapping function
# Note: this will be trapped multiple times
trap 'display_diagnostics_on_err' ERR

function display_current_process_tree() {
    # Not clear why ps seems to be truncating command name despite wide options
    echo
    ! PROCESS_TREE=$(ps --forest -w --cols=2000)
    ! PROCESS_TREE=$(echo "${PROCESS_TREE}" | grep -v "_ ps")
    echo "${PROCESS_TREE}"
}

function display_hints_once_on_exit() {
    exit_code=$?
    if [[ ${exit_code} -ne 0 && ! -f /tmp/debugging_hint_was_displayed ]]; then
        # Disabled as not so useful. Might reconsider in the future.
        # display_current_process_tree
        echo
        echo "Hint to re-run/patch this task quickly: "
        echo "   fly hijack -u <url of this pipeline> /bin/ash"
        echo "# then run"
        echo "   ${DEBUGGING_HINT_CMD}"
        echo "# or "
        echo "   DEBUG_MODE=true ${DEBUGGING_HINT_CMD}"
        echo "# once satisfied with patches, save them to properly contribute upstream:"
        echo "   ./templates-resource/coab-depls/common-broker-scripts/save-hijacked-modif.bash"
        touch /tmp/debugging_hint_was_displayed
    fi
    exit ${exit_code}
}
# This is still trapped multiple times: once for each nested bash script. Too complex to display it on last shell
trap 'display_hints_once_on_exit' EXIT



#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

function install_bosh_cli() {
    #--- Parameters
    local BOSH_CLI_VERSION="3.0.1"

    #--- Install bosh cli
    printf "%bInstall bosh cli ${BOSH_CLI_VERSION}...%b" "${YELLOW}" "${STD}"
    # https://curl.haxx.se/docs/manpage.html
    # Previously redirected stderr to stdout and stdout to /dev/null
    # 2>&1 is dangerous as order matters
    #   https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Moving-File-Descriptors
    #   https://github.com/koalaman/shellcheck/wiki/SC2069
    # Preferring &> syntax
    # https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Redirecting-Standard-Output-and-Standard-Error
    # https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators/159514#159514

    curl -L --silent --show-error "https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${BOSH_CLI_VERSION}-linux-amd64" -o /usr/local/bin/bosh
    if [[ $? != 0 ]] ; then
        printf "\n%bERROR: Install bosh cli failed%b\n\n" "${RED}" "${STD}" ;
        exit 1
    else
        printf "%bOK %b\n" "${YELLOW}" "${STD}"
    fi
    chmod 755 /usr/local/bin/bosh
}

# stdout: none
# stderr: potentially bosh cli install logs
function install_bosh_cli_if_needed() {
    if ! type -a bosh > /dev/null 2>&1
    then
        install_bosh_cli > /dev/stderr
    fi
}

# Fetch a property from deployment secrets.yml
# prereq COA-provided: $SECRETS_DIR (present in both pre-cf-push and post-deploy)
# $1: property name relative to /secrets/ (e.g. "smoke_test_service")
# $2: default value or none (undefined or "") to fail if the property is undefined
# stdout: the property value or the default
# stderr: potentially bosh cli install logs
function fetch_deployment_secret_prop() {
    local PROPERTY_NAME="$1"
    local DEFAULT_VALUE="$2"
    fetch_secret_prop "${SECRETS_DIR}/secrets/secrets.yml" "/secrets/${PROPERTY_NAME}" "${DEFAULT_VALUE}"
}

# Fetch a property from shared/secrets.yml
# $1: absolute path in the shared/secrets.yml structure (eg "/secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password" )
# $2: default value or none (undefined or "") to fail if the property is undefined
# stdout: the property value or the default
# stderr: potentially bosh cli install logs
function fetch_shared_secret_prop() {
    local PROPERTY_PATH="$1"
    local DEFAULT_VALUE="$2"
    fetch_secret_prop "${SHARED_SECRETS}" "${PROPERTY_PATH}" "${DEFAULT_VALUE}"
}

# Fetch a property from yml file using bosh-int
# $1: absolute path to yml file (e.g. ${SHARED_SECRETS}
# $2: property name in the yaml (eg. "/secrets/cloudfoundry/service_brokers/${DEPLOYMENT_NAME}/password"
# $3: default value or none (undefined or "") to fail if the property is undefined
# stdout: the property value or the default
# stderr: potentially bosh cli install logs
function fetch_secret_prop() {
    install_bosh_cli_if_needed
    local YAML_FILE_PATH="$1"
    local PROPERTY_PATH="$2"
    local DEFAULT_VALUE="$3"

    # redirect stdout to stderr to still print bosh cli install steps but
    install_bosh_cli_if_needed 1>&2

    #Note: redirect stderr to file to avoid poluttin stderr output with message such as
    # >  Expected to find a map key 'register_broker_enabled' for path '/secrets/register_broker_enabled' (found map keys: 'coa-noop-broker', 'mode'). Exit code 1
    ! bosh int "${YAML_FILE_PATH}" --path ${PROPERTY_PATH} >/tmp/fetch_deployment_secret_value.txt 2> /tmp/fetch_deployment_secret_prop.txt
    local NEGATED_EXIT_CODE=$? # negated above to avoid toggling off & on exitmode.
                               # See https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#index-trap
                               # "don't trap/exit if  if the command’s return status is being inverted using !"
    # We don't use the A=$(command || echo "Default") because bosh int happens to echo output on stdout before failing, which pollutes Default value
    if [[ ${NEGATED_EXIT_CODE} -eq 0 ]]; then
        if [[ -n "${DEFAULT_VALUE}" ]]; then
            echo "${DEFAULT_VALUE}"
        else
            >&2 echo "Unable to resolve mandatory property \"${PROPERTY_PATH}\" in ${YAML_FILE_PATH}. bosh int failed with message: $(cat /tmp/fetch_deployment_secret_prop.txt)"
            false
        fi
    else
        echo "$(cat /tmp/fetch_deployment_secret_value.txt)"
    fi
    #Save msg in a variable so that debugging traces will display it
    # shellcheck disable=SC2155,SC2034
    local BOSH_INT_MESSAGE=$(cat /tmp/fetch_deployment_secret_prop.txt || true)
}

function set_verbose_mode_as_requested_in_secrets() {
    #Refresh debug mode if overriden in deployment
    DEBUG_MODE=$(fetch_deployment_secret_prop "debug" "${DEBUG_MODE}")
    export DEBUG_MODE #TODO: consider passing as a function param
    setVerboseExitMode
}
#Note: we don't invoke the function directly as we want to avoid managing dependencies among function declarations
#This should rather be invoked by caller after sourcing this script

function install_credhub_cli() {
    local CREDHUB_CLI_VERSION="2.6.0"
    if credhub --version > /dev/null 2>&1 && [[ $(credhub --version) =~ ${CREDHUB_CLI_VERSION} ]]; then
        echo "credhub cli $CREDHUB_CLI_VERSION already installed"
        return
    fi
    printf "%bInstalling credhub cli version ${CREDHUB_CLI_VERSION} ...%b" "${YELLOW}" "${STD}"
    curl -L --silent --show-error "https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-linux-${CREDHUB_CLI_VERSION}.tgz" -o credhub.tgz
    tar xvfz credhub.tgz > /dev/null
    mv ./credhub /usr/local/bin/
    credhub --version >& /dev/nul
    printf "%bOK %b\n" "${YELLOW}" "${STD}"
}

function credhub_login() {
    printf "%bLogging into credhub%b\n" "${YELLOW}" "${STD}"
    # Parse secrets micro-depls/concourse/concourse.yml for format
    #instance_groups[0].jobs[0].properties.credhub ?

    # When invoked during post-deploy, SECRETS_DIR is defined
    local SHARED_SECRETS_FILE=${SECRETS_DIR}/../../../shared/secrets.yml
    if [[ ! -f ${SHARED_SECRETS_FILE} ]]; then
        echo "Unable to locate share/secrets.yml files"
        false #fail when exit mode is set
    fi
    local CREDHUB_PASSWORD
    CREDHUB_PASSWORD=$(bosh int "${SHARED_SECRETS_FILE}" --path /secrets/bosh_credhub_secrets)
    local SHARED_CERTS_DIR="${SECRETS_DIR}/../../../shared/certs"
    local CREDHUB_CERTS
    CREDHUB_CERTS="$(cat ${SHARED_CERTS_DIR}/internal_paas-ca/server-ca.crt ${SHARED_CERTS_DIR}/internal_paas-ca-2/server-ca.crt)"
    credhub login --server https://credhub.internal.paas:8844 --client-name=director_to_credhub --client-secret=${CREDHUB_PASSWORD} --ca-cert="${CREDHUB_CERTS}"
}

# Each credhub-var-xx.json file is expected to match the credhub API payload,
# e.g for a password  https://credhub-api.cfapps.io/version/2.8/#_generate_a_password_credential
# $ cat credhub-var-xx.json
# {
#  "name": "/some-password-name",
#  "type": "password",
#  "metadata": { "description": "example metadata"}
#}
#
function credhub_var_files() {
    find ${CUSTOM_SCRIPT_DIR}/ -name "credhub-var-*.json"
}

function credhub_declare_variables() {
    local CREDHUB_VAR_FILES
    CREDHUB_VAR_FILES=$(credhub_var_files)
    for s in ${CREDHUB_VAR_FILES}; do
        local CREDHUB_VAR_CONTENT
        CREDHUB_VAR_CONTENT=$(cat $s)
        echo "Creating credhub password for file: ${s} with content: ${CREDHUB_VAR_CONTENT}"
        echo "Generated credential is (masking value):"
        credhub curl -X POST -p /api/v1/data -d="${CREDHUB_VAR_CONTENT}" | grep -v value
    done;
}

# /${root_deployment}/cf-apps-deployments/${deployment}
function default_credhub_interpolate_prefix() {
    echo "/$(extract_rootdeployment_name)/cf-apps-deployments/$(extract_deployment_name)"
}

# $CF_MANIFEST manifest file path (optional)
# $INTERPOLATE_CREDHUB_PREFIX (optional, defaults to default_credhub_interpolate_prefix
function credhub_interpolate_manifest() {
    local CF_MANIFEST=${CF_MANIFEST:-manifest.yml}
    local NEW_CF_MANIFEST="${CF_MANIFEST}.credhubinterpolated"
    # https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html#Bash-Conditional-Expressions
    # -n non zero
    local INTERPOLATE_CREDHUB_PREFIX
    local PREFIX_OPTION
    INTERPOLATE_CREDHUB_PREFIX="${INTERPOLATE_CREDHUB_PREFIX:-$(default_credhub_interpolate_prefix)}"
    if [[ -n "${INTERPOLATE_CREDHUB_PREFIX}" ]]; then
        PREFIX_OPTION="--prefix=${INTERPOLATE_CREDHUB_PREFIX}"
    else
        PREFIX_OPTION=""
    fi

    echo "interpolating ${CF_MANIFEST} with prefix ${INTERPOLATE_CREDHUB_PREFIX}"
    credhub interpolate ${PREFIX_OPTION} -f ${CF_MANIFEST} > ${NEW_CF_MANIFEST}

    mv ${CF_MANIFEST} ${CF_MANIFEST}.orig
    mv ${NEW_CF_MANIFEST} ${CF_MANIFEST}
}

# In: $BASE_TEMPLATE_DIR defined by coa (e.g. /.../ops-depls/cf-apps-deployments/osb-cmdb-broker/template )
# or  $CUSTOM_SCRIPT_DIR defined by coa (e.g. template-resource/ops-depls/cf-apps-deployments/osb-cmdb-broker/template )
# stdout: osb-cmdb-broker
function extract_deployment_name() {
    local VAR_TO_EXTRACT_FROM="${BASE_TEMPLATE_DIR:-${CUSTOM_SCRIPT_DIR}}"
    extract_deployment_name_from_arg ${VAR_TO_EXTRACT_FROM}
}

function extract_deployment_name_from_arg() {
    local VAR_TO_EXTRACT_FROM="$1"
    # https://stackoverflow.com/a/2664746/1484823 extract-file-basename-without-path-and-extension-in-bash
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
    # ${parameter##[word]}
    #    Remove Largest Prefix Pattern. The word shall be expanded to produce a pattern.
    # ${parameter%%[word]}
    #    Remove Largest Suffix Pattern. The word shall be expanded to produce a pattern.
    local EXTRACTED_SUFFIX="${VAR_TO_EXTRACT_FROM##*/cf-apps-deployments/}" # eg osb-cmdb-broker/template
    echo "${EXTRACTED_SUFFIX%%/template}" # eg osb-cmdb-broker
}

# In: $BASE_TEMPLATE_DIR defined by coa (e.g. /.../ops-depls/cf-apps-deployments/osb-cmdb-broker/template )
# or  $CUSTOM_SCRIPT_DIR defined by coa (e.g. template-resource/ops-depls/cf-apps-deployments/osb-cmdb-broker/template )
# stdout: ops-depls
function extract_rootdeployment_name() {
    local VAR_TO_EXTRACT_FROM="${BASE_TEMPLATE_DIR:-${CUSTOM_SCRIPT_DIR}}"
    extract_rootdeployment_name_from_arg ${VAR_TO_EXTRACT_FROM}
}

function extract_rootdeployment_name_from_arg() {
    local VAR_TO_EXTRACT_FROM="$1"
    # https://stackoverflow.com/a/2664746/1484823 extract-file-basename-without-path-and-extension-in-bash
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
    # ${parameter##[word]}
    #    Remove Largest Prefix Pattern. The word shall be expanded to produce a pattern.
    # ${parameter%%[word]}
    #    Remove Largest Suffix Pattern. The word shall be expanded to produce a pattern.
    local EXTRACTED_SUFFIX="${VAR_TO_EXTRACT_FROM%%/cf-apps-deployments/*}" # eg .../ops-depls
    echo "${EXTRACTED_SUFFIX##*/}" # eg ops-depls
}

# $1: org name
function create_org_if_missing() {
    local CF_ORG_TO_CREATE="$1"
    if ! cf org "${CF_ORG_TO_CREATE}" &> /tmp/create-org-traces.txt
    then
        echo "Creating test org ${CF_ORG_TO_CREATE} as it is missing"
        cf create-org "${CF_ORG_TO_CREATE}"
    fi
}
