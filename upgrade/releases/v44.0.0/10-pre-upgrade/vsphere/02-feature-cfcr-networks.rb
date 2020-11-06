#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

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

def feature_cfcr_networks(secrets_dir)
  puts "Processing #{__method__.to_s}"
  puts "Processing shared secrets update"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  secrets = shared_secrets_yaml.dig('secrets') || {}
  update_required = false
  default_value = Upgrade::USER_VALUE_REQUIRED

  networks = secrets.dig('networks') || {}
  networks_keys = %w[tf-net-cf tf-net-cfcr-micro tf-net-cfcr-master tf-net-kubo]
  networks_keys.each do |name|
    current_update = update(name, default_value, networks)
    secrets['networks'] = networks if current_update
      update_required ||= current_update
  end

  shared_secrets.write(shared_secrets_yaml) if update_required

end

config_path = ARGV[0]
puts config_path

feature_cfcr_networks(config_path)