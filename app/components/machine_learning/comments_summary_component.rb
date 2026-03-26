class MachineLearning::CommentsSummaryComponent < ApplicationComponent
  attr_reader :commentable

  def initialize(commentable)
    @commentable = commentable
  end

  def render?
    MachineLearning.enabled? &&
      Setting["machine_learning.comments_summary"].present? &&
      body.present?
  end

  private

    def body
      # Use the correct association name from the model
      commentable.summary_comment&.body
    end

    def sentiment
      # Use the correct association name from the model
      @sentiment ||= commentable.summary_comment&.sentiment_analysis || {}
    end

    def sentiment_present?
      return false if sentiment.blank?

      (sentiment["positive"].to_i + sentiment["negative"].to_i + sentiment["neutral"].to_i) > 0
    end
end
