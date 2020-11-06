#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def feature_refactor_backup_secrets(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  #read existing values
  s3_host = shared_secrets_yaml.dig("secrets","shield","scality_host")
  s3_access_key_id = shared_secrets_yaml.dig("secrets","shield","scality_access_key_id")
  s3_secret_access_key = shared_secrets_yaml.dig("secrets","shield","scality_secret_access_key")
  s3_bucket_prefix = shared_secrets_yaml.dig("secrets","shield","scality_bucket_prefix")

  #migrate backup key
  backup = shared_secrets_yaml.dig("secrets", "backup") || {}
  unless s3_bucket_prefix.nil?
    puts "Migrating bucket_prefix"
    backup.store("bucket_prefix", s3_bucket_prefix)
    shared_secrets_yaml["secrets"]["backup"] = backup
    update_required = true
  else
    puts "scality_bucket_prefix already migrated"
  end

  #migrate local_s3 key
  local_s3 = shared_secrets_yaml.dig("secrets", "backup", "local_s3") || {}

  local_s3_host = shared_secrets_yaml.dig("secrets", "backup", "local_s3", "host")
  if local_s3_host.nil?
    puts "Processing local_s3_host"
    local_s3.store("host", Upgrade::USER_VALUE_REQUIRED)
    shared_secrets_yaml["secrets"]["backup"]["local_s3"] = local_s3
    update_required = true
  else
    puts "local_s3_host already processed"
  end

  local_s3_access_key_id = shared_secrets_yaml.dig("secrets", "backup", "local_s3", "access_key_id")
  if local_s3_access_key_id.nil?
    puts "Processing local_s3_access_key_id"
    local_s3.store("access_key_id", Upgrade::USER_VALUE_REQUIRED)
    shared_secrets_yaml["secrets"]["backup"]["local_s3"] = local_s3
    update_required = true
  else
    puts "local_s3_access_key_id already processed"
  end

  local_s3_secret_access_key = shared_secrets_yaml.dig("secrets", "backup", "local_s3", "secret_access_key")
  if local_s3_secret_access_key.nil?
    puts "Processing local_s3_secret_access_key"
    local_s3.store("secret_access_key", Upgrade::USER_VALUE_REQUIRED)
    shared_secrets_yaml["secrets"]["backup"]["local_s3"] = local_s3
    update_required = true
  else
    puts "local_s3_secret_access_key already processed"
  end

  #migrate remote_s3 key
  remote_s3 = shared_secrets_yaml.dig("secrets", "backup", "remote_s3") || {}
  unless s3_host.nil?
    puts "Migrating s3_host"
    remote_s3.store("host", s3_host)
    update_required = true
  else
    puts "scality_host already migrated"
  end

  unless s3_access_key_id.nil?
    puts "Migrating s3_access_key_id"
    remote_s3.store("access_key_id", s3_access_key_id)
    update_required = true
  else
    puts "scality_access_key_id already migrated"
  end

  unless s3_secret_access_key.nil?
    puts "Migrating s3_secret_access_key"
    remote_s3.store("secret_access_key", s3_secret_access_key)
    update_required = true
  else
    puts "scality_secret_access_key already migrated"
  end
  shared_secrets_yaml["secrets"]["backup"]["remote_s3"] = remote_s3

  remote_s3.store("signature_version", 4)

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_refactor_backup_secrets(config_path)
