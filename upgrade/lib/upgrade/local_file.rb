module Upgrade

  class LocalFile
    attr_reader :name, :config_base_dir

    LOCAL_SECRETS_DIRNAME = 'secrets'

    def initialize(name, config_base_dir)
      @name = name
      @config_base_dir = config_base_dir
    end
    
    def deployment_config_path
      File.join @config_base_dir, @name
    end
    
    def local_secrets_dir
      File.join(deployment_config_path, LOCAL_SECRETS_DIRNAME)
    end
    
    def local_secrets_filename
      File.join(local_secrets_dir, 'secrets.yml')
    end

    def local_meta_filename 
      File.join(local_secrets_dir, 'meta.yml')
    end
    
    def create_local_secrets(content = { 'secrets' => {} }, raw_content = false)
      create_local_file(local_secrets_filename, content, raw_content)
    end

    def update_local_secrets(content, raw_content = false)
      update_local_file(local_secrets_filename, content, raw_content)
    end

    def create_local_meta(content = { 'meta' => {} }, raw_content = false)
      create_local_file(local_meta_filename, content, raw_content)
    end

    def update_local_meta(content, raw_content = false)
      update_local_file(local_meta_filename, content, raw_content)
    end

    def load_local_secrets
      load_local_file(local_secrets_filename)
    end

    def load_local_meta
      load_local_file(local_meta_filename)
    end

    def delete_local_secrets
      delete_local_file(local_secrets_filename)
    end

    def delete_local_meta
      delete_local_file(local_meta_filename)
    end

    private

    def load_local_file(filename)
      raise "FATAL: #{filename} does not exist" unless File.exist?(filename)
      YAML.load_file(filename)
    end

    def update_local_file(filename, content, raw_content = false)
      unless File.exist?(filename)
        puts "creating #{filename}"
        FileUtils.mkdir_p(local_secrets_dir)
      end
      write_content(content, filename, raw_content)
    end

    def create_local_file(filename, content, raw_content = false)
      if File.exist?(filename)
        puts "WARNING: skipping #{filename}, file already exists"
      else
        puts "creating #{filename}"
        FileUtils.mkdir_p(local_secrets_dir)
        write_content(content, filename, raw_content)
      end
    end

    def write_content(content, filename, raw_content)
      if raw_content
        File.open(filename, 'w') { |file| file.write content }
      else
        File.open(filename, 'w') { |file| file.write YAML.dump(content) }
      end
    end

    def delete_local_file(filename)
      if File.exist?(filename)
        FileUtils.rm_rf(filename, verbose:true )
      else
        puts "WARNING: skipping #{filename} deletion, file does not exist"
      end
    end
  end
end
