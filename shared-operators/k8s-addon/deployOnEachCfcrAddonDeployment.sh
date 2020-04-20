#!/bin/sh
deploy=k8s-addon
cd ././../../micro-depls/${deploy}/template/tools/
sh ./add-symlink.sh
pwd
cd ../../../../shared-operators/${deploy}/



cd ././../../master-depls/${deploy}/template/tools/
sh ./add-symlink.sh
pwd
cd ../../../../shared-operators/${deploy}/

cd ././../../kubo-depls/${deploy}/template/tools/
sh ./add-symlink.sh
pwd
cd ../../../../shared-operators/${deploy}/
