#!/bin/bash
#==========================================================================================
# Clean minio-s3 buckets with obsolete packages (stemcells, buildpacks and bosh releases)
#==========================================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Get versions (stemcells, buildpacks and bosh releases) from bosh director template version file
clear
flag="$(mc config host list | grep minio)"
if [ "${flag}" = "" ] ; then
  printf "\n%b\"minio\" host unknown.%b\n\n" "${RED}" "${STD}"
  exit 1
fi

printf "\n%bGet minio versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
STEMCELLS_VERSIONS="" ; BUILDPACKS_VERSIONS="" ; RELEASES_VERSIONS=""
for bosh_director in ${BOSH_DIRECTORS} ; do
  VERSIONS_FILE="${TEMPLATE_REPO_DIR}/${bosh_director}-depls/${bosh_director}-depls-versions.yml"
  if [ -f ${VERSIONS_FILE} ] ; then
    STEMCELLS_VERSIONS="${STEMCELLS_VERSIONS}\n$(grep "stemcell\-version:" ${VERSIONS_FILE} | sed -e "s+\-version: *\"+:+" | sed -e "s+\".*$++")"
    RELEASES_VERSIONS="${RELEASES_VERSIONS}\n$(grep "\-version:" ${VERSIONS_FILE} | grep -vE "stemcell\-version:|\-buildpack\-" | sed -e "s+\-version: *\"+:+" | sed -e "s+\".*$++")"

    if [ "${bosh_director}" == "master" ] ; then
      BUILDPACKS_VERSIONS="${BUILDPACKS_VERSIONS}\n$(grep "buildpack\-version:" ${VERSIONS_FILE} | sed -e "s+\-version: *\"+:+" | sed -e "s+\".*$++")"
    fi
  fi
done

#--- Delete empty lines
STEMCELLS_VERSIONS="$(echo -e "${STEMCELLS_VERSIONS}" | sed '/^$/d')"
BUILDPACKS_VERSIONS="$(echo -e "${BUILDPACKS_VERSIONS}" | sed '/^$/d')"
RELEASES_VERSIONS="$(echo -e "${RELEASES_VERSIONS}" | sed '/^$/d')"

#--- Delete obsolete stemcells versions in minio-private-s3 bucket
printf "\n%bDelete obsolete stemcells versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
DELETE_STEMCELLS_LIST=""
OLDEST_VERSION="$(echo "${STEMCELLS_VERSIONS}" | LC_ALL=C sort -r --version-sort --field-separator=. | uniq | tail -1 | sed -e "s+.*:++")"
STORED_STEMCELLS="$(mc find minio/stemcells | LC_ALL=C sort -r --version-sort --field-separator=.)"
flag_delete=0

for stemcell in ${STORED_STEMCELLS} ; do
  if [ ${flag_delete} = 1 ] ; then
    printf "%b- Delete \"${stemcell}\"%b\n" "${YELLOW}" "${STD}"
    DELETE_STEMCELLS_LIST="${DELETE_STEMCELLS_LIST}\n${stemcell}"
  else
    printf "%b- Keep \"${stemcell}\"\n" "${STD}"
  fi

  flag_found="$(echo "${stemcell}" | grep "stemcell\-${OLDEST_VERSION}\-")"
  if [ "${flag_found}" != "" ] ; then
    flag_delete=1
  fi
done
DELETE_STEMCELLS_LIST="$(echo -e "${DELETE_STEMCELLS_LIST}" | sed '/^$/d')"

#--- Delete obsolete cached buildpacks versions in minio-private-s3 bucket
printf "\n%bDelete obsolete cached buildpacks versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
DELETE_BUILDPACKS_LIST=""
STORED_BUILDPACKS="$(mc find minio/cached-buildpacks | LC_ALL=C sort -r --version-sort --field-separator=.)"

for line in ${BUILDPACKS_VERSIONS} ; do
  flag_delete=0
  name="$(echo "${line}" | sed -e "s+\-buildpack.*++")"
  version="$(echo "${line}" | sed -e "s+.*:++")"
  buildpack_list="$(echo "${STORED_BUILDPACKS}" | grep "${name}_buildpack\-cached\-v")"

  for buildpack in ${buildpack_list} ; do
    if [ ${flag_delete} = 1 ] ; then
      printf "%b- Delete \"${buildpack}\"%b\n" "${YELLOW}" "${STD}"
      DELETE_BUILDPACKS_LIST="${DELETE_BUILDPACKS_LIST}\n${buildpack}"
    else
      printf "%b- Keep \"${buildpack}\"\n" "${STD}"
    fi

    flag_found="$(echo "${buildpack}" | grep "v${version}")"
    if [ "${flag_found}" != "" ] ; then
      flag_delete=1
    fi
  done
done

for line in ${BUILDPACKS_VERSIONS} ; do
  flag_delete=0
  name="$(echo "${line}" | sed -e "s+\-buildpack.*++")"
  version="$(echo "${line}" | sed -e "s+.*:++")"
  buildpack_list="$(echo "${STORED_BUILDPACKS}" | grep "${name}_buildpack\-cached\-cflinuxfs3\-v")"

  for buildpack in ${buildpack_list} ; do
    if [ ${flag_delete} = 1 ] ; then
      printf "%b- Delete \"${buildpack}\"%b\n" "${YELLOW}" "${STD}"
      DELETE_BUILDPACKS_LIST="${DELETE_BUILDPACKS_LIST}\n${buildpack}"
    else
      printf "%b- Keep \"${buildpack}\"\n" "${STD}"
    fi

    flag_found="$(echo "${buildpack}" | grep "v${version}")"
    if [ "${flag_found}" != "" ] ; then
      flag_delete=1
    fi
  done
done
DELETE_BUILDPACKS_LIST="$(echo -e "${DELETE_BUILDPACKS_LIST}" | sed '/^$/d')"

#--- Delete obsolete bosh releases versions in minio-private-s3 bucket
printf "\n%bDelete obsolete bosh releases versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
DELETE_RELEASES_LIST=""
STORED_RELEASES="$(mc find minio/bosh-releases | LC_ALL=C sort -r --version-sort --field-separator=.)"

#--- Get the oldest version for each bosh release
RELEASES_VERSIONS="$(echo "${RELEASES_VERSIONS}" | LC_ALL=C sort -r --version-sort --field-separator=. | uniq | awk -F ":" '{if(flag == "") {flag="1"} else {if($1 != old_name) {print old_value}} ; old_name=$1 ; old_value=$0} END {print $0}')"

for line in ${RELEASES_VERSIONS} ; do
  flag_delete=0
  name="$(echo "${line}" | sed -e "s+:.*++")"
  version="$(echo "${line}" | sed -e "s+.*:++")"
  release_list="$(echo "${STORED_RELEASES}" | grep "/${name}\-[0-9]*\.")"

  for release in ${release_list} ; do
    if [ ${flag_delete} = 1 ] ; then
      printf "%b- Delete \"${release}\"%b\n" "${YELLOW}" "${STD}"
      DELETE_RELEASES_LIST="${DELETE_RELEASES_LIST}\n${release}"
    else
      printf "%b- Keep \"${release}\"\n" "${STD}"
    fi

    flag_found="$(echo "${release}" | grep "/${name}\-${version}\.tgz")"
    if [ "${flag_found}" != "" ] ; then
      flag_delete=1
    fi
  done
done
DELETE_RELEASES_LIST="$(echo -e "${DELETE_RELEASES_LIST}" | sed '/^$/d')"

#--- Confirm packages deletion
printf "\n%bDelete minio S3 packages (y/n) ? :%b " "${REVERSE}${GREEN}" "${STD}"
read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit
fi

printf "\n%bDelete obsolete packages versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
for package in ${DELETE_STEMCELLS_LIST} ${DELETE_BUILDPACKS_LIST} ${DELETE_RELEASES_LIST} ; do
  printf "%b- Delete \"${package}\"%b\n" "${YELLOW}" "${STD}"
  mc rm ${package}
done
printf "\n"