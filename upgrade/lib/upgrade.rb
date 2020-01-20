module Upgrade
  require 'yaml'
  require_relative './upgrade/local_file'
  require_relative './upgrade/shared_secrets'
  require_relative './upgrade/deployment'
  require_relative './upgrade/cf_app_deployment'
  require_relative './upgrade/root_deployment'
  require_relative './upgrade/meta_inf'
  require_relative './upgrade/base_activation_enforcer'
  require_relative './upgrade/ci_deployment_overview'
  require_relative './upgrade/concourse_env'
  require_relative './upgrade/coa_config'
  require_relative './upgrade/coa'
  require_relative './upgrade/credhub_cli'
  require_relative './upgrade/ci_deployments'

  USER_VALUE_REQUIRED = '==> FIXME - REQUIRED - Please PROVIDE a value <=='
end
