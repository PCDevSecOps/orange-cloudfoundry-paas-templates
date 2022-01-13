module Upgrade
  class ConcourseEnv
    def self.infos
      [url, username, password, insecure]
    end

    def self.url
      get_env 'CONCOURSE_URL'
    end

    def self.username
      get_env 'CONCOURSE_USERNAME'
    end

    def self.password
      get_env 'CONCOURSE_PASSWORD'
    end

    def self.insecure
      get_env 'CONCOURSE_INSECURE'
    end

    private

    def self.get_env(name)
      env_value = ENV.fetch(name, USER_VALUE_REQUIRED)
      puts "Missing #{name}, using default value. Please set it before launching this script. In bash: `export #{name}=\"<your_value>\"`" if env_value.empty? || env_value == USER_VALUE_REQUIRED
      env_value
    end
  end
end
