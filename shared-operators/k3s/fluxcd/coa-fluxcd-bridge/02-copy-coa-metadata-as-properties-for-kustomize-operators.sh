#!/bin/bash
echo "copy coa metadata in properties"

cat <<EOF >${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests/metadata.properties
paas_template_commit_id=${PAAS_TEMPLATES_COMMIT_ID}
coa_root_deployment_name=${COA_ROOT_DEPLOYMENT_NAME}
coa_deployment_name=${COA_DEPLOYMENT_NAME}
iaas_type=${IAAS_TYPE}
profile=${PROFILES}
EOF
