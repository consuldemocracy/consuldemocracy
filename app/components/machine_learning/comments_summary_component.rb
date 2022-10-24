class MachineLearning::CommentsSummaryComponent < ApplicationComponent
  attr_reader :commentable

  def initialize(commentable)
    @commentable = commentable
  end

  def render?
    MachineLearning.enabled? && Setting["machine_learning.comments_summary"].present? && body.present?
  end

  private

    def body
      commentable.summary_comment&.body
    end
end
