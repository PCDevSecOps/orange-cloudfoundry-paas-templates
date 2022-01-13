#!/bin/bash
#===========================================================================
# Clean unused openstack private images
# Note: Use log-openstack before
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

BOSH_STEMCELL_NAME="bosh-openstack-kvm-"

#--- Check if connected
alias openstack='openstack --insecure'
openstack network list > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bERROR: You must \"log-openstack\" before using this script.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Collect openstack informations
printf "\n%bCollect openstack informations...\n%b" "${REVERSE}${YELLOW}" "${STD}"
USED_IMAGE_ID_LIST="$(openstack server list --long -f value --noindent | grep -E " ${BOSH_STEMCELL_NAME}" | sed -e "s+.* ${BOSH_STEMCELL_NAME}+${BOSH_STEMCELL_NAME}+g" | awk '{print " " $2 " "}' | sort | uniq)"
PRIVATE_IMAGE_ID_LIST="$(openstack image list -f value --noindent | grep -E " ${BOSH_STEMCELL_NAME}" | awk '{print $1 ":" $2}')"

#--- Check private images which are unused by ECS
printf "\n%bCheck unused private images...\n%b" "${REVERSE}${YELLOW}" "${STD}"
DELETE_IMAGE_ID_LIST=""
for line in ${PRIVATE_IMAGE_ID_LIST} ; do
  image_id="$(echo "${line}" | awk -F ":" '{print $1}')"
  BOSH_STEMCELL_NAME="$(echo "${line}" | awk -F ":" '{print $2}')"
  result=$(echo "${USED_IMAGE_ID_LIST}" | grep " ${image_id} ")
  if [ "${result}" = "" ] ; then
    printf "\n%b- Unused \"${BOSH_STEMCELL_NAME}\" image \"${image_id}\"" "${STD}"
    DELETE_IMAGE_ID_LIST="${image_id} ${DELETE_IMAGE_ID_LIST}"
  fi
done

if [ "${DELETE_IMAGE_ID_LIST}" != "" ] ; then
  printf "\n\n%bConfirm that you will clean obsolete images (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}"
  read choice
  if [ "${choice}" != "y" ] ; then
    printf "\n" ; exit
  fi

  printf "\n%bDelete unused private images...\n%b" "${REVERSE}${YELLOW}" "${STD}"
  for image_id in ${DELETE_IMAGE_ID_LIST} ; do
    printf "\n%b- Delete unused image \"${image_id}\"...%b" "${YELLOW}" "${STD}"
    openstack image delete ${image_id}
    if [ $? != 0 ] ; then
      printf "\n%b  Openstack delete image command failed.\n\n%b" "${REVERSE}${RED}" "${STD}"
    fi
  done
fi

printf "\n\n%bClean unused private images ended.\n\n%b" "${REVERSE}${GREEN}" "${STD}"