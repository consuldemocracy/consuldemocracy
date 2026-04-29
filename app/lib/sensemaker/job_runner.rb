require "shellwords"

module Sensemaker
  class JobRunner
    TIMEOUT = 1800
    attr_reader :job, :backend

    def initialize(job)
      @job = job
      @runtime_config = Sensemaker::RuntimeConfig.new(
        setting: Setting,
        llm_context: Llm::Config.context
      )
      @backend = Sensemaker::Backend.for(
        job,
        runtime_config: @runtime_config
      )
    end

    def run
      execute_job_workflow
    end
    handle_asynchronously :run, queue: "sensemaker"

    def run_synchronously
      execute_job_workflow
    end

    def artefacts
      job.artefacts
    end

    def output_file_name
      artefacts.output_file_name
    end

    def output_file
      artefacts.default_output_path
    end

    def self.enabled?
      Sensemaker.enabled?
    end

    private

      def runtime_config
        @runtime_config
      end

      def execute_job_workflow
        job.update!(started_at: Time.current)
        artefacts.ensure_directory!

        comments_prepared_count = prepare_input_data
        return unless check_dependencies?
        return if execute_script.blank?

        attribs = { finished_at: Time.current }
        if artefacts.complete?
          attribs[:comments_analysed] = comments_prepared_count
        else
          attribs = attribs.merge(error: "Output file(s) not found")
        end
        job.update!(attribs)
      rescue Exception => e
        handle_error(e)
        raise e
      end

      def prepare_with_prep_job(prep_script)
        prep_job = Sensemaker::Job.create!(
          user: job.user,
          parent_job: job,
          analysable_type: job.analysable_type,
          analysable_id: job.analysable_id,
          script: prep_script,
          additional_context: job.additional_context
        )

        prep_runner = Sensemaker::JobRunner.new(prep_job)
        prep_runner.run_synchronously

        if prep_job.reload.errored?
          raise "Preparation job #{prep_job.id} failed"
        end

        job.input_file = prep_runner.output_file
        job.save!

        prep_job.comments_analysed
      end

      def prepare_input_data
        conversation = job.conversation
        comments_prepared_count = 0
        persisted_input_missing = job.read_attribute(:input_file).blank?
        prep_script = Sensemaker::ScriptRegistry.prep_steps(job.script).first

        if job.additional_context.blank?
          job.update!(additional_context: conversation.compile_context)
        end

        if persisted_input_missing && prep_script
          comments_prepared_count = prepare_with_prep_job(prep_script)
        elsif persisted_input_missing
          comments_prepared_count = conversation.comments.size
          generated_input_path = artefacts.input_path
          exporter = Sensemaker::CsvExporter.new(conversation)
          exporter.export_to_csv(generated_input_path)
          job.update!(input_file: generated_input_path)
        end

        after_prep_count = backend.after_input_prepared
        comments_prepared_count = after_prep_count unless after_prep_count.nil?

        comments_prepared_count
      end

      def check_dependencies?
        if Tenant.current_secrets.sensemaker_data_folder.blank?
          job.record_error!(
            "Sensemaker data folder not configured. Add 'sensemaker_data_folder' to your secrets.yml"
          )
          return false
        end

        adapter = runtime_config.adapter

        if adapter == "vertex" && runtime_config.vertex_project_id.blank?
          job.record_error!(
            "Vertex AI is not configured. Set tenant secrets llm.vertexai_project_id " \
            "(and optionally vertexai_location)."
          )
          return false
        end

        if adapter.blank?
          job.record_error!(
            "Sensemaker LLM provider is not supported. Current provider: " \
            "#{runtime_config.provider.presence || "(not set)"}."
          )
          return false
        end

        if runtime_config.model.blank?
          job.record_error!(
            "Sensemaker requires an LLM model to be selected. Set it in Admin → Settings → LLM."
          )
          return false
        end

        if adapter == "openai-compatible" && runtime_config.api_key.blank?
          job.record_error!(
            "Sensemaker requires an API key for provider '#{runtime_config.compat_provider}'. " \
            "Set tenant secret llm.#{runtime_config.compat_provider}_api_key."
          )
          return false
        end

        key_path = Rails.application.secrets.google_application_credentials
        if key_path.present?
          path = (File.expand_path(key_path) == key_path) ? key_path : Rails.root.join(key_path).to_s
          return false unless file_exists?(path,
                                           description: "Key file (apis.google_application_credentials)")
        end

        backend.check_runtime_dependencies?
      end

      def execute_script
        target_folder = backend.working_directory
        command = "cd #{target_folder} && timeout #{TIMEOUT} #{backend.build_command}"
        Rails.logger.debug("Executing script: #{backend.redact_command(command)}")
        output = `#{command} 2>&1`

        result = process_exit_status
        if result.eql?(0)
          Rails.logger.debug("Script executed successfully: #{output}")
          output
        else
          output = "Timeout: #{TIMEOUT} seconds\n#{output}" if result.eql?(124)
          output = output.truncate(20000)
          message = "Command: #{backend.redact_command(command)}\n\n#{output}"
          job.record_error!(message)
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

        job.record_error!("#{description} not found: #{file_path}")
        false
      end
  end
end
