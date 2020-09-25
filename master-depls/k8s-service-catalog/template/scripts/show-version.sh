#!/bin/bash
# aim of this script
# this script will list all contents of *-versions-vars.yml file

for u in $(ls *-versions-vars.yml) ;
  do
  echo $(echo "### $u"| sed  's/-versions-vars.yml//g');
  cat $u;echo;echo;
  done
