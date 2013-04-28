require "rails"
require "ostruct"

class Secrets < Rails::Railtie
  class NotEnoughSecrets < StandardError; end

  config.secrets_path = "config/secrets.yml"
  
  initializer "secrets.load" do |_|
    Secrets.load!
  end
  
  def self.load!
    Object.send(:remove_const, :Secret) if defined? Secret
    secrets = {}
    
    Array("config/secrets.yml").each do |path|
      next unless File.exist?(Rails.root + path)

      secrets_file_values = YAML.load_file(Rails.root.join path)[Rails.env.to_s]
      if secrets_file_values
        secrets_file_values.each do |(key, value)|
          secrets[key] = value.is_a?(Hash) ? OpenStruct.new(value) : value
        end
      else
        raise NotEnoughSecrets unless Rails.env.test?
      end

    end
    
    Object.send :const_set, :Secret, OpenStruct.new(secrets)
  end
end
