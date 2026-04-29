module Sensemaker
  class Job < ApplicationRecord
    self.table_name = "sensemaker_jobs"

    ANALYSABLE_TYPES = [
      "Debate",
      "Proposal",
      "Poll",
      "Poll::Question",
      "Legislation::Question",
      "Legislation::Proposal",
      "Legislation::QuestionOption",
      "Budget",
      "Budget::Group"
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

    def artefacts
      @artefacts ||= Sensemaker::JobArtefacts.new(self)
    end

    def conversation
      @conversation ||= Sensemaker::Conversation.new(analysable_type, analysable_id)
    end

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

    def publishable?
      Sensemaker::ScriptRegistry.publishable.include?(script) && finished? && !errored? && artefacts.complete?
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

    def record_error!(message)
      update!(finished_at: Time.current, error: message)
      Rails.logger.error(message)
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

        if artefacts.complete?
          self.persisted_output = artefacts.relative_output_path
        end
      end

      def cleanup_associated_files
        result = artefacts.cleanup
        if result.nil?
          Rails.logger.warn("Failed to cleanup files for job #{id}")
        else
          Rails.logger.info("Cleaned up files for job #{id}: #{result.inspect}")
        end
        result
      end
  end
end
