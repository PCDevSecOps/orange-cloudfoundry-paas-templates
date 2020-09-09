#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

def configure_intranet_proxy_broker_deployment(config_path)
  puts "Processing #{__method__.to_s}"

  fpv_intranet_sec_broker_deployment = Upgrade::CfAppDeployment.new('fpv-intranet-sec-broker','ops-depls', config_path)
  fpv_enable_deployment = fpv_intranet_sec_broker_deployment.load_enable_deployment
  fpv_cf_app_level = fpv_enable_deployment.dig('cf-app') || {}
  %w[intranet-proxy-broker intranet-proxy-sec-broker].each { |app_name| fpv_cf_app_level.delete(app_name) }
  fpv_intranet_sec_broker_deployment.update_enable_deployment(fpv_enable_deployment)

end



config_path = ARGV[0]
puts config_path

configure_intranet_proxy_broker_deployment(config_path)