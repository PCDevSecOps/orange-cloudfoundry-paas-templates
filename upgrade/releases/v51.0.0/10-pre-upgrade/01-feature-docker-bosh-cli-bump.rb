#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def migrate_to_properties_in_instance_groups(docker_bosh_cli_secrets)
  old_properties = docker_bosh_cli_secrets.delete('properties')
  if old_properties
    puts "migrating to new secrets format"
    container_properties = old_properties['containers']
    user_add_properties = old_properties['users']
    docker_cli_job = [
        {'name' => 'containers',
         'properties' => {'containers' => container_properties}},
        {'name' => 'user_add',
         'properties' => {'users' => user_add_properties}}
    ]
    docker_bosh_cli_secrets['instance_groups'] = [{'name' => 'docker-cli', 'jobs' => docker_cli_job}]
  end
end

def feature_bosh_cli_bump(config_dir)
  puts "Processing #{__method__.to_s}"
  docker_bosh_cli_version="3.0.1"

  docker_bosh_cli = Upgrade::Deployment.new('docker-bosh-cli','micro-depls', config_dir)
  docker_bosh_cli_secrets  = docker_bosh_cli.load_local_secrets

  migrate_to_properties_in_instance_groups(docker_bosh_cli_secrets)

  instance_groups = docker_bosh_cli_secrets.dig('instance_groups')
  docker_cli_object = instance_groups.select {|item| item['name'] == 'docker-cli'}.first
  containers_object = docker_cli_object['jobs'].select {|item| item['name'] == 'containers'}.first
  containers_level = containers_object.dig('properties', 'containers')
  puts "updating #{docker_bosh_cli.local_secrets_filename} with new version #{docker_bosh_cli_version}"
  raise "Invalid secrets: missing properties, cannot find properties->containers" if containers_level.nil?
  containers_level.each do |datacontainer|
    image = datacontainer['image']
    image_parsed = image.split(':')
    image_name = image_parsed[0]
    old_image_version = image_parsed[1]
    datacontainer['image']= "#{image_name}:#{docker_bosh_cli_version}"
  end
  docker_bosh_cli.update_local_secrets(docker_bosh_cli_secrets)
end

config_path = ARGV[0]
puts config_path

feature_bosh_cli_bump(config_path)



