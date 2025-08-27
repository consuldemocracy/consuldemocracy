namespace :sensemaker do
  desc "Setup Sensemaking Tools"
  task setup: :environment do
    logger = ApplicationLogger.new
    logger.info "Setting up Sensemaking Tools..."

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

    setup_directories(sensemaker_path, data_path, logger)

    clone_or_update_repository(sensemaker_path, logger)

    install_dependencies(sensemaker_path, logger)

    set_file_permissions(sensemaker_path, data_path, logger)

    add_feature_flag(logger)

    logger.info "Sensemaking Tools setup complete!"
  end

  desc "Check if Sensemaking Tools dependencies are available"
  task check_dependencies: :environment do
    logger = ApplicationLogger.new
    check_dependencies(logger)
  end

  private

    def check_dependencies(logger)
      logger.info "Checking environment dependencies..."

      # Check if Node.js is available
      unless system("which node > /dev/null 2>&1")
        logger.error "Node.js not found. Please install Node.js to use the Sensemaker feature."
        raise "Node.js not found. Please install Node.js to use the Sensemaker feature."
      end
      logger.info "✓ Node.js found: #{`node --version`.strip}"

      # Check if npm is available
      unless system("which npm > /dev/null 2>&1")
        logger.error "npm not found. Please install npm to use the Sensemaker feature."
        raise "npm not found. Please install npm to use the Sensemaker feature."
      end
      logger.info "✓ npm found: #{`npm --version`.strip}"

      # Check if npx is available
      unless system("which npx > /dev/null 2>&1")
        logger.error "npx not found. Please install npx to use the Sensemaker feature."
        raise "npx not found. Please install npx to use the Sensemaker feature."
      end
      logger.info "✓ npx found: #{`npx --version`.strip}"

      logger.info "All dependencies are available."
    end

    def setup_directories(sensemaker_path, data_path, logger)
      logger.info "Setting up directory structure..."

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
          logger.warn "WARNING: vendor/sensemaking-tools is not properly linked to shared/vendor/sensemaking-tools"
          logger.warn "Make sure 'vendor/sensemaking-tools' is included in :linked_dirs in config/deploy.rb"
          logger.warn "Changes to sensemaking-tools will be lost on next deployment if this is not fixed"
        end
      end

      # Create directory if it doesn't exist (for both Capistrano and non-Capistrano environments)
      FileUtils.mkdir_p(sensemaker_path) unless File.directory?(sensemaker_path)

      # Create data directory if it doesn't exist
      FileUtils.mkdir_p(data_path) unless File.directory?(data_path)

      logger.info "Directory structure created."
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
            logger.error "Failed to update repository."
            raise "Failed to update repository."
          end
        end
      else
        logger.info "Cloning sensemaking-tools repository..."
        system("git clone #{repo_url} #{sensemaker_path}")

        if $?.success?
          logger.info "Repository cloned successfully."
        else
          logger.error "Failed to clone repository."
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
            logger.error "Failed to install dependencies."
            raise "Failed to install dependencies."
          end
        end
      else
        logger.error "Library directory not found at #{library_path}"
        raise "Library directory not found at #{library_path}"
      end

      # Verify installation by running a test command
      Dir.chdir(library_path) do
        system("npx ts-node ./runner-cli/categorization_runner.ts --help > /dev/null 2>&1")

        if $?.success?
          logger.info "Sensemaker CLI tool is working correctly."
        else
          logger.error "Failed to run sensemaker CLI tool. Please check the installation."
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
      if defined?(Setting) && !Setting.where(key: "feature.sensemaker").exists?
        logger.info "Adding sensemaker feature flag..."
        Setting.create!(
          key: "feature.sensemaker",
          value: nil,
          kind: "boolean"
        )
        logger.info "Feature flag added."
      else
        logger.info "Feature flag already exists."
      end
    end
end
