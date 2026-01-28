namespace :sensemaker do
  desc "Setup Sensemaker Integration"
  task setup: :environment do
    logger = ApplicationLogger.new
    logger.info "Setting up Sensemaker Integration..."

    tenant_schema = ENV["CONSUL_TENANT"]

    if tenant_schema.present?
      logger.info "Setting up for tenant: #{tenant_schema}"

      unless Tenant.exists?(schema: tenant_schema)
        err_msg = "Tenant '#{tenant_schema}' not found. Available: #{Tenant.pluck(:schema).join(", ")}"
        logger.warn err_msg
        raise "Tenant '#{tenant_schema}' not found"
      end

      Tenant.switch(tenant_schema) do
        setup_for_tenant(logger)
      end
    else
      logger.info "No tenant specified, using default tenant"
      setup_for_tenant(logger)
    end
  end

  desc "Check if sensemaker-tools dependencies are available"
  task check_dependencies: :environment do
    logger = ApplicationLogger.new
    check_dependencies(logger)
  end

  desc "Verify Sensemaker installation"
  task verify: :environment do
    logger = ApplicationLogger.new
    logger.info "Verifying Sensemaker installation..."

    tenant_schema = ENV["CONSUL_TENANT"]

    if tenant_schema.present?
      logger.info "Verifying for tenant: #{tenant_schema}"
      Tenant.switch(tenant_schema) do
        verify_installation(logger)
      end
    else
      logger.info "No tenant specified, using default tenant"
      verify_installation(logger)
    end
  end

  private

    def verify_installation(logger)
      check_env_variables(logger)
      check_dependencies(logger)
      check_directories(logger)
      check_key_file(logger)
      check_repository(logger)
      check_is_enabled(logger)
      check_sensemaker_cli(logger)
      ensure_angular_build_for_web_ui(logger)
      check_web_ui_health(logger)
      logger.info "Sensemaker installation verified you can now use the Sensemaker Tools."
    end

    def check_env_variables(logger)
      logger.info "Checking environment variables..."

      required_secrets = {
        sensemaker_data_folder: "<path to the data folder>",
        sensemaker_key_file: "<path to the service account key file>",
        sensemaker_model_name: "<model name>"
      }

      any_missing = false

      required_secrets.each do |key, description|
        value = Tenant.current_secrets.send(key)
        if value.present?
          logger.info "✓ #{key} found"
        else
          logger.warn "✗ #{key} not found. Please provide it in the tenant secrets: #{key}: #{description}"
          any_missing = true
        end
      end

      if any_missing
        abort "Error: One or more Sensemaker environment variables not found. Please check the logs."
      else
        logger.info "✓ All Sensemaker environment variables are present."
      end
    end

    def check_sensemaker_cli(logger)
      model_name = Tenant.current_secrets.sensemaker_model_name
      project_id = Sensemaker::Paths.parse_key_file.fetch("project_id")
      output_file = "#{Sensemaker::Paths.sensemaker_data_folder}/verify-output-#{Time.current.to_i}.txt"

      package_path = Sensemaker::Paths.sensemaker_package_folder
      runner_path = package_path.join("runner-cli/health_check_runner.ts")

      command = %Q(npx ts-node #{runner_path} \
        --vertexProject #{project_id} \
        --outputFile #{output_file} \
        --modelName #{model_name} \
        --keyFilename #{Sensemaker::Paths.key_file})

      output = `cd #{Rails.root} && #{command} 2>&1`
      result = $?.exitstatus

      if result.eql?(0)
        logger.info "✓ Sensemaker CLI is working correctly."
        logger.info output
      else
        logger.warn "✗ Sensemaker CLI is not working correctly."
        logger.warn output
        raise "Sensemaker CLI is not working correctly."
      end
    end

    def check_web_ui_health(logger)
      logger.info "Checking web-ui health..."

      visualization_path = Sensemaker::Paths.visualization_folder
      output_file = "#{Sensemaker::Paths.sensemaker_data_folder}/health-check-#{Time.current.to_i}.html"

      command = %Q(node #{visualization_path}/health_check.js --outputFile #{output_file})

      output = `cd #{visualization_path} && #{command} 2>&1`
      result = $?.exitstatus

      if result.eql?(0)
        logger.info "✓ Web-ui health check passed."
        logger.info output
      else
        logger.warn "✗ Web-ui health check failed."
        logger.warn output
        raise "Web-ui health check failed."
      end
    end

    def ensure_angular_build_for_web_ui(logger)
      logger.info "Ensuring Angular build for web-ui..."

      visualization_path = Sensemaker::Paths.visualization_folder
      dist_path = File.join(visualization_path, "dist/web-ui/browser")
      build_exists = File.directory?(dist_path) && File.exist?(File.join(dist_path, "index.csr.html"))

      logger.info "Installing Angular build dependencies..."
      install_command = "cd #{visualization_path} && npm install --include=dev 2>&1"
      install_output = `#{install_command}`
      install_result = $?.exitstatus

      if !install_result.eql?(0)
        logger.warn "✗ Failed to install dependencies"
        logger.warn install_output
        raise "Failed to install Angular build dependencies"
      end

      logger.info "✓ Dependencies installed"

      if build_exists
        logger.info "✓ Angular build already exists at: #{dist_path}"
        logger.info "Skipping build step."
        return
      end

      logger.info "Building Angular app..."

      build_command = "cd #{visualization_path} && npm run build -- --configuration development 2>&1"
      build_output = `#{build_command}`
      result = $?.exitstatus

      if result.eql?(0)
        logger.info "✓ Angular build for web-ui completed successfully."
      else
        logger.warn "✗ Angular build for web-ui failed"
        logger.warn build_output
        raise "Angular build for web-ui failed."
      end
    end

    def check_is_enabled(logger)
      setting = Setting.find_by(key: "feature.sensemaker")
      if setting.present?
        logger.info "✓ Sensemaker setting found"
      else
        logger.warn "✗ Sensemaker setting not found"
        raise "Sensemaker setting not found"
      end

      if Setting["feature.sensemaker"].present?
        logger.info "✓ Sensemaker is enabled via feature.sensemaker setting"
      else
        logger.warn "✗ Sensemaker is disabled via feature.sensemaker setting"
        raise "Sensemaker is disabled via feature.sensemaker setting"
      end
    end

    def check_repository(logger)
      package_path = Sensemaker::Paths.sensemaker_package_folder

      if File.directory?(package_path)
        logger.info "✓ sensemaking-tools package found: #{package_path}"

        package_json_path = File.join(package_path, "package.json")
        if File.exist?(package_json_path)
          package_json = JSON.parse(File.read(package_json_path))
          version = package_json["version"]
          logger.info "✓ Installed version: #{version}"
        end
      else
        logger.warn "✗ sensemaking-tools package not found at: #{package_path}"
        raise "sensemaking-tools package not found. Run 'npm install' first."
      end
    end

    def check_key_file(logger)
      key_file = Sensemaker::Paths.key_file

      if File.exist?(key_file)
        logger.info "✓ Key file found: #{key_file}"
      else
        logger.warn "✗ Key file not found: #{key_file}"
        raise "Key file is not found: #{key_file}"
      end

      parsed_file = Sensemaker::Paths.parse_key_file

      if parsed_file.blank?
        logger.warn "Key file is invalid: #{key_file}"
        raise "Key file is invalid: #{key_file}"
      end

      if parsed_file.fetch("project_id", "").blank?
        logger.warn "✗ Key file is missing project_id: #{key_file}"
        raise "Key file is missing project_id: #{key_file}"
      else
        logger.info "✓ Key file has project_id: #{parsed_file["project_id"]}"
      end
    end

    def check_directories(logger)
      package_path = Sensemaker::Paths.sensemaker_package_folder
      sensemaker_path = Sensemaker::Paths.sensemaker_folder
      data_path = Sensemaker::Paths.sensemaker_data_folder

      if File.directory?(package_path)
        logger.info "✓ Sensemaker package path found: #{package_path}"
      else
        logger.warn "✗ Sensemaker package path not found: #{package_path}"
        raise "Sensemaker package path not found: #{package_path}"
      end

      if File.directory?(sensemaker_path)
        logger.info "✓ Sensemaker data folder found: #{sensemaker_path}"
      else
        logger.warn "✗ Sensemaker data folder not found: #{sensemaker_path}"
        raise "Sensemaker data folder not found: #{sensemaker_path}"
      end

      if File.directory?(data_path)
        logger.info "✓ Data path found: #{data_path}"
      else
        logger.warn "✗ Data path not found: #{data_path}"
        raise "Data path not found: #{data_path}"
      end

      logger.info "✓ Directories found."
    end

    def setup_for_tenant(logger)
      begin
        package_path = Sensemaker::Paths.sensemaker_package_folder
        sensemaker_path = Sensemaker::Paths.sensemaker_folder
        data_path = Sensemaker::Paths.sensemaker_data_folder
      rescue => e
        logger.warn "Could not get paths from Sensemaker::Paths: #{e.message}"
        logger.warn "Using default paths instead"

        package_path = Rails.root.join("node_modules/@cosla/sensemaking-tools")
        sensemaker_path = Rails.root.join("vendor/sensemaking-tools")
        data_path = Rails.root.join("vendor/sensemaking-tools/data")
      end

      logger.info "Using sensemaking-tools package path: #{package_path}"
      logger.info "Using sensemaking-tools data folder: #{sensemaker_path}"
      logger.info "Using data path: #{data_path}"

      check_dependencies(logger)
      ensure_package_in_package_json(logger)
      ensure_web_ui_package_in_package_json(logger)
      ensure_angular_build_for_web_ui(logger)
      setup_sensemaker_directory(sensemaker_path, logger)
      setup_data_directory(data_path, logger)
      verify_cli_available(package_path, logger)
      add_feature_flag(logger)

      if File.exist?(Sensemaker::Paths.key_file)
        logger.info "Service account key file found at: #{Sensemaker::Paths.key_file}"
        logger.info "Sensemaker setup complete!"
        logger.info "To verify your installation, run: rake sensemaker:verify"
      else
        logger.info "IMPORTANT: Setup complete but you must provide a Google Cloud service account key file"
        logger.info "Location: #{Sensemaker::Paths.key_file}"
        logger.info ""
        logger.info "To create a service account key:"
        logger.info "1. In the Google Cloud console, go to the Service accounts page"
        logger.info "2. Select a project"
        logger.info "3. Click the email address of the service account that you want to create a key for"
        logger.info "4. Click the Keys tab"
        logger.info "5. Click the Add key drop-down menu, then select Create new key"
        logger.info "6. Select JSON as the Key type and click Create"
        logger.info ""
        logger.info "For more details, visit: https://cloud.google.com/iam/docs/keys-create-delete"
        logger.info ""
        logger.info "Once you have provided the account key file you can verify your installation by running:"
        logger.info "$ bundle exec rake sensemaker:verify"
      end
    end

    def check_dependencies(logger)
      logger.info "Checking environment dependencies..."

      unless system("which node > /dev/null 2>&1")
        logger.warn "Node.js not found. Please install Node.js to use the Sensemaker feature."
        raise "Node.js not found. Please install Node.js to use the Sensemaker feature."
      end
      logger.info "✓ Node.js found: #{`node --version`.strip}"

      unless system("which npm > /dev/null 2>&1")
        logger.warn "npm not found. Please install npm to use the Sensemaker feature."
        raise "npm not found. Please install npm to use the Sensemaker feature."
      end
      logger.info "✓ npm found: #{`npm --version`.strip}"

      unless system("which npx > /dev/null 2>&1")
        logger.warn "npx not found. Please install npx to use the Sensemaker feature."
        raise "npx not found. Please install npx to use the Sensemaker feature."
      end
      logger.info "✓ npx found: #{`npx --version`.strip}"

      logger.info "All dependencies are available."
    end

    def setup_sensemaker_directory(sensemaker_path, logger)
      logger.info "Setting up sensemaking-tools data directory..."
      FileUtils.mkdir_p(sensemaker_path) unless File.directory?(sensemaker_path)
      logger.info "Sensemaker data directory created."
    end

    def setup_data_directory(data_path, logger)
      logger.info "Setting up data directory..."
      FileUtils.mkdir_p(data_path) unless File.directory?(data_path)
      logger.info "Data directory created."
    end

    def ensure_package_in_package_json(logger)
      logger.info "Checking package.json for sensemaking-tools dependency..."

      package_json_path = Rails.root.join("package.json")
      unless File.exist?(package_json_path)
        logger.warn "✗ package.json not found."
        logger.info ""
        logger.info "Please create package.json and add the following dependency:"
        logger.info '  "@cosla/sensemaking-tools": "^1.0.0"'
        logger.info ""
        raise "package.json not found. Please create it and add the required dependencies."
      end

      package_json = JSON.parse(File.read(package_json_path))
      package_json["dependencies"] ||= {}

      package_name = "@cosla/sensemaking-tools"
      current_version = package_json["dependencies"][package_name]

      if current_version.nil?
        logger.warn "✗ #{package_name} not found in package.json"
        logger.info ""
        logger.info "Please add the following to your package.json dependencies:"
        logger.info '  "@cosla/sensemaking-tools": "^1.0.0"'
        logger.info ""
        logger.info "Then run: npm install"
        logger.info ""
        raise "#{package_name} not found in package.json. Please add it manually."
      else
        logger.info "✓ #{package_name}@#{current_version} found in package.json"
      end
    end

    def ensure_web_ui_package_in_package_json(logger)
      logger.info "Checking package.json for sensemaking-web-ui dependency..."

      package_json_path = Rails.root.join("package.json")
      unless File.exist?(package_json_path)
        logger.warn "✗ package.json not found."
        logger.info ""
        logger.info "Please create package.json and add the following dependency:"
        logger.info '  "@cosla/sensemaking-web-ui": "^1.0.0"'
        logger.info ""
        raise "package.json not found. Please create it and add the required dependencies."
      end

      package_json = JSON.parse(File.read(package_json_path))
      package_json["dependencies"] ||= {}

      package_name = "@cosla/sensemaking-web-ui"
      current_version = package_json["dependencies"][package_name]

      if current_version.nil?
        logger.warn "✗ #{package_name} not found in package.json"
        logger.info ""
        logger.info "Please add the following to your package.json dependencies:"
        logger.info '  "@cosla/sensemaking-web-ui": "^1.0.0"'
        logger.info ""
        logger.info "Then run: npm install"
        logger.info ""
        raise "#{package_name} not found in package.json. Please add it manually."
      else
        logger.info "✓ #{package_name}@#{current_version} found in package.json"
      end
    end

    def verify_cli_available(package_path, logger)
      runner_path = File.join(package_path, "runner-cli/health_check_runner.ts")

      Dir.chdir(Rails.root) do
        output = `npx ts-node #{runner_path} --help 2>&1`

        if $?.success?
          logger.info "Sensemaker CLI tool is working correctly."
        else
          logger.warn output
          logger.warn "Failed to run Sensemaker CLI tool. Please check the installation."
          raise "Failed to run Sensemaker CLI tool. Please check the installation."
        end
      end
    end

    def set_file_permissions(sensemaker_path, data_path, logger)
      logger.info "Setting file permissions..."
      FileUtils.chmod_R(0755, sensemaker_path)
      FileUtils.chmod_R(0755, data_path)
      logger.info "File permissions set."
    end

    def add_feature_flag(logger)
      setting = Setting.find_or_initialize_by(key: "feature.sensemaker")
      if setting.new_record?
        logger.info "Adding sensemaker feature flag..."
        setting.value = "true"
        setting.save!
        logger.info "Feature flag added."
      else
        logger.info "Feature flag already exists, enabling sensemaker..."
        setting.update!(value: "true")
        logger.info "Sensemaker enabled using feature.sensemaker setting."
      end
    end
end
