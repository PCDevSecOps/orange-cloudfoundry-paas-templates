#!/bin/bash
#copy shared kustomize bases
rm -rf ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases
mkdir -p ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases
cp -rf ${BASE_TEMPLATE_DIR}/../../../shared-operators/k8s-kustomize-bases/* ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases
find ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases -name ".last-reset" -exec rm {} \;
