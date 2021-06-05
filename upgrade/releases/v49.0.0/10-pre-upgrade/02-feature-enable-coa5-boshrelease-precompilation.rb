#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../lib/upgrade'

def feature_enable_coa_precompilation(config_path)
  puts "Processing #{__method__.to_s}"
  update_required = false
  private_config = Upgrade::PrivateConfig.new(config_path)
  private_config_content = private_config.load
  puts private_config_content
  if private_config_content.has_key?('precompile-mode')
    if private_config_content['precompile-mode']
      puts "> INFO: Skipping, COA precompile already enabled"
    else
      puts "> INFO: Enabling COA precompile mode"
      private_config_content['precompile-mode'] = true
      update_required = true
    end
  else
    puts "> INFO: Precompile mode not set, but it is enabled by default on COA: #{private_config_content['precompile-mode']}"
  end
  private_config.write(private_config_content) if update_required
end


config_path = ARGV[0]
puts config_path

feature_enable_coa_precompilation(config_path)