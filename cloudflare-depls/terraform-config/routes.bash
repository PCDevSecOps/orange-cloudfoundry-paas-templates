#!/usr/bin/env bash

# $1: APP_GUID
# $2: ROUTE name
function display_cmd() {
    APP=$1
    ROUTE=$2

    SPACE_GUID=$(cf curl v2/apps/$APP | jq -r ' .entity.space_guid');
    SPACE_NAME=$(cf curl v2/spaces/$SPACE_GUID | jq -r ' .entity.name' );
    ORG_GUID=$(cf curl v2/spaces/$SPACE_GUID | jq -r '.entity.organization_guid' );
    ORG_NAME=$(cf curl v2/organizations/$ORG_GUID | jq -r ' .entity.name');
    APP_NAME=$(cf curl v2/apps/$APP | jq -r ' .entity.name');

    echo "cf t -o $ORG_NAME -s $SPACE_NAME;cf map-route $APP_NAME $ROUTE"

}
