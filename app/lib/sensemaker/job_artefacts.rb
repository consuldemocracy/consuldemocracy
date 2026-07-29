module Sensemaker
  class JobArtefacts
    attr_reader :job

    SCRIPT_CONFIG = {
      "health_check_runner.ts" => {
        output_basename: ->(job) { "health-check-#{job.id}.txt" },
        output_suffixes: [],
        default_input_path: nil,
        input_suffixes: []
      },
      "categorization_runner.ts" => {
        output_basename: ->(job) { "categorization-output-#{job.id}.csv" },
        output_suffixes: [],
        default_input_path: ->(job) { "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv" },
        input_suffixes: []
      },
      "advanced_runner.ts" => {
        output_basename: ->(job) { "output-#{job.id}" },
        output_suffixes: %w[-summary.json -topic-stats.json -comments-with-scores.json],
        default_input_path: ->(job) {
          "#{Sensemaker::Paths.sensemaker_data_folder}/categorization-output-#{job.id}.csv"
        },
        input_suffixes: []
      },
      "runner.ts" => {
        output_basename: ->(job) { "output-#{job.id}" },
        output_suffixes: %w[-summary.json -summary.html -summary.md -summaryAndSource.csv],
        default_input_path: ->(job) { "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv" },
        input_suffixes: []
      },
      "sensemaking-report-ui" => {
        output_basename: ->(job) { "report-#{job.id}.html" },
        output_suffixes: [],
        default_input_path: ->(_job) { "#{Sensemaker::Paths.sensemaker_data_folder}/advanced-output" },
        input_suffixes: %w[-topic-stats.json -summary.json -comments-with-scores.json -metadata.json]
      }
    }.freeze

    DEFAULT_OUTPUT_BASENAME = ->(job) { "output-#{job.id}.csv" }
    DEFAULT_INPUT_PATH = ->(job) { "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv" }

    def initialize(job)
      @job = job
    end

    def output_file_name
      config[:output_basename].call(job)
    end

    def multiple_outputs?
      config[:output_suffixes].any?
    end

    def default_output_path
      File.join(Sensemaker::Paths.sensemaker_data_folder, output_file_name)
    end

    def relative_output_path
      File.join(Sensemaker::Paths.sensemaker_relative_data_folder, output_file_name)
    end

    def persisted_output_path
      path = job.read_attribute(:persisted_output)
      return nil if path.blank?

      Rails.root.join(path)
    end

    def output_artefact_paths
      base_path = if job.persisted_output.present?
                    persisted_output_path.to_s
                  else
                    default_output_path
                  end

      suffixes = config[:output_suffixes]
      suffixes.empty? ? [base_path] : suffixes.map { |suffix| "#{base_path}#{suffix}" }
    end

    def existing_output_artefact_paths
      output_artefact_paths.select { |path| File.exist?(path) }
    end

    def input_path
      stored = job.read_attribute(:input_file)
      return stored if stored.present?

      default = config[:default_input_path]
      default&.call(job)
    end

    def input_artefact_paths
      base_path = input_path.to_s
      return [] if base_path.blank?

      input_suffixes = config[:input_suffixes]
      input_suffixes.empty? ? [base_path] : input_suffixes.map { |suffix| "#{base_path}#{suffix}" }
    end

    def existing_input_artefact_paths
      input_artefact_paths.select { |path| File.exist?(path) }
    end

    def metadata_path
      path = input_path
      return nil if path.blank?

      "#{path}-metadata.json"
    end

    def complete?
      output_artefact_paths.all? { |path| File.exist?(path) }
    end

    def cleanup
      result = []
      result.concat(cleanup_input_files)
      result.concat(cleanup_output_files)
      result.concat(cleanup_persisted_output)
      result.flatten!
      result.compact!
      result
    rescue StandardError
      nil
    end

    private

      def config
        SCRIPT_CONFIG.fetch(job.script) do
          {
            output_basename: DEFAULT_OUTPUT_BASENAME,
            output_suffixes: [],
            default_input_path: DEFAULT_INPUT_PATH,
            input_suffixes: []
          }
        end
      end

      def cleanup_input_files
        result = input_artefact_paths.map { |path| FileUtils.rm_f(path) }

        default_csv = config[:default_input_path]&.call(job)
        if default_csv.present?
          result << FileUtils.rm_f(default_csv)
          result << FileUtils.rm_f("#{default_csv}.unfiltered")
        end

        result
      end

      def cleanup_output_files
        output_artefact_paths.map { |path| FileUtils.rm_f(path) }
      end

      def cleanup_persisted_output
        path = persisted_output_path
        return [] unless path.present? && File.exist?(path)

        [FileUtils.rm_f(path)]
      end
  end
end
