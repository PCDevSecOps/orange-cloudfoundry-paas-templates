#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_clean_v49(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  cassandra_coab_password = shared_secrets_yaml.dig('secrets','cloudfoundry','service_brokers','coa-cassandra-broker','password')
  if cassandra_coab_password
    puts "Removing coab cassandra broker password"
    shared_secrets_yaml["secrets"]['cloudfoundry']['service_brokers'].delete("coa-cassandra-broker")
    update_required = true
  end

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end

config_path = ARGV[0]
puts config_path

feature_clean_v49(config_path)
