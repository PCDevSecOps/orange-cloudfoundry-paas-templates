module Upgrade
  # Class easily manipulate (ie load and write) 'private-config.yml'
  class PrivateConfig

    def initialize(secrets_dir)
      @secrets_dir = secrets_dir
      @private_config_filename = File.join(@secrets_dir, 'private-config.yml')
    end

    def write(content)
      FileUtils.mkdir_p(@secrets_dir) unless Dir.exist? @secrets_dir
      File.open(@private_config_filename, 'w') { |file| file.write YAML.dump(content) }
    end

    def load
      unless File.exist?(@private_config_filename)
        puts "WARNING: #{@private_config_filename} does not exist"
        return {}
      end

      YAML.load_file(@private_config_filename)
    end
  end
end
