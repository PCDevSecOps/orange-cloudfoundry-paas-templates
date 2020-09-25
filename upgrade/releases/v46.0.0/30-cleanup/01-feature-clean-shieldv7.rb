#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_clean_shieldv7(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  shield = shared_secrets_yaml.dig("secrets")
  if shield
    puts "Removing secrets.shield"
    shared_secrets_yaml["secrets"].delete("shield")
    update_required = true
  end

  local_s3 = shared_secrets_yaml.dig("secrets", "backup")
  if local_s3
    puts "Removing secrets.backup.local_s3"
    shared_secrets_yaml["secrets"]["backup"].delete("local_s3")
    update_required = true
  end

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_clean_shieldv7(config_path)
