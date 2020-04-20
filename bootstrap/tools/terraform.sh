#!/bin/bash
#===========================================================================
# Create resources with terraform
#===========================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Script parameters
TERRAFORM_DIR="${TEMPLATE_REPO_DIR}/bootstrap/terraform-config"
TEMPLATE_TERRAFORM_CONFIG_DIR="${TEMPLATE_REPO_DIR}/micro-depls/terraform-config"
SECRETS_TERRAFORM_CONFIG_DIR="${SECRETS_REPO_DIR}/micro-depls/terraform-config"
SHARED_META="${SECRETS_REPO_DIR}/micro-depls/terraform-config/secrets/meta.yml"

#--- Initialize logs
LOG_FILE="${TERRAFORM_DIR}/terraform.log"
> ${LOG_FILE}

executeTerraform() {
  display "INFO" "Generate target configuration"
  cd ${TERRAFORM_DIR}/${IAAS_TYPE}
  rm -fr .terraform terraform.tfvars.json terraform.out > /dev/null 2>&1
  spruce merge --prune secrets ${SHARED_SECRETS} ${SHARED_META} terraform-tpl.tfvars.yml | spruce json > terraform.tfvars.json

  display "INFO" "Upload terraform provider"
  terraform init
  if [ $? != 0 ] ; then
    display "ERROR" "Upload terraform provider failed"
  fi

  display "INFO" "Create terraform plan"
  terraform plan -input=false -out terraform.out
  if [ $? != 0 ] ; then
    display "ERROR" "Create terraform plan failed"
  fi

  display "INFO" "Apply terraform plan"
  terraform apply terraform.out
  if [ $? != 0 ] ; then
    display "ERROR" "Apply terraform plan failed"
  fi
}

#--- Copy terraform files (needed for bootstrap) from paas-template and execute terraform
display "INFO" "Create bosh resources"
rm -fr ${TERRAFORM_DIR}/${IAAS_TYPE} > /dev/null 2>&1
mkdir -p ${TERRAFORM_DIR}/${IAAS_TYPE}

cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec/bosh-2-network.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec/compilation-network.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec-${IAAS_TYPE}/sg-default.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec-${IAAS_TYPE}/sg-internet.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec-${IAAS_TYPE}/terraform-providers.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec-${IAAS_TYPE}/terraform-vars.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/template/${IAAS_TYPE}/terraform-tpl.tfvars.yml ${TERRAFORM_DIR}/${IAAS_TYPE}

executeTerraform

#--- Save tfstate for future terraform operations
display "INFO" "Save tfstate file into secrets repository"
cd ${SECRETS_REPO_DIR}
executeGit "pull --rebase"
createDir "${SECRETS_TERRAFORM_CONFIG_DIR}"
cp ${TERRAFORM_DIR}/${IAAS_TYPE}/terraform.tfstate ${SECRETS_TERRAFORM_CONFIG_DIR}
executeGit "add ${SECRETS_TERRAFORM_CONFIG_DIR}/terraform.tfstate"
executeGit "commit -m Add_terraform_state_file"
executeGit "push"

#--- Create NAT GW for Internet acces from IAAS instances (don't save terraform.tfstate because instance will be replaced with target bosh deployment)
if [ "${IAAS_TYPE}" = "openstack-hws" ] ; then
  display "INFO" "Create NAT Gateway"
  cp ${TEMPLATE_TERRAFORM_CONFIG_DIR}/spec-${IAAS_TYPE}/nat-gw-network.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
  cp ${TERRAFORM_DIR}/nat-gateway/instances.tf ${TERRAFORM_DIR}/${IAAS_TYPE}
  cp ${TERRAFORM_DIR}/nat-gateway/install-natgw.sh ${TERRAFORM_DIR}/${IAAS_TYPE}
  executeTerraform
fi

display "OK" "Create bosh resources succeeded"