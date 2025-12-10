module Sensemaker
  module Paths
    def self.sensemaker_folder
      if Rails.env.test?
        Rails.root.join("tmp/sensemaker_test_folder")
      else
        Rails.root.join("vendor/sensemaking-tools")
      end
    end

    def self.sensemaker_data_folder
      if Rails.env.test?
        Rails.root.join("tmp/sensemaker_test_folder/data")
      else
        Rails.root.join(Tenant.current_secrets.sensemaker_data_folder)
      end
    end

    def self.visualization_folder
      if Rails.env.test?
        Rails.root.join("tmp/sensemaker_test_folder/web-ui")
      else
        Rails.root.join("vendor/sensemaking-tools/web-ui")
      end
    end

    def self.key_file
      if Rails.env.test?
        Rails.root.join("tmp/sensemaker_test_folder/default-service-account-key.json")
      else
        Rails.root.join(Tenant.current_secrets.sensemaker_key_file)
      end
    end

    def self.parse_key_file
      JSON.parse(File.read(key_file))
    rescue JSON::ParserError, Errno::ENOENT => e
      Rails.logger.error "Failed to parse key file: #{e.message}"
      {}
    end
  end
end
