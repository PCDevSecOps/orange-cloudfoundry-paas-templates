#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def update_coab_cfapps_secrets_file(broker, register_broker = true)
  begin
    puts "Processing #{broker.root_deployment}/#{broker.name}"
    broker_secrets  = broker.load_local_secrets
    secrets = broker_secrets.dig("secrets") || {}
    secrets.store("register_broker_enabled", register_broker)
    broker.update_local_secrets(broker_secrets)
  rescue RuntimeError => re
    puts "Skipping #{broker.root_deployment}/#{broker.name} - Error message: #{re.to_s}"
    puts re.backtrace_locations
  end
end

def feature_coab_tf_unmanaged_service_plans(config_dir)
  puts "Processing #{__method__.to_s}"

  mysql_broker = Upgrade::CfAppDeployment.new('coa-cf-mysql-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(mysql_broker, true)

  mysql_extended_broker = Upgrade::CfAppDeployment.new('coa-cf-mysql-extended-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(mysql_extended_broker, true)

  cf_rabbit_broker = Upgrade::CfAppDeployment.new('coa-cf-rabbit-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(cf_rabbit_broker, true)

  cf_rabbit_extended_broker = Upgrade::CfAppDeployment.new('coa-cf-rabbit-extended-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(cf_rabbit_extended_broker, true)

  mongodb_broker = Upgrade::CfAppDeployment.new('coa-mongodb-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(mongodb_broker, true)

  noop_broker = Upgrade::CfAppDeployment.new('coa-noop-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(noop_broker, true)

  cf_redis_broker = Upgrade::CfAppDeployment.new('coa-redis-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(cf_redis_broker, true)

  cf_redis_extended_broker = Upgrade::CfAppDeployment.new('coa-redis-extended-broker', 'coab-depls', config_dir)
  update_coab_cfapps_secrets_file(cf_redis_extended_broker, true)
end

config_path = ARGV[0]
puts config_path

feature_coab_tf_unmanaged_service_plans(config_path)
