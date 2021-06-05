#!/bin/bash
deploy=k8s-addon
final_name="${deploy}"

depls=k8s-common-master
cd ././../../../master-depls/${deploy}/template/tools;
./add-symlink.sh

depls=k8s-common-micro
cd ././../../../micro-depls/${deploy}/template/tools;
./add-symlink.sh

depls=k8s-common-serv
final_name="10-${deploy}"
cd ././../../../coab-depls/10-${deploy}/template/tools;
./add-symlink.sh
