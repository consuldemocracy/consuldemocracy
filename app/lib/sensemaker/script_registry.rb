# frozen_string_literal: true

module Sensemaker
  module ScriptRegistry
    REPORT_UI = "sensemaking-report-ui"
    HEALTH_CHECK = "health_check_runner.ts"
    CATEGORIZE = "categorization_runner.ts"
    ADVANCED = "advanced_runner.ts"
    SUMMARY = "runner.ts"

    REGISTRY = {
      HEALTH_CHECK => {
        backend: :node,
        logical_name: :health_check,
        publishable: false,
        internal: false,
        requires_input: false,
        prep_steps: [],
        i18n_key: "health_check_runner_ts",
        output_flag: :output_file,
        artefact_config: {
          output_basename: ->(_job) { "health-check.txt" },
          output_suffixes: [],
          default_input_path: nil,
          input_suffixes: []
        }
      },
      CATEGORIZE => {
        backend: :node,
        logical_name: :categorize,
        publishable: false,
        internal: false,
        requires_input: true,
        prep_steps: [],
        i18n_key: "categorization_runner_ts",
        output_flag: :output_file,
        artefact_config: {
          output_basename: ->(_job) { "categorization-output.csv" },
          output_suffixes: [],
          default_input_path: ->(job) {
            File.join(Sensemaker::Paths.job_directory(job), "input.csv")
          },
          input_suffixes: []
        }
      },
      ADVANCED => {
        backend: :node,
        logical_name: :advanced,
        publishable: false,
        internal: true,
        requires_input: true,
        prep_steps: [CATEGORIZE],
        i18n_key: "advanced_runner_ts",
        output_flag: :output_basename,
        artefact_config: {
          output_basename: ->(_job) { "output" },
          output_suffixes: %w[-summary.json -topic-stats.json -comments-with-scores.json],
          default_input_path: ->(job) {
            File.join(Sensemaker::Paths.job_directory(job), "categorization-output.csv")
          },
          input_suffixes: []
        }
      },
      SUMMARY => {
        backend: :node,
        logical_name: :summary,
        publishable: true,
        internal: false,
        requires_input: true,
        prep_steps: [],
        i18n_key: "runner_ts",
        output_flag: :output_basename,
        artefact_config: {
          output_basename: ->(_job) { "output" },
          output_suffixes: %w[-summary.json -summary.html -summary.md -summaryAndSource.csv],
          default_input_path: ->(job) {
            File.join(Sensemaker::Paths.job_directory(job), "input.csv")
          },
          input_suffixes: []
        }
      },
      REPORT_UI => {
        backend: :node,
        logical_name: :report,
        publishable: true,
        internal: false,
        requires_input: true,
        prep_steps: [ADVANCED],
        i18n_key: "sensemaking_report_ui",
        output_flag: :output_file,
        artefact_config: {
          output_basename: ->(_job) { "report.html" },
          output_suffixes: [],
          default_input_path: ->(job) {
            File.join(Sensemaker::Paths.job_directory(job), "advanced-output")
          },
          input_suffixes: %w[-topic-stats.json -summary.json -comments-with-scores.json -metadata.json]
        }
      }
    }.freeze

    def self.all
      REGISTRY.keys
    end

    def self.known?(script)
      REGISTRY.key?(script)
    end

    def self.for_backend(backend)
      REGISTRY.select { |_id, config| config[:backend] == backend.to_sym }.keys
    end

    def self.user_selectable
      REGISTRY.reject { |_id, config| config[:internal] }.keys
    end

    def self.publishable
      REGISTRY.select { |_id, config| config[:publishable] }.keys
    end

    def self.backend_for(script)
      config_for(script)&.fetch(:backend)
    end

    def self.logical_name(script)
      config_for(script)&.fetch(:logical_name)
    end

    def self.prep_steps(script)
      config_for(script)&.fetch(:prep_steps) || []
    end

    def self.i18n_key(script)
      config_for(script)&.fetch(:i18n_key)
    end

    def self.artefact_config(script)
      config_for(script)&.fetch(:artefact_config)
    end

    def self.scripts_for_logical_name(name)
      REGISTRY.select { |_id, config| config[:logical_name] == name.to_sym }.keys
    end

    def self.output_flag(script)
      config_for(script)&.fetch(:output_flag, :output_file)
    end

    def self.requires_input?(script)
      config_for(script)&.fetch(:requires_input, true)
    end

    def self.config_for(script)
      REGISTRY[script]
    end
    private_class_method :config_for
  end
end
