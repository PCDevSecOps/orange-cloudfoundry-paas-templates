#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_smtp(secrets_dir)
  puts "Processing #{__method__.to_s}"
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  smtp_host = shared_secrets_yaml.dig('secrets','smtp','host')
  if smtp_host
    puts "Removing secrets smtp host"
    shared_secrets_yaml["secrets"]['smtp'].delete("host")
    update_required = true
  end

  smtp_port = shared_secrets_yaml.dig('secrets','smtp','port')
  if smtp_port
    puts "Removing secrets smtp port"
    shared_secrets_yaml["secrets"]['smtp'].delete("port")
    update_required = true
  end

  #effective write
  shared_secrets.write(shared_secrets_yaml) if update_required
end

def cleanup_intranet_interco(secrets_dir)
  intranet_interco = Upgrade::Deployment.new("intranet-interco-relay",'master-depls',secrets_dir)
  intranet_interco.delete_local_secrets
end

config_path = ARGV[0]
puts config_path

feature_smtp(config_path)
