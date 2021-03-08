#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_set_vpn_r3_threshold(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  max_upload_speed_kbps = shared_secrets_yaml.dig('secrets','multi_region','region_3','max_upload_speed_kbps')
  if ! max_upload_speed_kbps
    puts "Set secrets max_upload_speed_kbps"
    shared_secrets_yaml["secrets"]['multi_region']['region_3']['max_upload_speed_kbps']=100000
    update_required = true
  end

  max_download_speed_kbps = shared_secrets_yaml.dig('secrets','multi_region','region_3','max_download_speed_kbps')
  if ! max_download_speed_kbps
    puts "Set secrets max_download_speed_kbps"
    shared_secrets_yaml["secrets"]['multi_region']['region_3']['max_download_speed_kbps']=100000
    update_required = true
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end

config_path = ARGV[0]
puts config_path

feature_set_vpn_r3_threshold(config_path)