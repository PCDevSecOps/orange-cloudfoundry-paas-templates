
# Set of feature to ease creation of upgrade scripts for Paas-templates and config repository
module PaasTemplatesUpgrader
  require 'yaml'
  require 'fileutils'
  require 'open3'

  require_relative 'paas_templates_upgrader/command_line_parser'

# class to handle error raised when a missing required parameter is detected
  class NoUpgradeScriptsDetected < RuntimeError; end

  def self.process_upgrade_files(config_dir, upgrade_scripts)
    config_dir_as_param = File.absolute_path(config_dir)
    overall_status_success = true
    error_message = 'Failed to execute: \n'
    puts "Detected upgrade scripts: #{upgrade_scripts}"
    upgrade_scripts&.sort.each do |upgrade_script|
      puts "Executing #{upgrade_script.green}: "
      cmd_line = "#{upgrade_script} #{config_dir_as_param}"
      Open3.popen2e(cmd_line.to_s) do |_, stdout_stderr, wait_thr|
        while line=stdout_stderr.gets
          puts(line)
        end
        status = wait_thr.value
        unless status.success?
          error_message += " - #{upgrade_script}\n"
        end
        overall_status_success &= status.success?
      end
      puts '*' * 20
    end
    raise error_message unless overall_status_success
  end


  def self.select_upgrade_files(upgrade_dir, file_selection_filter, iaas_type)
    puts "Selecting file matching <#{file_selection_filter}>"
    shared_upgrade_scripts = Dir[File.join(upgrade_dir, file_selection_filter)]


    iaas_specific_script_dir = File.join(upgrade_dir, iaas_type)

    iaas_specific_scripts = if Dir.exist?(iaas_specific_script_dir)
                              puts "Iaas specific directory detected: #{iaas_specific_script_dir}"
                              Dir[File.join(iaas_specific_script_dir, file_selection_filter)]
                            else
                              []
                            end

    upgrade_scripts = shared_upgrade_scripts + iaas_specific_scripts
    if upgrade_scripts.empty?
      warning_message = "WARNING - no upgrade script detected at #{upgrade_dir}, nor at #{iaas_specific_script_dir} matching #{file_selection_filter}"
      raise NoUpgradeScriptsDetected, warning_message
    end
    upgrade_scripts
  end
end

class String
  def black
    "\e[30m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
  end
end
