#!/bin/bash
#===========================================================================
# Delete k8s namespace (when stucked)
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Get k8s namespace to delete
RES_FILE="/tmp/ns.json"
NAMESPACES="$(kubectl get namespace)"
if [ "${NAMESPACES}" = "" ] ; then
  printf "\n%bYou must log to k8s cluster before using this script.%b\n" "${RED}" "${STD}"
else
  printf "\n%bk8s namespaces%b\n" "${REVERSE}${YELLOW}" "${STD}"

  echo "${NAMESPACES}"
  catchValue "namespace" "k8s namespace to delete"
  result="$(echo "${NAMESPACES}" | grep "${namespace} ")"
  if [ "${result}" = "" ] ; then
    printf "\n%bNo active k8s namespaces selected.%b\n" "${RED}" "${STD}"
  else
    kubectl config set-context --current --namespace=${namespace}

    #--- Confirm namespace deletion
    printf "\n%bDelete k8s namespace \"${namespace}\" (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
    if [ "${choice}" = "y" ] ; then
      kubectl get namespace ${namespace} -o json | jq -j '.spec.finalizers=null' > ${RES_FILE}
      kubectl proxy &
      sleep 5
      curl -X PUT -H "Content-Type: application/json" --data-binary @${RES_FILE} http://localhost:8001/api/v1/namespaces/${namespace}/finalize
      pkill -9 -f "kubectl proxy"
      rm -f ${RES_FILE} > /dev/null 2>&1
    fi
  fi
fi

printf "\n"