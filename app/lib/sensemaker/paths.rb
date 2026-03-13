module Sensemaker
  module Paths
    def self.sensemaker_package_folder
      if Rails.env.test?
        Rails.root.join("tmp/sensemaker_test_folder/package")
      else
        Rails.root.join("node_modules/@cosla/sensemaking-tools")
      end
    end

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
        Rails.root.join("node_modules/@cosla/sensemaking-web-ui")
      end
    end
  end
end
