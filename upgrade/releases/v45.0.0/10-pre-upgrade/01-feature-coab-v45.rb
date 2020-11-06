#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def update_smoke_test_service_plan(broker, service_plan = 'small')
  begin
    puts "Processing #{broker.root_deployment}/#{broker.name}"

    broker_secrets  = broker.load_local_secrets
    secrets = broker_secrets.dig("secrets") || {}
    secrets.store("smoke_test_service_plan", service_plan)
    broker.update_local_secrets(broker_secrets)
  rescue RuntimeError => re
    puts "Skipping #{broker.root_deployment}/#{broker.name} - Error message: #{re.to_s}"
    puts re.backtrace_locations
  end
end

def feature_coab_v45(config_dir)
  puts "Processing #{__method__.to_s}"
  cassandra_broker = Upgrade::CfAppDeployment.new('coa-cassandra-broker', 'coab-depls', config_dir)
  update_smoke_test_service_plan(cassandra_broker)

  mysql_broker = Upgrade::CfAppDeployment.new('coa-cf-mysql-broker', 'coab-depls', config_dir)
  update_smoke_test_service_plan(mysql_broker, 'medium')

  mongodb_broker = Upgrade::CfAppDeployment.new('coa-mongodb-broker', 'coab-depls', config_dir)
  update_smoke_test_service_plan(mongodb_broker)

  redis_broker = Upgrade::CfAppDeployment.new('coa-redis-broker', 'coab-depls', config_dir)
  update_smoke_test_service_plan(redis_broker)
end

config_path = ARGV[0]
puts config_path

feature_coab_v45(config_path)



