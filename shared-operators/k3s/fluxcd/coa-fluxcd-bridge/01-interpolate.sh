#!/bin/bash

set -x debug
set -e #fail on errors

echo ${K8S_GIT_REPO_PATH}
echo ${BASE_TEMPLATE_DIR}




#remove all previous git yml files
rm -rf ${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests
mkdir -p ${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests


#bosh vars file interpolation
cd ${PRE_PROCESSED_MANIFEST_PATH}
VARS_FILES="$(find * -name "*-vars.yml")"

BOSH_INTERPOLATE_FLAGS=""
for varfile in ${VARS_FILES} ; do
  flag="-v ${PRE_PROCESSED_MANIFEST_PATH}/${varfile}"
  #BOSH_INTERPOLATE_FLAGS= "${BOSH_INTERPOLATE_FLAGS}  ${flag}"
  #BOSH_INTERPOLATE_FLAGS="$BOSH_INTERPOLATE_FLAGS  $flag"
done

#manifests file list
cd ${BASE_TEMPLATE_DIR}/manifests
MANIFESTS="$(find * -name "*.yml" -o -name "*.yaml" )"

#identify root-deployment credhub ns (does not match COA_ROOT_DEPLOYMENT_NAME)
CREDHUB_ROOT_DEPLOYMENT_NAMESPACE="$(credhub find |grep name |grep "/${COA_DEPLOYMENT_NAME}/" |cut -d '/' -f 2 |uniq)"

echo "credhub root deployment namespace ${CREDHUB_ROOT_DEPLOYMENT_NAMESPACE}" 
#FIXME: ensure a single credhub ns is infered


#replace defined credhub vars (fail if missing)
for file in ${MANIFESTS} ; do
  mkdir -p "${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests/$(dirname ${file})"
  
  #only interpolate credhub files (credhub interpolate will break multi doc yaml)
  
  if grep -q '((' "${file}"; then
    #interpolation
    #TODO: error on multi doc yaml
    #bosh interpolate ${file} ${BOSH_INTERPOLATE_FLAGS}
    credhub interpolate -f ${file} > ${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests/${file} -p ${CREDHUB_ROOT_DEPLOYMENT_NAMESPACE}/${COA_DEPLOYMENT_NAME}
  else
   #raw copy
   cp -f ${file} ${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}/k8s-config/manifests/${file}

  fi

done
