#!/bin/bash

deploy=k8s-traefik
depls=cfcr-common-micro
final_name="${deploy}"
fixedprofile="10-embedded-cfcr-k8s"
source ../../../../shared-operators/tools/add-symlink.sh

