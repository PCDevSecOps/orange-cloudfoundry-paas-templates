#!/usr/bin/env bash

#Usage: restarts all apps in the currently targetted org. Makes normal usage of CF API. Prefer other script if API is instable.
# e.g
#restart-all-apps-in-one-org.bash | tee restart-traces.txt
# prepare CTRL-Z to pause script if needed
#Prereq: target the or to restart
# cf t -o orange-internet;
# 

#DEBUG_MODE=true
#DEBUG_MODE=false

function setVerboseExitMode() {
    set -o errexit # exit on errors
    if [ "$DEBUG_MODE" == "true" ]
    then
        set -o xtrace # debug mode
    fi
}
setVerboseExitMode

#DRY_RUN=true
#https://serverfault.com/questions/147628/implementing-dry-run-in-bash-scripts
function _run () {
    if [[ "$DRY_RUN" ]]; then
        echo $@
    else
        $@
    fi
}

#Arg1: message
function echo_header() {
    echo "-----------------------------------------------------"
    echo "$1"
    echo "-----------------------------------------------------"
}


IS=$(cf spaces | grep -v name | grep -v Getting);


for s in $IS; do
    echo_header "Please review space to be acted on:"
    cf space $s;
    echo
    echo
    #Display space details, allow visual checking of the isolation segment
    cf t -s $s;
    #Display apps that will be restarted
    echo "Please review potential apps to restart, and excluded in scripts patterns below"
    echo
    cf apps;

    APPS=$(cf apps | grep -v Getting | grep -v OK | grep -v requested| grep -v stopped | cut -f1 -d " ")
    echo_header "Restarting in space $s the following apps: $APPS"

    for a in $APPS; do
        APP_GUID=$(cf app $a --guid);
        #Async alternative to: cf restart $a
        #that speed up things (avoid sync waits)
        echo "restarting app $a in space $s"
        # the curl returns the desired state. Since this is verbose we only display the state response. If empty then something got wrong
        _run cf curl v3/apps/${APP_GUID}/actions/restart -X POST | grep state
    done;

    SLEEP_TIME=180
    echo_header "Sleeping $SLEEP_TIME s prior to move to next space to avoid too large load. Take opportunity to check load on CC/Minio, possibly CTRL-Z to suspend"
    _run sleep $SLEEP_TIME
    echo_header "Please review apps did not crash all and interrupt if this is the case"
    cf apps
done;