class SensemakerService
  attr_reader :job

  SENSEMAKING_FOLDER = Rails.root.join("vendor", "sensemaking-tools").freeze

  def initialize(job)
    @job = job
  end

  def run
    prepare_input_data
    return unless check_dependencies
    return unless execute_script

    process_output
    job.update!(finished_at: Time.current)
  rescue Exception => e
    handle_error(e)
    raise e
  end
  handle_asynchronously :run, queue: "sensemaking"

  def input_file
    "#{SENSEMAKING_FOLDER}/sensemaker-input.csv"
  end

  def key_file
    "#{SENSEMAKING_FOLDER}/sensemaker-key.json" # TODO we'll get this from the config
  end

  def output_file
    "#{SENSEMAKING_FOLDER}/sensemaker-output.csv"
  end

  def script_file
    "#{SENSEMAKING_FOLDER}/library/runner-cli/#{job.script}"
  end

  private

    def prepare_input_data
      # For the initial implementation, we assume the input data is already prepared
      # at a fixed location with the name sensemaker-input.csv
      # No export logic needed at this stage
    end

    def check_dependencies
      # Check if Node.js and NPX are available
      unless system("which node > /dev/null 2>&1")
        error_message = "Node.js not found. Please install Node.js to use the Sensemaker feature."
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      unless system("which npx > /dev/null 2>&1")
        error_message = "NPX not found. Please install NPX to use the Sensemaker feature."
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      # Check if the required files exist
      unless File.exist?(SENSEMAKING_FOLDER)
        error_message = "Sensemaking folder not found: #{SENSEMAKING_FOLDER}"
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      unless File.exist?(input_file)
        error_message = "Input file not found: #{input_file}"
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      unless File.exist?(key_file)
        error_message = "Key file not found: #{key_file}"
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      unless File.exist?(script_file)
        error_message = "Script file not found: #{script_file}"
        job.update!(finished_at: Time.current, error: error_message)
        Rails.logger.error(error_message)
        return false
      end

      true
    end

    def test_hello
      system("echo \"Hello, world!\"")
    end

    def execute_script
      model_name = "gemini-2.5-flash-lite" # TODO we'll get this from the config
      additional_context = job.additional_context.presence
      # Construct the command with proper paths and parameters # TODO get vars from the config
      command = %Q(npx ts-node #{script_file} \
                 --vertexProject "sensemaker-466109" \
                 --outputFile #{output_file} \
                 --inputFile #{input_file} \
                 --modelName #{model_name} \
                 --keyFilename #{key_file})
      command += " --additionalContext \"#{additional_context}\"" if additional_context.present?

      # Execute the command
      output = `cd #{SENSEMAKING_FOLDER} && #{command} 2>&1`
      result = process_exit_status

      if result.eql?(0)
        true
      else
        # Error
        job.update!(finished_at: Time.current, error: output)
        Rails.logger.error("SensemakerService error: #{output}")
        false
      end
    end

    def process_output
      if File.exist?(output_file)
        # Process the output file - in a real implementation, this would
        # parse the output and potentially store results in the database OR just check it was ok

        # For now, just update the SensemakerInfo record
        SensemakerInfo.find_or_create_by!(kind: "categorization",
                                          commentable_type: job.commentable_type,
                                          commentable_id: job.commentable_id)
                      .update!(generated_at: job.started_at, script: job.script)

        true
      else
        job.update!(finished_at: Time.current, error: "Output file not found")
        false
      end
    end

    def handle_error(error)
      message = error.message
      backtrace = error.backtrace.select { |line| line.include?("sensemaker_service.rb") }
      full_error = ([message] + backtrace).join("<br>")
      job.update!(finished_at: Time.current, error: full_error)
    end

    def process_exit_status
      $?.exitstatus
    end
end
