#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_fix_cf_rabbit37_shared(secrets_dir)
  puts "Processing #{__method__.to_s}"
  cf_rabbit37_secrets_dir = File.join(secrets_dir, 'ops-depls', 'cf-rabbit37', 'secrets')
  cf_rabbit37_meta_filename = File.join(cf_rabbit37_secrets_dir, 'meta.yml')
  if File.exist?(cf_rabbit37_meta_filename)
    puts "cleaning #{cf_rabbit37_meta_filename}"
    cf_rabbit37_meta = YAML.load_file(cf_rabbit37_meta_filename)
    operator_set_policy = cf_rabbit37_meta.dig("meta","rabbitmq-broker","rabbitmq","operator_set_policy")
    operator_set_policy.store("policy_definition", "{\"max-length\":500000}")
    File.open(cf_rabbit37_meta_filename, 'w') { |file| file.write YAML.dump cf_rabbit37_meta }
  else
    puts "WARNING: skipping #{cf_rabbit37_meta_filename}, file doesn't exist"
  end
end

config_path = ARGV[0]
puts config_path

feature_fix_cf_rabbit37_shared(config_path)
