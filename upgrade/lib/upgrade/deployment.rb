module Upgrade
  class Deployment < LocalFile
    attr_reader :root_deployment
    ENABLE_DEPLOYMENT_FILENAME = 'enable-deployment.yml'

    def initialize(name, root_deployment, config_base_dir)
      @name = name
      @root_deployment = root_deployment
      @config_base_dir = config_base_dir
    end

    def deployment_config_path
      File.join @config_base_dir, @root_deployment, @name
    end

    def enable_deployment_filename
      File.join(deployment_config_path,ENABLE_DEPLOYMENT_FILENAME)
    end

    def enable
      FileUtils.mkdir_p(deployment_config_path)
      FileUtils.touch(enable_deployment_filename, verbose:true) unless File.exist? enable_deployment_filename
    end

    def disable
      FileUtils.rm(enable_deployment_filename, verbose:true ) if File.exist? enable_deployment_filename
    end

    def destroy
      FileUtils.rm_rf(deployment_config_path, verbose:true ) if File.exist? deployment_config_path
    end

    def to_s
      "#{root_deployment}/#{name} (config base dir: #{config_base_dir})"
    end
  end
end
