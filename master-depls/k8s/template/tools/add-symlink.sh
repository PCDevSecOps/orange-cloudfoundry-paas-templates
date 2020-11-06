#!/bin/bash

deploy=k8s
depls=k8s-common-master
final_name="${deploy}"

source ../../../../shared-operators/tools/add-symlink.sh
rm k8s-tpl.yml
