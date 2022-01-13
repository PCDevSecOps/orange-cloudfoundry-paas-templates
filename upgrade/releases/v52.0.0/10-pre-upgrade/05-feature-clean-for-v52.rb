#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'
PROXY = 'proxy'

def feature_clean(secrets_dir)
  update_required = false
  shared_secrets = Upgrade::SharedSecrets.new(secrets_dir)
  shared_secrets_yaml = shared_secrets.load

  proxy = shared_secrets_yaml.dig(SECRETS, PROXY)
  return unless proxy

  %w(internet_host internet_port intranet_host intranet_port).each { |key| proxy.delete(key); update_required = true }

  shared_secrets_yaml[SECRETS][PROXY] = proxy


  puts "proxy.size: #{proxy.size}"
  if proxy.empty?
    puts "Cleanup [#{SECRETS}.#{PROXY}]"
    shared_secrets_yaml[SECRETS].delete(PROXY)
    update_required = true
  else
    puts "[#{SECRETS}.#{PROXY}] still contains values"
  end

  shared_secrets.write(shared_secrets_yaml) if update_required
end


config_path = ARGV[0]
puts config_path

feature_clean(config_path)