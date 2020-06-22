#!/bin/bash
deploy=k8s-jaeger
final_name="${deploy}"

depls=cfcr-common-master
cd ././../../../master-depls/${deploy}/template/tools;
./add-symlink.sh

depls=cfcr-common-micro
cd ././../../../micro-depls/${deploy}/template/tools;
./add-symlink.sh

depls=cfcr-common-serv
final_name="10-${deploy}"
cd ././../../../coab-depls/10-${deploy}/template/tools;
./add-symlink.sh
