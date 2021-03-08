#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_credhub_seeder_shared_secrets_triggering_activation(secrets_dir)
  puts "Processing #{__method__.to_s}"

  credhub_seeder_depl = Upgrade::Deployment.new('credhub-seeder', 'micro-depls', secrets_dir)
  puts "Processing deployment #{credhub_seeder_depl.to_s}"

  credhub_seeder_depl.create_local_secrets
end


config_path = ARGV[0]
feature_credhub_seeder_shared_secrets_triggering_activation(config_path)



