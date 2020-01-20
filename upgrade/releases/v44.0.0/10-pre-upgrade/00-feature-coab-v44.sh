#!/bin/bash

#--- Clean local secrets
CONFIG_DIR=$1

if [ -d ${CONFIG_DIR}/coab-depls ] ; then
    cd ${CONFIG_DIR}/coab-depls
    for directory in `find [0-9a-zA-Z]*/secrets -type d`
    do
      if ! [[ ${directory} =~ terraform-config ]]
      then
          echo "removing ${directory}"
          rm -rf ${directory}
      fi
    done
fi


