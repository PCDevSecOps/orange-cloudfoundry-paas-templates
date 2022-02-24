#!/bin/bash
#===========================================================================

set -o errexit # exit on errors
#set -x

GENERATE_DIR=${GENERATE_DIR:-.}
CUSTOM_SCRIPT_DIR=${CUSTOM_SCRIPT_DIR:-template-resource}
SECRETS_DIR=${SECRETS_DIR:-.}

echo "executing $0"
echo "use and generate file at $GENERATE_DIR"
echo "use template dir: <$CUSTOM_SCRIPT_DIR>  and secrets dir: <$SECRETS_DIR>"

####### end common header ######

#--- Colors and styles
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export STD='\033[0m'

# See https://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/
declare -A coab_fields

# Note: this is indented on the left because bash is sensitive to spaces after equal
# See https://github.com/koalaman/shellcheck/wiki/SC1007

# v48 labels added for CF profile. Removed
#                 coab_fields["osb_client_organization"]="/parameters/x-osb-cmdb/labels/brokered_service_context_organization_guid"
#                        coab_fields["osb_client_space"]="/parameters/x-osb-cmdb/labels/brokered_service_context_space_guid"
#                         coab_fields["osb_client_name"]="/parameters/x-osb-cmdb/labels/brokered_service_client_name"

# common to all profiles
                  coab_fields["osb_client_service_guid"]="/parameters/x-osb-cmdb/labels/brokered_service_instance_guid"
                      coab_fields["osb_client_platform"]="/parameters/x-osb-cmdb/labels/brokered_service_context_platform"

# For CF profile
          coab_fields["osb_client_cf_organization_guid"]="/parameters/x-osb-cmdb/labels/brokered_service_context_organization_guid"
                 coab_fields["osb_client_cf_space_guid"]="/parameters/x-osb-cmdb/labels/brokered_service_context_space_guid"
                  coab_fields["osb_client_cf_user_guid"]="/parameters/x-osb-cmdb/labels/brokered_service_originating_identity_user_id"
                   coab_fields["osb_client_cf_org_name"]="/parameters/x-osb-cmdb/annotations/brokered_service_context_organizationName"
                 coab_fields["osb_client_cf_space_name"]="/parameters/x-osb-cmdb/annotations/brokered_service_context_spaceName"
              coab_fields["osb_client_cf_instance_name"]="/parameters/x-osb-cmdb/annotations/brokered_service_context_instanceName"
# orange annotations
     coab_fields["osb_client_orange_annotation_basicat"]="/parameters/x-osb-cmdb/labels/brokered_service_context_orange_basicat"
      coab_fields["osb_client_orange_annotation_entity"]="/parameters/x-osb-cmdb/labels/brokered_service_context_orange_entity"
      coab_fields["osb_client_orange_annotation_mod26e"]="/parameters/x-osb-cmdb/labels/brokered_service_context_orange_mod26e"
 coab_fields["osb_client_orange_annotation_orangecarto"]="/parameters/x-osb-cmdb/labels/brokered_service_context_orange_orangecarto"
  coab_fields["osb_client_orange_annotation_production"]="/parameters/x-osb-cmdb/labels/brokered_service_context_orange_production"

#For K8S
                      coab_fields["osb_client_k8s_user"]="/parameters/x-osb-cmdb/labels/brokered_service_originating_identity_uid"
                 coab_fields["osb_client_k8s_namespace"]="/parameters/x-osb-cmdb/labels/brokered_service_context_namespace"
                 coab_fields["osb_client_k8s_user_name"]="/parameters/x-osb-cmdb/annotations/brokered_service_originating_identity_username" # credential_leak_validated



function extract_relevant_value_from_coab_vars_with_empty_defaults() {
  local coab_vars_file="${GENERATE_DIR}/coab-vars.yml"
  local unsorted_extracted_file="${GENERATE_DIR}/unsorted_extracted-osb-cmdb-params-for-coab-vars.yml"
  local extracted_file="${GENERATE_DIR}/extracted-osb-cmdb-params-for-coab-vars.yml"

  # Start from clean state when running this script in unit-tests or interactively.
  rm -f ${extracted_file} ${unsorted_extracted_file}

  for key in "${!coab_fields[@]}"; do
    local yaml_path="${coab_fields[${key}]}"
    local coab_vars_value
    coab_vars_value=$(bosh int ${coab_vars_file} --path "${yaml_path}" || echo "")

    echo "${key}: \"${coab_vars_value}\""  >> ${unsorted_extracted_file}
  done
  #check yaml file is correct and reformat it using bosh int
  bosh int ${unsorted_extracted_file} > ${extracted_file}
  # remove temporary file so that `bosh deploy` gets only exposed the ${extracted_file}
  rm ${unsorted_extracted_file}

  echo "extracted annotations from  coab-vars.yml into ${extracted_file}"
  ls -al "${extracted_file}"
  cat "${extracted_file}"

}
extract_relevant_value_from_coab_vars_with_empty_defaults

####### end treatment ######
