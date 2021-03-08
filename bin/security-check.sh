#!/usr/bin/env bash
set -e
. ./load-git-secrets-env.sh

#Note: self checks use git config instead of git-secrets to protect against git-secrets misconfiguration
# and has better precisions (asserts some rejected patterns are present)
PATTERN_COUNT=$(git config --get-all secrets.patterns|wc -l)
echo "${PATTERN_COUNT} secrets rejected patterns registered. Here is the full allowed and rejected patterns:"
git-secrets --list
if [ $PATTERN_COUNT -eq 0 ];
then
    echo "No patterns detected, please check your git-secrets config below:"
    exit 1
fi

cd ..
# we ignore files in root directory, vendor directory, submodules directory and .git directory, including .git-secret-config.sh
FILE_LIST=$(find . -maxdepth 1 -type d|grep -v .git|grep -v ./vendor|grep -v ./submodules|grep ./)

# We add files in root directory, except .git-secret-config.sh
TOP_LEVEL_FILES="$(find . -maxdepth 1 -type f| grep -v .git)"
git-secrets --scan -r ${FILE_LIST} ${TOP_LEVEL_FILES}
cd -
