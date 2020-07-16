#!/bin/bash

deploy=k8s
depls=cfcr-common-micro
final_name="${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh
rm k8s-tpl.yml
