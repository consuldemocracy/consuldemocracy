module Sensemaker
  class Job < ApplicationRecord
    self.table_name = "sensemaker_jobs"

    ANALYSABLE_TYPES = [
      "Debate",
      "Proposal",
      "Poll",
      "Poll::Question",
      "Topic",
      "Legislation::Question",
      "Legislation::Proposal",
      "Legislation::QuestionOption",
      "Budget",
      "Budget::Group"
    ].freeze

    PUBLISHABLE_SCRIPTS = [
      "single-html-build.js",
      "runner.ts"
    ].freeze

    validates :analysable_type, inclusion: { in: ANALYSABLE_TYPES }

    belongs_to :user, optional: false
    belongs_to :parent_job, class_name: "Sensemaker::Job", optional: true
    has_many :children, class_name: "Sensemaker::Job", foreign_key: :parent_job_id, inverse_of: :parent_job,
                        dependent: :nullify

    validates :analysable_type, presence: true
    validates :analysable_id, presence: true, unless: -> { analysable_type == "Proposal" }
    validate :publishing_is_allowed

    belongs_to :analysable, polymorphic: true, optional: true

    before_save :set_persisted_output_if_successful
    after_destroy :cleanup_associated_files

    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }

    def started?
      started_at.present?
    end

    def finished?
      finished_at.present?
    end

    def errored?
      error.present?
    end

    def cancelled?
      finished_at.present? && error.eql?("Cancelled")
    end

    def running?
      started? && !finished?
    end

    def status
      if cancelled?
        "Cancelled"
      elsif errored?
        "Failed"
      elsif finished?
        "Completed"
      elsif started?
        "Running"
      else
        "Unstarted"
      end
    end

    def self.unstarted
      where(started_at: nil).where(finished_at: nil)
    end

    def self.running
      where.not(started_at: nil).where(finished_at: nil)
    end

    def self.successful
      where(error: nil).where.not(finished_at: nil)
    end

    def self.failed
      where.not(error: nil).where.not(finished_at: nil)
    end

    def cancel!
      update!(finished_at: Time.current, error: "Cancelled")
    end

    def conversation
      @conversation ||= Sensemaker::Conversation.new(analysable_type, analysable_id)
    end

    def output_file_name
      case script
      when "health_check_runner.ts"
        "health-check-#{id}.txt"
      when "advanced_runner.ts", "runner.ts"
        "output-#{id}"
      when "categorization_runner.ts"
        "categorization-output-#{id}.csv"
      when "single-html-build.js"
        "report-#{id}.html"
      else
        "output-#{id}.csv"
      end
    end

    def has_multiple_outputs?
      ["advanced_runner.ts", "runner.ts"].include?(script)
    end

    def default_output_path
      File.join(Sensemaker::Paths.sensemaker_data_folder, output_file_name)
    end

    def output_artifact_paths
      if persisted_output.present?
        base_path = persisted_output
      else
        base_path = default_output_path
      end

      case script
      when "advanced_runner.ts"
        [
          "#{base_path}-summary.json",
          "#{base_path}-topic-stats.json",
          "#{base_path}-comments-with-scores.json"
        ]
      when "runner.ts"
        [
          "#{base_path}-summary.json",
          "#{base_path}-summary.html",
          "#{base_path}-summary.md",
          "#{base_path}-summaryAndSource.csv"
        ]
      else
        [base_path]
      end
    end

    def has_outputs?
      output_artifact_paths.all? { |path| File.exist?(path) }
    end

    def publishable?
      PUBLISHABLE_SCRIPTS.include?(script) && finished? && !errored? && has_outputs?
    end

    def self.for_budget(budget)
      group_subquery = budget.groups.select(:id)
      published.where(analysable_type: "Budget", analysable_id: budget.id).or(
        published.where(analysable_type: "Budget::Group", analysable_id: group_subquery)
      )
    end

    def self.for_process(process)
      proposals_subquery = process.proposals.select(:id)
      questions_subquery = process.questions.select(:id)
      question_options_subquery = Legislation::QuestionOption
                                  .where(legislation_question_id: questions_subquery)
                                  .select(:id)

      published
        .where(analysable_type: "Legislation::Proposal", analysable_id: proposals_subquery)
        .or(published.where(analysable_type: "Legislation::Question", analysable_id: questions_subquery))
        .or(published.where(analysable_type: "Legislation::QuestionOption",
                            analysable_id: question_options_subquery))
    end

    private

      def publishing_is_allowed
        return unless published? && published_changed? && !published_was

        unless publishable?
          errors.add(:published, :not_publishable, message: "cannot be published")
        end
      end

      def set_persisted_output_if_successful
        return unless finished_at.present? && error.nil?
        return if persisted_output.present?

        if has_outputs?
          self.persisted_output = default_output_path
        end
      end

      def cleanup_associated_files
        data_folder = Sensemaker::Paths.sensemaker_data_folder
        result = []
        result << cleanup_input_files(data_folder)
        result << cleanup_output_files(data_folder)
        result << cleanup_persisted_output()
        result.flatten!
        result.compact!
        Rails.logger.info("Cleaned up files for job #{id}: #{result.inspect}")
        result
      rescue => e
        Rails.logger.warn("Failed to cleanup files for job #{id}: #{e.message}")
        nil
      end

      def cleanup_input_files(data_folder)
        input_file = "#{data_folder}/input-#{id}.csv"
        result = []
        result << FileUtils.rm_f(input_file)
        result << FileUtils.rm_f("#{input_file}.unfiltered")
        result
      end

      def cleanup_output_files(data_folder)
        result = []
        case script
        when "advanced_runner.ts"
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-summary.json")
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-topic-stats.json")
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-comments-with-scores.json")
        when "runner.ts"
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-summary.json")
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-summary.html")
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-summary.md")
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}-summaryAndSource.csv")
        else
          result << FileUtils.rm_f("#{data_folder}/#{output_file_name}")
        end
        result
      end

      def cleanup_persisted_output
        return unless persisted_output.present? && File.exist?(persisted_output)

        [FileUtils.rm_f(persisted_output)]
      end
  end
end
