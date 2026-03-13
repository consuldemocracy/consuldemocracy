namespace :sensemaker do
  desc "Setup Sensemaker Integration"
  task setup: :environment do
    logger = ApplicationLogger.new
    logger.info "Setting up Sensemaker Integration..."
    setup_sensemaker_app_prerequisites(logger)
    with_sensemaker_tenant(logger, "Setting up") { |lgr| setup_for_tenant(lgr) }
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
    with_sensemaker_tenant(logger, "Verifying") { |lgr| verify_installation(lgr) }
  end

  private

    def with_sensemaker_tenant(logger, action_prefix)
      tenant_schema = ENV["CONSUL_TENANT"]
      if tenant_schema.present?
        logger.info "#{action_prefix} for tenant: #{tenant_schema}"
        unless Tenant.exists?(schema: tenant_schema)
          err_msg = "Tenant '#{tenant_schema}' not found. Available: #{Tenant.pluck(:schema).join(", ")}"
          logger.warn err_msg
          raise "Tenant '#{tenant_schema}' not found"
        end
        Tenant.switch(tenant_schema) { yield logger }
      else
        logger.info "No tenant specified, using default tenant"
        yield logger
      end
    end

    def setup_sensemaker_app_prerequisites(logger)
      begin
        package_path = Sensemaker::Paths.sensemaker_package_folder
        sensemaker_path = Sensemaker::Paths.sensemaker_folder
      rescue => e
        logger.warn "Could not get paths from Sensemaker::Paths: #{e.message}"
        logger.warn "Using default paths instead"
        package_path = Rails.root.join("node_modules/@cosla/sensemaking-tools")
        sensemaker_path = Rails.root.join("vendor/sensemaking-tools")
      end

      check_dependencies(logger)
      ensure_package_in_package_json(logger, "@cosla/sensemaking-tools")
      ensure_web_ui_package_in_package_json(logger)

      logger.info "Using sensemaking-tools package path: #{package_path}"
      logger.info "Using sensemaking-tools folder: #{sensemaker_path}"

      ensure_angular_build_for_web_ui(logger)
      setup_sensemaker_directory(sensemaker_path, logger)
      verify_cli_available(package_path, logger)
      check_key_file(logger)
    end

    def verify_installation(logger)
      check_env_variables(logger)
      check_dependencies(logger)
      check_directories(logger)
      check_key_file(logger)
      check_package(logger)
      check_is_enabled(logger)
      ensure_angular_build_for_web_ui(logger)
      check_web_ui_health(logger)
      check_sensemaker_cli(logger)
      logger.info "Sensemaker installation verified you can now use the Sensemaker Tools."
    end

    def check_env_variables(logger)
      logger.info "Checking environment variables..."

      if Tenant.current_secrets.sensemaker_data_folder.blank?
        logger.warn "✗ sensemaker_data_folder not found. Please provide it in the tenant secrets."
        abort "Error: sensemaker_data_folder is required. Please check the logs."
      end
      logger.info "✓ sensemaker_data_folder found"

      context = Llm::Config.context
      if context.config.vertexai_project_id.blank?
        logger.warn "✗ Vertex AI is not configured. Please set tenant secrets " \
                    "llm.vertexai_project_id (and optionally vertexai_location)."
        abort "Error: Vertex AI configuration not found. Please check the logs."
      end
      logger.info "✓ Vertex AI configuration (context.config.vertexai_project_id) is present."

      provider = Setting["llm.provider"].to_s
      unless provider.downcase.include?("vertex")
        logger.warn "✗ Sensemaker requires Vertex AI as the LLM provider. " \
                    "Current provider: #{provider.presence || "(not set)"}. Set it in Admin → Settings → LLM."
        abort "Error: Vertex AI must be selected as the LLM provider. Please check the logs."
      end
      logger.info "✓ Vertex AI is selected as the LLM provider."

      if Setting["llm.model"].blank?
        logger.warn "✗ Sensemaker requires an LLM model to be selected. Set it in Admin → Settings → LLM."
        abort "Error: No LLM model selected. Please check the logs."
      end
      logger.info "✓ LLM model is selected."
    end

    def check_sensemaker_cli(logger)
      context = Llm::Config.context

      output_file = "#{Sensemaker::Paths.sensemaker_data_folder}/verify-output-#{Time.current.to_i}.txt"
      package_path = Sensemaker::Paths.sensemaker_package_folder
      runner_path = package_path.join("runner-cli/health_check_runner.ts")

      command = %Q(npx ts-node #{runner_path} \
        --vertexProject #{context.config.vertexai_project_id} \
        --outputFile #{output_file} \
        --modelName #{Setting["llm.model"]})

      full_command = "cd #{Rails.root} && #{command}"

      logger.info "Running command: #{full_command}"
      output = `#{full_command} 2>&1`
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

    def check_package(logger)
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
      key_path = Rails.application.secrets.google_application_credentials
      if key_path.present?
        path = Pathname.new(key_path).absolute? ? key_path : Rails.root.join(key_path).to_s
        if File.exist?(path)
          logger.info "✓ Key file found: #{path}"
        else
          logger.warn "✗ Key file not found at path apis.google_application_credentials : #{path}"
          raise "Key file not found: #{path}"
        end
      else
        logger.info "✓ Using Application Default Credentials " \
                    "(gcloud auth application-default login or metadata server)."
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
        data_path = Sensemaker::Paths.sensemaker_data_folder
      rescue => e
        logger.warn "Could not get data path from Sensemaker::Paths: #{e.message}"
        logger.warn "Using default path instead"
        data_path = Rails.root.join("vendor/sensemaking-tools/data")
      end

      logger.info "Using data path: #{data_path}"
      setup_data_directory(data_path, logger)
      add_feature_flag(logger)

      logger.info "Sensemaker setup complete!"
      logger.info "Ensure tenant secrets include llm.vertexai_project_id (and optionally vertexai_location)."
      logger.info "To verify your installation, run: bundle exec rake sensemaker:verify"
    end

    def check_dependencies(logger)
      logger.info "Checking environment dependencies..."
      %w[node npm npx].each do |cmd|
        check_dependency(logger, cmd, cmd == "node" ? "Node.js" : cmd)
      end
      logger.info "All dependencies are available."
    end

    def check_dependency(logger, cmd, display_name)
      unless system("which #{cmd} > /dev/null 2>&1")
        logger.warn "#{display_name} not found. Please install #{display_name} to use the Sensemaker feature."
        raise "#{display_name} not found. Please install #{display_name} to use the Sensemaker feature."
      end
      logger.info "✓ #{display_name} found: #{`#{cmd} --version`.strip}"
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

    def ensure_package_in_package_json(logger, package_name, suggested_version: "^1.0.0")
      logger.info "Checking package.json for #{package_name} dependency..."

      package_json_path = Rails.root.join("package.json")
      unless File.exist?(package_json_path)
        logger.warn "✗ package.json not found."
        logger.info ""
        logger.info "Please create package.json and add the following dependency:"
        logger.info "  \"#{package_name}\": \"#{suggested_version}\""
        logger.info ""
        raise "package.json not found. Please create it and add the required dependencies."
      end

      package_json = JSON.parse(File.read(package_json_path))
      package_json["dependencies"] ||= {}
      current_version = package_json["dependencies"][package_name]

      if current_version.nil?
        logger.warn "✗ #{package_name} not found in package.json"
        logger.info ""
        logger.info "Please add the following to your package.json dependencies:"
        logger.info "  \"#{package_name}\": \"#{suggested_version}\""
        logger.info ""
        logger.info "Then run: npm install"
        logger.info ""
        raise "#{package_name} not found in package.json. Please add it manually."
      else
        logger.info "✓ #{package_name}@#{current_version} found in package.json"
      end
    end

    def ensure_web_ui_package_in_package_json(logger)
      ensure_package_in_package_json(logger, "@cosla/sensemaking-web-ui")
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
