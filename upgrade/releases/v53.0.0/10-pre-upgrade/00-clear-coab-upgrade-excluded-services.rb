#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'uri'
require_relative '../../../lib/upgrade'

SECRETS = 'secrets'.freeze
UPGRADE = 'upgrade'.freeze
EXCLUDED_SERVICES = 'exclude-service-prefixes'.freeze
EXCLUDED_SERVICES_DESCRIPTION = 'exclude-service-prefixes-description'.freeze
EXCLUDED_MODELS = 'exclude-models'.freeze
EXCLUDED_MODELS_DESCRIPTION = 'exclude-models-description'.freeze

def clear_excluded_services(secrets_dir)
  model_migration_pipeline_deployment = Upgrade::Deployment.new("model-migration-pipeline","coab-depls",secrets_dir)
  model_migration_pipeline_yaml = model_migration_pipeline_deployment.load_local_secrets

  secrets_level = model_migration_pipeline_yaml.dig(SECRETS) || {}
  if secrets_level.empty?
    model_migration_pipeline_yaml[SECRETS] = secrets_level
  end

  upgrade_level = secrets_level.dig(UPGRADE) || {}
  if upgrade_level.empty?
    secrets_level[UPGRADE] = upgrade_level
  end

  puts "Resetting COAB auto-migration excluded services (previous value: #{upgrade_level.dig(EXCLUDED_SERVICES)})"
  upgrade_level[EXCLUDED_SERVICES_DESCRIPTION] = "Array of excluded service prefixes. One per entry and first letter only. Sample ['y', 'x']"
  upgrade_level[EXCLUDED_SERVICES] = []

  puts "Resetting COAB auto-migration excluded models (previous value: #{upgrade_level.dig(EXCLUDED_MODELS)})"
  upgrade_level[EXCLUDED_MODELS_DESCRIPTION] = "Array of excluded models. One per entry and full name. Sample ['02-redis-extended' ]"
  upgrade_level[EXCLUDED_MODELS] = []

  puts model_migration_pipeline_yaml
  model_migration_pipeline_deployment.update_local_secrets(model_migration_pipeline_yaml)
end

config_path = ARGV[0]
puts config_path

clear_excluded_services(config_path)