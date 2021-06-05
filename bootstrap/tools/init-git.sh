#!/bin/bash
#==============================================================================
# Initialize inception git-server with needed branches for concourse pipelines
#==============================================================================

#--- Load common parameters and functions
TOOLS_PATH=$(dirname $(which $0))
. ${TOOLS_PATH}/functions.sh

#--- Initialize git-server repository
pushToRemote() {
  repository="$1"
  branch="$2"
  cd $3
  display "INFO" "Update \"${branch}\" branch on \"${repository}\" git-server repository"
  git remote remove inception > /dev/null 2>&1
  git remote add inception git://${INCEPTION_INTERNAL_IP}/${repository}
  if [ $? != 0 ] ; then
    display "ERROR" "\"${repository}\" remote git server repository not accessible"
  fi

  git push -u -f inception ${branch} --tags
  if [ $? != 0 ] ; then
    display "ERROR" "\"${repository}\" remote git server repository not initialized"
  fi
}

#--- Catch template tag version for bootstrap and check if exists
if [ "$1" == "" ] ; then
  catchValue "TAG_VERSION" "Paas-template version"
else
  TAG_VERSION="$1"
fi

cd ${TEMPLATE_REPO_DIR}
executeGit "fetch --tags origin"
flag=$(git tag -l | sed -e "s+^+ +g" | sed -e "s+$+ +g")
flag=$(echo " ${flag} " | grep " ${TAG_VERSION} ")
if [ "${flag}" = "" ] ; then
  display "ERROR" "Git tag \"${TAG_VERSION}\" unknown"
fi

#--- Create "reference" branch from active tag/branch
initial_branch=$(git branch | grep '* ' | awk '{print $2}')
flag=$(git branch | sed -e "s+$+ +g")
flag=$(echo " ${flag} " | grep " reference ")
if [ "${flag}" = "" ] ; then
  display "INFO" "Create \"reference\" branch"
else
  display "INFO" "Recreate \"reference\" branch"
  executeGit "branch -D reference"
fi
executeGit "checkout -b reference"
executeGit "reset --hard ${TAG_VERSION}"
executeGit "checkout ${initial_branch}"

#--- Initialize template, secrets and coa repositories to git-server on inception instance
pushToRemote "template" "reference" "${TEMPLATE_REPO_DIR}"
pushToRemote "secrets" "master" "${SECRETS_REPO_DIR}"
pushToRemote "coa" "master" "${COA_REPO_DIR}"

#--- Create remote concourse branches for synchronizing feature branches
cd ${TEMPLATE_REPO_DIR}
display "INFO" "Create \"feature-fix-bootstrap\" branch"
executeGit "push -f inception reference:feature-fix-bootstrap"

display "INFO" "Create \"reference-wip-merged\" branch for concourse"
executeGit "push -f inception reference:reference-wip-merged"

display "INFO" "Create \"pipeline-current-reference-wip-merged\" branch for concourse"
executeGit "push -f inception reference:pipeline-current-reference-wip-merged"

display "OK" "Git branches configuration ended"