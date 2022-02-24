#!/usr/bin/env bash

#Usage: commit-and-bump-shared-content.sh will bump all brokers

set -o xtrace # debug mode
set -o errexit # exit on errors


if [[ ! "$(basename $(pwd))" =~ "paas-template" ]]; then
    echo "please cd to your paas-template root dir to run this script"
    exit 1
fi

BROKERS="./coab-depls/cf-apps-deployments/*broker"
COMMIT_FILES=""
for b in ${BROKERS}; do
    f="${b}/bump-shared-content-on.txt"
    echo "Bumping model ${b} through ${f}"
    date -R > ${f}
    COMMIT_FILES=" ${f} ${COMMIT_FILES}"
done;

git add ${COMMIT_FILES}
git commit -m "forcing symlinked common files updates for coab-x" -m "as a workaround for https://github.com/orange-cloudfoundry/cf-ops-automation/issues/144" ${COMMIT_FILES}

echo "please review commited files and push"
