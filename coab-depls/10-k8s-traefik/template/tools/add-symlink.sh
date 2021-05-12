#!/bin/bash

deploy=10-k8s-traefik
depls=00-k3s-serv
final_name="${deploy}"
fixedprofile="10-embedded-cfcr-k8s"
source ../../../../shared-operators/tools/add-symlink.sh
