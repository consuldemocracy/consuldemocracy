module Sensemaker
  class Job < ApplicationRecord
    self.table_name = "sensemaker_jobs"

    TARGET_TYPES = [
      "Debate",
      "Proposal",
      "Poll",
      "Topic",
      "Legislation::Question",
      "Legislation::Proposal"
    ].freeze

    validates :commentable_type, inclusion: { in: TARGET_TYPES }

    belongs_to :user, optional: false
    belongs_to :parent_job, class_name: "Sensemaker::Job", optional: true
    has_many :children, class_name: "Sensemaker::Job", foreign_key: :parent_job_id, inverse_of: :parent_job,
                        dependent: :nullify

    validates :commentable_type, presence: true
    validates :commentable_id, presence: true

    belongs_to :commentable, polymorphic: true

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

    def has_output?
      persisted_output.present? && File.exist?(persisted_output)
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

    private

      def cleanup_associated_files
        data_folder = Sensemaker::JobRunner.sensemaker_data_folder
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
        when "health_check_runner.ts"
          result << FileUtils.rm_f("#{data_folder}/health-check-#{id}.txt")
        when "advanced_runner.ts"
          result << FileUtils.rm_f("#{data_folder}/output-#{id}-summary.json")
          result << FileUtils.rm_f("#{data_folder}/output-#{id}-topic-stats.json")
          result << FileUtils.rm_f("#{data_folder}/output-#{id}-comments-with-scores.json")
        when "categorization_runner.ts"
          result << FileUtils.rm_f("#{data_folder}/categorization-output-#{id}.csv")
        when "single-html-build.js"
          result << FileUtils.rm_f("#{data_folder}/report-#{id}.html")
        else
          result << FileUtils.rm_f("#{data_folder}/output-#{id}.csv")
        end
        result
      end

      def cleanup_persisted_output
        return unless persisted_output.present? && File.exist?(persisted_output)

        [FileUtils.rm_f(persisted_output)]
      end
  end
end
