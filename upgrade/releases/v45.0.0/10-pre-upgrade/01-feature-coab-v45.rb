#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_coab_v45(config_dir)
  puts "Processing #{__method__.to_s}"
  cassandra_broker = Upgrade::CfAppDeployment.new('coa-cassandra-broker', 'coab-depls', config_dir)
  cassandra_broker_secrets  = cassandra_broker.load_local_secrets
  secrets = cassandra_broker_secrets.dig("secrets") || {}
  secrets.store("smoke_test_service_plan", "small")
  cassandra_broker.update_local_secrets(cassandra_broker_secrets)

  mysql_broker = Upgrade::CfAppDeployment.new('coa-cf-mysql-broker', 'coab-depls', config_dir)
  mysql_broker_secrets  = mysql_broker.load_local_secrets
  secrets = mysql_broker_secrets.dig("secrets") || {}
  secrets.store("smoke_test_service_plan", "medium")
  mysql_broker.update_local_secrets(mysql_broker_secrets)

  mongodb_broker = Upgrade::CfAppDeployment.new('coa-mongodb-broker', 'coab-depls', config_dir)
  mongodb_broker_secrets  = mongodb_broker.load_local_secrets
  secrets = mongodb_broker_secrets.dig("secrets") || {}
  secrets.store("smoke_test_service_plan", "small")
  mongodb_broker.update_local_secrets(mongodb_broker_secrets)

  redis_broker = Upgrade::CfAppDeployment.new('coa-redis-broker', 'coab-depls', config_dir)
  redis_broker_secrets  = redis_broker.load_local_secrets
  secrets = redis_broker_secrets.dig("secrets") || {}
  secrets.store("smoke_test_service_plan", "small")
  redis_broker.update_local_secrets(redis_broker_secrets)

end

config_path = ARGV[0]
puts config_path

feature_coab_v45(config_path)



