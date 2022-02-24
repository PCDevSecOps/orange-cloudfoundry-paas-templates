#!/bin/bash
echo "copy vendored k8s manifest"
rm -rf ${K8S_GIT_REPO_PATH}/vendor/k8s-manifests
mkdir -p ${K8S_GIT_REPO_PATH}/vendor/k8s-manifests
cp -rf -L ${BASE_TEMPLATE_DIR}/../../../vendor/k8s-manifests/* ${K8S_GIT_REPO_PATH}/vendor/k8s-manifests
find -L ${K8S_GIT_REPO_PATH}/vendor/k8s-manifests -name ".last-reset" -exec rm {} \;
