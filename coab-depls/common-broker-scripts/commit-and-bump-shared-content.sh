#!/usr/bin/env bash

#Usage: commit-and-bump-shared-content.sh "message" cf-mysql mongodb cassandra noop
# will commit change

# This is a workaround for https://github.com/orange-cloudfoundry/cf-ops-automation/issues/144

# given current directory is paas-template root
# given a change to common-broker-scripts/smokeTest.bash
# and a call to commit-and-bump-shared-content.sh "message" mysql mongodb
# then staged files in the current branch are commit with "message"
# and on the feature-coab-mysql branch the file "bump-shared-content-on.txt" will have the current date
# and on the feature-coab-mongo branch the file "bump-shared-content-on.txt" will have the current date

#set -o xtrace # debug mode
set -o errexit # exit on errors


if [[ ! "$(basename $(pwd))" =~ "paas-template" ]]; then
    echo "please cd to your paas-template root dir to run this script"
    exit 1
fi

MESSAGE="$1"
shift
BRANCHES="$@"

#DRY_RUN=true
#https://serverfault.com/questions/147628/implementing-dry-run-in-bash-scripts
function _run () {
    if [[ "$DRY_RUN" ]]; then
        echo $@
    else
        $@
    fi
}

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "committing in ${CURRENT_BRANCH}"
#Did not yet find the right quote escape syntax on MESSAGE to avoid this duplication using _run function
if [[ "$DRY_RUN" ]]; then
    echo git commit -a -m "${MESSAGE}"
else
    ! git commit -a -m "${MESSAGE}"
fi
_run git push

#arg 1: service type (e.g mongodb)
get_branch_name() {
    local service="$1"
    case "${service}" in
    "cassandra")
        echo "feature-coab-generalisation";;
    "cf-mysql")
        echo "feature-coab-mysql";; #mysql broker is in coa-cf-mysql-broker but its branch is still feature-coab-mysql
    *)
        echo "feature-coab-$service";;
    esac
}


for m in ${BRANCHES}
do
    #b="feature-coab-${m}"
    b=$(get_branch_name ${m})
    f="./coab-depls/cf-apps-deployments/coa-${m}-broker/bump-shared-content-on.txt"
    echo "Bumping model ${m} in branch ${b} through ${f}"
    _run git checkout $b
    _run git pull --rebase

    if [[ "$DRY_RUN" ]]; then
        echo "date -R > ${f}"
    else
        date -R > "${f}"
    fi

    _run git add "${f}"
    #Did not yet find the right quote escape syntax on MESSAGE to avoid this duplication using _run function
    if [[ "$DRY_RUN" ]]; then
        #variants for multiline messages: https://stackoverflow.com/questions/5064563/add-line-break-to-git-commit-m-from-the-command-lineœ
        echo git commit -m "forcing symlinked common files updates" -m "as a workaround for https://github.com/orange-cloudfoundry/cf-ops-automation/issues/144" "${f}"
    else
        !    git commit -m "forcing symlinked common files updates" -m "as a workaround for https://github.com/orange-cloudfoundry/cf-ops-automation/issues/144" "${f}"
    fi
    _run git push
done

_run git checkout "${CURRENT_BRANCH}"