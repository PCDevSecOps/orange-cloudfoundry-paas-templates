#!/bin/bash
#=========================================================================================
# Enable branch (rename disable-feature-xxx to feature-xxx)
#=========================================================================================

#--- Script properties
SCRIPT=`basename $0`
MASTER_BRANCH_NAME="reference"
BRANCH_NAME="$1"
ENABLE_BRANCH_NAME="$(echo "${BRANCH_NAME}" | sed -e "s+disable-++g")"

#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

#--- Check if git repository and refresh local repository from remote
git fetch --all --prune > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%b\"$(pwd)\" is not a git repository%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

feature_branches="$(git branch -r | grep "origin/disable-feature-" | sed -e "s+origin/++g" 2> /dev/null)"
flag="$(echo "${feature_branches}" | grep " ${BRANCH_NAME}$")"
if [ "${BRANCH_NAME}" = "" ] || [ "${flag}" = "" ] ; then
  printf "\n%bUsage : ${SCRIPT} <disable-feature-branch-name>%b\n\n" "${RED}${BOLD}" "${STD}"
  printf "%b${feature_branches}%b\n\n" "${RED}" "${STD}" ; exit 1
fi

#--- Catch active branch and checkout on "master" branch
initial_branch="$(git symbolic-ref HEAD --short 2> /dev/null)"
git checkout ${MASTER_BRANCH_NAME} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit checkout on \"${MASTER_BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

#--- Check if local branch already exist
checkBranch="$(git branch 2> /dev/null | grep " ${ENABLE_BRANCH_NAME}$")"
if [ "${checkBranch}" != "" ] ; then
  printf "\n%bDelete local branch \"${ENABLE_BRANCH_NAME}\"...%b\n" "${YELLOW}${REVERSE}" "${STD}"
  git branch -D ${ENABLE_BRANCH_NAME}
  if [ $? != 0 ] ; then
    printf "\n%bGit delete local branch \"${ENABLE_BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
  fi
fi

#--- Check if remote branch already exist
checkBranch="$(git branch -r 2> /dev/null | grep "origin/${ENABLE_BRANCH_NAME}$")"
if [ "${checkBranch}" != "" ] ; then
  printf "\n%bDelete remote branch \"${ENABLE_BRANCH_NAME}\"...%b\n" "${YELLOW}${REVERSE}" "${STD}"
  git push origin --delete ${ENABLE_BRANCH_NAME}
  if [ $? != 0 ] ; then
    printf "\n%bGit delete remote branch \"${ENABLE_BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
  fi
fi

#--- Rename branch
printf "\n%bRename branch \"${BRANCH_NAME}\" to \"${ENABLE_BRANCH_NAME}\"...%b\n" "${YELLOW}${REVERSE}" "${STD}"
git checkout ${BRANCH_NAME} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit checkout on \"${BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

git branch -m ${ENABLE_BRANCH_NAME} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit rename branch \"${ENABLE_BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

git push origin --delete ${BRANCH_NAME} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit delete remote \"${BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

git branch --unset-upstream > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit unset-upstream failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

git push -u origin ${ENABLE_BRANCH_NAME} > /dev/null 2>&1
if [ $? != 0 ] ; then
  printf "\n%bGit push to origin \"${ENABLE_BRANCH_NAME}\" failed%b\n\n" "${RED}${BOLD}" "${STD}" ; exit 1
fi

#-- Checkout on initial branch
if [ "${BRANCH_NAME}" != "${initial_branch}" ] ; then 
  git checkout ${initial_branch} > /dev/null 2>&1
fi

printf "\n%bBranch \"${BRANCH_NAME}\" has been renamed into \"${ENABLE_BRANCH_NAME}\".%b\n\n" "${GREEN}${BOLD}" "${STD}"