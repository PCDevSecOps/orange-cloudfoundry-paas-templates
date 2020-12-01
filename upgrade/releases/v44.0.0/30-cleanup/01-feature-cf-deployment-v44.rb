#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def cleanup_cf_rps(config_path)
  cf_rps = Upgrade::Deployment.new("cf-rps", "master-depls", config_path)
  cf_rps.destroy
end

config_path = ARGV[0]
puts config_path

cleanup_cf_rps(config_path)
