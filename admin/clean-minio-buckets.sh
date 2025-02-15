#!/bin/bash
#==========================================================================================
# Clean minio-s3 buckets with obsolete packages
# (stemcells, buildpacks, source and precompiled bosh releases)
#==========================================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

BOSH_DIRECTORS="$(echo "${BOSH_DIRECTORS}" | sed -e "s+-bosh++g" | sed -e "s+bosh-++g")"

#--- Get versions (stemcells, buildpacks and bosh releases) from bosh director template version file
clear
flag="$(mc config host list | grep minio)"
if [ "${flag}" = "" ] ; then
  printf "\n%b\"minio\" host alias unknown.%b\n\n" "${RED}" "${STD}" ; exit 1
fi

printf "\n%bGet template versions in root deployment files...%b\n" "${REVERSE}${YELLOW}" "${STD}"
INITIAL_SIZE="$(mc du minio | sed -e "s+\t++")"
STEMCELLS_VERSIONS="" ; BUILDPACKS_VERSIONS="" ; RELEASES_VERSIONS=""
for bosh_director in ${BOSH_DIRECTORS} ; do
  VERSIONS_FILE="${TEMPLATE_REPO_DIR}/${bosh_director}-depls/root-deployment.yml"
  if [ -f ${VERSIONS_FILE} ] ; then
    TEMPLATE_STEMCELL_VERSION="$(getValue ${VERSIONS_FILE} "/stemcell/version")"
    STEMCELLS_VERSIONS="${STEMCELLS_VERSIONS}\n${TEMPLATE_STEMCELL_VERSION}"
    releases="$(grep -E "^  [a-zA-Z0-9_-]*:" ${VERSIONS_FILE} | grep -vE "version:" | sed -e "s+^ *++g" | sed -e "s+:++g")"
    releases_name="$(echo "${releases}" | grep -v "\-buildpack")"
    buildpacks_name="$(echo "${releases}" | grep "\-buildpack")"

    for name in ${releases_name} ; do
      release_version="$(getValue ${VERSIONS_FILE} "/releases/${name}/version")"
      RELEASES_VERSIONS="${RELEASES_VERSIONS}\n${name}:${release_version}"
    done

    if [ "${bosh_director}" = "master" ] ; then
      for name in ${buildpacks_name} ; do
        buildpack_version="$(getValue ${VERSIONS_FILE} "/releases/${name}/version")"
        BUILDPACKS_VERSIONS="${BUILDPACKS_VERSIONS}\n${name}:${buildpack_version}"
      done
    fi
  fi
done

#--- Delete empty lines and get unique version value
STEMCELLS_VERSIONS="$(echo -e "${STEMCELLS_VERSIONS}" | sed '/^$/d' | LC_ALL=C sort -r --version-sort --field-separator=. | uniq)"
OLDEST_STEMCELL_VERSION="$(echo "${STEMCELLS_VERSIONS}" | tail -1)"
BUILDPACKS_VERSIONS="$(echo -e "${BUILDPACKS_VERSIONS}" | sed '/^$/d' | LC_ALL=C sort -r --version-sort --field-separator=. | uniq)"
RELEASES_VERSIONS="$(echo -e "${RELEASES_VERSIONS}" | sed '/^$/d' | LC_ALL=C sort -r --version-sort --field-separator=. | uniq)"

#--- Get the oldest version for each bosh release
RELEASES_VERSIONS="$(echo "${RELEASES_VERSIONS}" | awk -F ":" '{if(flag == "") {flag="1"} else {if($1 != old_name) {print old_value}} ; old_name=$1 ; old_value=$0} END {print $0}')"

#--- Check obsolete stemcells versions in minio-private-s3 bucket
printf "\n%bCheck obsolete Stemcells in minio buckets%b\n" "${REVERSE}${GREEN}" "${STD}"
delete_stemcells_list="" ; keep_stemcells_list=""
printf "\n%bStemcell oldest version defined in template : ${OLDEST_STEMCELL_VERSION}%b\n" "${REVERSE}${YELLOW}" "${STD}"
stored_stemcells="$(mc find minio/stemcells | LC_ALL=C sort -r --version-sort --field-separator=.)"
#minio/stemcells/bosh-vsphere-esxi-ubuntu-bionic-go_agent/bosh-stemcell-621.89-vsphere-esxi-ubuntu-bionic-go_agent.tgz
#minio/stemcells/bosh-openstack-kvm-ubuntu-bionic-go_agent/bosh-stemcell-621.89-openstack-kvm-ubuntu-bionic-go_agent.tgz

if [ "${stored_stemcells}" != "" ] ; then
  flag_delete=0 ; OldStemcellType=""
  for stemcell in ${stored_stemcells} ; do
    #--- Delete stemcell not bionic
    flag_bionic="$(echo "${stemcell}" | grep "ubuntu\-bionic")"
    if [ "${flag_bionic}" = "" ] ; then
      flag_delete=1
    else
      StemcellType="$(echo "${stemcell}" | awk -F "/" '{print $3}')"
      if [ "${StemcellType}" != "${OldStemcellType}" ] ; then
        flag_delete=0
      fi
      OldStemcellType="${StemcellType}"
    fi

    if [ ${flag_delete} = 0 ] ; then
      printf "%b- Keep \"${stemcell}\"\n" "${STD}"
      keep_stemcells_list="${keep_stemcells_list}\n${stemcell}"
    else
      printf "%b- Delete \"${stemcell}\"%b\n" "${YELLOW}" "${STD}"
      delete_stemcells_list="${delete_stemcells_list}\n${stemcell}"
    fi

    #--- Delete stemcell oldest than that referenced in template
    flag_found="$(echo "${stemcell}" | grep "stemcell\-${OLDEST_STEMCELL_VERSION}\-")"
    if [ "${flag_found}" != "" ] ; then
      flag_delete=1
    fi
  done
fi

#--- Delete empty lines
keep_stemcells_list="$(echo -e "${keep_stemcells_list}" | sed '/^$/d')"
delete_stemcells_list="$(echo -e "${delete_stemcells_list}" | sed '/^$/d')"
keep_stemcells_versions="$(echo "${keep_stemcells_list}" | sed -e "s+^.*stemcell\-++g" | sed -e "s+\-.*\.tgz++g" | LC_ALL=C sort -r --version-sort --field-separator=. | uniq)"

#--- Check obsolete cached buildpacks versions in minio-private-s3 bucket
printf "\n%bCheck obsolete cached buildpacks in minio buckets%b\n" "${REVERSE}${GREEN}" "${STD}"
delete_buildpacks_list=""
stored_buildpacks="$(mc find minio/cached-buildpacks | LC_ALL=C sort -r --version-sort --field-separator=.)"

for line in ${BUILDPACKS_VERSIONS} ; do
  name="$(echo "${line}" | awk -F ":" '{print $1}' | sed -e "s+\-buildpack.*++")"
  buildpack_version="$(echo "${line}" | awk -F ":" '{print $2}')"
  printf "\n%b\"${name}\" buildpack oldest used version : ${buildpack_version}%b\n" "${REVERSE}${YELLOW}" "${STD}"
  #minio/cached-buildpacks/go_buildpack-cached-v1.9.7.zip
  #minio/cached-buildpacks/java-buildpack-offline-v4.21.zip
  buildpack_list="$(echo "${stored_buildpacks}" | grep -E "${name}.buildpack.*cached\-v|${name}.buildpack.*offline\-v")"

  if [ "${buildpack_list}" != "" ] ; then
    flag_delete=0
    for buildpack in ${buildpack_list} ; do
      if [ ${flag_delete} = 0 ] ; then
        printf "%b- Keep \"${buildpack}\"\n" "${STD}"
      else
        printf "%b- Delete \"${buildpack}\"%b\n" "${YELLOW}" "${STD}"
        delete_buildpacks_list="${delete_buildpacks_list}\n${buildpack}"
      fi

      flag_found="$(echo "${buildpack}" | grep "v${buildpack_version}")"
      if [ "${flag_found}" != "" ] ; then
        flag_delete=1
      fi
    done
  fi

  #minio/cached-buildpacks/go_buildpack-cached-cflinuxfs3-v1.9.14.zip
  buildpack_fs_list="$(echo "${stored_buildpacks}" | grep "${name}.buildpack.*cached\-cflinuxfs.\-v")"

  if [ "${buildpack_fs_list}" != "" ] ; then
    flag_delete=0
    for buildpack in ${buildpack_fs_list} ; do
      if [ ${flag_delete} = 0 ] ; then
        printf "%b- Keep \"${buildpack}\"\n" "${STD}"
      else
        printf "%b- Delete \"${buildpack}\"%b\n" "${YELLOW}" "${STD}"
        delete_buildpacks_list="${delete_buildpacks_list}\n${buildpack}"
      fi

      flag_found="$(echo "${buildpack}" | grep "v${buildpack_version}")"
      if [ "${flag_found}" != "" ] ; then
        flag_delete=1
      fi
    done
  fi
done

#--- Delete empty lines
delete_buildpacks_list="$(echo -e "${delete_buildpacks_list}" | sed '/^$/d')"

#--- Check obsolete source bosh releases versions in minio-private-s3 bucket
printf "\n%bCheck obsolete source bosh releases in minio buckets%b\n" "${REVERSE}${GREEN}" "${STD}"
delete_source_releases_list=""
stored_releases="$(mc find minio/bosh-releases | LC_ALL=C sort -r --version-sort --field-separator=.)"

for line in ${RELEASES_VERSIONS} ; do
  name="$(echo "${line}" | awk -F ":" '{print $1}')"
  release_version="$(echo "${line}" | awk -F ":" '{print $2}')"
  printf "\n%b\"${name}\" source bosh release oldest used version : ${release_version}%b\n" "${REVERSE}${YELLOW}" "${STD}"
  #minio/bosh-releases/shieldproject/shield-addon-mongodb-1.0.0.tgz
  #minio/bosh-releases/cloudfoundry/bosh-openstack-cpi-44.tgz
  release_list="$(echo "${stored_releases}" | grep "/${name}\-[0-9]*\.")"

  if [ "${release_list}" != "" ] ; then
    flag_delete=0
    for release in ${release_list} ; do
      if [ ${flag_delete} = 0 ] ; then
        printf "%b- Keep \"${release}\"\n" "${STD}"
      else
        printf "%b- Delete \"${release}\"%b\n" "${YELLOW}" "${STD}"
        delete_source_releases_list="${delete_source_releases_list}\n${release}"
      fi

      flag_found="$(echo "${release}" | grep "/${name}\-${release_version}\.tgz")"
      if [ "${flag_found}" != "" ] ; then
        flag_delete=1
      fi
    done
  fi
done

#--- Delete empty lines
delete_source_releases_list="$(echo -e "${delete_source_releases_list}" | sed '/^$/d')"

#--- Check obsolete precompiled bosh releases versions in minio-private-s3 bucket
printf "\n%bCheck obsolete precompiled bosh releases in minio buckets%b\n" "${REVERSE}${GREEN}" "${STD}"
delete_precompiled_releases_list=""
stored_precompiled_releases="$(mc find minio/compiled-releases | LC_ALL=C sort -r --version-sort --field-separator=.)"

for line in ${RELEASES_VERSIONS} ; do
  release_list=""
  name="$(echo "${line}" | awk -F ":" '{print $1}')"
  release_version="$(echo "${line}" | awk -F ":" '{print $2}')"
  printf "\n%b\"${name}\" precompiled bosh release oldest used version : ${release_version}%b\n" "${REVERSE}${YELLOW}" "${STD}"
  #minio/compiled-releases/cppforlife/zookeeper-0.0.10-ubuntu-bionic-621.81.tgz
  stemcell_release_list="$(echo "${stored_precompiled_releases}" | grep "/${name}\-[0-9]")"
  if [ "${stemcell_release_list}" != "" ] ; then
    #--- First step : Check obsolete stemcells precompiled versions
    for release in ${stemcell_release_list} ; do
      flag_stemcell=0
      for stemcell_version in ${keep_stemcells_versions} ; do
        flag_found="$(echo "${release}" | grep "\-${stemcell_version}\.tgz")"
        if [ "${flag_found}" != "" ] ; then
          flag_stemcell=1 ; break
        fi
      done

      if [ ${flag_stemcell} = 1 ] ; then
        release_list="${release_list}\n${release}"
      else
        printf "%b- Delete \"${release}\"%b\n" "${YELLOW}" "${STD}"
        delete_precompiled_releases_list="${delete_precompiled_releases_list}\n${release}"
      fi
    done

    #--- 2nd step : Check obsolete bosh release precompiled versions
    release_list="$(echo -e "${release_list}" | sed '/^$/d')"
    if [ "${release_list}" != "" ] ; then
      flag_delete=0
      for release in ${release_list} ; do
        if [ ${flag_delete} = 0 ] ; then
          printf "%b- Keep \"${release}\"\n" "${STD}"
        else
          printf "%b- Delete \"${release}\"%b\n" "${YELLOW}" "${STD}"
          delete_precompiled_releases_list="${delete_precompiled_releases_list}\n${release}"
        fi

        flag_found="$(echo "${release}" | grep "/${name}\-${release_version}\-ubuntu\-\(xenial\|bionic\)\-${OLDEST_STEMCELL_VERSION}\.tgz")"
        if [ "${flag_found}" != "" ] ; then
          flag_delete=1
        fi
      done
    fi
  fi
done

#--- Delete empty lines
delete_precompiled_releases_list="$(echo -e "${delete_precompiled_releases_list}" | sed '/^$/d')"

#--- Confirm packages deletion
printf "\n%bDelete minio S3 packages (y/[n]) ? :%b " "${REVERSE}${GREEN}" "${STD}" ; read choice
printf "\n"
if [ "${choice}" != "y" ] ; then
  exit
fi

printf "\n%bDelete obsolete packages versions...%b\n" "${REVERSE}${YELLOW}" "${STD}"
for package in ${delete_stemcells_list} ${delete_buildpacks_list} ${delete_source_releases_list} ${delete_precompiled_releases_list} ; do
  mc rm ${package}
done

#--- Display cleanup size
FINAL_SIZE="$(mc du minio | sed -e "s+\t++")"
printf "\n%bMinio reduce size:%b ${INITIAL_SIZE} => ${FINAL_SIZE}\n\n" "${REVERSE}${YELLOW}" "${STD}"