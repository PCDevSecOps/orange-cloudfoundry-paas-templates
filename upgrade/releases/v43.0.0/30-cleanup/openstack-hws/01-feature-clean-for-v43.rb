#!/usr/bin/env ruby
require 'fileutils'

config_path = ARGV[0]
puts config_path
deployments = %w[
  micro-depls/concourse-micro
  micro-depls/credhub-concourse-seeder
  ops-depls/admin-ui
  ops-depls/cf-apps-deployments/app-with-metrics-influxdb
  ops-depls/cf-apps-deployments/cf-webui
]

deployments.each do |deployment|
  deployment_path = File.join(config_path, deployment)
  puts "Processing #{deployment} at #{deployment_path}"
  if Dir.exist?(deployment_path)
    puts "Removing #{deployment_path}"
    FileUtils.rm_rf deployment_path
  end
end
