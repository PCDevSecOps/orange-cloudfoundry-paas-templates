#!/bin/sh
echo "remove share-operators, as profile 90-fluxcd-fast-track is active"
rm -rf ${K8S_GIT_REPO_PATH}/shared-operators/k8s-kustomize-bases