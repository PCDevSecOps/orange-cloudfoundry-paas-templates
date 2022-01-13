#!/bin/bash

cd ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases
git add .

cd ${K8S_GIT_REPO_PATH}/vendor/k8s-manifests
git add .

cd ${K8S_GIT_REPO_PATH}/${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}
git add .


CHANGE_DETECTED_COUNTER=$(git ls-files --others --exclude-standard  -d -c |wc -l )
if [ ${CHANGE_DETECTED_COUNTER} -gt 0 ]; then
  git commit --no-verify -a -m "${PAAS_TEMPLATES_COMMIT_MESSAGE} - COA manifests commit ${PAAS_TEMPLATES_COMMIT_ID}, on behalf of ${COA_ROOT_DEPLOYMENT_NAME}/${COA_DEPLOYMENT_NAME}"
  git --no-pager show HEAD
else
  echo "No change detected, skip commit"
fi


#COA does the git push
