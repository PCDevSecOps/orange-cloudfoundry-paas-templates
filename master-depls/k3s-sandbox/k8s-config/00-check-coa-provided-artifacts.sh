#!/bin/bash

#check tools versions
ytt version
kustomize version
credhub --version #credentials configured by COA

#for artifact push to k8s
kapp version
kubectl version
helm version

kuttl --version
git --version
