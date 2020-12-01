require 'optparse'

module PaasTemplatesUpgrader
  #Manage upgrade lifecycle
  class Lifecycle
    attr_accessor :name

    def initialize(name)
      self.name = name
    end

    def path
      case name
      when :premerge
        "05-pre-merge"
      when :preupgrade
        "10-pre-upgrade"
      when :postupgrade
        "20-post-upgrade"
      when :cleanup
        "30-cleanup"
      else
        nil
      end
    end

    def to_s
      @name
    end

  end

  # Common command line parsing for upgrade scripts
  class CommandLineParser
    OPTIONS = {
      dump_output: true,
      config_path: '',
      templates_path: '.',
      version: '',
      step: Lifecycle.new(:preupgrade),
      filter: '',
      iaas_type: 'openstack-hws'
    }.freeze

    def initialize(options = OPTIONS.dup)
      @options = options
    end

    IAAS_TYPES = %w(vsphere openstack-hws)
    def parse
      options = @options
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Incomplete/wrong parameter(s): #{opts.default_argv}.\n Usage: ./#{opts.program_name} <options>"

        opts.on( "--iaas [TYPE]", IAAS_TYPES , "specific iaas type to process #{IAAS_TYPES}. Default: #{options[:iaas_type]}") do |input|
          options[:iaas_type] = input
        end

        opts.on( "--step [TYPE]", [:premerge, :preupgrade, :postupgrade, :cleanup] , "upgrade steps to process [premerge|preupgrade|postupgrade|cleanup]. Default: #{options[:step].to_s}") do |s_symbol|
          options[:step] = Lifecycle.new(s_symbol)
        end

        opts.on('-c', '--config PATH', "config-path location (main git directory). Default: #{options[:config_path]}") do |cp_string|
          options[:config_path] = cp_string
        end

        opts.on('-t', '--templates PATH', "paas-templates path location (main git directory). Default: #{options[:templates_path]}") do |tp_string|
          options[:templates_path] = tp_string
        end

        opts.on('-v', '--version VERSION', "version to upgrade to. Default: #{options[:version]}") do |v_string|
          options[:version] = v_string
        end

        opts.on('--[no-]dump', 'Dump generated file on standard output') do |dump|
          options[:dump_output] = dump
        end

        opts.on('-f', '--filter PATTERN', "restrict script execution to matching pattern.") do |f_string|
          options[:filter] = f_string
        end
      end
      opt_parser.parse!
      @options = options
    end
  end
end
