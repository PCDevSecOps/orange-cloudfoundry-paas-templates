#!/bin/bash

echo "source $0 to set up interactive debug env and then reexecute individual/last failed svcat functions in the current shell"

export DONT_EXIT_SHELL_ON_ERRORS=true
source template-resource/coab-depls/common-broker-scripts/common-lib.bash
source template-resource/coab-depls/common-broker-scripts/svcat-functions.bash
update_http_no_proxy_with_k8s_cluster_if_exists

# don't exit the current shell on 1st error
set +e
#avoid that display_diagnostics_on_err exits the current shel
export DEBUG_MODE=true

#test_svcat_service_provisionning service-sandbox-coa-noop-smoke-tests-1623073612 noop-ondemand-smoke-test1623073614-8 noop-ondemand default
