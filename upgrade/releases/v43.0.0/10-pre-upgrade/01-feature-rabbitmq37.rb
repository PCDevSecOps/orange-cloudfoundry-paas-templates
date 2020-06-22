#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_rabbitmq_operators(secrets_dir)
  puts "Processing #{__method__.to_s}"
  rabbit_yaml = <<~YAML
                meta:
                  rabbitmq-broker:
                    rabbitmq:
                      operator_set_policy:
                        policy_name: "operator_set_policy"
                        policy_definition: "{\\"ha-mode\\":\\"exactly\\",\\"ha-params\\":2,\\"ha-sync-mode\\":\\"automatic\\",\\"max-length\\":700000}"
                        policy_priority: 200
                      max-connections-per-vhost: 2000
  YAML
  rabbit_secrets_dir = File.join(secrets_dir, 'ops-depls', 'cf-rabbit37', 'secrets')
  rabbit_meta_filename = File.join(rabbit_secrets_dir, 'meta.yml')

  if File.exist?(rabbit_meta_filename)
    puts "WARNING: skipping #{rabbit_meta_filename}, file already exists"
  else
    puts "creating #{rabbit_meta_filename}"
    FileUtils.mkdir_p(rabbit_secrets_dir)
    File.open(rabbit_meta_filename, 'w') { |file| file.write rabbit_yaml }
  end
end


config_path = ARGV[0]
puts config_path

feature_rabbitmq_operators(config_path)
