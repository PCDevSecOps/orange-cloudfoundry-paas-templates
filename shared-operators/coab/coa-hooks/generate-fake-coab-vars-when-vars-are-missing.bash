#!/bin/bash
#===========================================================================

set -o errexit # exit on errors

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

function generate_fake_coab_vars_when_vars_are_missing(){
  # generate fake coab vars file if brokered_service_instance_guid not present in coab-vars.yml
  INSTANCE_ID=$(bosh int "${GENERATE_DIR}/coab-vars.yml" --path /instance_id)
  echo "INSTANCE_ID is:${INSTANCE_ID}"
  set +e # prevent from exiting in case of grep failure (because fake-coab-vars.yml generation is triggered on grep failure)
  grep brokered_service_instance_guid ${BASE_TEMPLATE_DIR}/coab-vars.yml
  if [ $? != 0 ] ; then
      echo "brokered_service_instance_guid is missing from coab-vars.yml"
      echo "generating fake-coab-vars.yml in ${GENERATE_DIR} to complete it for coab smoke tests not fronted by osb-cmdb"
      cat << EOF > ${GENERATE_DIR}/fake-coab-vars.yml
      parameters:
        x-osb-cmdb:
          labels:
            brokered_service_instance_guid: ${INSTANCE_ID}
            brokered_service_context_organization_guid: "faked_organization_guid_in_pre_deploy_sh"
            brokered_service_context_space_guid: "faked_space_guid_in_pre_deploy_sh"
EOF
      cat ${GENERATE_DIR}/fake-coab-vars.yml
  fi
  set -e
}
generate_fake_coab_vars_when_vars_are_missing

####### end treatment ######
