#!/bin/bash

deploy=k8s-traefik-core-connectivity
depls=00-core-connectivity-k8s
final_name="${deploy}"
fixedprofile="10-embedded-cfcr-k8s"
source ../../../../shared-operators/tools/add-symlink.sh

