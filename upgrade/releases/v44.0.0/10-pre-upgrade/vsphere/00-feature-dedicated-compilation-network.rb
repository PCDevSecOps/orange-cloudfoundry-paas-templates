#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def feature_dedicated_compilation_network(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  compilation_dedicated = shared_secrets_yaml.dig("secrets", "networks","compilation-dedicated")
  if compilation_dedicated.nil?
    puts "Processing compilation-dedicated"
    compilation_dedicated = shared_secrets_yaml.dig("secrets", "networks") || {}
    compilation_dedicated.store("compilation-dedicated", Upgrade::USER_VALUE_REQUIRED)
    update_required = true
  else
    puts "compilation-dedicated already processed"
  end

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_dedicated_compilation_network(config_path)
