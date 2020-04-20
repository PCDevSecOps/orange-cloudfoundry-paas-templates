module Upgrade

  class CoaConfig
    attr_reader :config_base_dir

    def initialize(config_base_dir)
      @config_base_dir = config_base_dir
    end

    def location
      File.join(@config_base_dir, "coa", "config")
    end

    def get(key)
      @credentials_files = init_config_file unless @credentials_files
      filename = @credentials_files.dig(key)
      return false if filename&.empty?
      filename
    end

    def load_credentials(key)
      filename = get(key)
      return false unless filename
      fullpath = File.join(self.location, filename)
      YAML.load_file fullpath if File.exist?(fullpath)
    end

    def write_raw_credentials(key, content)
      filename = get(key)
      return false if filename&.empty?
      fullpath = File.join(self.location, filename)
      unless File.exist?(self.location)
        puts "creating #{self.location}"
        FileUtils.mkdir_p(self.location)
      end
      File.open(fullpath, 'w') { |file| file.write content }
    end

    def write_yaml_credentials(key, content)
      write_raw_credentials(key, YAML.dump(content))
    end


    private

    def init_config_file
      {
          docker_registry: "credentials-docker-registry.yml",
          credhub: "credentials-credhub.yml",
          git_config: "credentials-git-config.yml",
          profiles: "credentials-active-profiles.yml"
      }
    end
  end
end
