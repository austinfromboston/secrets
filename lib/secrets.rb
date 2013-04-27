require "rails"
require "ostruct"

class Secrets < Rails::Railtie
  config.secrets_path = "config/secrets.yml"
  
  initializer "secrets.load" do |_|
    Secrets.load!
  end
  
  def self.load!
    Object.send(:remove_const, :Secret) if defined? Secret
    secrets = {}
    
    Array(config.secrets_path).each do |path|
      next unless File.exist?(Rails.root + path)

      YAML.load_file(Rails.root.join config.secrets_path)[Rails.env.to_s].each do |(key, value)|
        secrets[key] = value.is_a?(Hash) ? OpenStruct.new(value) : value
      end

    end
    
    Object.send :const_set, :Secret, OpenStruct.new(secrets)
  end
end
