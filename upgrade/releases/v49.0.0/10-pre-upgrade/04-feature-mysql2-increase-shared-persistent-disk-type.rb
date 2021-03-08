#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def feature_mysql2_increase_shared_persistent_disk_type(secrets_dir)
  puts "Processing #{__method__.to_s}"
  meta_yaml = <<~YAML
                meta:
YAML

  cf_mysql_secrets_dir = File.join(secrets_dir, 'ops-depls', 'cloudfoundry-mysql', 'secrets')
  cf_mysql_meta_filename = File.join(cf_mysql_secrets_dir, 'meta.yml')
  if File.exist?(cf_mysql_meta_filename)
    puts "WARNING: skipping #{cf_mysql_meta_filename} because file already exists"
  else
    puts "creating #{cf_mysql_meta_filename}"
    FileUtils.mkdir_p(cf_mysql_secrets_dir)
    File.open(cf_mysql_meta_filename, 'w') { |file| file.write meta_yaml }
  end

  cf_mysql_osb_secrets_dir = File.join(secrets_dir, 'ops-depls', 'cloudfoundry-mysql-osb', 'secrets')
  cf_mysql_meta_filename = File.join(cf_mysql_osb_secrets_dir, 'meta.yml')
  if File.exist?(cf_mysql_meta_filename)
    puts "WARNING: skipping #{cf_mysql_meta_filename} because file already exists"
  else
    puts "creating #{cf_mysql_meta_filename}"
    FileUtils.mkdir_p(cf_mysql_osb_secrets_dir)
    File.open(cf_mysql_meta_filename, 'w') { |file| file.write meta_yaml }
  end

end

config_path = ARGV[0]
puts config_path

feature_mysql2_increase_shared_persistent_disk_type(config_path)
