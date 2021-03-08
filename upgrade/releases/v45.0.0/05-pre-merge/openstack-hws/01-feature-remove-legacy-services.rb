#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def feature_remove_legacy_services(config_dir)
  puts "Processing #{__method__.to_s}"

  fpv_broker = Upgrade::CfAppDeployment.new('fpv-intranet-sec-broker', 'ops-depls', config_dir)

  fpv_broker_enable_deployment  = if File.exists?(fpv_broker.enable_deployment_filename)
                                    fpv_broker.load_enable_deployment
                                  else
                                    puts "WARNING: #{fpv_broker.enable_deployment_filename} file not found"
                                    {}
                                  end

  cf_app_level = fpv_broker_enable_deployment.dig("cf-app")
  if cf_app_level
    update_required = cf_app_level.delete("fpv-internet-broker")
    update_required = cf_app_level.delete("fpv-internet-sec-broker") || update_required
  end

  fpv_broker.update_enable_deployment(fpv_broker_enable_deployment) if update_required


  dep = Upgrade::Deployment.new("cf-rabbit", "ops-depls", config_dir)
  dep.destroy

end


config_path = ARGV[0]
puts config_path

feature_remove_legacy_services(config_path)
