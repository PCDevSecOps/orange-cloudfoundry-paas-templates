#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_add_mongodb_extended_to_coab_pipeline_migration(secrets_dir)
  puts "Processing #{__method__.to_s}"
  coab_secrets_yaml = <<~YAML
                secrets:
                  paas-templates-reference-branch: reference
                  cf-mysql-service-instances-branch: feature-coabdepls-cf-mysql-serviceinstances
                  cf-mysql-extended-service-instances-branch: feature-coabdepls-cf-mysql-extended-serviceinstances
                  noop-service-instances-branch: feature-coabdepls-noop-serviceinstances
                  cf-rabbit-service-instances-branch: feature-coabdepls-cf-rabbit-serviceinstances
                  cf-rabbit-extended-service-instances-branch: feature-coabdepls-cf-rabbit-extended-serviceinstances
                  mongodb-service-instances-branch: feature-coabdepls-mongodb-serviceinstances
                  mongodb-extended-service-instances-branch: feature-coabdepls-mongodb-extended-serviceinstances
                  redis-service-instances-branch: feature-coabdepls-redis-serviceinstances
                  redis-extended-service-instances-branch: feature-coabdepls-redis-extended-serviceinstances
YAML
  coab_secrets_dir = File.join(secrets_dir, 'coab-depls', 'model-migration-pipeline', 'secrets')
  coab_secrets_filename = File.join(coab_secrets_dir, 'secrets.yml')

  if File.exist?(coab_secrets_filename)
    puts "WARNING: overriding #{coab_secrets_filename} because file already exists"
    File.open(coab_secrets_filename, 'w') { |file| file.write coab_secrets_yaml }
  else
    puts "creating #{coab_secrets_filename}"
    FileUtils.mkdir_p(coab_secrets_dir)
    File.open(coab_secrets_filename, 'w') { |file| file.write coab_secrets_yaml }
  end
end

config_path = ARGV[0]
puts config_path

feature_add_mongodb_extended_to_coab_pipeline_migration(config_path)
