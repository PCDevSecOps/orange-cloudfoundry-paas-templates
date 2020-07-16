#!/bin/bash
#===========================================================================
# Migrate coab instances based on its model
#===========================================================================

usage() {
    echo "$0 -m <model> -b <branch_name>" 1>&2
    echo -e "\t -s coab service Default: cassandra" 1>&2
    echo -e "\t -p coab service prefix Default: c_" 1>&2

    echo -e "\t -u paas-templates url. Default: $default_paas_template_url" 1>&2
    echo -e "\t    well known paas-templates repository url:" 1>&2
    echo -e "\t\t- ${GITLAB_FE_INT}" 1>&2
    echo -e "\t\t- ${GITLAB_FE_DEV}" 1>&2
    echo -e "\t\t- ${GITLAB_FE_PREPROD}" 1>&2
    echo -e "\t\t- ${GITLAB_FE_PROD}" 1>&2
    echo -e "\t -b <branch name to rebase>. Sample \".*hotfix.*\".Default (when -b is not set): all branches excluding COAB branches" 1>&2
    echo -e "\t -r dry run mode: execute rebase but do not push result on remote. Default is disabled" 1>&2
    exit 1
}

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
repository_path=/tmp/paas-templates
root_path="${repository_path}/coab-depls"
vsphere=vsphere
openstack=openstack-hws
services="cf-mysql#y|cassandra#c|mongodb#m|cf-rabbit#r|redis#e"

#-----------------
#cloning repository
#$1 is path as basename
#-----------------
is_directory() {
    path=$1
    directory=$(file ${path} | grep "directory" | wc -l)
    if [[ ${directory} -eq 1 ]]; then
        return 0
    fi
    return 1
}


#-----------------
#building a file with contains first level files under model
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#-----------------
building_first_level(){
    model=$1
    >/tmp/service_first_level.lst
    for file in $(find ${model} -maxdepth 1 -type f -name '*.yml'); do
        #../cf-mysql/deployment-dependencies.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "..${relative}" >> /tmp/service_first_level.lst
    done
    cat /tmp/service_first_level.lst
    echo "first level building done"
}

#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
building_second_level(){
    model=$1
    template=$2
    >/tmp/service_second_level.lst
    vars="/${service}/template/coab-vars.yml"
#    for file in $(find ${model}/${template} -maxdepth 1 -type f -name '*'); do #search for files
    for file in $(find ${model}/${template} -maxdepth 1 -name '*'); do #search for files
        #../../cf-mysql/template/pre-deploy.sh
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        name=$(basename ${file})
        if [[ ${relative} = ${vars} || ${name} = ${vsphere} || ${name} = ${openstack} || ${name} = ${template} ]]; then #escape coab-vars file and directories
            echo "escaping ${file}"
        else
            echo "../..${relative}" >> /tmp/service_second_level.lst
        fi
    done
    cat /tmp/service_second_level.lst
    echo "second level building done"
}

#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
#$3 is profile parameter - profile
building_third_level(){
    model=$1
    template=$2
    profile=$3
    >/tmp/service_third_level.lst
    for file in $(find ${model}/${template}/${profile} -maxdepth 1 -type f -name '*.yml'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "../../..${relative}" >> /tmp/service_third_level.lst
    done
    cat /tmp/service_third_level.lst
    echo "third level building done"
}

#-----------------
#build model links
#-----------------
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
building() {
    model=$1
    echo "begin building"
    #search first level files under model
    building_first_level ${model}

    #first level directories
    for directory in $(find ${model} -maxdepth 1 -type d -name '*'); do
        #template
        template=$(basename ${directory})
        if [[ ${template} = "template" ]]; then #escape service and process only template directory#
            #search second level files under template
            building_second_level $1 ${template}

            #second level directory
            for directory in $(find ${model}/${template} -maxdepth 1 -type d -name '*'); do
                profile=$(basename ${directory})
                if [ ${profile} = ${vsphere} -o ${profile} = ${openstack} ]; then #escape template and sub-module, only profiles#
                    #search thirds level files under profile
                    building_third_level $1 ${template} ${profile}
                fi
            done
        fi
    done
    echo "end building"
}

#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
migrating_first_level(){
    instance=$1
    #cleaning first level links under instance
    for file in $(find ${instance} -maxdepth 1 -type l -name '*'); do
        #../cf-mysql/deployment-dependencies.yml
        link=$(basename ${file})
        #echo "unlink ${link}"
        unlink ${link}
    done
    #linking
    for line in $(cat /tmp/service_first_level.lst); do
        #echo "ln -s ${line} $(basename ${line})"
        ln -s ${line} $(basename ${line})
    done
    echo "first level migrating done"
}

#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is service parameter - cf-mysql
migrating_second_level(){
    instance=$1
    template=$2
    service=$3
    #cleaning second level files under instance/template
    for file in $(find ${instance}/${template} -maxdepth 1 -type l -name '*'); do
        #../../cf-mysql/template/pre-deploy.sh
        link=$(basename ${file})
        #echo "unlink ${link}"
        unlink ${link}
    done

    #linking
    for line in $(cat /tmp/service_second_level.lst); do
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

#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is profile parameter - profile
migrating_third_level(){
    instance=$1
    template=$2
    profile=$3
    #cleaning third level files under model/template/profile
    for file in $(find ${instance}/${template}/${profile} -maxdepth 1 -type l -name '*'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        link=$(basename ${file})
        #echo "unlink ${link}"
        unlink ${link}
    done
    #linking
    for line in $(cat /tmp/service_third_level.lst); do
        #echo "ln -s ${line} $(basename ${line})"
        ln -s ${line} $(basename ${line})
    done
    echo "third level migrating done"
}


#--------------------------------
#manage links (clean and rebuild)
#--------------------------------
#$1 is branch parameter - feature-coabdepls-cf-mysql-serviceinstances
#$2 is service parameter - cf-mysql
#$3 is prefix parameter - y_*

#
migrating() {
    branch=$1
    service=$2
    prefix=$3

    echo "begin migrating"
    cd ${root_path}
    git co ${branch}
    for instance in $(find ${root_path} -maxdepth 1 -type d -name "${prefix}"); do
        echo migrating ${instance}
        cd ${instance}
        migrating_first_level ${instance}

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

                        cd ${profile}
                        migrating_third_level ${instance} ${template} ${profile}

                    fi
                done
            fi
        done
    done

    echo "end migrating"
}


#####main#####

#cloning repository
cloning

#browsing
for s in $(echo ${services} | tr "|" " "); do
    service=$(echo ${s} |cut -d'#' -f1)
    alias=$(echo ${s} |cut -d'#' -f2)
    branch="feature-coabdepls-${service}-serviceinstances"
    prefix="${alias}_*"
    model=${root_path}/${service}

    echo "processing ${service} on branch ${branch} with prefix ${prefix}"

    startup=$(pwd)

    building ${model}

    migrating ${branch} ${service} ${prefix}

    cd ${startup}
done
