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
reset=".last-reset" #excluded item
vars="coab-vars.yml" #excluded item
services="noop#x|cf-mysql#y|01-cf-mysql-extended#t|mongodb#m|cf-rabbit#r|03-cf-rabbit-extended#a|redis#e|02-redis-extended#s|04-mongodb-extended#o|20-strimzi-kafka#z"
excluded_directories="template|cf-mysql-deployment|cassandra-deployment" #excluded directories
file_prefix_first="/tmp/service_first_level"
file_prefix_second="/tmp/service_second_level"
file_prefix_third="/tmp/service_third_level"
hash="#"
file_extension="lst"
dot="."

#-----------------
#test directory
#$1 is the path to test
#$returns 1 if path is a directory, 0 if it is not a directory
#-----------------
is_directory() {
    path=$1
    if [[ -d "${path}" ]]; then
        return 1
    fi
    return 0
}

#-----------------
#test excluded directory
#$1 is the directory to test
#$returns 1 if it is an excluded directory, 0 otherwise
#-----------------
is_excluded_directory() {
    path=$1
    for ed in $(echo ${excluded_directories} | tr "|" " "); do
        if [[ ${ed} = ${path} ]]; then
            return 1
        fi
    done
    return 0
}

#-----------------
#test excluded items
#$1 is the item to test
#$returns 1 if it is an excluded item, 0 otherwise
#-----------------
is_excluded_item() {
    path=$1
    if [[ ${path} = ${vars} || ${path} = ${reset} ]]; then
        return 1
    fi
    return 0
}

#-----------------
#build a file with contains first level files under model
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is service parameter - cf-mysql
#-----------------
build_first_level(){
    model=$1
    service=$2

    echo "<-begin first level build"
    >${file_prefix_first}${hash}${service}${dot}${file_extension} #/tmp/service_first_level#${service}.lst
    for file in $(find ${model} -maxdepth 1 -type f -name '*.yml'); do
        #../cf-mysql/deployment-dependencies.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "..${relative}" >> ${file_prefix_first}${hash}${service}${dot}${file_extension}
    done
    cat ${file_prefix_first}${hash}${service}${dot}${file_extension}
    echo "end first level build->"
}

#-----------------
#build a file with contains second level files under model
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
#$3 is service parameter - cf-mysql
#-----------------
build_second_level(){
    model=$1
    template=$2
    service=$3

    echo "<-begin second level build"
    >${file_prefix_second}${hash}${service}${dot}${file_extension}
    for file in $(find ${model}/${template} -maxdepth 1 -name '*'); do #search for files
        #../../cf-mysql/template/pre-deploy.sh
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        name=$(basename ${file})
        is_directory ${file};is_directory_rc=$?
        is_excluded_item ${name};is_excluded_item_rc=$?
        if [[ ${is_directory_rc} = 1 || ${is_excluded_item_rc} = 1 ]]; then #escape excluded items and directories
            echo "${file} is excluded"
        else
            echo "../..${relative}" >> ${file_prefix_second}${hash}${service}${dot}${file_extension}
        fi
    done
    cat ${file_prefix_second}${hash}${service}${dot}${file_extension}
    echo "end second level build->"
}

#-----------------
#build a file with contains third level files under model
#$1 is model parameter - /tmp/paas-template/coab-depls/cf-mysql
#$2 is template parameter - template
#$3 is profile parameter - profile
#$4 is service parameter - service
#-----------------
build_third_level(){
    model=$1
    template=$2
    profile=$3
    service=$4

    echo "<-begin third level build"
    >${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension}
    for file in $(find ${model}/${template}/${profile} -maxdepth 1 -name '*.yml'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        relative=$(echo ${file} | awk -v var=${root_path} '{gsub(var,"") ; print}')
        echo "../../..${relative}" >> ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension}
    done
    cat ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension}
    echo "end third level build->"
}

#-----------------
#build model links
#$1 is root_path parameter -
#$2 is service parameter - cf-mysql
#-----------------
build() {
    rp=$1
    s=$2

    model=${rp}/${s}

    echo "begin building"
    #search first level files under model
    build_first_level ${model} ${s}

    #first level directories
    for directory in $(find ${model} -maxdepth 1 -type d -name '*'); do
        #template
        template=$(basename ${directory})
        if [[ ${template} = "template" ]]; then #escape service and process only template directory#
            #search second level files under template
            build_second_level ${model} ${template} ${s}

            #second level directory
            for directory in $(find ${model}/${template} -maxdepth 1 -type d -name '*'); do
                profile=$(basename ${directory})
                is_excluded_directory ${profile} #escape template and sub-module, only profiles are processed#
                if [[ $? = 0 ]]; then
                    #search thirds level files under profile
                    build_third_level ${model} ${template} ${profile} ${s}
                else
                    echo "${directory} is excluded"
                fi
            done
        fi
    done
    echo "end building"
}

#-----------------
#delete_link function
#$1 is the path parameter
#-----------------
delete_link(){
    path=$1
    link=$(basename ${path})
    echo "unlinking ${link}"
    unlink ${link}
}

#-----------------
#create_link function
#$1 is the path parameter
#-----------------
create_link(){
    path=$1
    echo "linking from ${path} to $(basename ${path})"
    ln -s ${path} $(basename ${path})
}

#-----------------
#migrate first level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is service parameter - cf-mysql
#-----------------
migrate_first_level(){
    instance=$1
    service=$2

    echo "->begin first level migration"
    #cleaning first level links under instance
    for file in $(find ${instance} -maxdepth 1 -type l -name '*'); do
        #../cf-mysql/deployment-dependencies.yml
        delete_link ${file}
    done
    #linking
    for line in $(cat ${file_prefix_first}${hash}${service}${dot}${file_extension}); do
        create_link ${line}
    done
    echo "end first level migration->"
}

#-----------------
#migrate second level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is service parameter - cf-mysql
#-----------------
migrate_second_level(){
    instance=$1
    template=$2
    service=$3

    echo "<-begin second level migration"
    #cleaning second level files under instance/template
    for file in $(find ${instance}/${template} -maxdepth 1 -type l -name '*'); do
        #../../cf-mysql/template/pre-deploy.sh
        delete_link ${file}
    done

    #linking
    for line in $(cat ${file_prefix_second}${hash}${service}${dot}${file_extension}); do
        var=$(basename ${line})
        if [[ ${var} = "${service}.yml" ]]; then #deployment name particular case
            link=$(basename ${instance})
            link="${link}.yml"
            echo "linking from ${line} to ${link}"
            ln -s ${line} ${link}
        else
            create_link ${line}
        fi
    done
    echo "end second level migration->"
}

#-----------------
#migrate third level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is profile parameter - profile
#$4 is service parameter - cf-mysql
#-----------------
migrate_third_level(){
    instance=$1
    template=$2
    profile=$3
    service=$4

    echo "<-begin third level migration"
    #cleaning third level files under model/template/profile
    for file in $(find ${instance}/${template}/${profile} -maxdepth 1 -type l -name '*'); do
        #../../../cf-mysql/template/vsphere/99-osb-operators.yml
        delete_link ${file}
    done

    #linking
    if [[ -f ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension} ]]; then #means that there are links for this profile
        for line in $(cat ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension}); do
            create_link ${line}
        done
    else #means no links for this profile, so we can clean the directory
        #cleaning if empty directory (this additional test is not required)
        if [[ -z "$(ls -A ${instance}/${template}/${profile})" ]]; then #empty directory
            echo "/!\cleaning ${instance}/${template}/${profile}"
            rm -r ${instance}/${template}/${profile}
        fi
    fi

    echo "end third level migration->"
}

#-----------------
#create third level links
#$1 is instance parameter - /tmp/paas-template/coab-depls/y_aaaaaaaaaaaaaaabbbbbbbbbbbbbbbb
#$2 is template parameter - template
#$3 is profile parameter - profile
#$4 is service parameter - cf-mysql
#-----------------
create_third_level(){
    instance=$1
    template=$2
    profile=$3
    service=$4

    echo "/!\creating ${instance}/${template}/${profile}"
    mkdir -p ${instance}/${template}/${profile}
    cd ${profile}

    if [[ -f ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension} ]]; then #means that there are links for this profile
        for line in $(cat ${file_prefix_third}${hash}${service}${hash}${profile}${dot}${file_extension}); do
            create_link ${line}
        done
    fi
    cd .. #it is possible to have several new profiles
}

#--------------------------------
#migrate links (clean and rebuild)
#$1 is root_path parameter -
#$2 is service parameter - cf-mysql
#$3 is prefix parameter - y_*
#--------------------------------
migrate() {
    rp=$1
    service=$2
    prefix=$3

    echo "<-begin migrating"
    echo ${rp}
    cd ${rp}

    for instance in $(find ${rp} -maxdepth 1 -type d -name "${prefix}"); do
        echo migrating ${instance}
        cd ${instance}
        migrate_first_level ${instance} ${service}

        #first level directories (i.e template)
        for directory in $(find ${instance} -maxdepth 1 -type d -name '*'); do
            #template
            template=$(basename ${directory})
            relative=$(echo ${directory} | awk -v var=${root_path} '{gsub(var,"") ; print}')
            if [ ${template} != ${relative:1} ]; then # escape /y_xxx #

                cd ${template}
                migrate_second_level ${instance} ${template} ${service}

                #existing second level directory (i.e existingprofiles)
                for directory in $(find ${instance}/${template} -maxdepth 1 -type d -name '*'); do
                    profile=$(basename ${directory})
                    is_excluded_directory ${profile} #escape template and sub-module, only profiles are processed#
                    if [[ $? = 0 ]]; then
                        #search thirds level files under profile
                        cd ${profile}
                        migrate_third_level ${instance} ${template} ${profile} ${service}
                        cd .. #it is possible to have several profiles
                    else
                        echo "${directory} is excluded"
                    fi
                done

                #new second level directory (i.e new profiles)
                basename_file_prefix_third=$(basename ${file_prefix_third})
                for file in $(find /tmp -maxdepth 1 -type f -name "${basename_file_prefix_third}#${service}*${dot}${file_extension}"); do #service_third_level#cf-mysql*.lst
                    basename_profile=$(basename ${file})
                    profile=$(echo ${basename_profile} | cut -d'#' -f 3 | cut -d'.' -f 1)
                    if [[ ! -d "${instance}/${template}/${profile}" ]]; then
                        create_third_level ${instance} ${template} ${profile} ${service}
                    fi
                done
            fi
        done
    done
    echo "end migrating->"
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
FLAG_BUILD=0;FLAG_MIGRATION=0
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
    alias=$(echo ${s} |cut -d'#' -f2)
    prefix="${alias}_*"
    echo "processing ${service} with prefix ${prefix}"
    startup_browsing=$(pwd)

    if [[ ${FLAG_ALL} = 1 || ${FLAG_BUILD} = 1 ]] ; then
        #build model links
        build ${root_path} ${service}
    fi

    if [[ ${FLAG_ALL} = 1 || ${FLAG_MIGRATION} = 1 ]] ; then
        #recreate instance links based on model ones
        migrate ${root_path} ${service} ${prefix}
    fi

    cd ${startup_browsing}
done