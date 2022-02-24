#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'optparse'
require_relative 'lib/upgrade'

def select_broker_deployments(config_dir)
  coab_deployments = Upgrade::RootDeployment.new('coab-depls',config_dir)
  cf_apps = coab_deployments.cf_apps_deployments
  cf_apps.keep_if {|name| name.end_with?('-broker')}
end

def default_read_only_mode_comment
  <<~STRING
       When set to true, then service instance operations (create/update/delete) are rejected,
       while service binding operations (create/delete) are still accepted.
       This enables to perform maintenance on the underlying COA/git branches infrastructure while not risking
       corrupted COA inventory and not imposing full control plan downtime to coab users.
  STRING
end

def default_read_only_mode_message_comment
  <<~STRING
       User facing message to display when a service instance operation is requested while serviceInstanceReadOnlyMode is set to true
       Useful to tell users about ETA for end of maintenance window.
       when no value is specified (null in yaml), a default COAB message is used instead.
  STRING
end

def add_default_key(broker_name, deployment_level, key, value)
  update_required = false
  read_only_mode_comment = deployment_level.dig(key)
  if read_only_mode_comment
    puts "Key #{key} already set for #{broker_name}"
  else
    puts "Updating key #{key} for #{broker_name}"
    update_required = true
    read_only_mode_comment = value
  end
  deployment_level[key] = read_only_mode_comment

  [update_required, deployment_level]
end

def forced_update(broker_name, deployment_level, key, expected_value)
  update_required = false
  existing_value = deployment_level.dig(key).to_s
  has_key = deployment_level.has_key?(key)

  if has_key && existing_value.to_s == expected_value.to_s
    puts "Key #{key} already exists with expected value set for #{broker_name}. Expecting: #{expected_value}"
  else
    update_required = true
    existing_value = expected_value
  end
  deployment_level[key] = existing_value
  [update_required, deployment_level]
end


def update_broker_secrets(broker_name, config_dir, read_only_mode = false)
  update_required = false
  broker = Upgrade::CfAppDeployment.new(broker_name,'coab-depls', config_dir)

  broker_content  = broker.load_local_secrets || {}
  secrets_level = broker_content.dig('secrets') || {}
  broker_level = secrets_level.dig(broker_name) || {}
  deployment_level = broker_level.dig('deployment') || {}

  last_update_result, deployment_level = add_default_key(broker_name, deployment_level, 'serviceInstanceReadOnlyMode-comment', default_read_only_mode_comment)
  update_required ||= last_update_result

  last_update_result, deployment_level = forced_update(broker_name, deployment_level, 'serviceInstanceReadOnlyMode', read_only_mode)
  update_required ||= last_update_result

  last_update_result, deployment_level = add_default_key(broker_name, deployment_level, 'serviceInstanceReadOnlyMessage-comment', default_read_only_mode_message_comment)
  update_required ||= last_update_result

  if update_required
    broker_content['secrets'][broker_name]['deployment'] = deployment_level
  end

  broker.update_local_secrets(broker_content) if update_required
end


OPTIONS = {
    config_path: '',
    read_only_mode: true
  }.freeze

def parse
  options = OPTIONS.dup
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Incomplete/wrong parameter(s): #{opts.default_argv}.\n Usage: ./#{opts.program_name} <options>"

    opts.on('-c', '--config PATH', "config-path location (main git directory). Default: #{options[:config_path]}") do |cp_string|
      options[:config_path] = cp_string
    end

    opts.on("--read-only-mode [MODE]", %w[true false], "Read only mode to set. Default: #{options[:read_only_mode].to_s}") do |mode|
      options[:read_only_mode] = mode
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end
  opt_parser.parse!
  @options = options
end

options = parse
config_path = options[:config_path]
read_only_mode = options[:read_only_mode]

puts "Config path: #{config_path}"

brokers_names = select_broker_deployments(config_path)
puts brokers_names
brokers_names.each do |name|
  update_broker_secrets(name, config_path, read_only_mode)
end

