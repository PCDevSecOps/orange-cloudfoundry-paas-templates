#!/bin/bash

deploy=k8s-traefik
depls=00-core-connectivity-k8s
final_name="${deploy}-core-connectivity"
fixedprofile="10-embedded-cfcr-k8s"
source ../../../../shared-operators/tools/add-symlink.sh

