module Upgrade
  require 'json'

  class KeyNotFound < RuntimeError; end
  class CredhubSetError < RuntimeError; end

  class CredhubCli
    class << self
      def execute(arg, env = {})
        env_var = env.collect { |k, v| "#{k}=#{v}" }.join(' ')
        cmd = "env #{env_var} credhub #{arg}"
        out, err, status = Open3.capture3(cmd)
      end

      def set_value(name, value, env = {})
        puts "Credhub - Setting key '#{name}'"
        output, err, status = execute("set --type value --output-json --name '#{name}' --value '#{value}'", env)
        raise CredhubSetError, "Cannot set key #{name} - Error: #{err}" unless status.success?
        begin
          JSON.parse(output)
        rescue JSON::ParserError => pe
          raise CredhubSetError, "Cannot set key #{name} - Error: #{err}"
        end

      end

      def get_value(name, env = {})
        property = get(name,env)
        property['value']
      end

      def get(name, env = {})
        puts "Credhub - Getting key '#{name}'"
        output = execute("get  --output-json --name #{name}", env)
        raise KeyNotFound, name if output =~ /The request could not be completed because the credential does not exist or you do not have sufficient authorization./
        JSON.parse(output)
      end
    end
  end
end
