#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def update(key, value, level)
  current_value = level.dig(key)
  if current_value.nil?
    puts "WARNING: #{key} is missing, it should be provided !!!"
    level[key] = value
    update_required = true
  else
    puts "skipping, #{key} already defined"
  end
  update_required
end

def feature_cf_activation(secrets_dir)
  puts "Processing #{__method__.to_s}"
  puts "Processing shared secrets update"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  secrets = shared_secrets_yaml.dig('secrets') || {}
  update_required = false
  default_value = Upgrade::USER_VALUE_REQUIRED

  cloudfoundry = secrets.dig('cloudfoundry') || {}
  cf_keys = %w[admin_password ccdb_password cf_ssh_port diegodb_password firehose_password nats_password uaadb_password]
  cf_keys.each do |name|
    current_update = update(name, default_value, cloudfoundry)
    secrets['cloudfoundry'] = cloudfoundry if current_update
    update_required ||= current_update
  end

  intranet_interco_1 = secrets.dig("intranet_interco_1") || {}
  current_update = update('cf_org', 'orange', intranet_interco_1)
  secrets['intranet_interco_1'] = intranet_interco_1 if current_update
  update_required ||= current_update

  shared_secrets.write(shared_secrets_yaml) if update_required

  puts "Processing master-depls/cf deployment secrets"
  cf_depl = Upgrade::Deployment.new('cf', 'master-depls', secrets_dir)
  cf_depl.create_local_meta
  meta_cf = cf_depl.load_local_meta
  meta_level = meta_cf.dig('meta') || {}
  cf_level = meta_level.dig('cf') || {}
  update('api_instances_count', 4, cf_level)
  update('gorouter_instances_count', 2, cf_level)
  update('diego_cell_instances_count', 4, cf_level)
  update('doppler_instances_count', 2, cf_level)
  meta_level['cf'] = cf_level
  meta_cf['meta'] = meta_level
  cf_depl.update_local_meta(meta_cf)

  puts "Processing master-depls/bosh-coab deployment meta"
  bosh_coab_depl = Upgrade::Deployment.new('bosh-coab', 'master-depls', secrets_dir)
  bosh_coab_depl.create_local_meta
  bosh_coab_secrets = bosh_coab_depl.load_local_meta
  secrets_level = bosh_coab_secrets.dig('secrets') || {}
  repair_level = secrets_level.dig('repair') || {}
  update('variables', '', repair_level)
  update('deployments', '', repair_level)
  secrets_level['repair'] = repair_level
  bosh_coab_secrets['secrets'] = secrets_level
  bosh_coab_depl.update_local_meta(bosh_coab_secrets)
end

def setup_broker_passwords(config_path)
  puts "Processing #{__method__.to_s}"
  puts "Processing broker passwords update"
  shared_secrets = Upgrade::SharedSecrets.new(config_path)
  shared_secrets_yaml = shared_secrets.load

  secrets = shared_secrets_yaml.dig('secrets') || {}
  update_required = false
  default_value = Upgrade::USER_VALUE_REQUIRED

  cloudfoundry = secrets.dig('cloudfoundry') || {}
  service_brokers = cloudfoundry.dig('service_brokers') || {}
  broker_name = %w[o-intranet-proxy-access coa-cassandra-broker coa-cf-mysql-broker coa-mongodb-broker coa-noop-broker coa-redis-broker coa-cf-rabbit-broker]
  broker_name.each do |name|
    broker = service_brokers.dig(name) || {}
    current_update = update('password', default_value, broker)
    service_brokers[name] = broker if current_update
    update_required ||= current_update
  end
  cloudfoundry['service_brokers'] = service_brokers

  shared_secrets.write(shared_secrets_yaml) if update_required
end

config_path = ARGV[0]
puts config_path

feature_cf_activation(config_path)
setup_broker_passwords(config_path)