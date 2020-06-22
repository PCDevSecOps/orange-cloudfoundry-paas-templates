#!/usr/bin/env bash
# Extract the host where the server is running, and add the URL to the APIs

if [ "$GITLAB_URL" = "" ];then
    echo "Please set GITLAB_URL to your gitlab project url"
    exit 1
fi

PRIVATE_TOKEN=""
CI_PROJECT_ID=
CI_COMMIT_REF_NAME=
LABELS="[\"short term\", \"ready-to-merge\" ]"

set -ex

[[ $GITLAB_URL =~ ^https?://[^/]+ ]] && GITLAB_API_URL="${BASH_REMATCH[0]}/api/v4/projects/"
echo $GITLAB_API_URL
# Look which is the default branch
#set -x

DESCRIPTION_TEMPLATE_NAME=${DESCRIPTION_TEMPLATE_NAME:-Merge_Request.md}
AVAILABLE_PROJECTS=$(curl --silent -S "${GITLAB_API_URL}" --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}")
TARGET_BRANCH=$(echo ${AVAILABLE_PROJECTS}|jq -r ".[]|select(.id==$CI_PROJECT_ID)|.default_branch")
echo ${TARGET_BRANCH}


BODY="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
    \"target_branch\": \"${TARGET_BRANCH}\",
    \"remove_source_branch\": true,
    \"title\": \"WIP: ${CI_COMMIT_REF_NAME}\",
    \"labels\": ${LABELS}
}";
# Require a list of all the merge request and take a look if there is already
# one with the same source branch
LISTMR=`curl --silent -S "${GITLAB_API_URL}${CI_PROJECT_ID}/merge_requests?state=opened" --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}"`;
COUNTBRANCHES=`echo ${LISTMR} | grep -o "\"source_branch\":\"${CI_COMMIT_REF_NAME}\"" | wc -l`;
# No MR found, let's create a new one
if [ ${COUNTBRANCHES} -eq "0" ]; then
    set -x
#    MR_DESCRIPTION=$(curl --silent "${GITLAB_API_URL}${CI_PROJECT_ID}/repository/files/.gitlab%2Fmerge_request_templates%2F${DESCRIPTION_TEMPLATE_NAME}/raw?ref=develop" --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}")
    MR_DESCRIPTION="Please use an appropriate merge request templates"
    BODY="{
        \"id\": ${CI_PROJECT_ID},
        \"source_branch\": \"${CI_COMMIT_REF_NAME}\",
        \"target_branch\": \"${TARGET_BRANCH}\",
        \"remove_source_branch\": true,
        \"title\": \"WIP: ${CI_COMMIT_REF_NAME}\",
        \"description\": \"${MR_DESCRIPTION}\",
        \"labels\": ${LABELS}
    }";
#    echo $BODY|jq '.'

    curl -sS -X POST "${GITLAB_API_URL}${CI_PROJECT_ID}/merge_requests" \
        --header "PRIVATE-TOKEN:${PRIVATE_TOKEN}" \
        --header "Content-Type: application/json" \
        --data "${BODY}";
    echo "Opened a new merge request: WIP: ${CI_COMMIT_REF_NAME}";
else
    echo "No new merge request opened";
fi
