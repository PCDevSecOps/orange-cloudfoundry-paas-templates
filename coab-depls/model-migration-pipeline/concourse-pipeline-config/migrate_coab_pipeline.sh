#!/bin/bash
#===========================================================================
# Migrate coab instances based on its model
#===========================================================================

#------------------------
#help on file command
#------------------------
#/feature-coab-migration-pipeline/coab-depls/cf-rabbit/template$ file 00-add-cf-rabbit-releases-operators.yml
#>00-add-cf-rabbit-releases-operators.yml: ASCII text
#/feature-coab-migration-pipeline/coab-depls/cf-rabbit/template$ file vsphere
#>vsphere: directory
#/feature-coab-migration-pipeline/coab-depls/cf-rabbit/template$ file 01-add-cf-rabbit-server-operators.yml
#>01-add-cf-rabbit-server-operators.yml: symbolic link to ../../../shared-operators/cf-rabbit/01-add-cf-rabbit-server-operators.yml

#------------------------
#(1) means first level files and links
#(2) means second level files and links
#(3) means third level files and links
#------------------------
#.
#(1)├── deployment-dependencies.yml
#└── template
#(2)   ├── 00-add-cf-rabbit-releases-operators.yml
#(2)   ├── 01-add-cf-rabbit-server-operators.yml -> ../../../shared-operators/cf-rabbit/01-add-cf-rabbit-server-operators.yml
#(2)   ├── 02-add-cf-rabbit-osbbroker-operators.yml -> ../../../shared-operators/cf-rabbit/02-add-cf-rabbit-osbbroker-operators.yml
#(2)    ├── 04-route-registrar-operators.yml
#(2)    ├── 05-add-bpm-operators.yml
#(2)    ├── 06-patch-osb-broker-password-operators.yml
#(2)    ├── 40-enable-prometheus-exporter-operators.yml
#(2)    ├── 70-enable-shieldv8-release-and-variables-operators.yml
#(2)    ├── 71-enable-shieldv8-shield-core-operators.yml
#(2)    ├── 72-enable-shieldv8-shield-cf-rabbit-operators.yml
#(2)    ├── cf-rabbitmq-37-vars.yml
#(2)    ├── cf-rabbit.yml
#(2)    ├── coab-operators.yml
#(2)    ├── coab-vars.yml
#(2)    ├── post-deploy.sh
#(2)    ├── pre-deploy.sh
#(2)    ├── shield-vars.yml
#    └── vsphere
#(3)       └── 99-osb-operators.yml

#------------------------
#constants and parameters
#------------------------
repository_path=/tmp/build/get/paas-templates
root_path="${repository_path}/coab-depls"
vsphere=vsphere
openstack=openstack-hws
reset=.last-reset
services="cf-mysql#y|cassandra#c|mongodb#m|cf-rabbit#r|redis#e"

#-----------------
#test directory
#$1 is the path to test
#$returns 1 if path is a directory, 0 if it is not a directory
#-----------------
is_directory() {
    path=$1
    directory=$(file ${path} | grep "directory" | wc -l)
    if [[ ${directory} -eq 1 ]]; then
        return 1
    fi
    return 0
}

#-----------------
#building a file with contains first level files under model
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is service parameter - cf-mysql
#-----------------
building_first_level(){
    model=$1
    service=$2
    >/tmp/service_first_level_${service}.lst
    for file in $(find ${model} -maxdepth 1 -type f -name '*.yml'); do
        #../cf-mysql/deployment-dependencies.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "..${relative}" >> /tmp/service_first_level_${service}.lst
    done
    cat /tmp/service_first_level_${service}.lst
    echo "first level building done"
}

#-----------------
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
#$3 is service parameter - cf-mysql
#-----------------
building_second_level(){
    model=$1
    template=$2
    service=$3
    >/tmp/service_second_level_${service}.lst
    vars="/${service}/template/coab-vars.yml"
    for file in $(find ${model}/${template} -maxdepth 1 -name '*'); do #search for files
        #../../cf-mysql/template/pre-deploy.sh
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        name=$(basename ${file})
        is_directory ${file}
        if [[ ${relative} = ${vars} || ${name} = ${vsphere} || ${name} = ${openstack} || ${name} = ${template} || ${name} = ${reset} || $? = 1 ]]; then #escape coab-vars file and directories
            echo "escaping ${file}"
        else
            echo "../..${relative}" >> /tmp/service_second_level_${service}.lst
        fi
    done
    cat /tmp/service_second_level_${service}.lst
    echo "second level building done"
}

#-----------------
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
#$3 is profile parameter - profile
#$4 is service parameter - service
#-----------------
building_third_level(){
    model=$1
    template=$2
    profile=$3
    service=$4
    >/tmp/service_third_level_${service}_${profile}.lst
    for file in $(find ${model}/${template}/${profile} -maxdepth 1 -type f -name '*.yml'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "../../..${relative}" >> /tmp/service_third_level_${service}_${profile}.lst
    done
    cat /tmp/service_third_level_${service}_${profile}.lst
    echo "third level building done"
}

#-----------------
#build model links
#$1 is root_path parameter -
#$2 is service parameter - cf-mysql
#-----------------
building() {
    rp=$1
    s=$2

    model=${rp}/${s}

    echo "begin building"
    #search first level files under model
    building_first_level ${model} ${s}

    #first level directories
    for directory in $(find ${model} -maxdepth 1 -type d -name '*'); do
        #template
        template=$(basename ${directory})
        if [[ ${template} = "template" ]]; then #escape service and process only template directory#
            #search second level files under template
            building_second_level ${model} ${template} ${s}

            #second level directory
            for directory in $(find ${model}/${template} -maxdepth 1 -type d -name '*'); do
                profile=$(basename ${directory})
                if [[ ${profile} = ${vsphere} || ${profile} = ${openstack} ]]; then #escape template and sub-module, only profiles#
                    #search thirds level files under profile
                    building_third_level ${model} ${template} ${profile} ${s}
                fi
            done
        fi
    done
    echo "end building"
}

#-----------------
#migrate first level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is service parameter - cf-mysql
#-----------------
migrating_first_level(){
    instance=$1
    service=$2
    #cleaning first level links under instance
    for file in $(find ${instance} -maxdepth 1 -type l -name '*'); do
        #../cf-mysql/deployment-dependencies.yml
        link=$(basename ${file})
        unlink ${link}
    done
    #linking
    for line in $(cat /tmp/service_first_level_${service}.lst); do
        ln -s ${line} $(basename ${line})
    done
    echo "first level migrating done"
}

#-----------------
#migrate second level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is service parameter - cf-mysql
#-----------------
migrating_second_level(){
    instance=$1
    template=$2
    service=$3
    #cleaning second level files under instance/template
    for file in $(find ${instance}/${template} -maxdepth 1 -type l -name '*'); do
        #../../cf-mysql/template/pre-deploy.sh
        link=$(basename ${file})
        unlink ${link}
    done

    #linking
    for line in $(cat /tmp/service_second_level_${service}.lst); do
        var=$(basename ${line})
        if [[ ${var} = "${service}.yml" ]]; then
            link=$(basename $1)
            link="${link}.yml"
            ln -s ${line} ${link}
        else
            ln -s ${line} $(basename ${line})
        fi
    done
    echo "second level migrating done"
}

#-----------------
#migrate third level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is profile parameter - profile
#$4 is service parameter - cf-mysql
#-----------------
migrating_third_level(){
    instance=$1
    template=$2
    profile=$3
    service=$4
    #cleaning third level files under model/template/profile
    for file in $(find ${instance}/${template}/${profile} -maxdepth 1 -type l -name '*'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        link=$(basename ${file})
        unlink ${link}
    done
    #linking
    for line in $(cat /tmp/service_third_level_${service}_${profile}.lst); do
        ln -s ${line} $(basename ${line})
    done
    echo "third level migrating done"
}


#--------------------------------
#manage links (clean and rebuild)
#$1 is root_path parameter -
#$2 is branch parameter - feature-coabdepls-cf-mysql-serviceinstances
#$3 is service parameter - cf-mysql
#$4 is prefix parameter - y_*
#--------------------------------

migrating() {
    rp=$1
    branch=$2
    service=$3
    prefix=$4

    echo "begin migrating"
    echo ${rp}
    cd ${rp}

    for instance in $(find ${rp} -maxdepth 1 -type d -name "${prefix}"); do
        echo migrating ${instance}
        cd ${instance}
        migrating_first_level ${instance} ${service}

        #first level directories
        for directory in $(find ${instance} -maxdepth 1 -type d -name '*'); do
            #template
            template=$(basename ${directory})
            relative=$(echo ${directory} | awk -v var=${root_path} '{gsub(var,"") ; print}')
            if [ ${template} != ${relative:1} ]; then # escape /y_xxx #

                cd ${template}
                migrating_second_level ${instance} ${template} ${service}

                #second level directory
                for directory in $(find ${instance}/${template} -maxdepth 1 -type d -name '*'); do
                    profile=$(basename ${directory})
                    if [[ ${profile} = ${vsphere} || ${profile} = ${openstack} ]]; then #escape template and sub-module, only profiles#
                        cd ${directory}
                        migrating_third_level ${instance} ${template} ${profile} ${service}
                    fi
                done
            fi
        done
    done

    echo "end migrating"
}

usage() {
    echo "$(basename -- $0) [OPTIONS]" 1>&2
    echo -e "\t -r resource: " 1>&2
    echo -e "\t -a all (build and migration modes together): " 1>&2
    echo -e "\t -b build (build mode): " 1>&2
    echo -e "\t -m migration (migration mode): " 1>&2
    exit 1
}

#--------------------------------
#main
#--------------------------------
while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-r"|"--resource") resource="$2" ; shift ; shift ;;
    "-a"|"--all") FLAG_ALL=1 ; shift ;;
    "-b"|"--build") FLAG_BUILD=1 ; shift ;;
    "-m"|"--migration") FLAG_MIGRATION=1 ; shift ;;
    *) usage ;;
  esac
done


#browsing
for s in $(echo ${services} | tr "|" " "); do

    #compute root path
    root_path=$(pwd)"/${resource}/coab-depls"
    echo ${root_path}

    #extract service, alias, branch and prefix
    service=$(echo ${s} |cut -d'#' -f1)
    branch="feature-coabdepls-${service}-serviceinstances"
    alias=$(echo ${s} |cut -d'#' -f2)
    prefix="${alias}_*"
    echo "processing ${service} on branch ${branch} with prefix ${prefix}"

    startup=$(pwd)

    if [[ ${FLAG_ALL} = 1 || ${FLAG_BUILD} = 1 ]] ; then
        #build model links
        building ${root_path} ${service}
    fi

    if [[ ${FLAG_ALL} = 1 || ${FLAG_MIGRATION} = 1 ]] ; then
        #recreate instance links based on model ones
        migrating ${root_path} ${branch} ${service} ${prefix}
    fi

    cd ${startup}
done
