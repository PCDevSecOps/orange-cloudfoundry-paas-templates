#!/bin/bash

deploy=k8s-traefik
depls=cfcr-common-serv
final_name="10-${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh