#!/bin/bash
set -x
#see example https://blog.inkubate.io/deploy-kubernetes-on-vsphere-with-kubo/
#credhub login  --client-name=director_to_credhub  --client-secret=zzzzzzzzzzzzzzzzz


bosh int <(credhub get -n "/bosh-kubo/cfcr/tls-kubernetes" --output-json) --path=/value/ca > ~/kubecert.crt

kubectl config set-cluster "kubo-cluster-01" \
--server="https://cfcr-api.internal.paas" \
--certificate-authority=~/kubecert.crt \
--embed-certs=true


bosh int <(credhub get -n "/bosh-kubo/cfcr/kubo-admin-password" --output-json) --path=/value > ~/kubepassword
token=`cat ~/kubepassword`
kubectl config set-credentials "kubo-cluster-admin" \
--token=$token



kubectl config set-context "kubo-cluster-01" \
--cluster="kubo-cluster-01" \
--user="kubo-cluster-admin"

kubectl config use-context "kubo-cluster-01"
kubectl get nodes

kubectl get pods --namespace=kube-system
kubectl get services --namespace=kube-system
kubectl get pods --namespace=default
kubectl get services --namespace=default

kubectl get events

