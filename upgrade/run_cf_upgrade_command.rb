#!/usr/bin/env ruby
require 'open3'
require_relative 'lib/paas_templates_upgrader'

def display_available_versions
  base_dir = File.dirname(__FILE__)
  versions_dir = File.join(base_dir, 'releases','v*')
  Dir[versions_dir].map { |path| File.basename(path)[1..-1] }.sort
end


options = PaasTemplatesUpgrader::CommandLineParser.new.parse
PaasTemplatesUpgrader
version = options[:version]
step = options[:step]
iaas_type = options[:iaas_type]
config_dir = options[:config_path]
filter = options[:filter]

full_version = 'v' + version
file_selection_filter = if filter.empty?
                          'CF-*'
                        else
                          filter
                        end
version_dir = File.join(File.dirname(__FILE__), 'releases', full_version)
raise "invalid version: <#{version}> does not exist - Available versions: #{display_available_versions}" unless Dir.exist?(version_dir)
upgrade_dir = File.join(version_dir, step.path)

COA_CONFIG_DIR = File.join(config_dir, "coa", "config")

begin
  upgrade_scripts = PaasTemplatesUpgrader.select_upgrade_files(upgrade_dir, file_selection_filter, iaas_type)
rescue PaasTemplatesUpgrader::NoUpgradeScriptsDetected => e
  puts e.message
  exit 0
end

PaasTemplatesUpgrader.process_upgrade_files(config_dir, upgrade_scripts)