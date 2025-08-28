namespace :sensemaker do
  desc "Setup Sensemaking Tools"
  task setup: :environment do
    logger = ApplicationLogger.new
    logger.info "Setting up Sensemaking Tools..."

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

  desc "Check if Sensemaking Tools dependencies are available"
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
      check_dependencies(logger)
      check_directories(logger)
      check_key_file(logger)
      check_repository(logger)
      check_is_enabled(logger)
      check_sensemaker_cli(logger)
      logger.info "Sensemaker integration verified you can now use the Sensemaker Tools."
    end

    def check_sensemaker_cli(logger)
      model_name = Tenant.current_secrets.sensemaker_model_name
      sensemaker_folder = SensemakerService.sensemaker_folder
      project_id = SensemakerService.parse_key_file.fetch("project_id")
      output_file = "#{sensemaker_folder}/testoutput.txt"

      command = %Q(npx ts-node #{sensemaker_folder}/library/runner-cli/health_check_runner.ts \
        --vertexProject #{project_id} \
        --outputFile #{output_file} \
        --modelName #{model_name} \
        --keyFilename #{SensemakerService.key_file})

      output = `cd #{SensemakerService.sensemaker_folder} && #{command} 2>&1`
      result = $?.exitstatus

      if result.eql?(0)
        logger.info "✓ Sensemaker Tools are working correctly."
        logger.info output
      else
        logger.warn "✗ Sensemaker Tools are not working correctly."
        logger.warn output
        raise "Sensemaker Tools are not working correctly."
      end
    end

    def check_is_enabled(logger)
      setting = Setting.find_by(key: "feature.sensemaking")
      if setting.present?
        logger.info "✓ Sensemaking setting found"
      else
        logger.warn "✗ Sensemaking setting not found"
        raise "Sensemaking setting not found"
      end

      if SensemakerService.enabled?
        logger.info "✓ Sensemaking is enabled via feature.sensemaking setting"
      else
        logger.warn "✗ Sensemaking is disabled via feature.sensemaking setting"
        raise "Sensemaking is disabled via feature.sensemaking setting"
      end
    end

    def check_repository(logger)
      sensemaker_path = SensemakerService.sensemaker_folder

      if File.directory?(sensemaker_path) && File.directory?(File.join(sensemaker_path, ".git"))
        logger.info "✓ Sensemaker repository found: #{sensemaker_path}"
        Dir.chdir(sensemaker_path) do
          logger.info "  Current branch: #{`git rev-parse --abbrev-ref HEAD`.strip} "
          logger.info "  Latest commit: #{`git log -1 --pretty=format:"%h %s"`.strip}"
          logger.info "  Last updated: #{`git log -1 --pretty=format:"%ci"`.strip}"
        end
      else
        logger.warn "✗ Sensemaker repository not found at: #{sensemaker_path}"
        raise "Sensemaker repository not found at: #{sensemaker_path}"
      end
    end

    def check_key_file(logger)
      key_file = SensemakerService.key_file

      if File.exist?(key_file)
        logger.info "✓ Key file found: #{key_file}"
      else
        logger.warn "✗ Key file not found: #{key_file}"
        raise "Key file not found: #{key_file}"
      end

      parsed_file = SensemakerService.parse_key_file

      if parsed_file.blank?
        logger.warn "Key file is invalid: #{key_file}"
        raise "Key file is invalid: #{key_file}"
      else
        logger.info "✓ Key file is valid: #{key_file}"
      end

      if parsed_file.fetch("project_id", "").blank?
        logger.warn "✗ Key file is missing project_id: #{key_file}"
        raise "Key file is missing project_id: #{key_file}"
      else
        logger.info "✓ Key file has project_id: #{parsed_file["project_id"]}"
      end
    end

    def check_directories(logger)
      sensemaker_path = SensemakerService.sensemaker_folder
      data_path = SensemakerService.sensemaker_data_folder

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
      # Try to get paths from SensemakerService, but provide fallbacks for installation/setup
      begin
        sensemaker_path = SensemakerService.sensemaker_folder
        data_path = SensemakerService.sensemaker_data_folder
      rescue => e
        logger.warn "Could not get paths from SensemakerService: #{e.message}"
        logger.warn "Using default paths instead"

        sensemaker_path = Rails.root.join("vendor/sensemaking-tools")
        data_path = Rails.root.join("vendor/sensemaking-tools/data")
      end

      logger.info "Using sensemaker path: #{sensemaker_path}"
      logger.info "Using data path: #{data_path}"

      check_dependencies(logger)

      setup_sensemaker_directory(sensemaker_path, logger)

      clone_or_update_repository(sensemaker_path, logger)

      setup_data_directory(data_path, logger)

      install_dependencies(sensemaker_path, logger)

      set_file_permissions(sensemaker_path, data_path, logger)

      verify_cli_available(sensemaker_path, logger)

      add_feature_flag(logger)

      logger.info "Sensemaking Tools setup complete!"
    end

    def check_dependencies(logger)
      logger.info "Checking environment dependencies..."

      # Check if Node.js is available
      unless system("which node > /dev/null 2>&1")
        logger.warn "Node.js not found. Please install Node.js to use the Sensemaker feature."
        raise "Node.js not found. Please install Node.js to use the Sensemaker feature."
      end
      logger.info "✓ Node.js found: #{`node --version`.strip}"

      # Check if npm is available
      unless system("which npm > /dev/null 2>&1")
        logger.warn "npm not found. Please install npm to use the Sensemaker feature."
        raise "npm not found. Please install npm to use the Sensemaker feature."
      end
      logger.info "✓ npm found: #{`npm --version`.strip}"

      # Check if npx is available
      unless system("which npx > /dev/null 2>&1")
        logger.warn "npx not found. Please install npx to use the Sensemaker feature."
        raise "npx not found. Please install npx to use the Sensemaker feature."
      end
      logger.info "✓ npx found: #{`npx --version`.strip}"

      logger.info "All dependencies are available."
    end

    def setup_sensemaker_directory(sensemaker_path, logger)
      logger.info "Setting up sensemaker directory..."

      # Check if we're in a Capistrano deployment
      shared_path = Rails.root.join("../../shared")
      in_capistrano = File.directory?(shared_path)

      if in_capistrano
        logger.info "Detected Capistrano deployment structure"

        # In Capistrano, vendor/sensemaking-tools should be a symlink to shared/vendor/sensemaking-tools
        # Check if the directory exists in the shared path
        File.join(shared_path, "vendor/sensemaking-tools")

        # Check if the symlink exists and points to the right place
        unless File.symlink?(sensemaker_path) && File.directory?(sensemaker_path)
          logger.warn %(
            "WARNING: vendor/sensemaking-tools is not properly linked to shared/vendor/sensemaking-tools"
            "Make sure 'vendor/sensemaking-tools' is included in :linked_dirs in config/deploy.rb"
            "Changes to sensemaking-tools will be lost on next deployment if this is not fixed"
          )
        end
      end

      # Create directory if it doesn't exist (for both Capistrano and non-Capistrano environments)
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
        logger.info "Repository already exists, updating..."
        Dir.chdir(sensemaker_path) do
          system("git fetch --all")
          system("git reset --hard origin/main")

          if $?.success?
            logger.info "Repository updated successfully."
          else
            logger.warn "Failed to update repository."
            raise "Failed to update repository."
          end
        end
      else
        logger.info "Cloning sensemaking-tools repository..."
        system("git clone #{repo_url} #{sensemaker_path}")

        if $?.success?
          logger.info "Repository cloned successfully."
        else
          logger.warn "Failed to clone repository."
          raise "Failed to clone repository."
        end
      end
    end

    def install_dependencies(sensemaker_path, logger)
      logger.info "Installing npm dependencies..."

      # Install dependencies in the library directory
      library_path = File.join(sensemaker_path, "library")
      if File.directory?(library_path)
        Dir.chdir(library_path) do
          system("npm install")

          if $?.success?
            logger.info "Dependencies installed successfully."
          else
            logger.warn "Failed to install dependencies."
            raise "Failed to install dependencies."
          end
        end
      else
        logger.warn "Library directory not found at #{library_path}"
        raise "Library directory not found at #{library_path}"
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
          logger.warn "Failed to run sensemaker CLI tool. Please check the installation."
          raise "Failed to run sensemaker CLI tool. Please check the installation."
        end
      end
    end

    def set_file_permissions(sensemaker_path, data_path, logger)
      logger.info "Setting file permissions..."

      # Set permissions for the sensemaker directory
      FileUtils.chmod_R(0755, sensemaker_path)

      # Set permissions for the data directory
      FileUtils.chmod_R(0755, data_path)

      logger.info "File permissions set."
    end

    def add_feature_flag(logger)
      setting = Setting.find_or_initialize_by(key: "feature.sensemaking")
      if setting.new_record?
        logger.info "Adding sensemaking feature flag..."
        setting.value = "true"
        setting.save!
        logger.info "Feature flag added."
      else
        logger.info "Feature flag already exists, enabling sensemaking..."
        setting.update!(value: "true")
        logger.info "Sensemaking enabled using feature.sensemaking setting."
      end
    end
end
