#!/bin/bash

function backing_services_org() {
    # the key is not suffixed by symlink index to avoid editing spruce tpl files per index
    echo "$(fetch_deployment_secret_prop "osb-cmdb-broker/default-org" )"
}
export -f backing_services_org

function backing_services_space() {
    # the key is not suffixed by symlink index to avoid editing spruce tpl files per index
    echo "$(fetch_deployment_secret_prop "osb-cmdb-broker/default-space" )"
}
export -f backing_services_space
