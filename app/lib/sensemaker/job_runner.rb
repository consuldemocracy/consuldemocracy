module Sensemaker
  class JobRunner
    TIMEOUT = 900
    attr_reader :job

    SCRIPTS = [
      "health_check_runner.ts",
      "categorization_runner.ts",
      "runner.ts",
      "advanced_runner.ts",
      "single-html-build.js"
    ].freeze

    def initialize(job)
      @job = job
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
        Rails.root.join("vendor/sensemaking-tools/web-ui")
      end
    end

    def run
      execute_job_workflow
    end
    handle_asynchronously :run, queue: "sensemaker"

    def run_synchronously
      execute_job_workflow
    end

    def input_file
      if job.input_file.present?
        job.input_file
      elsif job.script == "advanced_runner.ts"
        "#{self.class.sensemaker_data_folder}/categorization-output-#{job.id}.csv"
      elsif job.script == "single-html-build.js"
        "#{self.class.sensemaker_data_folder}/advanced-output"
      else
        "#{self.class.sensemaker_data_folder}/input-#{job.id}.csv"
      end
    end

    def output_file_name
      case job.script
      when "health_check_runner.ts"
        "health-check-#{job.id}.txt"
      when "advanced_runner.ts"
        "output-#{job.id}" # advanced runner has multiple output files
      when "categorization_runner.ts"
        "categorization-output-#{job.id}.csv"
      when "single-html-build.js"
        "report.html"
      else
        "output-#{job.id}.csv"
      end
    end

    def output_file
      if job.script == "single-html-build.js"
        "#{self.class.visualization_folder}/dist/bundled/report.html"
      else
        "#{self.class.sensemaker_data_folder}/#{output_file_name}"
      end
    end

    def script_file
      if job.script == "single-html-build.js"
        "#{self.class.visualization_folder}/single-html-build.js"
      else
        "#{self.class.sensemaker_folder}/library/runner-cli/#{job.script}"
      end
    end

    def self.key_file
      Rails.root.join(Tenant.current_secrets.sensemaker_key_file)
    end

    def self.parse_key_file
      key_file_content = File.read(key_file)
      JSON.parse(key_file_content)
    rescue JSON::ParserError
      {}
    end

    def project_id
      parse_key_file.fetch("project_id", "")
    end

    def key_file
      Sensemaker::JobRunner.key_file
    end

    def parse_key_file
      Sensemaker::JobRunner.parse_key_file
    end

    def self.enabled?
      Setting["feature.sensemaker"].present?
    end

    def build_command
      if job.script == "single-html-build.js"
        conversation = job.conversation
        target_label = conversation.target_label(format: :full)

        return %Q(npx ts-node site-build.ts \
                 --topics #{input_file}-topic-stats.json \
                 --summary #{input_file}-summary.json \
                 --comments #{input_file}-comments-with-scores.json \
                 --reportTitle "Report for #{target_label}" && \
                 npx ts-node single-html-build.js)
      end

      model_name = Tenant.current_secrets.sensemaker_model_name
      additional_context = nil
      additional_context = job.additional_context.presence unless job.script == "health_check_runner.ts"

      command = %Q(npx ts-node #{script_file} \
                 --vertexProject #{project_id} \
                 --modelName #{model_name} \
                 --keyFilename #{key_file})
      command += " --inputFile #{input_file}" unless job.script == "health_check_runner.ts"
      command += " --additionalContext \"#{additional_context}\"" if additional_context.present?
      if job.script == "advanced_runner.ts"
        command += " --outputBasename #{output_file}"
      else
        command += " --outputFile #{output_file}"
      end

      command
    end

    private

      def execute_job_workflow
        job.update!(started_at: Time.current)

        prepare_input_data
        return unless check_dependencies?
        return if execute_script.blank?

        process_output
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
      end

      def prepare_input_data
        conversation = job.conversation

        if job.additional_context.blank?
          job.update!(additional_context: conversation.compile_context)
        end

        if job.input_file.blank? && job.script.eql?("advanced_runner.ts")
          prepare_with_categorization_job
        elsif job.input_file.blank? && job.script.eql?("single-html-build.js")
          prepare_with_advanced_runner_job
        elsif job.input_file.blank?
          exporter = Sensemaker::CsvExporter.new(conversation)
          exporter.export_to_csv(input_file)
        end

        if job.script.eql?("advanced_runner.ts")
          Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(input_file)
        end
      end

      def check_dependencies?
        if Tenant.current_secrets.sensemaker_data_folder.blank?
          message = "Sensemaker data folder not configured. Add 'sensemaker_data_folder' to your secrets.yml"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if Tenant.current_secrets.sensemaker_key_file.blank?
          message = "Sensemaker key file not configured. Add 'sensemaker_key_file' to your secrets.yml"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if Tenant.current_secrets.sensemaker_model_name.blank?
          message = "Sensemaker model name not configured. Add 'sensemaker_model_name' to your secrets.yml"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
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

        return false unless file_exists?(self.class.sensemaker_folder,
                                         description: "sensemaking-tools folder")
        return false unless file_exists?(self.class.sensemaker_data_folder,
                                         description: "Sensemaker data folder")

        if job.script == "single-html-build.js"
          return false unless file_exists?(self.class.visualization_folder,
                                           description: "Visualization folder")
          return false unless file_exists?(input_file + "-topic-stats.json",
                                           description: "Input file - topic stats")
          return false unless file_exists?(input_file + "-summary.json",
                                           description: "Input file - summary")
          return false unless file_exists?(input_file + "-comments-with-scores.json",
                                           description: "Input file - comments with scores")
        else
          return false unless file_exists?(input_file, description: "Input file")
        end

        return false unless file_exists?(key_file, description: "Key file")

        if parse_key_file.blank?
          message = "Key file is invalid: #{key_file}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        if project_id.blank?
          message = "Key file is missing project_id: #{key_file}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error(message)
          return false
        end

        return false unless file_exists?(script_file, description: "Script file")

        true
      end

      def execute_script
        target_folder = self.class.sensemaker_folder
        target_folder = self.class.visualization_folder if job.script == "single-html-build.js"

        command = "cd #{target_folder} && timeout #{TIMEOUT} #{build_command}"
        Rails.logger.debug("Executing script: #{command}")
        output = `#{command} 2>&1`

        result = process_exit_status
        if result.eql?(0)
          Rails.logger.debug("Script executed successfully: #{output}")
          output
        else
          output = "Timeout: #{TIMEOUT} seconds\n#{output}" if result.eql?(124)
          output = output.truncate(20000)
          message = "Command: #{command}\n\n#{output}"
          job.update!(finished_at: Time.current, error: message)
          Rails.logger.error("Sensemaker::JobRunner error: #{output}")
          nil
        end
      end

      def process_output
        if job.script == "advanced_runner.ts"
          path_to_check = "#{output_file}-summary.json"
        else
          path_to_check = output_file
        end

        if File.exist?(path_to_check)
          if job.script == "single-html-build.js"
            final_output_path = "#{self.class.sensemaker_data_folder}/report-#{job.id}.html"
            FileUtils.cp(path_to_check, final_output_path)
            job.update!(finished_at: Time.current, persisted_output: final_output_path)
          else
            job.update!(finished_at: Time.current, persisted_output: path_to_check)
          end

          true
        else
          job.update!(finished_at: Time.current, error: "Output file not found")
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
  end
end
