module Sensemaker
  class JobRunner
    attr_reader :job

    SCRIPTS = [
      "health_check_runner.ts",
      "runner.ts",
      "advanced_runner.ts",
      "categorization_runner.ts"
    ].freeze

    def initialize(job)
      @job = job
    end

    def self.sensemaker_folder
      Rails.root.join("vendor/sensemaking-tools")
    end

    def self.sensemaker_data_folder
      Rails.root.join(Tenant.current_secrets.sensemaker_data_folder)
    end

    def run
      prepare_input_data
      return unless check_dependencies?
      return if execute_script.blank?

      process_output
      job.update!(finished_at: Time.current)
    rescue Exception => e
      handle_error(e)
      raise e
    end
    handle_asynchronously :run, queue: "sensemaker"

    def input_file
      "#{self.class.sensemaker_data_folder}/input-#{job.id}.csv"
    end

    def output_file
      "#{self.class.sensemaker_data_folder}/output-#{job.id}.csv"
    end

    def script_file
      "#{self.class.sensemaker_folder}/library/runner-cli/#{job.script}"
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

    def self.compile_context(commentable)
      parts = []

      commentable_type = commentable.class.name.humanize
      parts << "Analyzing citizen #{commentable_type} from Consul Democracy platform"
      parts << "#{commentable_type}: #{commentable.title}"

      if commentable.respond_to?(:summary)
        parts << "Summary: #{commentable.summary}"
      end

      if commentable.respond_to?(:description) && commentable.description.present?
        parts << "Description: #{commentable.description}" # TODO: consider strip tags?
      end

      if commentable.respond_to?(:text) && commentable.text.present?
        parts << "Text: #{commentable.text}"
      end

      if commentable.author.present?
        parts << "Author: #{commentable.author.username}"
      end

      if commentable.respond_to?(:geozone) && commentable.geozone.present?
        parts << "Location: #{commentable.geozone.name}"
      end

      if commentable.respond_to?(:tag_list) && commentable.tag_list.any?
        parts << "Tags: #{commentable.tag_list.join(", ")}"
      end

      if commentable.respond_to?(:cached_votes_up)
        parts << "Support votes: #{commentable.cached_votes_up || 0}"
      end

      if commentable.respond_to?(:cached_votes_down)
        parts << "Opposition votes: #{commentable.cached_votes_down || 0}"
      end

      parts << "Comments: #{commentable.comments_count || 0}"

      parts << "Created: #{commentable.created_at.strftime("%B %d, %Y")}"

      if commentable.respond_to?(:published?) && commentable.published?
        parts << "Published: #{commentable.published_at.strftime("%B %d, %Y")}"
      end

      parts.join("\n")
    end

    private

      def prepare_input_data
        exporter = Sensemaker::CsvExporter.new(job.commentable)
        exporter.export_to_csv(input_file)
        job.update!(additional_context: self.class.compile_context(job.commentable))
      end

      def check_dependencies?
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
        unless File.exist?(self.class.sensemaker_folder)
          error_message = "sensemaking-tools folder not found: #{self.class.sensemaker_folder}"
          job.update!(finished_at: Time.current, error: error_message)
          Rails.logger.error(error_message)
          return false
        end

        unless File.exist?(self.class.sensemaker_data_folder)
          error_message = "Sensemaker data folder not found: #{self.class.sensemaker_data_folder}"
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

        if parse_key_file.blank?
          error_message = "Key file is invalid: #{key_file}"
          job.update!(finished_at: Time.current, error: error_message)
          Rails.logger.error(error_message)
          return false
        end

        if project_id.blank?
          error_message = "Key file is missing project_id: #{key_file}"
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

      def execute_script
        model_name = Tenant.current_secrets.sensemaker_model_name
        additional_context = nil
        additional_context = job.additional_context.presence unless job.script == "health_check_runner.ts"

        command = %Q(npx ts-node #{script_file} \
                   --vertexProject #{project_id} \
                   --outputFile #{output_file} \
                   --modelName #{model_name} \
                   --keyFilename #{key_file})
        command += " --inputFile #{input_file}" unless job.script == "health_check_runner.ts"
        command += " --additionalContext \"#{additional_context}\"" if additional_context.present?

        # Execute the command
        output = `cd #{self.class.sensemaker_folder} && #{command} 2>&1`
        result = process_exit_status

        if result.eql?(0)
          output
        else
          job.update!(finished_at: Time.current, error: output)
          Rails.logger.error("Sensemaker::JobRunner error: #{output}")
          nil
        end
      end

      def process_output
        if File.exist?(output_file)
          # Process the output file - in a real implementation, this would
          # parse the output and potentially store results in the database OR just check it was ok
          # For now, just update the Sensemaker::Info record
          sensemaker_info = Sensemaker::Info.find_or_create_by!(kind: "categorization",
                                                                commentable_type: job.commentable_type,
                                                                commentable_id: job.commentable_id)
          sensemaker_info.update!(generated_at: job.started_at, script: job.script)

          sensemaker_info
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
  end
end
