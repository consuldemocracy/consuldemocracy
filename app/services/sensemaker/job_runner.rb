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

    def output_file_name
      if job.script == "health_check_runner.ts"
        "health-check-#{job.id}.txt"
      elsif job.script == "advanced_runner.ts"
        "output-#{job.id}" # advanced runner has multiple output files
      else
        "output-#{job.id}.csv"
      end
    end

    def output_file
      "#{self.class.sensemaker_data_folder}/#{output_file_name}"
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

    def self.compile_context(target)
      parts = []

      target_type = target.class.name.humanize
      parts << I18n.t("sensemaker.context.base", type: target_type)

      if target.respond_to?(:title)
        parts << I18n.t("sensemaker.context.title", title: target.title)
      elsif target.respond_to?(:name)
        parts << I18n.t("sensemaker.context.name", name: target.name)
      else
        raise "Target #{target.class.name} does not respond to title or name"
      end

      if target.respond_to?(:summary)
        parts << I18n.t("sensemaker.context.summary", summary: target.summary)
      end

      if target.respond_to?(:description) && target.description.present?
        parts << I18n.t("sensemaker.context.description", description: target.description)
      end

      if target.respond_to?(:text) && target.text.present?
        parts << I18n.t("sensemaker.context.text", text: target.text)
      end

      parts.concat(compile_class_specific_context(target))

      parts << "\n--Meta--"
      if target.respond_to?(:geozone) && target.geozone.present?
        parts << I18n.t("sensemaker.context.location", location: target.geozone.name)
      end
      if target.respond_to?(:tag_list) && target.tag_list.any?
        parts << I18n.t("sensemaker.context.tags", tags: target.tag_list.join(", "))
      end
      parts << I18n.t("sensemaker.context.comments", count: target.comments_count || 0)
      parts << I18n.t("sensemaker.context.created", date: target.created_at.strftime("%B %d, %Y"))
      if target.respond_to?(:published?) && target.published?
        parts << I18n.t("sensemaker.context.published", date: target.published_at.strftime("%B %d, %Y"))
      end

      parts.join("\n")
    end

    def self.compile_class_specific_context(target)
      parts = []

      case target.class.name
      when "Poll"
        parts << I18n.t("sensemaker.context.poll.questions_header") if target.questions.any?
        target.questions.each do |question|
          parts << I18n.t("sensemaker.context.poll.question_title", title: question.title)
          question.question_options.each do |question_option|
            parts << I18n.t("sensemaker.context.poll.question_option",
                            title: question_option.title,
                            total_votes: question_option.total_votes)
          end
        end
      when "Proposal"
        parts << I18n.t("sensemaker.context.proposal.votes",
                        total_votes: target.total_votes,
                        required_votes: Proposal.votes_needed_for_success)
      when "Debate"
        parts << I18n.t("sensemaker.context.debate.votes",
                        votes_up: target.cached_votes_up,
                        votes_down: target.cached_votes_down)
      when "Legislation::Question"
        parts << I18n.t("sensemaker.context.legislation_question.process",
                        process_title: target.process.title)
        if target.question_options.any?
          parts << I18n.t("sensemaker.context.legislation_question.responses_header")
          target.question_options.each do |option|
            parts << I18n.t("sensemaker.context.legislation_question.option",
                            value: option.value,
                            answers_count: option.answers_count)
          end
        end
      when "Legislation::Proposal"
        parts << I18n.t("sensemaker.context.legislation_proposal.process",
                        process_title: target.process.title)
        parts << I18n.t("sensemaker.context.legislation_proposal.votes",
                        votes_up: target.cached_votes_up,
                        votes_down: target.cached_votes_down)
      end

      parts
    end

    private

      def prepare_input_data
        exporter = Sensemaker::CsvExporter.new(job.commentable)
        exporter.export_to_csv(input_file)
        if job.additional_context.blank?
          job.update!(additional_context: self.class.compile_context(job.commentable))
        end
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

      def build_command
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

      def execute_script
        # Execute the command
        output = `cd #{self.class.sensemaker_folder} && #{build_command} 2>&1`
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
