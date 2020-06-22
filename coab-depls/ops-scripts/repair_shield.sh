#!/bin/bash

usage() {
  echo "USAGE:" 
  echo "  $(basename -- $0) [OPTIONS]:"
  echo "-b : backup shield database into /tmp/shield"
  echo "-r : restore shield database from /tmp/shield"
  exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-b") MODE="0" ; shift ;;
    "-r") MODE="1" ; shift ; shift ;;
    *) usage ;;
  esac
done

deployments=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" > deployments.lst)
for deployment in $(cat deployments.lst); do
  if [[ ${MODE} = "0" ]]; then
    echo "backup of ${deployment}" 
    bosh -d ${deployment} ssh shield -c "sudo mkdir -p /tmp/shield;sudo cp -a /var/vcap/store/shield /tmp;sudo chown -R vcap:vcap /tmp/shield"  
  elif [[ ${MODE} = "1" ]]; then
    echo "restore of ${deployment}" 
    bosh -d ${deployment} ssh shield -c "sudo cp -a /tmp/shield /var/vcap/store/;sudo chown -R vcap:vcap /var/vcap/store/shield;sudo monit restart vault;sudo monit restart shieldd" 
  fi
done
