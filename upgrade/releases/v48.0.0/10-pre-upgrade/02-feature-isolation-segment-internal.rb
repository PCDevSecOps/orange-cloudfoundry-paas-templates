#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_isolation_segment_internal_operators(secrets_dir,deploy)
  puts "Processing #{__method__.to_s}"
  yaml = <<~YAML
                meta:
                  isolation_segment:
                    gorouter_instances_count: 2
                    diego_cell_instances_count: 2
  YAML
  secrets_dir = File.join(secrets_dir, deploy, 'isolation-segment-internal', 'secrets')
  meta_filename = File.join(secrets_dir, 'meta.yml')

  if File.exist?(meta_filename)
    puts "WARNING: skipping #{meta_filename}, file already exists"
  else
    puts "creating #{meta_filename}"
    FileUtils.mkdir_p(secrets_dir)
    File.open(meta_filename, 'w') { |file| file.write yaml }
  end
end


config_path = ARGV[0]
puts config_path

feature_isolation_segment_internal_operators(config_path,'master-depls')
