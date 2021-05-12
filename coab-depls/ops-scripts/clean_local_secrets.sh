#!/bin/bash

if [ $# != 1 ] ; then
  printf "\n%bUsage : %s <path to secrets repository (e.g ~/secrets)> %b\n\n" "${YELLOW}${BOLD}" "$0" "${STD}"
  exit 1
fi

#--- Check if directory exists
function verifyDirectory() {
  if [ ! -d $1 ] ; then
    printf "\nERROR : Directory \"$1\" doesn't exist\n"
    exit 1
  fi
}

verifyDirectory $1

#--- Clean local secrets
cd $1/coab-depls
for directory in `find [0-9a-zA-Z]*/secrets -type d`
do
  if ! [[ ${directory} =~ terraform-config ]]
  then
      echo "removing ${directory}"
      rm -rf $directory
  fi
done

