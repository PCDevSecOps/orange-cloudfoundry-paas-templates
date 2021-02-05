#!/usr/bin/env bash

echo "Usage: source this script and then invoke bash functions: "
echo " coab_display_service_name_pipeline <service-instance-name>   (cf t to org/space)"
echo " coab_display_service_name_git_log <service-instance-name>   (cf t to org/space)"
echo " delete_orphan_services   (COAB_SERVICE_OFFER=noop-ondemand)"
echo "      Prereq: cd to a directory where you have ./int-secrets available"
COAB_SERVICE_OFFER=${COAB_SERVICE_OFFER-"noop-ondemand"}



# $1 service type such as "noop-ondemand" or "cassandra-ondemand"
# output: the concourse service prefix such as "x_" or "c_"
function _get_service_prefix {
    SERVICE_NAME=$1
    case "${SERVICE_NAME}" in
        # specific case of noop
        noop-ondemand)
            echo "x_";;
        # specific case of mysql
        cf-mysql-ondemand)
            echo "y_";;
        # general case: use 1st service letter, e.G. "cassandra-ondemand"
        *)
            # https://www.tldp.org/LDP/abs/html/string-manipulation.html
            # ${string:position:length}
            #       0-based indexing.
            echo "${SERVICE_NAME:0:1}_";;
    esac
}

function _get_ops_domain_base_url {
    CONCOURSE_BASE_URL=$(cf api | grep endpoint | awk '{print $3}' | sed 's/-cfapi\./-ops-paas\./')
    echo "${CONCOURSE_BASE_URL}"
}

function _get_gitlab_base_url {
    CONCOURSE_BASE_URL=$(_get_ops_domain_base_url | sed 's/api\./elpaaso-gitlab\./' )
    echo "${CONCOURSE_BASE_URL}"
}


#Opens in browser the concourse pipeline associated with a service instance
# $1: the name of the CF service instance in the currently selected space (cf t)
function coab_display_service_name_pipeline {
    SERVICE_INSTANCE_NAME="$1"
    SERVICE_INSTANCE_GUID=$(cf service --guid ${SERVICE_INSTANCE_NAME})
    SERVICE_NAME=$(cf service ${SERVICE_INSTANCE_NAME} | grep 'service:' | awk '{print $2}')
    URL="$(_get_concourse_base_url)/teams/main/pipelines/coab-depls-bosh-generated/jobs/deploy-$(_get_service_prefix ${SERVICE_NAME})${SERVICE_INSTANCE_GUID}"
    echo "pipeline for si guid=${SERVICE_INSTANCE_GUID}"
    echo "opening url: ${URL}"
    xdg-open "${URL}"
}


#Opens in browser the git log associated with a service instance
# $1: the name of the CF service instance in the currently selected space (cf t)
function coab_display_service_name_git_log {
    SERVICE_INSTANCE_NAME="$1"
    SERVICE_INSTANCE_GUID=$(cf service --guid ${SERVICE_INSTANCE_NAME})
    SERVICE_NAME=$(cf service ${SERVICE_INSTANCE_NAME} | grep 'service:' | awk '{print $2}')
    RELATIVE_FE_INT_FILE_PATH='skc-ops-int/int-secrets'
    FILE_PATH="${RELATIVE_FE_INT_FILE_PATH}/blob/master/coab-depls"
    LOG_PATH="${RELATIVE_FE_INT_FILE_PATH}/commits/master/coab-depls"
    COAB_DEPLOYMENT_NAME="$(_get_service_prefix ${SERVICE_NAME})${SERVICE_INSTANCE_GUID}"
    LOG_URL="$(_get_gitlab_base_url)/${RELATIVE_FE_INT_LOG_PATH}/${COAB_DEPLOYMENT_NAME}/enable-deployment.yml"
    FILE_URL="$(_get_gitlab_base_url)/${RELATIVE_FE_INT_FILE_PATH}/${COAB_DEPLOYMENT_NAME}/enable-deployment.yml"
    echo "git log for si guid=${SERVICE_INSTANCE_GUID}"
    echo "CTRL+click to open in browser"
    echo "enable-deployment.yml file: ${FILE_URL}"
    echo "enable-deployment.yml log: ${LOG_URL}"
    xdg-open "${LOG_URL}"
}





function get_orphaned_service_instances {
    #check number of actual service instances
    find ./int-secrets/coab-depls/ -name enable* | grep x_ | wc -l

    #find orphan service instances
    REQUESTED_SERVICE_NAMES=$( cf s | grep ${COAB_SERVICE_OFFER} | cut -d ' ' -f 1)

    # https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html#Command-Substitution
    # If the () command substitution appears within double quotes, word splitting and filename expansion are not performed on the results. I.e. each entry is separated by a new line
    REQUESTED_SERVICE_GUIDS="$(echo $REQUESTED_SERVICE_NAMES| xargs -n 1  cf service --guid | sort)"
    ACTUAL_SERVICE_GUIDS="$(find int-secrets/coab-depls/ -name enable* | grep x_ | cut -d '/' -f 3 |sed 's/x_//' | sort)"


    # "comm - compare two sorted files line by line"
    # -3     suppress column 3 (lines that appear in both files)
    ORPHAN_SERVICE_GUIDS="$(comm -3 <(echo "$REQUESTED_SERVICE_GUIDS") <(echo "$ACTUAL_SERVICE_GUIDS"))"
}

#Delete orphan services
function delete_orphan_services {
    cd int-secrets
    for s in $ORPHAN_SERVICE_GUIDS ; do rm -rf coab-depls/x_$s; done
    for s in $ORPHAN_SERVICE_GUIDS ; do git add -u coab-depls/x_$s; done
    git commit -m "manually cleaning orphan services"
    git pull --rebase
    git push origin
}