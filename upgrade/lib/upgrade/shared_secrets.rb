module Upgrade
  class SharedSecrets
    def self.load(secrets_dir = '.')
        shared_secrets_dir = File.join(secrets_dir, 'shared')
        shared_secrets_filename = File.join(shared_secrets_dir, 'secrets.yml')
        raise "FATAL: #{shared_secrets_filename} does not exist" unless File.exist?(shared_secrets_filename)

        YAML.load_file(shared_secrets_filename)
    end

    def initialize(secrets_dir)
      @secrets_dir = secrets_dir
      @shared_secrets_dir = File.join(secrets_dir, 'shared')
      @shared_secrets_filename = File.join(@shared_secrets_dir, 'secrets.yml')
    end

    def write(content)
      FileUtils.mkdir_p(@shared_secrets_dir) unless Dir.exist? @shared_secrets_dir
      File.open(@shared_secrets_filename, 'w') { |file| file.write YAML.dump(content) }
    end

    def load
      raise "FATAL: #{@shared_secrets_filename} does not exist" unless File.exist?(@shared_secrets_filename)
      YAML.load_file(@shared_secrets_filename)
    end
  end
end
