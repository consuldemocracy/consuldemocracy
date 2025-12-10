namespace :sensemaker do
  def self.git_tag
    "v1.0.0"
  end

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
      check_web_ui_health(logger)
      check_angular_build(logger)
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
      sensemaker_folder = Sensemaker::Paths.sensemaker_folder
      project_id = Sensemaker::Paths.parse_key_file.fetch("project_id")
      output_file = "#{Sensemaker::Paths.sensemaker_data_folder}/verify-output-#{Time.current.to_i}.txt"

      command = %Q(npx ts-node #{sensemaker_folder}/library/runner-cli/health_check_runner.ts \
        --vertexProject #{project_id} \
        --outputFile #{output_file} \
        --modelName #{model_name} \
        --keyFilename #{Sensemaker::Paths.key_file})

      output = `cd #{Sensemaker::Paths.sensemaker_folder} && #{command} 2>&1`
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

    def check_angular_build(logger)
      logger.info "Testing Angular compilation..."

      visualization_path = Sensemaker::Paths.visualization_folder

      output = `cd #{visualization_path} && npm run build -- --configuration development 2>&1`
      result = $?.exitstatus

      if result.eql?(0)
        logger.info "✓ Angular build test passed."
      else
        logger.warn "✗ Angular build test failed."
        logger.warn output
        raise "This may indicate a TypeScript version incompatibility or other compilation issue."
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
      sensemaker_path = Sensemaker::Paths.sensemaker_folder

      if File.directory?(sensemaker_path) && File.directory?(File.join(sensemaker_path, ".git"))
        logger.info "✓ sensemaking-tools repository found: #{sensemaker_path}"
        Dir.chdir(sensemaker_path) do
          current_tag = `git describe --exact-match --tags HEAD 2>/dev/null`.strip
          if current_tag.eql?(git_tag)
            logger.info "✓ sensemaking-tools repository is using the expected tag: #{git_tag}"
          else
            logger.warn "⚠ sensemaking-tools repository tag is '#{current_tag}', not '#{git_tag}'"
          end
          logger.info " - Current branch: #{`git rev-parse --abbrev-ref HEAD`.strip} "
          logger.info " - Latest commit: #{`git log -1 --pretty=format:"%h %s"`.strip}"
          logger.info " - Last updated: #{`git log -1 --pretty=format:"%ci"`.strip}"
        end
      else
        logger.warn "✗ sensemaking-tools repository not found at: #{sensemaker_path}"
        raise "sensemaking-tools repository not found at: #{sensemaker_path}"
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
      sensemaker_path = Sensemaker::Paths.sensemaker_folder
      data_path = Sensemaker::Paths.sensemaker_data_folder

      if File.directory?(sensemaker_path)
        logger.info "✓ Sensemaker path found: #{sensemaker_path}"
      else
        logger.warn "✗ Sensemaker path not found: #{sensemaker_path}"
        raise "Sensemaker path not found: #{sensemaker_path}"
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
        sensemaker_path = Sensemaker::Paths.sensemaker_folder
        visualization_path = Sensemaker::Paths.visualization_folder
        data_path = Sensemaker::Paths.sensemaker_data_folder
      rescue => e
        logger.warn "Could not get paths from Sensemaker::Paths: #{e.message}"
        logger.warn "Using default paths instead"

        sensemaker_path = Rails.root.join("vendor/sensemaking-tools")
        data_path = Rails.root.join("vendor/sensemaking-tools/data")
      end

      logger.info "Using sensemaking-tools path: #{sensemaker_path}"
      logger.info "Using data path: #{data_path}"

      check_dependencies(logger)

      setup_sensemaker_directory(sensemaker_path, logger)

      clone_or_update_repository(sensemaker_path, logger)

      setup_data_directory(data_path, logger)

      install_dependencies(sensemaker_path, visualization_path, logger)

      # set_file_permissions(sensemaker_path, data_path, logger)

      verify_cli_available(sensemaker_path, logger)

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
      logger.info "Setting up sensemaking-tools directory..."

      shared_path = Rails.root.join("../../shared")
      in_capistrano = File.directory?(shared_path)

      if in_capistrano
        logger.info "Detected Capistrano deployment structure"

        File.join(shared_path, "vendor/sensemaking-tools")

        unless File.symlink?(sensemaker_path) && File.directory?(sensemaker_path)
          logger.warn %(
            "WARNING: vendor/sensemaking-tools is not properly linked to shared/vendor/sensemaking-tools"
            "Make sure 'vendor/sensemaking-tools' is included in :linked_dirs in config/deploy.rb"
            "Changes to sensemaking-tools will be lost on next deployment if this is not fixed"
          )
        end
      end

      FileUtils.mkdir_p(sensemaker_path) unless File.directory?(sensemaker_path)

      logger.info "Sensemaker directory created."
    end

    def setup_data_directory(data_path, logger)
      logger.info "Setting up data directory..."
      FileUtils.mkdir_p(data_path) unless File.directory?(data_path)
      logger.info "Data directory created."
    end

    def clone_or_update_repository(sensemaker_path, logger)
      repo_url = "https://github.com/CoslaDigital/sensemaking-tools.git"

      if File.directory?(File.join(sensemaker_path, ".git"))
        logger.info "Repository already exists, updating to tag #{git_tag}..."
        Dir.chdir(sensemaker_path) do
          system("git fetch --all --tags")
          system("git checkout #{git_tag}")

          if $?.success?
            logger.info "Repository updated successfully to tag #{git_tag}."
          else
            logger.warn "Failed to update repository to tag #{git_tag}."
            raise "Failed to update repository to tag #{git_tag}."
          end
        end
      else
        logger.info "Cloning sensemaking-tools repository (tag #{git_tag})..."
        system("git clone -b #{git_tag} #{repo_url} #{sensemaker_path}")

        if $?.success?
          logger.info "Repository cloned successfully with tag #{git_tag}."
        else
          logger.warn "Failed to clone repository."
          raise "Failed to clone repository."
        end
      end
    end

    def install_dependencies(sensemaker_path, visualization_path, logger)
      install_main_dependencies(sensemaker_path, logger)
      install_visualization_dependencies(visualization_path, logger)
    end

    def install_main_dependencies(sensemaker_path, logger)
      logger.info "Installing npm dependencies for sensemaking-tools..."
      if File.exist?(File.join(sensemaker_path, "package.json"))
        Dir.chdir(sensemaker_path) do
          logger.info "Installing dependencies for sensemaking-tools..."
          system("npm install")

          if $?.success?
            logger.info "Dependencies installed successfully for sensemaking-tools."
          else
            logger.warn "Failed to install dependencies."
            raise "Failed to install dependencies."
          end
        end
      else
        logger.warn "package.json not found at #{sensemaker_path}"
        raise "package.json not found at #{sensemaker_path}"
      end
    end

    def install_visualization_dependencies(visualization_path, logger)
      logger.info "Installing npm dependencies for sensemaker-tools/web-ui..."
      if File.exist?(File.join(visualization_path, "package.json"))
        Dir.chdir(visualization_path) do
          logger.info "Installing dependencies for web-ui..."
          system("npm install")

          if $?.success?
            logger.info "Dependencies installed successfully for web-ui."
          else
            logger.warn "Failed to install dependencies."
            raise "Failed to install dependencies."
          end
        end
      else
        logger.warn "package.json not found at #{visualization_path}"
        raise "package.json not found at #{visualization_path}"
      end
    end

    def verify_cli_available(sensemaker_path, logger)
      library_path = File.join(sensemaker_path, "library")

      Dir.chdir(library_path) do
        output = `npx ts-node ./runner-cli/health_check_runner.ts --help`

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
