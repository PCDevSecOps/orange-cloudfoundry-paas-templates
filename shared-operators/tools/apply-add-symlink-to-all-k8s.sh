#!/bin/sh

initDir=$(pwd)
echo "initDir ${initDir}"
for brd in "micro-depls" "master-depls"; do
    cd $initDir
    cd ../../${brd}/
    for depls in $(ls -doG k8s*|cut -d" " -f9); do
        cd $initDir
        cd ../../${brd}/${depls}/template/tools
        ./add-symlink.sh
    done
done


for brd in "coab-depls"; do
    cd $initDir
    cd ../../${brd}/
    for depls in $(ls -doG 10-k8s*|cut -d" " -f9); do
        cd $initDir
        cd ../../${brd}/${depls}/template/tools
        ./add-symlink.sh
    done
done

