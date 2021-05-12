#!/bin/bash
set -o errexit #needed as not inherited from invoked scripts

# shellcheck source=common-lib.bash
source ${BASE_TEMPLATE_DIR}/common-lib.bash
set_verbose_mode_as_requested_in_secrets

# Override coab-depls/common-broker-scripts defaults
#REPO_NAME="${REPO_NAME:-cf-ops-automation-broker}"
export REPO_NAME="sec-group-broker-filter"
#JAR_ARTEFACT_BASE_NAME=${JAR_ARTEFACT_BASE_NAME:-cf-ops-automation-bosh-broker}
export JAR_ARTEFACT_BASE_NAME="service-broker-filter-securitygroups"
#JAR_ARTEFACT_NAME=${JAR_ARTEFACT_NAME:-${JAR_ARTEFACT_BASE_NAME}.jar}
export RELEASE_VERSION="2.5.0.RELEASE"
#RELEASE_VERSION=${RELEASE_VERSION:-0.29.0}

#Download jar
${BASE_TEMPLATE_DIR}/common-pre-cf-push.sh

cf create-space "$CF_SPACE" -o "$CF_ORG"
cf target -s "$CF_SPACE" -o "$CF_ORG"

#enable gitlab https access
cf bind-security-group ops "$CF_ORG" --space  "$CF_SPACE"

# COA pushes the