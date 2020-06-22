#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def destroy_shield_deployment(config_path)
  dep = Upgrade::Deployment.new("shield", "master-depls", config_path)
  dep.destroy
end

config_path = ARGV[0]
puts config_path

destroy_shield_deployment(config_path)
