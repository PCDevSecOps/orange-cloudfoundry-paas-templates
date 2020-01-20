#!/bin/bash

set -x
ks="master"
dep="bosh-master"

bosh int <(credhub get -n "/${dep}/cfcr/tls-kubernetes" --output-json) --path=/value/ca > ~/kubecert.crt
kubectl config set-cluster "kubo-${ks}" --server="https://cfcr-api-${ks}.internal.paas" --certificate-authority=~/kubecert.crt --embed-certs=true
bosh int <(credhub get -n "/${dep}/cfcr/kubo-admin-password" --output-json) --path=/value > ~/kubepassword
token=`cat ~/kubepassword`
kubectl config set-credentials "kubo-cluster-admin" --token=$token
kubectl config set-context "kubo-${ks}" --cluster="kubo-${ks}" --user="kubo-${ks}-admin"
kubectl config use-context "kubo-${ks}"
kubectl get nodes

