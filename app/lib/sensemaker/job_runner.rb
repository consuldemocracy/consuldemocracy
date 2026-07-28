require "shellwords"

module Sensemaker
  class JobRunner
    TIMEOUT = 1800
    attr_reader :job

    SCRIPTS = [
      "health_check_runner.ts",
      "categorization_runner.ts",
      "runner.ts",
      "advanced_runner.ts",
      "sensemaking-report-ui"
    ].freeze

    def initialize(job)
      @job = job
    end

    def run
      execute_job_workflow
    end
    handle_asynchronously :run, queue: "sensemaker"

    def run_synchronously
      execute_job_workflow
    end

    def max_attempts
      1
    end

    def output_file_name
      job.output_file_name
    end

    def output_file
      "#{Sensemaker::Paths.sensemaker_data_folder}/#{output_file_name}"
    end

    def script_file
      if job.script == "sensemaking-report-ui"
        "#{Sensemaker::Paths.report_ui_folder}/bin/cli.js"
      else
        "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/#{job.script}"
      end
    end

    def sensemaker_adapter
      runtime_config.adapter
    end

    def sensemaker_provider
      runtime_config.compat_provider
    end

    def sensemaker_api_key
      runtime_config.api_key
    end

    def sensemaker_base_url
      runtime_config.base_url
    end

    def self.enabled?
      Sensemaker.enabled?
    end

    def build_command
      if job.script == "sensemaking-report-ui"
        conversation = job.conversation
        target_label = conversation.target_label(format: :full)
        base = job.input_file
        data_folder = Sensemaker::Paths.sensemaker_data_folder

        return [
          "npx sensemaking-report-ui inline",
          "--topics #{Shellwords.escape("#{base}-topic-stats.json")}",
          "--summary #{Shellwords.escape("#{base}-summary.json")}",
          "--comments #{Shellwords.escape("#{base}-comments-with-scores.json")}",
          "--metadata #{Shellwords.escape("#{base}-metadata.json")}",
          "--reportTitle #{Shellwords.escape("Report for #{target_label}")}",
          "--outputDir #{Shellwords.escape(data_folder.to_s)}",
          "--outputFile #{Shellwords.escape(output_file_name)}"
        ].join(" ")
      end

      model_name = runtime_config.model
      additional_context = nil
      additional_context = job.additional_context.presence unless job.script == "health_check_runner.ts"

      command_parts = ["npx ts-node #{script_file}"]
      command_parts << "--modelName #{Shellwords.escape(model_name)}" if model_name.present?

      case sensemaker_adapter
      when "vertex"
        command_parts << "--adapter vertex"
        command_parts << "--vertexProject #{Shellwords.escape(runtime_config.vertex_project_id)}"
        command_parts << "--vertexLocation #{Shellwords.escape(runtime_config.vertex_location)}"
      when "openai-compatible"
        command_parts << "--adapter openai-compatible"
        command_parts << "--provider #{Shellwords.escape(sensemaker_provider)}"
        command_parts << "--apiKey #{Shellwords.escape(sensemaker_api_key)}" if sensemaker_api_key.present?
      when "ollama"
        command_parts << "--adapter ollama"
      end
      command_parts << "--baseUrl #{Shellwords.escape(sensemaker_base_url)}" if sensemaker_base_url.present?

      command = command_parts.join(" ")
      command += " --inputFile #{job.input_file}" unless job.script == "health_check_runner.ts"
      if additional_context.present?
        command += " --additionalContext #{Shellwords.escape(additional_context.to_s)}"
      end
      if ["advanced_runner.ts", "runner.ts"].include?(job.script)
        command += " --outputBasename #{output_file}"
      else
        command += " --outputFile #{output_file}"
      end

      command
    end

    private

      def llm_context
        @llm_context ||= Llm::Config.context
      end

      def runtime_config
        @runtime_config ||= Sensemaker::RuntimeConfig.new(setting: Setting, llm_context: llm_context)
      end

      def execute_job_workflow
        job.update!(started_at: Time.current)

        comments_prepared_count = prepare_input_data
        return unless check_dependencies?
        return if execute_script.blank?

        attribs = { finished_at: Time.current }
        if job.has_outputs?
          attribs[:comments_analysed] = comments_prepared_count
        else
          attribs = attribs.merge(error: "Output file(s) not found")
        end
        job.update!(attribs)
      rescue Exception => e
        handle_error(e)
        raise e
      end

      def prepare_with_categorization_job
        categorization_job = Sensemaker::Job.create!(
          user: job.user,
          parent_job: job,
          analysable_type: job.analysable_type,
          analysable_id: job.analysable_id,
          script: "categorization_runner.ts",
          additional_context: job.additional_context
        )

        categorization_runner = Sensemaker::JobRunner.new(categorization_job)
        categorization_runner.run_synchronously

        if categorization_job.reload.errored?
          raise "Preparation job #{categorization_job.id} failed"
        end

        job.input_file = categorization_runner.output_file
        job.save!

        categorization_job.comments_analysed
      end

      def prepare_with_advanced_runner_job
        advanced_job = Sensemaker::Job.create!(
          user: job.user,
          parent_job: job,
          analysable_type: job.analysable_type,
          analysable_id: job.analysable_id,
          script: "advanced_runner.ts",
          additional_context: job.additional_context
        )

        advanced_runner = Sensemaker::JobRunner.new(advanced_job)
        advanced_runner.run_synchronously

        if advanced_job.reload.errored?
          raise "Preparation job #{advanced_job.id} failed"
        end

        job.input_file = advanced_runner.output_file
        job.save!

        advanced_job.comments_analysed
      end

      def prepare_input_data
        conversation = job.conversation
        comments_prepared_count = 0
        persisted_input_missing = job.read_attribute(:input_file).blank?

        if job.additional_context.blank?
          job.update!(additional_context: conversation.compile_context)
        end

        if persisted_input_missing && job.script.eql?("advanced_runner.ts")
          comments_prepared_count = prepare_with_categorization_job
        elsif persisted_input_missing && job.script.eql?("sensemaking-report-ui")
          comments_prepared_count = prepare_with_advanced_runner_job
        elsif persisted_input_missing
          comments_prepared_count = conversation.comments.size
          generated_input_path = job.input_file
          exporter = Sensemaker::CsvExporter.new(conversation)
          exporter.export_to_csv(generated_input_path)
          job.update!(input_file: generated_input_path)
        end

        if job.script.eql?("advanced_runner.ts")
          comments_prepared_count = Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(job.input_file)
        end

        write_report_metadata if job.script.eql?("sensemaking-report-ui")

        comments_prepared_count
      end

      def write_report_metadata
        metadata_path = "#{job.input_file}-metadata.json"
        return if File.exist?(metadata_path)

        conversation = job.conversation
        title = conversation.target_label(format: :full)
        File.write(metadata_path, { title: title }.to_json)
      end

      def check_dependencies?
        if Tenant.current_secrets.sensemaker_data_folder.blank?
          message = "Sensemaker data folder not configured. Add 'sensemaker_data_folder' to your secrets.yml"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if sensemaker_adapter == "vertex" && runtime_config.vertex_project_id.blank?
          message = "Vertex AI is not configured. Set tenant secrets llm.vertexai_project_id " \
                    "(and optionally vertexai_location)."
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if sensemaker_adapter.blank?
          message = "Sensemaker LLM provider is not supported. Current provider: " \
                    "#{runtime_config.provider.presence || "(not set)"}."
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if runtime_config.model.blank?
          message = "Sensemaker requires an LLM model to be selected. Set it in Admin → Settings → LLM."
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if sensemaker_adapter == "openai-compatible" && sensemaker_api_key.blank?
          message = "Sensemaker requires an API key for provider '#{sensemaker_provider}'. " \
                    "Set tenant secret llm.#{sensemaker_provider}_api_key."
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        key_path = Rails.application.secrets.google_application_credentials
        if key_path.present?
          path = (File.expand_path(key_path) == key_path) ? key_path : Rails.root.join(key_path).to_s
          return false unless file_exists?(path,
                                           description: "Key file (apis.google_application_credentials)")
        end

        unless system("which node > /dev/null 2>&1")
          message = "Node.js not found. Install Node.js to use the Sensemaker feature."
          message += "\nPATH: #{ENV["PATH"]}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        unless system("which npx > /dev/null 2>&1")
          message = "NPX not found. Install NPX to use the Sensemaker feature."
          message += "\nPATH: #{ENV["PATH"]}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        return false unless file_exists?(Sensemaker::Paths.sensemaker_package_folder,
                                         description: "sensemaking-tools package folder")
        return false unless file_exists?(Sensemaker::Paths.sensemaker_data_folder,
                                         description: "Sensemaker data folder")

        if job.script == "sensemaking-report-ui"
          return false unless file_exists?(Sensemaker::Paths.report_ui_folder,
                                           description: "sensemaking-report-ui package folder")

          job.input_artefact_paths.each do |artefact_path|
            return false unless file_exists?(artefact_path, description: "Report input artefact")
          end
        else
          return false unless file_exists?(job.input_file, description: "Input file")
        end

        return false unless file_exists?(script_file, description: "Script file")

        true
      end

      def execute_script
        target_folder = if job.script == "sensemaking-report-ui"
                          Rails.root
                        else
                          Sensemaker::Paths.sensemaker_package_folder
                        end

        command = "cd #{target_folder} && timeout #{TIMEOUT} #{build_command}"
        Rails.logger.debug("Executing script: #{redact_command(command)}")
        output = `#{command} 2>&1`

        result = process_exit_status
        if result.eql?(0)
          Rails.logger.debug("Script executed successfully: #{output}")
          output
        else
          output = "Timeout: #{TIMEOUT} seconds\n#{output}" if result.eql?(124)
          output = output.truncate(20000)
          message = "Command: #{redact_command(command)}\n\n#{output}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error("Sensemaker::JobRunner error: #{output}")
          nil
        end
      end

      def handle_error(error)
        message = error.message
        backtrace = error.backtrace.select { |line| line.include?("job_runner.rb") }
        full_error = ([message] + backtrace).join("<br>")
        job.update!(finished_at: Time.current, error: full_error)
      end

      def process_exit_status
        $?.exitstatus
      end

      def file_exists?(file_path, description: "File or directory")
        return true if File.exist?(file_path)

        message = "#{description} not found: #{file_path}"
        job.update!(finished_at: Time.current, error: message)
        Rails.logger.error(message)
        false
      end

      def redact_command(command)
        command.to_s.gsub(/--apiKey\s+\S+/, "--apiKey [REDACTED]")
      end
  end
end
