#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def feature_coab_uses_backup_secrets(secrets_dir)
  puts "Processing #{__method__.to_s}"

  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  shield = shared_secrets_yaml.dig("secrets", "shield")
  if shield
    puts "removing shield s3 entries"
    shared_secrets_yaml["secrets"]["shield"].delete("s3_host")
    shared_secrets_yaml["secrets"]["shield"].delete("s3_access_key_id")
    shared_secrets_yaml["secrets"]["shield"].delete("s3_secret_access_key")
    shared_secrets_yaml["secrets"]["shield"].delete("s3_bucket_prefix")
    update_required = true
  end

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_coab_uses_backup_secrets(config_path)
